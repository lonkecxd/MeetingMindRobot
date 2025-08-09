from fish_audio_sdk import Session, TTSRequest, ReferenceAudio
import os
import uuid
import requests
from config.logger import setup_logging
from datetime import datetime
from core.providers.tts.base import TTSProviderBase

TAG = __name__
logger = setup_logging()

class TTSProvider(TTSProviderBase):
    def __init__(self, config, delete_audio_file):
        super().__init__(config, delete_audio_file)
        self.api_key = config.get("api_key")
        if config.get("private_voice"):
            self.voice = config.get("private_voice")
        else:
            self.voice = config.get("voice")
        self.format = config.get("format", "mp3")
        self.output_file = config.get("output_dir", "tmp/")

    def generate_filename(self):
        return os.path.join(self.output_file, f"tts-{datetime.now().date()}@{uuid.uuid4().hex}.{self.format}")

    async def text_to_speak(self, text, output_file):
        # print("###### FISH AUDIO TTS ###")
        # print(f"Text: {text}")
        session = Session(self.api_key)
        # print(f"Session: {session}")
        # print(f"API Key: {self.api_key}")
        # print(f"Voice: {self.voice}")
        # Option 1: Using a reference_id
        with open(output_file, "wb") as f:
            # print(f"Output file: {output_file}")
            # print(f"format: {self.format}")
            for chunk in session.tts(TTSRequest(
                reference_id=self.voice,
                text=text,
                format=self.format
            )):
                f.write(chunk)
                # print(f"Writing chunk to file: {output_file}")
        # print(f"File written: {output_file}")
