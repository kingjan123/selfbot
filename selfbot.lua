package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'
dofile("./utils.lua")
print('Loading utilities.lua...')
VERSION = '0.1'

-- This function is called when tg receive a msg
function on_msg_receive (msg)
  if not started then
    return
  end
  local receiver = get_receiver(msg)
  msg = pre_process_service_msg(msg)
  if msg_valid(msg) then
    msg = pre_process_msg(msg)
    if msg then
      match_plugins(msg)
      if not db:get("bot:nomarkread") and not db:hget(receiver,'nomarkread') then
          mark_read(receiver, ok_cb, false)
          end
    end
  end
end

function ok_cb(extra, success, result)
end

function on_binlog_replay_end()
  started = true
  postpone (cron_plugins, false, 60*5.0)
  -- load config
  _config = load_config()
  -- load plugins
  plugins = {}
  load_plugins()
end

function msg_valid(msg)
    
  -- Before bot was started
  if msg.date < now then
    print('\27[36mNot valid: old msg\27[39m')
    return false
  end

  if msg.unread == 0 then
    print('\27[36mNot valid: readed\27[39m')
    return false
  end

  if not msg.to.id then
    print('\27[36mNot valid: To id not provided\27[39m')
    return false
  end

  if not msg.from.id then
    print('\27[36mNot valid: From id not provided\27[39m')
    return false
  end
if db:get("bot:justsudo") and not msg.service and not is_sudo_id(msg.from.id) then
    print('\27[36mNot valid: Msg is not from sudo\27[39m')
    return false
  end

  if msg.to.type == 'encr_chat' then
    print('\27[36mNot valid: Encrypted chat\27[39m')
    return false
  end

  if msg.from.id == 777000 then
    print('\27[36mNot valid: Telegram message\27[39m')
    return false
  end

  return true
end

--
function pre_process_service_msg(msg)
   if msg.service then
      local action = msg.action or {type=""}
      -- wipe the data to allow the bot to read service messages
      if msg.out then
         msg.out = false
      end
      if msg.from.id == our_id then
         msg.from.id = 0
      end
   end
   return msg
end

-- Apply plugin.pre_process function
function pre_process_msg(msg)
    local names = ''
  for name,plugin in pairs(plugins) do
    if plugin.pre_process and msg then
        names = names..'\n'
      msg = plugin.pre_process(msg)
    end
  end
if names ~= '' then 
    print('On All Msg Plugins :\n'..names)
end
  return msg
end

-- Go over enabled plugins patterns.
function match_plugins(msg)
  for name, plugin in pairs(plugins) do
    match_plugin(plugin, name, msg)
  end
end

-- Check if plugin is on _config.disabled_plugin_on_chat table
local function is_plugin_disabled_on_chat(plugin_name, receiver)
  local disabled_chats = _config.disabled_plugin_on_chat
  -- Table exists and chat has disabled plugins
  if disabled_chats and disabled_chats[receiver] then
    -- Checks if plugin is disabled on this chat
    for disabled_plugin,disabled in pairs(disabled_chats[receiver]) do
      if disabled_plugin == plugin_name and disabled then
        return true
      end
    end
  end
  return false
end
-- DEPRECATED, use send_large_msg(destination, text)
function _send_msg(destination, text)
  send_large_msg(destination, text)
end
function match_plugin(plugin, plugin_name, msg)
  local receiver = get_receiver(msg)

  -- Go over patterns. If one matches it's enough.
  for k, pattern in pairs(plugin.patterns) do
    local matches = match_pattern(pattern, msg.text)
    if matches then
      print("msg matches: ", pattern)

      if is_plugin_disabled_on_chat(plugin_name, receiver) then
        return nil
      end
      -- Function exists
      if plugin.run then
		local success, result = pcall(function()
		return plugin.run(msg, matches)
		end)
		if not success then
		print(msg.text or 'nth', result)
		api.sendReply(msg, 'This is a bug! Sorry', true)
		save_log('errors', result, msg.from.id or false, msg.to.id or false, msg.text or false)
        _send_msg(_config.logchat or _config.sudo_users[1],'An #error occurred.\n'..result..'\n'..(msg.text or 'nth'))
		return
		end
          if result then
            send_large_msg(receiver, result)
          end
      end
      -- One patterns matches
      return
    end
  end
end
-- Save the content of _config to config.lua
function save_config( )
  serialize_to_file(_config, './config.lua')
  print ('saved config into ./config.lua')
end

-- Returns the config from config.lua file.
-- If file doesn't exist, create it.
function load_config( )
  local f = io.open('./config.lua', "r")
  -- If config.lua doesn't exist
  if not f then
    print ("Created new config file: config.lua")
    create_config()
end
    f:close()
  local config = loadfile ("./config.lua")()
  print('Loading config.lua...')
  local stext = ''
  for v,user in pairs(config.sudo_users) do
      stext = stext..user..'\n'
  end
  if not stext ~= '' then
      print("Sudo users: \n" ..stext)
      end
  return config
end
-- Create a basic config.json file and saves it.
function create_config( )
  -- A simple config with basic plugins and ourselves as privileged user
  config = {
    enabled_plugins = {
      "settings",
      "plugin_manager"
    },
    sudo_users = {},
    disabled_channels = {}
  }
  serialize_to_file(config, './config.lua')
  print ('saved config into ./config.lua')
end

function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)
  --vardump (chat)
end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
end

-- Enable plugins in config.json
function load_plugins()
  for k, v in pairs(_config.enabled_plugins) do
    print("Loading plugin", v)

    local ok, err =  pcall(function()
      local t = loadfile("plugins/"..v..'.lua')()
      plugins[v] = t
    end)

    if not ok then
      print('\27[31mError loading plugin '..v..'\27[39m')
      print('\27[31m'..err..'\27[39m')
         _send_msg(_config.logchat or _config.sudo_users[1],'An #error occurred on loading plugin.\nPlugin: '..v..'\n'..err)
    end

  end
end
-- Call and postpone execution for cron plugins
function cron_plugins()
  for name, plugin in pairs(plugins) do
    -- Only plugins with cron function
    if plugin.cron ~= nil then
      plugin.cron()
    end
  end
  -- Called again in 5 mins
  postpone (cron_plugins, false, 5*60.0)
end
-- Start and load values
our_id = 0
now = os.time()
math.randomseed(now)
started = false