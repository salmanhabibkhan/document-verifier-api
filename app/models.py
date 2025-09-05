from typing import Optional
from pydantic import BaseModel

class DocumentMetadata(BaseModel):
    filename: str
    content_type: str
    size_bytes: int
    sha256: str

class VerificationResponse(BaseModel):
    valid: bool
    reason: Optional[str] = None
    metadata: DocumentMetadata