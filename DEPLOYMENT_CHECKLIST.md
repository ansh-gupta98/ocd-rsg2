# Pre-Deployment Checklist for Railway

## ✅ Code & Files (All done)
- [x] Fixed `requirements.txt` (removed invalid `--index-url` flag)
- [x] Created `.env.example` with all required & optional vars
- [x] Added `.dockerignore` to reduce image size
- [x] Updated `Dockerfile` with torch index URL handling
- [x] Added startup logging to `main.py` for visibility
- [x] Added health check endpoint in Dockerfile

## 📋 Railway Setup Checklist (Do these)

### Before First Deploy
- [ ] Create Railway account at https://railway.app
- [ ] Connect GitHub repo to Railway
- [ ] Pick Dockerfile deployment method

### Environment Variables
- [ ] **CRITICAL**: Set `HUGGINGFACEHUB_API_TOKEN` 
  - Get from: https://huggingface.co/settings/tokens
  - Paste into Railway → Variables
- [ ] (Optional) Set `HF_LLM_REPO_ID` if using different model
- [ ] (Optional) Set `HF_EMBED_MODEL` if using different embeddings

### Configuration
- [ ] Ensure `ocd_documentation/` is committed to git
- [ ] Verify `railway.toml` exists with restart policy
- [ ] Check `.gitignore` doesn't exclude needed files

### Deployment
- [ ] Run `railway up` OR push to GitHub
- [ ] Monitor logs: `railway logs`
- [ ] Check for ✅ "OCDRAGService initialized successfully"
- [ ] Test `/health` endpoint
- [ ] Test `/session/start` endpoint

---

## 🧪 Post-Deployment Validation

### 1. Startup Performance
```bash
# Expected logs (watch for timings):
# 🚀 Starting OCDRAGService initialization...
# 📦 Initializing HuggingFace clients...
#   → Loading LLM: meta-llama/Llama-3.1-8B-Instruct ...
#   ✓ LLM loaded
#   → Loading embeddings: sentence-transformers/all-MiniLM-L6-v2 ...
#   ✓ Embeddings loaded
# ✅ HuggingFace clients ready in X.XXs
# 📚 Loading knowledge base from: /app/ocd_documentation ...
# ✅ Knowledge base ready (XXX chunks)
# 🚀 Starting OCDRAGService initialization complete
```

**Target times:**
- Clients ready: < 60s
- Knowledge base ready: < 60s
- **Total startup: < 120s** ✅ (Railway timeout)

### 2. API Validation
```bash
BASE_URL="https://your-app.up.railway.app"

# Health check
curl $BASE_URL/health

# Create session
SESSION=$(curl -s -X POST $BASE_URL/session/start | jq -r .session_id)

# Test chat
curl -X POST $BASE_URL/chat \
  -H "Content-Type: application/json" \
  -d "{
    \"session_id\": \"$SESSION\",
    \"message\": \"I have intrusive thoughts about harm\",
    \"kotlin_severity\": \"MILD\"
  }"
```

### 3. Resource Monitoring
- Check Railway Dashboard → Metrics
- **Memory usage should stabilize at 1-2GB** (not continuously growing)
- **CPU usage should be low** (high only during requests)
- If memory grows indefinitely → memory leak (report to dev)

---

## ⚠️ Common Issues & Fixes

### Startup Timeout (120s exceeded)
**Symptom**: App crashed immediately, no logs in `/health`

**Cause**: First deploy downloading 3GB+ models

**Fix**:
1. Try again - sometimes just slow first time
2. Upgrade to Railway Pro (4GB RAM)
3. Use smaller model:
   ```
   HF_LLM_REPO_ID=TinyLlama/TinyLlama-1.1B-Chat-v1.0
   ```

### "No HuggingFace token" Error
**Symptom**: Logs show "RuntimeError: No HuggingFace token found"

**Fix**: 
1. Create token at https://huggingface.co/settings/tokens
2. Add to Railway Variables: `HUGGINGFACEHUB_API_TOKEN`
3. Redeploy

### "No documentation files found"
**Symptom**: ValueError about ocd_documentation/

**Fix**:
1. Ensure `ocd_documentation/` folder has .txt/.pdf/.md files
2. Commit to git: `git add ocd_documentation/`
3. Push and Railway will auto-redeploy

### Very Slow Responses (>5s for inference)
**Symptom**: `/chat` responses take 5-10+ seconds

**Cause**: 
- Railway starter plan has shared/slow CPU
- First request loads model into memory (cold start)

**Fix**:
- Upgrade to Railway Pro or higher
- Or use faster model (TinyLlama)

---

## 🚀 Next Steps (Enhancements)

**After successful deployment to Railway:**

1. **Add PostgreSQL** for session persistence
   - Railway → Create PostgreSQL service
   - Modify `main.py` to save sessions to DB
   - See: `PERSISTENCE.md` (to be created)

2. **Add Caching**
   - Cache LLM responses for common queries
   - Reduce latency and HuggingFace API calls

3. **Performance Monitoring**
   - Add Sentry for error tracking
   - Track API response times and errors

4. **Rate Limiting**
   - Prevent abuse
   - Protect HuggingFace quota

---

## 📞 Quick Reference

| Command | Purpose |
|---------|---------|
| `railway login` | Authenticate Railway CLI |
| `railway init` | Create new Railway project |
| `railway up` | Deploy from current directory |
| `railway logs` | Stream live logs |
| `railway logs -f 100` | Last 100 lines |
| `railway down` | Stop service |
| `railway remove` | Delete project |

---

**Status**: 🟢 Ready for Railway deployment (after setting env vars)
