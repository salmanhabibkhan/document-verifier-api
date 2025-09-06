import os
import logging
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from .verification import verify_document
from .models import VerificationResponse

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s %(levelname)s %(name)s %(message)s"
)
logger = logging.getLogger("document-verifier")

app = FastAPI(
    title="PayNest Document Verifier",
    version="1.0.0",
    description="Verifies user documents uploaded from the frontend."
)

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/verify", response_model=VerificationResponse)
async def verify(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        result = verify_document(contents, filename=file.filename, content_type=file.content_type)
        return JSONResponse(content=result.model_dump())
    except HTTPException as he:
        logger.exception("HTTPException during verification")
        raise he
    except Exception as e:
        logger.exception("Unexpected error during verification")
        raise HTTPException(status_code=500, detail="Internal server error")