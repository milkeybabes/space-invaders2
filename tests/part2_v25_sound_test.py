"""v25 audio regression: actual game sound buses are not changed by playback."""
import wave
from pathlib import Path
from part2_audio import Part2Audio
from part2_first_play import Part2FirstPlay
from part2_two_player import Part2TwoPlayer
from sound_ports import SoundEvent

class FakeSound:
    def __init__(self, filename): self.filename=filename; self.played=0
    def set_volume(self, vol): self.volume=vol
    def play(self, *args, **kwargs): self.played+=1
class FakeChannel:
    def __init__(self): self.played=0; self.stopped=0
    def play(self, *a, **k): self.played+=1
    def stop(self): self.stopped+=1
class FakeMixer:
    def __init__(self): self.channels={};self.played=[];self.stopped=0;self.ispaused=False
    def get_init(self): return True
    def set_num_channels(self, n):pass
    def get_num_channels(self):return 8
    def Sound(self, name):
        snd=FakeSound(name);self.played.append(snd);return snd
    def Channel(self, index):return self.channels.setdefault(index,FakeChannel())
    def stop(self):self.stopped+=1
    def pause(self):self.ispaused=True
    def unpause(self):self.ispaused=False
class FakePygame:
    def __init__(self):self.mixer=FakeMixer()

samples=Path(__file__).resolve().parents[1] / 'sounds'
for i in range(10):
    with wave.open(str(samples/f'{i}.wav')) as wav:
        assert wav.getnframes()>0 and wav.getsampwidth()==2

pg=FakePygame();audio=Part2Audio(pg)
assert len(audio.wav.samples)==10
one=Part2FirstPlay()
bus=one.sound.bus
original=bytes(one.rack.mem)
audio.connect(one)
assert one.sound.bus is bus
assert bytes(one.rack.mem)==original
bus.write(3, 0x02, frame=7, source='TEST_SHOT')
assert audio.wav.samples['PLAYER_SHOT'].played==1
assert audio.toggle()
bus.write(3, 0x00, frame=8)
bus.write(3, 0x02, frame=9)
assert audio.wav.samples['PLAYER_SHOT'].played==1
assert not audio.toggle()
audio.pause(True)
bus.write(3, 0x00, frame=10)
bus.write(3, 0x02, frame=11)
assert audio.wav.samples['PLAYER_SHOT'].played==1
audio.pause(False)
for i in range(2):
    bus.write(3, 0x00)
    bus.write(3, 0x02)
assert audio.wav.samples['PLAYER_SHOT'].played==3
# Part II port 3 bit 2 also drives red-screen: sound hookup may NOT
# replace, reset, or share the per-player sound-port latches.
two=Part2TwoPlayer()
first,second=two.games
before=[g.sound.bus for g in two.games]
audio.connect(two)
assert first.sound.bus is before[0] and second.sound.bus is before[1]
assert before[0] is not before[1]
first.sound.bus.write(3, 0x04)
assert first.sound.bus.values[3]&0x04
second.sound.bus.write(3, 0x20)
two.active=1
audio.switched(two)
assert first.sound.bus.values[3]&0x04
assert second.sound.bus.values[3]==0x20
audio.reset()
assert first.sound.bus.values[3]&0x04
assert second.sound.bus.values[3]==0x20
audio.close()
print('PASS: 10 WAV samples, original separate 2P port latches, mute/pause, events, game-memory isolation')
