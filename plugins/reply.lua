do

local function pre_process(msg)
          local hpr = "your msg :)"

    local hash = 'reply:'..msg.to.id
    if db:get(hash) and msg.reply_id and not is_sudo_id(msg.from.id) then
         reply_msg(msg.id, hpr, ok_cb, false)
            return ""
        end
    
        return msg
    end

  
--Plug by Mehran_hpr @iGodFather

local function run(msg, matches)
    chat_id =  msg.to.id
    
    if is_sudo_id(msg.from.id) and matches[1] == 'reply' then
      
            --Plug by Mehran_hpr @iGodFather
                    local reply = 'mate:'..msg.to.id
                    db:set(hash, true)
                    return "turned on"
  elseif is_sudo_id(msg.from.id) and matches[1] == 'unreply' then
                    local hash = 'mate:'..msg.to.id
                    db:del(hash)
                    return "turned off"
end

end
--Plug by Mehran_hpr @iGodFather
return {
    patterns = {
        '^[/!#](reply)$',
        '^[/!#](unreply)$'
    },
    run = run,
    pre_process = pre_process
}
end
--Plug by Mehran_hpr @iGodFather
--it Works Only In Groups/Supergroups
--change your msg :) in line 4 to every msg that you want
