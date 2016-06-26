do

local function pre_process(msg)
local hpbase = {
"😐",
"😐😐",
"😐😐😐",
"😐😐😐😐",
"😐😐😐😐😐",
"😐😐😐😐😐😐",
"😐😐😐😐😐😐😐",
"😐😐😐😐😐😐😐😐",
"😐😐😐😐😐😐😐😐😐",
"😐😐😐😐😐😐😐😐😐😐",
"😐😐😐😐😐😐😐😐😐😐😐",
"😐😐😐😐😐😐😐😐😐😐😐😐",
"😐😐😐😐😐😐😐😐😐😐😐😐😐",
}
local hpr = hpbase[math.random(#hpbase)]


    local hash = 'poker:'..msg.to.id
    if db:get(hash) and msg.text == "😐" and not is_sudo_id(msg.from.id) then
         reply_msg(msg.id, hpr, ok_cb, false)
            return ""
        end
    
        return msg
    end

  
--Plug by Mehran_hpr @iGodFather

local function run(msg, matches)
    chat_id =  msg.to.id
    
    if is_sudo_id(msg.from.id) and matches[1] == 'poker' then
      
            
                    local hash = 'poker:'..msg.to.id
                    db:set(hash, true)
                    return "turned on"
  elseif is_sudo_id(msg.from.id) and matches[1] == 'unpoker' then
                    local hash = 'poker:'..msg.to.id
                    db:del(hash)
                    return "turned off"
end

end

return {
    patterns = {
      '^(😐)$',   
      '^[/!#](poker)$',
       '^[/!#](unpoker)$'
    },
    run = run,
    pre_process = pre_process
}
end
