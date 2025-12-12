# --- Builder/Dependency Stage (Implicitly used to download uv and install dependencies) ---
# Use a specific, slim Python base image for minimal size and security.
FROM python:3.12.3-slim

# Copy the uv executable binary directly from its official GitHub Container Registry (GHCR) image.
# This makes the build incredibly fast as it avoids a 'pip install uv' step.
COPY --from=ghcr.io/astral-sh/uv:0.9.17 /uv /uvx /bin/

# Set working directory inside the container. All subsequent commands run from here.
WORKDIR /app

# Copy dependency definition files (pyproject.toml) and the locked environment file (uv.lock).
# This layer is cached well, as dependency files rarely change.
COPY pyproject.toml uv.lock ./

# Install all dependencies as specified in the uv.lock file.
# The --locked flag ensures reproducible builds.
# Dependencies are installed into the system site-packages, avoiding a separate venv folder.
RUN uv sync --locked

# Copy the actual application code into the image.
# This layer is the one that changes most often, leveraging the cache from the previous layers.
COPY app/ app/

# --- Final Execution Command ---
# Define the command that runs when the container starts.
# We use 'uv run uvicorn' to execute uvicorn using the environment established by uv sync.
# This ensures all dependencies are correctly in the PATH for uvicorn to execute,
# thereby fixing the "executable file not found" error.
CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]