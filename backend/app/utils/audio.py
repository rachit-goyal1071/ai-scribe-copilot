import io
import wave
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
    output_path = f"/tmp/{session_id}_combined.wav"

    # Read first chunk fully to extract WAV params
    first_data = client.get_object(MINIO_BUCKET, chunks[0].gcs_path).read()
    first_wav = wave.open(io.BytesIO(first_data), 'rb')

    params = first_wav.getparams()
    sample_width = first_wav.getsampwidth()
    channels = first_wav.getnchannels()
    framerate = first_wav.getframerate()

    # Create output WAV
    with wave.open(output_path, 'wb') as out_wav:
        out_wav.setnchannels(channels)
        out_wav.setsampwidth(sample_width)
        out_wav.setframerate(framerate)

        # Write PCM from first chunk
        out_wav.writeframes(first_wav.readframes(first_wav.getnframes()))

        # Write PCM from other chunks
        for ch in chunks[1:]:
            data = client.get_object(MINIO_BUCKET, ch.gcs_path).read()
            wav = wave.open(io.BytesIO(data), 'rb')
            out_wav.writeframes(wav.readframes(wav.getnframes()))

    return output_path