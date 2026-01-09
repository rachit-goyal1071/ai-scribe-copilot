from __future__ import annotations

import os
from pathlib import Path
from typing import Literal, Optional, cast

from openai import OpenAI


def _get_openai_api_key() -> str:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError(
            "Missing OpenAI API key. Set OPENAI_API_KEY in the environment."
        )
    return api_key


TranscriptionResponseFormat = Literal["json", "text", "srt", "verbose_json", "vtt"]


def transcribe_audio(
    file_path: str,
    *,
    model: Optional[str] = None,
    response_format: TranscriptionResponseFormat = "text",
) -> str:
    """Transcribe an audio file and return transcript text.

    Args:
        file_path: Path to audio file on disk.
        model: OpenAI transcription model name. Defaults to env OPENAI_TRANSCRIBE_MODEL
               or "gpt-4o-mini-transcribe".
        response_format: OpenAI response format. "text" returns plain text.

    Returns:
        Transcript as a string.
    """
    path = Path(file_path)
    if not path.exists() or not path.is_file():
        raise FileNotFoundError(f"Audio file not found: {path}")
    if path.stat().st_size == 0:
        raise ValueError(f"Audio file is empty: {path}")

    api_key = _get_openai_api_key()
    client = OpenAI(api_key=api_key)

    chosen_model = model or os.getenv("OPENAI_TRANSCRIBE_MODEL", "gpt-4o-mini-transcribe")

    with path.open("rb") as audio_file:
        # The OpenAI SDK uses overloads for response_format; cast keeps strict type-checkers happy.
        result = client.audio.transcriptions.create(
            model=chosen_model,
            file=audio_file,
            response_format=cast(object, response_format),
        )

    # For response_format="text" the SDK returns a string.
    if isinstance(result, str):
        return result

    # Defensive: if response_format is changed later.
    return getattr(result, "text", str(result))
