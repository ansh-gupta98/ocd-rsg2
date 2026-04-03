# OCD RAG - Memory-Optimized Configuration for 4GB RAM

## Option 1: TinyLlama (Recommended for 4GB Plan)
```bash
# Set these in Railway Variables:
HF_LLM_REPO_ID=TinyLlama/TinyLlama-1.1B-Chat-v1.0
HF_EMBED_MODEL=all-MiniLM-L6-v2
```

**Memory Usage**: ~2-3 GB
**Speed**: Fast (responses in 500ms-1s)
**Quality**: Good for mental health support (templated answers work well)

---

## Option 2: Phi-2 (If you need more capability)
```bash
HF_LLM_REPO_ID=microsoft/phi-2
HF_EMBED_MODEL=all-MiniLM-L6-v2
```

**Memory Usage**: ~3-4 GB
**Speed**: 1-3s per response
**Quality**: Better than TinyLlama

---

## Option 3: Quantized Llama-3.1 (Most capable under 4GB)
```bash
HF_LLM_REPO_ID=TheBloke/Llama-2-7B-Chat-GGUF
HF_EMBED_MODEL=all-MiniLM-L6-v2
```

**Memory Usage**: ~4-5 GB (tight fit)
**Speed**: 2-5s per response
**Quality**: Much better than TinyLlama
**Caveat**: May occasionally OOM (out of memory)

---

## Option 4: Use HuggingFace Inference API (Recommended!)

**Simplest**: Don't run model locally, use API calls instead

```python
# Remove all local model loading
# Use HuggingFace Inference API instead
# Memory needed: ~500MB - 1GB
# Cost: ~$0.01 per 1000 tokens (pay-as-you-go)
```

**Pros**:
- ✅ Works on 512MB free tier
- ✅ No memory issues
- ✅ Automatic model updates
- ✅ Support for any model

**Cons**:
- Cost: ~$5/month for light usage
- Latency: 1-3s per request (API call overhead)

---

## Quick Comparison

| Model | Memory | Speed | Quality | Cost |
|-------|--------|-------|---------|------|
| **Current (Llama-3.1-8B)** | 12-25 GB | 2-5s | Excellent | Free |
| **TinyLlama** | 2-3 GB | 500ms-1s | Good | Free |
| **Phi-2** | 3-4 GB | 1-3s | Very Good | Free |
| **Llama-2-7B-GGUF** | 4-5 GB | 2-5s | Excellent | Free |
| **HF Inference API** | 1 GB | 1-3s | Excellent | ~$5/mo |

---

## My Recommendation for 4GB Railway

**Best**: Use **TinyLlama** + keep everything else
- Works reliably on 4GB
- Fast responses
- Free (no additional cost)
- Good enough for mental health chatbot

**If you need better quality**: Use **HF Inference API**
- Same memory as TinyLlama
- Much better responses
- Small monthly cost (~$5)
- No deployment headaches
