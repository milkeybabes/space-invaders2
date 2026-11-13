"""WAV effects connected to original 8080 sound-port edges.

Optional sounds/0.wav ... sounds/9.wav. The supplied starter sounds are
original, approximate placeholders; replace with your existing Part I samples
for closer arcade character. Samples do not participate in gameplay timing.
"""
from pathlib import Path

SAMPLE_NAMES = {
    'UFO_FLYING':'0.wav', 'PLAYER_SHOT':'1.wav',
    'PLAYER_EXPLOSION':'2.wav', 'INVADER_EXPLOSION':'3.wav',
    'FLEET_STEP_1':'4.wav', 'FLEET_STEP_2':'5.wav',
    'FLEET_STEP_3':'6.wav', 'FLEET_STEP_4':'7.wav',
    'UFO_EXPLOSION':'8.wav', 'BONUS_SHIP':'9.wav',
}

class WavBackend:
    def __init__(self, pygame, folder='sounds'):
        self.pygame = pygame
        self.folder = Path(folder)
        self.samples = {}
        self.channels = {}
        self.available = False
        self.muted = False
        self.paused = False
        self.ufo_active = False
        if not hasattr(pygame, 'mixer'):
            return
        try:
            if pygame.mixer.get_init() is None:
                pygame.mixer.init()
            pygame.mixer.set_num_channels(max(12,pygame.mixer.get_num_channels()))
            self.available = True
        except Exception:
            return
        for name, filename in SAMPLE_NAMES.items():
            sample_path = self.folder / filename
            if sample_path.is_file():
                try:
                    sound = pygame.mixer.Sound(str(sample_path))
                    sound.set_volume(0.65 if name == 'UFO_FLYING' else 0.75)
                    self.samples[name] = sound
                except Exception as exc:
                    print(f'[SOUND] Could not load {sample_path.name}: {exc}')
        self.channels['UFO_FLYING'] = pygame.mixer.Channel(10)

    def _start_ufo(self):
        if not self.available or self.muted or self.paused or not self.ufo_active:
            return
        sound = self.samples.get('UFO_FLYING')
        if sound is not None:
            self.channels['UFO_FLYING'].play(sound,loops=-1)

    def silence(self):
        """Stop all current sounds without changing either player's port bus."""
        self.ufo_active = False
        if self.available:
            self.pygame.mixer.stop()

    def set_muted(self, muted):
        self.muted = bool(muted)
        if self.available:
            if self.muted:
                self.pygame.mixer.stop()
            else:
                self._start_ufo()

    def set_paused(self, paused):
        self.paused = bool(paused)
        if self.available:
            (self.pygame.mixer.pause if paused else self.pygame.mixer.unpause)()

    def on_event(self, event):
        if event.name == 'UFO_FLYING':
            self.ufo_active = bool(event.active)
            if self.available:
                channel = self.channels['UFO_FLYING']
                if event.active:
                    self._start_ufo()
                else:
                    channel.stop()
            return
        if not event.active or self.muted or self.paused or not self.available:
            return
        sample = self.samples.get(event.name)
        if sample is not None:
            sample.play()

    def close(self):
        if self.available:
            self.pygame.mixer.stop()
