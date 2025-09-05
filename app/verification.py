import os
import time
import hashlib
from typing import Optional
from fastapi import HTTPException
from .models import VerificationResponse, DocumentMetadata

API_KEY_ENV = "VERIFICATION_API_KEY"

def _get_api_key() -> str:
    v = os.getenv(API_KEY_ENV)
    if not v:
        raise HTTPException(status_code=500, detail="Verification API key missing")
    return v

ALLOWED_TYPES = {
    "application/pdf",
    "image/jpeg",
    "image/png",
}

MAX_SIZE_BYTES = 10 * 1024 * 1024  # 10 MB

def verify_document(content: bytes, filename: Optional[str], content_type: Optional[str]) -> VerificationResponse:
    if not content:
        raise HTTPException(status_code=400, detail="Empty file")
    if content_type not in ALLOWED_TYPES:
        raise HTTPException(status_code=415, detail=f"Unsupported content type: {content_type}")
    if len(content) > MAX_SIZE_BYTES:
        raise HTTPException(status_code=413, detail="File too large")

    # Simulate external verification by hashing content
    api_key = _get_api_key()
    # Fake "call" time
    time.sleep(0.05)

    sha256 = hashlib.sha256(content).hexdigest()
    # Simulate a verification rule: PDFs whose hash ends with '0' are "invalid"
    is_valid = not (content_type == "application/pdf" and sha256.endswith("0"))

    metadata = DocumentMetadata(
        filename=filename or "unknown",
        content_type=content_type or "application/octet-stream",
        size_bytes=len(content),
        sha256=sha256,
    )

    return VerificationResponse(
        valid=is_valid,
        reason=None if is_valid else "Failed heuristic verification",
        metadata=metadata,
    )