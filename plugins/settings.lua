local function run(msg,matches,ln)
if matches[1] == lang[ln].settings.cmd_1 and is_sudo_id(msg.from.id) then
local just_sudo = lang[ln].settings.jsudo_off
if db:get("bot:justsudo") then
just_sudo = lang[ln].settings.jsudo_on
end
return glang(lang[ln].settings.text,just_sudo)
end
end
return {
run = run,
patterns = {'^[!#/](langcmd{settings.cmd_1})$'}
}