# RAG Pipeline

## Why This Skill Exists
Retrieval-Augmented Generation (RAG) is the most common pattern for building LLM applications that use private or up-to-date data. But naive implementations — dump everything into a vector DB, retrieve top-5, stuff into prompt — produce unreliable results. This skill covers the full pipeline with production-tested patterns for each stage.

## Pipeline Overview

```
Documents → Parsing → Chunking → Embedding → Indexing
                                                  │
User Query → Embedding → Retrieval → Reranking → Context Assembly → LLM → Response
```

Each stage has tunable knobs that dramatically affect output quality. The defaults below are reasonable starting points — measure and adjust for your domain.

## Stage 1: Document Ingestion

### Parsing
Extract clean text from source documents. Garbage in, garbage out.

| Source | Tool | Watch Out For |
|--------|------|---------------|
| PDF | PyMuPDF, pdfplumber | Tables, multi-column layouts, headers/footers |
| HTML | BeautifulSoup, trafilatura | Boilerplate (nav, ads, footer) — extract main content only |
| Markdown | Direct parse | Preserve heading hierarchy for metadata |
| Code | Tree-sitter | Preserve function/class boundaries |
| Office docs | python-docx, openpyxl | Embedded images, track changes |

### Metadata Extraction
Attach metadata at parse time — you'll need it for filtering later.

```python
document = {
    "content": "...",
    "metadata": {
        "source": "docs/architecture.md",
        "title": "System Architecture",
        "doc_type": "technical",
        "last_modified": "2025-03-15",
        "section": "Backend Services",   # heading hierarchy
    }
}
```

## Stage 2: Chunking

Chunking strategy is the single biggest lever for RAG quality.

### Strategies

| Strategy | How It Works | Best For |
|----------|-------------|----------|
| Fixed-size | Split every N tokens with overlap | Simple, predictable, baseline |
| Recursive | Split by paragraphs → sentences → words | General-purpose text |
| Semantic | Split when embedding similarity drops | Long-form, topic-shifting content |
| Document-structure | Split on headings, sections, functions | Technical docs, code |

### Fixed-Size with Overlap
```python
chunk_size = 512      # tokens per chunk
chunk_overlap = 64    # tokens overlap between chunks

# Why overlap? Prevents information from being split across chunk boundaries
# A fact at the end of chunk N is also at the start of chunk N+1
```

### Recursive Splitting (Recommended Default)
```python
from langchain.text_splitter import RecursiveCharacterTextSplitter

splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    separators=["\n\n", "\n", ". ", " ", ""],  # try biggest breaks first
)
chunks = splitter.split_text(document)
```

### Document-Structure Splitting
```python
# For Markdown — split on headings, preserving hierarchy
def chunk_by_headings(markdown_text):
    sections = []
    current_section = {"heading": "", "content": ""}

    for line in markdown_text.split("\n"):
        if line.startswith("#"):
            if current_section["content"].strip():
                sections.append(current_section)
            current_section = {"heading": line, "content": ""}
        else:
            current_section["content"] += line + "\n"

    if current_section["content"].strip():
        sections.append(current_section)
    return sections
```

### Chunk Size Guidelines
| Content Type | Chunk Size | Why |
|-------------|-----------|-----|
| FAQ / Q&A | 200-300 tokens | Each Q&A is self-contained |
| Technical docs | 500-1000 tokens | Needs enough context for a concept |
| Legal / contracts | 1000-1500 tokens | Clauses reference each other |
| Code | Function/class level | Natural boundaries |

## Stage 3: Embedding

### Model Selection
| Model | Dimensions | Speed | Quality | Cost |
|-------|-----------|-------|---------|------|
| OpenAI `text-embedding-3-small` | 1536 | Fast | Good | Low |
| OpenAI `text-embedding-3-large` | 3072 | Medium | Better | Medium |
| Cohere `embed-v4.0` | 1024 | Fast | Very good | Medium |
| Open-source (e5-large, BGE) | 1024 | Self-hosted | Good | Infra cost |

**Key trade-off**: Higher dimensions = better quality = more storage + slower search. Start with a smaller model and upgrade only if retrieval quality is measurably insufficient.

### Embedding Best Practices
- **Embed query and documents the same way** — or use models with separate query/document modes (asymmetric embedding)
- **Normalize vectors** — required for cosine similarity
- **Batch embed** — don't embed one document at a time
- **Cache embeddings** — re-embedding unchanged documents is wasted compute

## Stage 4: Indexing (Vector Database)

### Options
| Database | Type | Best For |
|----------|------|----------|
| pgvector | Extension | Already using PostgreSQL, moderate scale |
| Pinecone | Managed | No infra management, large scale |
| Weaviate | Managed/Self-hosted | Hybrid search built-in |
| Milvus | Self-hosted | Full control, very large scale |
| Chroma | In-process | Prototyping, small datasets |
| Qdrant | Self-hosted/Cloud | High performance, rich filtering |

