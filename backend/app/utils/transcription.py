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
    language: str = "en",
) -> str:
    """Transcribe an audio file and return transcript text.

    Args:
        file_path: Path to audio file on disk.
        model: OpenAI transcription model name. Defaults to env OPENAI_TRANSCRIBE_MODEL
               or "gpt-4o-mini-transcribe".
        response_format: OpenAI response format. "text" returns plain text.
        language: Force transcription language (default: "en").

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
            language=language,
            response_format=cast(object, response_format),
        )

    if isinstance(result, str):
        return result

    return getattr(result, "text", str(result))


def generate_detailed_english_summary(
    transcript_text: str,
    *,
    model: Optional[str] = None,
) -> str:
    """Generate a fully detailed English summary from transcript text.

    This step is intentionally separate from transcription because:
    - transcription may be partial
    - transcript may not be English
    - you want a structured, detailed English output
    """
    api_key = _get_openai_api_key()
    client = OpenAI(api_key=api_key)

    chosen_model = model or os.getenv("OPENAI_SUMMARY_MODEL", "gpt-4o-mini")

    prompt = (
        "You are a medical scribe. You will be given an audio transcript that may be incomplete "
        "and may contain non-English text.\n\n"
        "Requirements:\n"
        "- Always output in ENGLISH.\n"
        "- If the transcript is not English, translate it first.\n"
        "- Produce a fully detailed, structured note with headings.\n"
        "- If the transcript seems cut off or too short, explicitly say what is missing/uncertain.\n\n"
        "Return format (headings):\n"
        "1) Chief complaint\n"
        "2) HPI\n"
        "3) ROS\n"
        "4) Medications\n"
        "5) Allergies\n"
        "6) PMH/PSH\n"
        "7) Assessment\n"
        "8) Plan\n\n"
        f"Transcript:\n{transcript_text}\n"
    )

    # Use the Responses API for general text generation.
    resp = client.responses.create(
        model=chosen_model,
        input=prompt,
    )

    output_text = getattr(resp, "output_text", None)
    if isinstance(output_text, str) and output_text.strip():
        return output_text

    return str(resp)
