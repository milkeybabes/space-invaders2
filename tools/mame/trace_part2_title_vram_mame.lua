-- Cold-boot raw VRAM snapshots: exact byte comparison (not lit-pixel totals).
-- mame.exe invadpt2 -video none -autoboot_script trace_part2_title_vram_mame.lua
-- Do not reset during capture. Files are written into MAME's working directory.
local frames = {[270]=true,[273]=true,[334]=true,[337]=true,[360]=true,[364]=true}
local screen, space
local done = {}
local function frame_done()
  if not screen then
    local machine = manager.machine
    screen = assert(machine.screens[':screen'])
    space = assert(machine.devices[':maincpu'].spaces['program'])
  end
  local frame = screen:frame_number()
  if not frames[frame] or done[frame] then return end
  done[frame] = true
  local outname = string.format('part2_mame_vram_%03d.bin',frame)
  local fp = assert(io.open(outname, 'wb'))
  for a = 0x2400, 0x3FFF do fp:write(string.char(space:read_u8(a))) end
  fp:close()
  print('Saved ' .. outname .. ' (7168 bytes)')
end
emu.register_frame_done(frame_done, 'part2_title_vram_snapshots')
