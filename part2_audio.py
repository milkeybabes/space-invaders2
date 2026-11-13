"""Presentation-only pygame audio connection for Space Invaders Part II.

Each player retains their own sound-port bus: the gameplay renderer uses
port 3 bit 2 for the original Part II red screen, so buses MUST NOT be shared.
Only the output listener (WAV mixer) is shared by the two players.
"""
from pathlib import Path
from wav_audio import WavBackend


class Part2Audio:
    def __init__(self, pygame, *, samples_folder=None, muted=False, sound_trace=None):
        folder = Path(samples_folder) if samples_folder is not None else Path(__file__).resolve().parent / 'sounds'
        self.wav = WavBackend(pygame, folder)
        self.wav.set_muted(muted)
        self.driver = None
        self.muted = bool(muted)
        self.sound_trace = sound_trace
        self.logger = None
        self.connected = set()
        if sound_trace:
            from sound_logger import CsvSoundLogger
            self.logger = CsvSoundLogger(sound_trace)

    @staticmethod
    def active_driver(game):
        if game is None:
            return None
        if hasattr(game, 'games'):
            return game.games[game.active].sound
        return game.sound

    def connect(self, game):
        self.wav.silence()
        if hasattr(game, 'games'):
            drivers = [g.sound for g in game.games]
        else:
            drivers = [game.sound]
        for driver in drivers:
            bus = driver.bus
            if bus not in self.connected:
                bus.add_backend(self.wav)
                if self.logger is not None:
                    bus.add_backend(self.logger)
                self.connected.add(bus)
        self.driver = self.active_driver(game)

    def switched(self, game):
        new = self.active_driver(game)
        if new is not self.driver:
            # Only silence the outgoing audio. Never alter the buses: that
            # changes sound-port RAM and even the rendered screen-red state.
            self.wav.silence()
            self.driver = new

    def reset(self):
        self.wav.silence()
        self.driver = None

    def toggle(self):
        self.muted = not self.muted
        self.wav.set_muted(self.muted)
        return self.muted

    def pause(self, paused):
        self.wav.set_paused(paused)

    def close(self):
        self.reset()
        self.wav.close()
        if self.logger is not None:
            self.logger.close()
            self.logger = None
