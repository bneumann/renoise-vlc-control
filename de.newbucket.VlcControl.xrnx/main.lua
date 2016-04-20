-------------------------------------------------------------
-- VLC Control by Benjamin Neumann (for Renoise 3.1)       --
-------------------------------------------------------------

--------------------------------------------------------------------------------
-- variables and states
--------------------------------------------------------------------------------

local client = nil
local socket_error = nil
local success = false
local connection_timeout = 2000
local message = ""
local vlc_started = false
local DEFAULT_PATH = "C:\\Program Files (x86)\\VideoLAN\\VLC\\"

-- Initialize and load settings
local options = renoise.Document.create("VlcRemotePreferences") {
  vlc_path = DEFAULT_PATH,
  port = 53842
}

renoise.tool().preferences = options

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
  local port = options.port
  print(port)
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

local function setOption(key, value)
    options:remove_property(options[key])
    options:add_property(key, value)
end

local function selectPath()
  local ret = renoise.app():prompt_for_path("Select your VLC installation path")
  if not (ret == nil or ret == '') then
    setOption("vlc_path", ret)
    print(options.vlc_path)
  end
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
  local args = "-I qt --extraintf rc --rc-host localhost:53842 --video-on-top --rc-quiet --rc-show-pos"
  if os.platform() == 'WINDOWS' then
    local cmdString = 'start /D "' .. tostring(options.vlc_path) .. '" vlc.exe ' .. args;
    print(cmdString)
    os.execute(cmdString)
  else
    os.execute("vlc " .. args .. " &")
  end
  -- Set the state variable to enabled so we try to send data to VLC
  vlc_started = true
end

local function settings()
 -- we memorize a reference to the dialog this time, to close it
  local this_dialog = nil
  
  local vb = renoise.ViewBuilder()
  local DEFAULT_MARGIN = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN

  local dialog_content = vb:column { margin = DEFAULT_MARGIN, width = 200 }
  
  local pathRow = vb:row { width = "100%" }
  local buttonRow = vb:row {width = "100%"}
  
  local pathText = vb:text { text = tostring(options.vlc_path), width = "80%" }
  local pathButton = vb:button {
        text = "Find player",
        width = "100%",
        tooltip = "Select path to the VLC player",
        notifier = function()
          selectPath()
          pathText.text = tostring(options.vlc_path)
        end
        }
  local defaultButton = vb:button {
        text = "Default",
        width = "100%",
        tooltip = "Set default path",
        notifier = function()
          setOption("vlc_path", DEFAULT_PATH)
          pathText.text = tostring(options.vlc_path)
        end
        }
   local saveButton = vb:button {
        text = "Save",
        width = "100%",
        tooltip = "Save end return",
        notifier = function()
          options:save_as("preferences.xml")
          this_dialog:close()
        end
        }
  pathRow:add_child(pathText)
  buttonRow:add_child(pathButton)
  buttonRow:add_child(defaultButton)
  buttonRow:add_child(saveButton)
  
  dialog_content:add_child(pathRow)
  dialog_content:add_child(buttonRow)
  this_dialog = renoise.app():show_custom_dialog("VLC Remote Settings", dialog_content)
end

-- Starter --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:VLC Remote:Start VLC with remote interface",
  invoke = init
}

-- Settings --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:VLC Remote:Settings",
  invoke = settings
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
