from minio import Minio
import os
from datetime import timedelta

MINIO_ENDPOINT = os.getenv("MINIO_ENDPOINT", "142.93.213.55:9000")
PUBLIC_MINIO_ENDPOINT = os.getenv("PUBLIC_MINIO_ENDPOINT", "142.93.213.55:9000")

MINIO_ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY", "minio")
MINIO_SECRET_KEY = os.getenv("MINIO_SECRET_KEY", "minio123")
MINIO_BUCKET = os.getenv("MINIO_BUCKET", "medinote")

client = Minio(
    MINIO_ENDPOINT,
    access_key=MINIO_ACCESS_KEY,
    secret_key=MINIO_SECRET_KEY,
    secure=False
)


def _ensure_bucket_exists() -> None:
    # MinIO may not be reachable at import/startup time (especially in local dev).
    # Ensure the bucket exists only when we actually need to generate a URL.
    if not client.bucket_exists(MINIO_BUCKET):
        client.make_bucket(MINIO_BUCKET)


def get_presigned_upload(gcs_path: str):
    """
    gcs_path example: sessions/sessionId/chunk_1.wav
    """
    _ensure_bucket_exists()

    MINIO_ANDROID_URL = os.getenv("MINIO_ANDROID_URL", "142.93.213.55:9000")

    # Generate presigned URL
    signed_url = client.presigned_put_object(
        MINIO_BUCKET,
        gcs_path,
        expires=timedelta(hours=1)
    )
    public_url = f"http://{PUBLIC_MINIO_ENDPOINT}/{MINIO_BUCKET}/{gcs_path}"

    # signed_url = signed_url.replace(MINIO_ENDPOINT, MINIO_ANDROID_URL)

    return signed_url, public_url