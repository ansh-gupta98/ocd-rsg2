# 🚀 Railway Deployment Guide for OCD RAG Backend

## Prerequisites

- Railway account: https://railway.app
- GitHub repo with this code
- HuggingFace API token: https://huggingface.co/settings/tokens

---

## ✅ Step-by-Step Deployment

### 1. **Create Railway Project**
```bash
# From your repo root
railway init
# Select "Dockerfile"
# Follow prompts to connect GitHub repo
```

### 2. **Set Environment Variables**

In Railway Dashboard → Variables:

**Required:**
```
HUGGINGFACEHUB_API_TOKEN = hf_xxxxxxxxxxxxx  (your HF token)
```

**Optional (adjust as needed):**
```
HF_LLM_REPO_ID = meta-llama/Llama-3.1-8B-Instruct
HF_EMBED_MODEL = sentence-transformers/all-MiniLM-L6-v2
OCD_REBUILD_VECTOR = false
```

### 3. **Configure Service Settings**

In Railway → Settings:

| Setting | Value | Reason |
|---------|-------|--------|
| **Port** | `$PORT` (auto) | FastAPI listens on Railway's port |
| **Listening Address** | `0.0.0.0` | Required for Railway networking |
| **Restart Policy** | `ON_FAILURE` (default) | From railway.toml |

### 4. **Deploy**
```bash
railway up
# Or push to GitHub and Railway auto-deploys
```

---

## ⏱️ Expected Startup Times

**First deploy:**
- `0-5s`: Dockerfile builds
- `10-30s`: Dependencies install (torch, transformers, etc.)
- `30-60s`: HuggingFace models download (~3GB for LLM + embeddings)
- `20-40s`: Knowledge base loads and FAISS index builds
- **Total: 90-180 seconds** 🟠

**Subsequent deploys:**
- `10-20s`: Dependencies install
- `20-40s`: FAISS index loads from cache
- **Total: 30-60 seconds** ✅

**Production requests:**
- `/health` health check: `<50ms`
- `/session/start` new session: `~200ms`
- `/chat` inference: `500ms-3s` (depends on LLM latency)

---

## ⚠️ Known Issues & Limitations

### 1. **Ephemeral Filesystem**
- ❌ Vector store (`ocd_documentation_vector/`) is **rebuilt on every restart**
- ✅ Safe: Rebuilt from committed `ocd_documentation/` source files
- 💡 If you add new docs, rebuild: `OCD_REBUILD_VECTOR=true` (temporary env var)

### 2. **In-Memory Session Storage**
- ❌ User sessions lost on restart (no persistence)
- ✅ Workaround: Add PostgreSQL for session persistence (see below)

### 3. **Startup Timeout (⏰ Critical)**
- Railway has a **120-second startup timeout**
- First deploy on slower hardware may exceed this
- 🔧 Fix: Set `--workers 1` in Dockerfile CMD (already done)

### 4. **Memory/CPU Constraints**
- Railway starter plan: 512MB RAM
- LLM inference can use 2-4GB temporarily
- 🔧 Solution: Upgrade to Pro plan ($20+/month) for 4GB RAM

---

## 🔧 Performance Tuning

### Reduce Startup Time
```bash
# Only if startup times are >120s:
# 1. Reduce model size (but will degrade quality):
HF_LLM_REPO_ID=TinyLlama/TinyLlama-1.1B-Chat-v1.0

# 2. Use quantized models:
HF_LLM_REPO_ID=TheBloke/Llama-2-7B-Chat-GGUF
```

### Persist Sessions (Add PostgreSQL)
```bash
# In Railway: Add PostgreSQL service
# Then modify main.py to store sessions in DB instead of memory
# (See PERSISTENCE.md for details)
```

---

## 🧪 Testing Deployment

### 1. **Check Deployment Logs**
```bash
railway logs
# Look for ✅ OCDRAGService initialized in XXXs
```

### 2. **Test Health Check**
```bash
curl https://your-railway-app.up.railway.app/health
# Should return: {"status": "ok", "timestamp": "2024-04-03T..."}
```

### 3. **Test Chat Endpoint**
```bash
# Start a session
curl -X POST https://your-railway-app.up.railway.app/session/start
# Response: {"session_id": "uuid", "created_at": "timestamp"}

# Send a message
curl -X POST https://your-railway-app.up.railway.app/chat \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "uuid-from-above",
    "message": "I am having OCD symptoms",
    "kotlin_severity": null
  }'
```

---

## 📊 Monitoring

### Railway Dashboard
- **Status**: Shows if app is running/crashed
- **Logs**: Real-time application output (look for init messages)
- **Metrics**: CPU, memory, network usage

### Health Check Integration
- Railway automatically probes `/health` endpoint every 30s
- If 3 probes fail → auto-restart (from railway.toml)

---

## 🛑 Troubleshooting

| Problem | Solution |
|---------|----------|
| **Startup timeout (after 120s)** | Logs show nothing → Docker build/install too slow → Check if downloading models → May need Pro plan for more RAM |
| **"No HuggingFace token" error** | Set `HUGGINGFACEHUB_API_TOKEN` in Railway Variables |
| **"No documentation files found"** | `ocd_documentation/` not committed to git → Commit it first |
| **Sessions disappear on restart** | Expected behavior (ephemeral storage) → Add PostgreSQL for persistence |
| **Very slow inference (>10s per request)** | LLM cold start / Railway shared CPU → Upgrade to dedicated CPU |

---

## 🔄 CI/CD Pipeline (Optional)

To auto-deploy when pushing to main:

1. Railway auto-detects GitHub pushes
2. Rebuilds Docker image
3. Redeploys service
4. Old instance → new instance swap (zero downtime)

---

## 💾 Backup & Recovery

**Your data:**
- ✅ Knowledge base (`ocd_documentation/`) → In git
- ❌ Vector store → Rebuilt on startup (ephemeral)
- ❌ Sessions → Lost on restart (no persistence)

**To preserve sessions:** Implement PostgreSQL backend (future enhancement).

---

## 📞 Support

- Railway Docs: https://docs.railway.app
- LangChain Docs: https://python.langchain.com
- HuggingFace Inference: https://huggingface.co/inference-api
