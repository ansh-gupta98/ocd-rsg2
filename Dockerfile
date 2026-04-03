# Use Python 3.11 slim — good balance of size and compatibility
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies needed by ML packages and PyTorch
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies first (layer caching)
# Install PyTorch CPU from PyTorch index to avoid build issues on Railway
COPY requirements.txt .
RUN pip install --no-cache-dir \
    --index-url https://download.pytorch.org/whl/cpu \
    torch==2.4.0 && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of your app
COPY . .

# Railway injects $PORT at runtime — default to 8000 locally
ENV PORT=8000

# Create directories for knowledge base and vector store
RUN mkdir -p ocd_documentation ocd_documentation_vector

# Healthcheck for Railway orchestration (checks every 30s)
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:$PORT/health', timeout=5)"

# Start the FastAPI app with uvicorn
# Workers=1 for Railway's ephemeral nature; increase if you get timeout on startup
CMD uvicorn main:app --host 0.0.0.0 --port $PORT --workers 1
