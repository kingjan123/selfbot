local function run(msg, matches)
if not is_sudo_id(msg.from.id) then
local text = '😐'
reply_msg(msg.id, text, ok_cb, false)
end
end
return {
patterns = {
    "^😐$"
},
run = run
}
