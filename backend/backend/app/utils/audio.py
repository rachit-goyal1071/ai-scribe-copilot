from minio import Minio
import os

MINIO_ENDPOINT = os.getenv("MINIO_ENDPOINT", "minio:9000")
MINIO_ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY", "minio")
MINIO_SECRET_KEY = os.getenv("MINIO_SECRET_KEY", "minio123")
MINIO_BUCKET = os.getenv("MINIO_BUCKET", "medinote")

client = Minio(
    MINIO_ENDPOINT,
    access_key=MINIO_ACCESS_KEY,
    secret_key=MINIO_SECRET_KEY,
    secure=False
)

def combine_chunks(session_id: str, chunks: list):
    """
    chunks: List of SessionChunk objects
    Returns: path to combined WAV file
    """
    output_path = f"/tmp/{session_id}_combined.wav"

    with open(output_path, "wb") as outfile:
        for ch in chunks:
            data = client.get_object(MINIO_BUCKET, ch.gcs_path)
            outfile.write(data.read())

    return output_path
