-------------------------------------------------------------
-- VLC Control by Benjamin Neumann (for Renoise 3.1)       --
-------------------------------------------------------------

local client = nil
local socket_error = nil
local success = false
local connection_timeout = 2000
local message = ""
local vlc_started = false;

--------------------------------------------------------------------------------
-- helper functions
--------------------------------------------------------------------------------

local function get_time()
  local songpos = renoise.song().transport.playback_pos_beats
  local time = (songpos / renoise.song().transport.bpm) * 60
  time = math.floor((time * 100) / 100)
  print(("Current time is %s"):format(time))
  return time
end

local function connect_vlc()
  -- If the VLC is not started it does not make sense to connect
  if not vlc_started then
    return
  end
  print(connection_timeout)
  client, socket_error = renoise.Socket.create_client("localhost", 53842,  renoise.Socket.PROTOCOL_TCP, connection_timeout)

  if socket_error then
    renoise.app():show_warning("Failed to connect to VLC: " .. socket_error)
    vlc_started = false;
    return
  end

end

local function send(message)
  -- If the VLC is not started it does not make sense to send something
  if not vlc_started then
    return
  end
  print("Sending " .. message)
  if client == nil then
    renoise.app():show_warning("Not connected")
    return
  end
  success, socket_error = client:send(message .. "\n")

  if socket_error then
    renoise.app():show_warning("Failed to send message to VLC: " .. socket_error)
    client:close();
    return
  end

  local rec = true
  while (rec)
  do
    message, socket_error = client:receive("*all", 20)
    if message == nil then
      rec = false
    else
      print(message)
    end
  end

  client:close();
end

--------------------------------------------------------------------------------
-- main functions
--------------------------------------------------------------------------------

local function connect()
  connect_vlc()
  send("pause")
end


local function stop()
  connect_vlc()
  send("pause")
end

local function pause()
  connect_vlc()
  send("pause");
end

local function go_to(seconds)
  connect_vlc()
  send("seek " .. seconds);
end

local function init()
  print("Init");
  -- Start the VLC in foreground mode with remote control --
  local args = "-I qt --extraintf rc --rc-host localhost:53842 --video-on-top --rc-quiet --rc-show-pos"
  if os.platform() == 'WINDOWS' then
    local cmdString = 'start /D "C:\\Program Files (x86)\\VideoLAN\\VLC\\" vlc.exe ' .. args;
    print(cmdString)
    os.execute(cmdString)
  else
    os.execute("vlc " .. args .. " &")
  end
  -- Set the state variable to enabled so we try to send data to VLC
  vlc_started = true
end


-- Menu --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Start VLC with remote interface",
  invoke = init
}


function start_stop_video()
  local time = get_time()
  local isPlaying = renoise.song().transport.playing
  if isPlaying then
    pause()
  else
    pause()
  end
  go_to(time)
end

function on_loop_pattern()
  local time = get_time()
  go_to(time)
end

-- When starting or loading a new song, place the notifiers. otherwise renoise throws
-- an error because no song has been loaded
renoise.tool().app_new_document_observable:add_notifier(function()
  renoise.song().selected_sequence_index_observable:add_notifier(on_loop_pattern)
  renoise.song().transport.playing_observable:add_notifier(start_stop_video)
end)



_AUTO_RELOAD_DEBUG = function()

end
