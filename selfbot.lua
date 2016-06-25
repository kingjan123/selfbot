package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'
dofile("./utils.lua")
print('Loading utilities.lua...')
VERSION = '0.1'
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
-- This function is called when tg receive a msg
function on_msg_receive (msg)
  if not started then
    return
  end
  msg = backward_msg_format(msg)
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
-- Returns the config from config.lua file.
-- If file doesn't exist, create it.
function load_config(ex,suc,res)
if suc == 1 then
  local f = io.open('./config.lua', "r")
  -- If config.lua doesn't exist
  if not f then
    config = {
    enabled_plugins = {
      "settings",
	  "plugin_manager",
	  "poker"
    },
	supported_langs = {
	'fa'
	},
    sudo_users = {res.peer_id},
    disabled_channels = {}
  }
  serialize_to_file(config, './config.lua')
    print ("Created new config file: config.lua")
else
  f:close()
  end
    local config = loadfile ("./config.lua")()
  print('Loading config.lua...')
  local stext = ''
  for v,user in pairs(config.sudo_users) do
      stext = stext..user..'\n'
  end
  if not stext ~= '' then
      print("Sudo users: \n" ..stext)
      end
_config = config
  -- load plugins
  plugins = {}
  load_plugins()
  lang = {}
  load_langs()
  started = true
  postpone (cron_plugins, false, 60*5.0)
 end
end
function on_binlog_replay_end()
 bot_info(load_config,false)
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
  if pattern:find('langcmd') then
  local pattern_2 = pattern:match('langcmd{(.+)}')
  for l,langu in pairs(_config.supported_langs) do
  local mypattern = {}
  local p = 1
  for get_pattern in pattern_2:gmatch('([^%.]+)') do
  if p == 1 then
  mypattern = lang[langu][get_pattern] or lang['fa'][get_pattern]
  else
  mypattern = mypattern[get_pattern]
  end
  p = p + 1
  end
  local opattern = pattern:gsub('langcmd{[^}]+}',mypattern)
    local matches = match_pattern(opattern, msg.text)
    if matches then
      print("msg matches: ", opattern)
      if is_plugin_disabled_on_chat(plugin_name, receiver) then
        return nil
      end
      -- Function exists
      if plugin.run then
		local success, result = pcall(function()
		return plugin.run(msg, matches,db:hget(receiver,'lang') or 'fa')
		end)
		if not success then
		print(msg.text or 'nth', result)
		send_large_msg(receiver, 'This is a bug! Sorry')
		--save_log('errors', result, msg.from.id or false, msg.to.id or false, msg.text or false)
        send_large_msg((_config.logchat or ('user#id'.._config.sudo_users[1])),'An #error occurred.\n'..result..'\n'..(msg.text or 'nth'))
		return
		else
		if result then
		send_large_msg(receiver,result)
		end
		end
      end
      -- One patterns matches
      return
    end
  end
  
  else
 
 
    local matches = match_pattern(pattern, msg.text)
    if matches then
      print("msg matches: ", pattern)

      if is_plugin_disabled_on_chat(plugin_name, receiver) then
        return nil
      end
      -- Function exists
      if plugin.run then
		local success, result = pcall(function()
		return plugin.run(msg, matches,db:hget(receiver,'lang') or 'fa')
		end)
		if not success then
		print(msg.text or 'nth', result)
		send_large_msg(receiver, 'This is a bug! Sorry')
		--save_log('errors', result, msg.from.id or false, msg.to.id or false, msg.text or false)
        send_large_msg((_config.logchat or ('user#id'.._config.sudo_users[1])),'An #error occurred.\n'..result..'\n'..(msg.text or 'nth'))
		return
		else
		if result then
		send_large_msg(receiver,result)
		end
		end
      end
      -- One patterns matches
      return
    end
 
 
end
end
end
-- Save the content of _config to config.lua
function save_config( )
  serialize_to_file(_config, './config.lua')
  print ('saved config into ./config.lua')
end

function on_our_id (id)
  if not io.open('./config.lua', "r") then
   bot_info(load_config,false)
  end
end

function on_user_update (user, what)
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
      local p = dofile("plugins/"..v..'.lua')
      plugins[v] = p
  end
end
-- Load Langs
function load_langs()
  for k, v in pairs(_config.supported_langs) do
    print("Loading lang", v)
	lang[v] = dofile('langs/'..v..'.lua')
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
now = os.time()
math.randomseed(now)
started = false