### Choosing
```
Start here:
  Already use PostgreSQL?  →  pgvector (simplest path)
  <1M vectors?             →  pgvector or Chroma
  Need managed + scale?    →  Pinecone or Weaviate
  Need full control?       →  Milvus or Qdrant
```

### Index Type
- **Flat (brute force)**: Exact results, slow at scale. Fine for <100K vectors.
- **IVF**: Partitions vectors into clusters. Fast, approximate.
- **HNSW**: Graph-based, excellent recall/speed trade-off. Default choice for most use cases.

## Stage 5: Retrieval

### Basic Retrieval
```python
results = vector_db.similarity_search(
    query_embedding,
    top_k=10,              # retrieve more than you need (reranker will filter)
    score_threshold=0.7,   # minimum similarity — filter noise
)
```

### Hybrid Search (Keyword + Semantic)
Semantic search misses exact matches (product codes, error messages, proper nouns). Combine with keyword search for best results.

```python
# Reciprocal Rank Fusion — merge two ranked lists
def hybrid_search(query, alpha=0.5):
    semantic_results = vector_search(query, top_k=20)
    keyword_results = bm25_search(query, top_k=20)

    scores = {}
    for rank, doc in enumerate(semantic_results):
        scores[doc.id] = alpha * (1 / (rank + 60))      # RRF formula
    for rank, doc in enumerate(keyword_results):
        scores[doc.id] = scores.get(doc.id, 0) + (1 - alpha) * (1 / (rank + 60))

    return sorted(scores.items(), key=lambda x: x[1], reverse=True)
```

### Metadata Filtering
Pre-filter before vector search — dramatically reduces noise.

```python
results = vector_db.similarity_search(
    query_embedding,
    top_k=10,
    filter={
        "doc_type": "technical",
        "last_modified": {"$gte": "2025-01-01"},
    },
)
```

## Stage 6: Reranking

Bi-encoder retrieval (embedding similarity) is fast but rough. Cross-encoder reranking is slower but much more precise.

```python
from sentence_transformers import CrossEncoder

reranker = CrossEncoder("cross-encoder/ms-marco-MiniLM-L-6-v2")

# Score each (query, document) pair
pairs = [(query, doc.content) for doc in retrieved_docs]
scores = reranker.predict(pairs)

# Keep top results after reranking
reranked = sorted(zip(retrieved_docs, scores), key=lambda x: x[1], reverse=True)
final_docs = [doc for doc, score in reranked[:5]]
```

**Pipeline**: Retrieve 20 with embeddings (fast) → Rerank to top 5 with cross-encoder (precise).

## Stage 7: Context Assembly

### Prompt Structure
```python
context = "\n\n---\n\n".join([
    f"Source: {doc.metadata['source']}\n{doc.content}"
    for doc in final_docs
])

prompt = f"""Answer the question based on the provided context.
If the context doesn't contain enough information, say so — don't guess.

Context:
{context}

Question: {user_query}

Answer:"""
```

### Context Window Budget
| Component | Token Budget |
|-----------|-------------|
| System prompt | 200-500 |
| Retrieved context | 2000-6000 |
| User query | 50-200 |
| Response headroom | 1000-2000 |

**Rule**: Don't stuff the maximum context. More context = more noise = worse answers. 3-5 highly relevant chunks outperform 20 mediocre ones.

## Evaluation

### Metrics
| Metric | What It Measures | Target |
|--------|-----------------|--------|
| Retrieval precision | % of retrieved docs that are relevant | >80% |
| Retrieval recall | % of relevant docs that were retrieved | >70% |
| Answer faithfulness | Does the answer match the retrieved context? | >90% |
| Answer relevance | Does the answer address the question? | >85% |

### RAGAS Framework
Automated evaluation using LLM-as-judge:
```python
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_precision

results = evaluate(
    dataset,
    metrics=[faithfulness, answer_relevancy, context_precision],
)
```

### Test Set Design
- Include questions with known answers (ground truth)
- Include questions that should return "I don't know" (out-of-scope)
- Include questions requiring information from multiple chunks
- Include questions with exact match requirements (codes, names, dates)

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Stuffing max context | Dilutes relevant information | Retrieve fewer, higher-quality chunks |
| Ignoring chunk boundaries | Splits mid-sentence, loses meaning | Use overlap or semantic chunking |
| No metadata filtering | Retrieves outdated or irrelevant docs | Filter by date, type, source |
| Single retrieval strategy | Misses exact matches or semantic matches | Use hybrid search |
| No reranking | Top-k by embedding isn't precise enough | Add cross-encoder reranking |
| Embedding once, never updating | Stale index as documents change | Incremental re-indexing pipeline |
| No evaluation | No way to measure if changes help or hurt | RAGAS or manual eval set |
| Treating all docs equally | API reference ≠ blog post ≠ changelog | Chunk and weight by document type |

## $ARGUMENTS
When invoked with arguments, treat them as a description of the RAG use case (data sources, query types, scale). Design a pipeline following these patterns: recommend chunking strategy, embedding model, vector DB, retrieval approach, and evaluation plan — tailored to the specific use case.
