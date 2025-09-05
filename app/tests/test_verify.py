import io
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"

def test_verify_png(monkeypatch):
    monkeypatch.setenv("VERIFICATION_API_KEY", "test-key")
    png_bytes = b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR"
    files = {"file": ("test.png", io.BytesIO(png_bytes), "image/png")}
    r = client.post("/verify", files=files)
    assert r.status_code == 200
    data = r.json()
    assert "valid" in data
    assert data["metadata"]["content_type"] == "image/png"

def test_verify_missing_key(monkeypatch):
    monkeypatch.delenv("VERIFICATION_API_KEY", raising=False)
    pdf_bytes = b"%PDF-1.4 test"
    files = {"file": ("test.pdf", io.BytesIO(pdf_bytes), "application/pdf")}
    r = client.post("/verify", files=files)
    assert r.status_code == 500