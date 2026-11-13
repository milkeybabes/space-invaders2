-- Read-only Space Invaders Part II title trace (cold power-on).
-- Place in your MAME directory, launch with:
--   mame.exe invadpt2 -video none -autoboot_script trace_part2_title_mame.lua
-- Uses the same frame-done sampling as the original comparison scripts.
-- Record beginning at frame zero; do not F3/Shift+F3 after starting.
-- The frame counter reported by MAME may differ from a recording's AVI index.
local FIRST_FRAME, LAST_FRAME = 250, 400
local PREFIX = 'part2_title_mame_frames.csv'
local screen, space, output
local last_frame, prev, finished
local fallback_frame = -1

local function initialize()
  local machine = manager.machine
  local cpu = assert(machine.devices[':maincpu'], 'maincpu unavailable')
  space = assert(cpu.spaces['program'], 'program space unavailable')
  screen = assert(machine.screens[':screen'], 'screen unavailable')
  output = assert(io.open(PREFIX, 'w'))
  output:write('frame,vram_bits_set,bytes_changed,bits_cleared,bits_added,first_changed_address\n')
  output:flush()
  print('Part II title VRAM trace: frames ' .. FIRST_FRAME .. '-' .. LAST_FRAME)
end

local function count_bits(x)
  local n = 0
  while x ~= 0 do x = x & (x - 1); n = n + 1 end
  return n
end

local function frame_number()
  local ok, n = pcall(function() return screen:frame_number() end)
  if ok and type(n) == 'number' then return n end
  fallback_frame = fallback_frame + 1
  return fallback_frame
end

local function tick()
  if finished then return end
  if not output then initialize() end
  local frame = frame_number()
  if frame == last_frame then return end
  last_frame = frame
  if frame > LAST_FRAME then
    output:flush(); output:close(); output = nil
    finished = true
    print('Finished: ' .. PREFIX)
    return
  end
  local current = {}
  local count, changed, removed, added = 0, 0, 0, 0
  local first_addr = ''
  for a = 0x2400, 0x3fff do
    local index = a - 0x2400 + 1
    local byte = space:read_u8(a)
    current[index] = byte
    count = count + count_bits(byte)
    if prev then
      local old = prev[index]
      if old ~= byte then
        changed = changed + 1
        removed = removed + count_bits(old & (~byte & 255))
        added = added + count_bits((~old & 255) & byte)
        if first_addr == '' then first_addr = string.format('%04X', a) end
      end
    end
  end
  if frame >= FIRST_FRAME then
    output:write(string.format('%d,%d,%d,%d,%d,%s\n',
      frame, count, changed, removed, added, first_addr))
    output:flush()
  end
  prev = current
end

emu.register_frame_done(tick, 'part2_title_trace')
