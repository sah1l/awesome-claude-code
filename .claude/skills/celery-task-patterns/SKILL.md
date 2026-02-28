# Background Task Patterns

## Why This Skill Exists
Every non-trivial application eventually needs background job processing — sending emails, processing uploads, generating reports, syncing data. The patterns here (idempotency, retries, dead letters, fan-out) are universal across task queue systems. Examples use Celery (Python) but translate directly to BullMQ (Node.js), Sidekiq (Ruby), Hangfire (.NET), and others.

## Task Design Principles

### 1. Idempotency
A task must produce the same result whether it runs once or ten times. Queues guarantee *at-least-once* delivery, not *exactly-once*.

```python
# Bad — sends duplicate emails on retry
@app.task
def send_welcome_email(user_id):
    user = User.objects.get(id=user_id)
    send_email(user.email, "Welcome!")

# Good — idempotent with a check
@app.task
def send_welcome_email(user_id):
    user = User.objects.get(id=user_id)
    if user.welcome_email_sent:
        return  # Already processed
    send_email(user.email, "Welcome!")
    user.welcome_email_sent = True
    user.save()
```

**Idempotency key pattern**: For external API calls, generate a deterministic key and let the external service deduplicate:
```python
idempotency_key = f"charge-{order_id}-{amount}"
stripe.charges.create(amount=amount, idempotency_key=idempotency_key)
```

### 2. Serializable Arguments
Pass IDs, not objects. Task arguments are serialized to JSON/MessagePack and may be processed minutes or hours later.

```python
# Bad — serializes entire object, stale data
send_report.delay(user_object)

# Good — passes ID, fetches fresh data at execution time
send_report.delay(user_id=42)
```

### 3. Small Payloads
Keep task arguments small. Store large data in blob storage or the database and pass a reference.

```python
# Bad — 10MB CSV in the message broker
process_csv.delay(csv_content=huge_string)

# Good — reference to stored data
upload_key = s3.upload(csv_content)
process_csv.delay(upload_key=upload_key)
```

## Retry Patterns

### Exponential Backoff
Prevents retry storms from overwhelming downstream services.

```python
@app.task(
    bind=True,
    max_retries=5,
    default_retry_delay=60,  # base delay in seconds
)
def call_external_api(self, endpoint, payload):
    try:
        response = requests.post(endpoint, json=payload, timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as exc:
        # Exponential backoff: 60s, 120s, 240s, 480s, 960s
        raise self.retry(exc=exc, countdown=60 * (2 ** self.request.retries))
```

**BullMQ equivalent**:
```typescript
const queue = new Queue('api-calls', {
  defaultJobOptions: {
    attempts: 5,
    backoff: { type: 'exponential', delay: 60_000 },
  },
})
```

### Retry Only Transient Failures
Don't retry errors that will never succeed.

```python
@app.task(bind=True, max_retries=3)
def process_payment(self, order_id):
    try:
        charge(order_id)
    except NetworkError as exc:
        raise self.retry(exc=exc)          # Transient — retry
    except InvalidCardError:
        mark_payment_failed(order_id)       # Permanent — don't retry
    except RateLimitError as exc:
        raise self.retry(exc=exc, countdown=exc.retry_after)  # Retry with hint
```

### Dead Letter Queues
Tasks that exhaust all retries must go somewhere for investigation, not vanish silently.

```python
@app.task(bind=True, max_retries=3)
def fragile_task(self, data):
    try:
        process(data)
    except Exception as exc:
        if self.request.retries >= self.max_retries:
            # Send to dead letter queue for manual review
            dead_letter_queue.delay(
                original_task='fragile_task',
                args={'data': data},
                error=str(exc),
                retries_exhausted=self.request.retries,
            )
            return
        raise self.retry(exc=exc)
```

## Task Composition

### Chains — Sequential Pipeline
```python
from celery import chain

# Each task's return value feeds into the next
pipeline = chain(
    download_file.s(url),
    parse_csv.s(),          # receives file path from download
    validate_rows.s(),      # receives parsed rows
    import_to_db.s(),       # receives validated rows
)
pipeline.apply_async()
```

