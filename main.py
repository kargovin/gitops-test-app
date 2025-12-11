# app/main.py

from fastapi import FastAPI
import os

app = FastAPI(title="GitOps Test App")

# Use an environment variable, which is good practice in K8s
# This will default to 'v1.0' if the ENV variable is not set
VERSION = os.environ.get("APP_VERSION", "v1.0")

@app.get("/", tags=["Root"])
def read_root():
    return {
        "message": f"Hello from FastAPI! Deployment Version: {VERSION}",
        "status": "OK",
        "service": "GitOps Test App"
    }

@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "UP"}