# Use a slim Python image for a small container size
FROM python:3.11-slim as builder

# Set working directory
WORKDIR /app

# 1. Install uv itself
# We use the standard pip to install uv, which is often easier in a multi-stage build setup.
# Alternatively, you could download the binary, but this is the simplest path.
RUN pip install uv

# 2. Copy dependency files: pyproject.toml and uv.lock are required by uv
# We no longer need requirements.txt
COPY pyproject.toml uv.lock ./

# 3. Install dependencies using uv from the lock file
ENV UV_PROJECT_ENVIRONMENT="/usr/local/"
RUN uv sync --locked

# --- Final Stage ---
# Start from a clean, small base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy application files
COPY app/ app/

# 4. Copy the entire Python environment built by uv
# This ensures all your dependencies are available in the final, small image.
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/ /usr/local/bin/

# Command to run the Uvicorn/Gunicorn server
# Note: You can now call uvicorn directly if it was installed by uv
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]