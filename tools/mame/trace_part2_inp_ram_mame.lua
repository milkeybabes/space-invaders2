-- Read-only MAME 0.282 RAM trace for the supplied invadpt2 INP.
-- Run in MAME working folder:
-- mame.exe invadpt2 -playback part2_2player.inp -video none -sound none -nothrottle -autoboot_script trace_part2_inp_ram_mame.lua
-- Captures every frame's $2000-$22FF, including shared shot state and both player banks.
-- frame is the MAME screen counter, NOT guaranteed identical to Python's zero-based INP frame.
local OUT = 'part2_mame_inp_ram.csv'
local FIRST, LAST = 0, 7299
local screen, space, out
local previous, fallback, finished = nil, -1, false
local function csv_frame()
  local ok, n = pcall(function() return screen:frame_number() end)
  if ok and type(n) == 'number' then return n end
  fallback = fallback + 1
  return fallback
end
local function tick()
  if finished then return end
  if not out then
    local machine = manager.machine
    local cpu = assert(machine.devices[':maincpu'], 'invadpt2 maincpu not found')
    space = assert(cpu.spaces['program'], 'program space unavailable')
    screen = assert(machine.screens[':screen'], 'screen not found')
    out = assert(io.open(OUT, 'w'))
    out:write('frame,ram_2000_22ff\n')
  end
  local frame = csv_frame()
  if frame == previous then return end
  previous = frame
  if frame > LAST then
    out:flush(); out:close(); out = nil; finished = true
    print('Finished ' .. OUT)
    return
  end
  if frame < FIRST then return end
  local bytes = {}
  for a = 0x2000, 0x22ff do
    bytes[#bytes + 1] = string.format('%02X', space:read_u8(a))
  end
  out:write(frame .. ',' .. table.concat(bytes) .. '\n')
  if frame % 500 == 0 then out:flush(); print('Part II RAM frame ' .. frame) end
end
emu.register_frame_done(tick, 'part2_inp_ram_capture')
