# Use a slim Python image for a small container size
FROM python:3.11-slim as builder

# Set working directory
WORKDIR /app

# Install dependencies (uv is great, but pip is standard for Dockerfiles)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- Final Stage ---
FROM python:3.11-slim

WORKDIR /app
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY app/ app/

# Command to run the Uvicorn/Gunicorn server
# We use port 8080 because that's what we defined in our K8s manifest
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]