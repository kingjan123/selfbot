do

local function pre_process(msg)
          local hpr = "کص نگو"

    local hash = 'mate:'..msg.to.id
    if redis:get(hash) and msg.reply_id and is_sudo_id(msg.from.id) then
         reply_msg(msg.id, hpr, ok_cb, false)
            return ""
        end
    
        return msg
    end

  
--Plug by Mehran_hpr @iGodFather

local function run(msg, matches)
    chat_id =  msg.to.id
    
    if is_sudo_id(msg.from.id) and matches[1] == 'reply' then
      
            
                    local hash = 'mate:'..msg.to.id
                    redis:set(hash, true)
                    return "turned on"
  elseif is_sudo_id(msg.from.id) and matches[1] == 'unreply' then
                    local hash = 'mate:'..msg.to.id
                    redis:del(hash)
                    return "turned off"
end

end

return {
    patterns = {
        '^[/!#](reply)$',
        '^[/!#](unreply)$'
    },
    run = run,
    pre_process = pre_process
}
end
