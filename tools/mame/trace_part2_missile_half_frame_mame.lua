-- Space Invaders Part II (invadpt2), MAME 0.282: interrupt-phase/missile-order trace.
-- Replay the SAME part2_2player.inp as previous comparisons.
-- The ROM writes $2072=00 at the scanline-96 ISR and $2072=80 at the
-- vblank ISR. Those writes are ENTRY markers, NOT completed-ISR snapshots.
-- Memory write taps show the actual order of rack / missile / hit updates.
-- No CPU data, inputs, or timing are modified.
-- Output: part2_mame_missile_half_frame.csv

local OUTPUT = 'part2_mame_missile_half_frame.csv'
local FIRST, LAST = 1800, 1900  -- inclusive MAME screen frame numbers
local machine, cpu, space, screen, output
local taps = {} -- keep tap references alive
local last_frame, phase, serial = -1, 'unknown', 0
local observed = { 0x2072, 0x2008, 0x200A, 0x200B, 0x200D,
                   0x2032, 0x2035, 0x2036, 0x203D, 0x203E,
                   0x2080, 0x2015, 0x2069, 0x206A }
local watched = {}
for _, a in ipairs(observed) do watched[a] = true end
local function hx(n) return string.format('%02X', n & 0xff) end
local function state(override_address, override_value)
  local v = {}
  for _, a in ipairs(observed) do
    v[#v+1] = hx(a == override_address and override_value or space:read_u8(a))
  end
  return table.concat(v, ',')
end
local function frame_now()
  return screen:frame_number()
end
local function log(kind, addr, old, value)
  local f = frame_now()
  if f < FIRST or f > LAST then return end
  serial = serial + 1
  output:write(string.format('%d,%d,%s,%s,%s,%s,%s,%s\n',
    f, serial, phase, kind, addr and string.format('%04X', addr) or '',
    old == nil and '' or hx(old), value == nil and '' or hx(value),
    state(addr, value)))
end

local function on_write(addr, value, _mask)
  if not watched[addr] then return end
  local old = space:read_u8(addr)  -- write taps run before the write is committed
  if addr == 0x2072 then
    phase = (value == 0x00) and 'SCANLINE96' or
            (value == 0x80) and 'VBLANK' or ('2072_' .. hx(value))
    -- Include every interrupt entry, even if the value did not change.
    log('ISR_ENTRY', addr, old, value)
  elseif old ~= value then
    log('WRITE', addr, old, value)
  end
  -- Return unchanged value: pass-through tap must not alter the machine.
  return value
end

local started = false
local function setup()
  if started then return end
  machine = manager.machine
  cpu = assert(machine.devices[':maincpu'], 'maincpu not available')
  space = assert(cpu.spaces['program'], 'maincpu program space missing')
  screen = assert(machine.screens[':screen'], 'screen missing')
  output = assert(io.open(OUTPUT, 'w'))
  local headers = {}
  for _, a in ipairs(observed) do headers[#headers+1] = string.format('m_%04X', a) end
  output:write('frame,sequence,phase,event,address,old,new,' .. table.concat(headers, ',') .. '\n')
  -- An individual tap per address avoids reading/writing unrelated VRAM.
  for _, a in ipairs(observed) do
    taps[#taps+1] = space:install_write_tap(a, a, 'part2_trace_' .. string.format('%04X', a), on_write)
  end
  started = true
  print('Part II missile phase logger active; frames ' .. FIRST .. '-' .. LAST)
end

local finished = false
emu.register_frame_done(function()
  if finished then return end
  if not started then setup() end
  local f = frame_now()
  if f ~= last_frame then
    last_frame = f
    if f >= FIRST and f <= LAST then
      log('FRAME_DONE', nil, nil, nil)
    end
    if f % 100 == 0 and f >= FIRST and f <= LAST then output:flush() end
    if f > LAST then
      output:flush(); output:close(); output = nil
      for _, t in ipairs(taps) do t:remove() end
      finished = true
      print('Saved ' .. OUTPUT)
    end
  end
end, 'part2_missile_interrupt_trace')
