import openai
import os

openai.api_key = os.getenv("OPENAI_API_KEY")


def transcribe_audio(file_path: str):
    """
    Uses OpenAI Whisper (gpt-4o-mini-transcribe or whisper-1)
    to transcribe WAV audio.
    """
    with open(file_path, "rb") as audio_file:
        response = openai.audio.transcriptions.create(
            model="gpt-4o-mini-transcribe",  # Fast and cheap
            file=audio_file,
            response_format="text"
        )

    return response
