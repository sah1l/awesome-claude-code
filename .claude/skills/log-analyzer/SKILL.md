# Log Analyzer

## Why This Skill Exists
Production incidents require correlating logs across services, identifying error patterns, and tracing request flows. This skill leverages MCP servers (CloudWatch, Datadog, etc.) to investigate production issues without leaving Claude Code.

## Prerequisites
This skill works best with MCP servers configured for your observability stack. Example MCP config:

```json
{
  "mcpServers": {
    "cloudwatch": {
      "command": "npx",
      "args": ["-y", "@anthropic/cloudwatch-mcp"],
      "env": { "AWS_REGION": "us-east-1" }
    }
  }
}
```

Without MCP servers, this skill still guides structured log analysis from pasted log output.

## Investigation Workflow

### Step 1: Establish Timeline
- When did the issue start?
- When was it resolved (if applicable)?
- What deployments happened in that window?

### Step 2: Identify Error Patterns
Query for errors in the affected time range:
```
# CloudWatch Insights example
fields @timestamp, @message
| filter @message like /ERROR|Exception|FATAL/
| sort @timestamp desc
| limit 100
```

Group errors by type to find the dominant pattern:
```
fields @timestamp, @message
| filter @message like /ERROR/
| stats count(*) by errorType
| sort count desc
```

### Step 3: Trace Request Flow
Follow a single failing request across services using correlation/request ID:
```
fields @timestamp, @message, service
| filter requestId = "abc-123"
| sort @timestamp asc
```

### Step 4: Correlate with Metrics
- Check CPU/memory/disk around the error spike
- Check deployment timestamps
- Check dependency health (DB connections, external APIs)

### Step 5: Root Cause Report

Structure findings as:

```markdown
## Incident Summary
- **Impact**: What users experienced
- **Duration**: Start → resolution
- **Root Cause**: One-sentence summary

## Timeline
- HH:MM — First error observed
- HH:MM — Alert triggered
- HH:MM — Investigation started
- HH:MM — Root cause identified
- HH:MM — Fix deployed

## Root Cause Analysis
Detailed explanation of what went wrong and why.

## Action Items
- [ ] Immediate fix (already deployed)
- [ ] Preventive measure
- [ ] Monitoring improvement
```

## $ARGUMENTS
When invoked with arguments, treat them as the error/issue description and begin the investigation workflow. Use available MCP tools to query logs, or ask the user to paste relevant log output.

## MCP Integration Notes
This skill demonstrates how skills can orchestrate MCP server tools. The skill provides the *methodology*, while MCP servers provide the *data access*. This separation means the same investigation workflow works across different observability platforms — just swap the MCP server.