### Groups — Fan-Out (Parallel)
```python
from celery import group

# Process all images in parallel
job = group(
    resize_image.s(image_id) for image_id in image_ids
)
results = job.apply_async()
```

### Chords — Fan-Out then Aggregate
```python
from celery import chord

# Generate reports in parallel, then combine
chord(
    [generate_section.s(section) for section in sections],
    combine_report.s()  # called with list of all results
).apply_async()
```

**BullMQ equivalent** — use FlowProducer:
```typescript
await flowProducer.add({
  name: 'combine-report',
  queueName: 'reports',
  children: sections.map(section => ({
    name: 'generate-section',
    queueName: 'reports',
    data: { section },
  })),
})
```

## Monitoring & Observability

### Essential Metrics
| Metric | Why | Alert When |
|--------|-----|------------|
| Queue depth | Measures backlog | Growing for >5 min |
| Task latency (queue → start) | Workers keeping up? | >30s for critical tasks |
| Task duration | Performance regression? | P95 > 2x baseline |
| Failure rate | System health | >5% of tasks failing |
| Retry rate | Transient issue frequency | Sustained spike |
| Dead letter count | Unresolvable failures | Any increase |

### Task Status Tracking
For user-facing tasks (report generation, file processing), track status in the database — not just in the broker.

```python
@app.task(bind=True)
def generate_report(self, report_id):
    report = Report.objects.get(id=report_id)
    report.status = 'processing'
    report.task_id = self.request.id
    report.save()
    try:
        result = build_report(report)
        report.status = 'completed'
        report.result_url = result.url
    except Exception:
        report.status = 'failed'
        raise
    finally:
        report.save()
```

## Common Pitfalls

### Long-Running Tasks Blocking Workers
**Problem**: A 30-minute task blocks a worker, starving short tasks.

**Fix**: Use dedicated queues with separate worker pools.
```python
# Route by task type
app.conf.task_routes = {
    'tasks.quick_*': {'queue': 'fast'},
    'tasks.generate_report': {'queue': 'slow'},
    'tasks.send_email': {'queue': 'fast'},
}
```
```bash
# Run separate worker pools
celery -A app worker -Q fast --concurrency=8
celery -A app worker -Q slow --concurrency=2
```

### Database Connection Exhaustion
**Problem**: Each worker process opens a DB connection. 10 workers x 4 processes = 40 connections.

**Fix**: Use connection pooling (pgBouncer, PgPool) and limit worker concurrency.

### Memory Leaks in Long-Running Workers
**Problem**: Workers accumulate memory over thousands of tasks.

**Fix**: Restart workers after N tasks.
```python
app.conf.worker_max_tasks_per_child = 1000
```

### Task Visibility Timeout
**Problem**: A slow task exceeds the visibility timeout. The broker re-delivers it to another worker. Now two workers process the same task.

**Fix**: Set visibility timeout higher than your longest expected task duration. Combine with idempotency as a safety net.

## Testing Async Tasks

Run tasks synchronously in tests — don't start a real broker.

```python
# pytest fixture
@pytest.fixture(autouse=True)
def celery_eager(settings):
    settings.CELERY_TASK_ALWAYS_EAGER = True
    settings.CELERY_TASK_EAGER_PROPAGATES = True

def test_send_welcome_email(celery_eager, user):
    send_welcome_email.delay(user.id)
    user.refresh_from_db()
    assert user.welcome_email_sent is True
```

**BullMQ**: Use `sandboxedProcessors: false` and call `worker.processJob()` directly in tests.

**Sidekiq**: Use `Sidekiq::Testing.inline!` mode.

## $ARGUMENTS
When invoked with arguments, treat them as a description of the background task or workflow to implement. Design the task following these patterns: define the task with idempotency, configure retries with backoff, set up monitoring, and identify the appropriate composition pattern (chain, group, or chord).
