local function run(msg,matches,ln)
if not is_sudo_id(msg.from.id) then
return 
end
if matches[1] == 'fasearch' then
return fasearch(matches[2])
elseif matches[1] == 'fasearch2' then
return fasearch(fasearch2(matches[2]))
elseif matches[1] == 'faget' then
return fasearch(faget(matches[2],matches[3],matches[4]))
elseif matches[1] == 'fixlang' then
local nu = 0
local text = 'List fix English : \n'
    for n in pairs(lang.fa) do
if not lang.en[n] then
  nu = nu + 1
  text = text..nu..'- '..n..'\n'
  lang.en[n] = lang.fa[n]
  end
  if type(lang.fa[n]) == 'table' then
for t in pairs(lang['fa'][n]) do
  if not lang.en[n][t] then
  nu = nu + 1
  text = text..nu..'- '..n..'.'..t..'\n'
  lang.en[n][t] = lang.fa[n][t]
  end
 if type(lang.fa[n][t]) == 'table' then
    for f in pairs(lang['fa'][n][t]) do
  if not lang.en[n][t][f] then
    nu = nu + 1
  text = text..nu..'- '..n..'.'..t..'.'..f..'\n'
  lang.en[n][t][f] = lang.fa[n][t][f]
  end
  end
  end
  end
  end
  end
  if nu == 0 then
  text = text..'not thing fixed\n'
  end
  local nu = 0
  local text = text..'List fix Persian : \n'
  for n in pairs(lang.en) do
if not lang.fa[n] then
  nu = nu + 1
  text = text..nu..'- '..n..'\n'
  lang.fa[n] = lang.en[n]
  print(serpent.block(lang))
  end
if type(lang.en[n]) == 'table' then
for t in pairs(lang['en'][n]) do
  if not lang.fa[n][t] then
  nu = nu + 1
  text = text..nu..'- '..n..'.'..t..'\n'
  lang.fa[n][t] = lang.en[n][t]
  end
 if type(lang.en[n][t]) == 'table' then
    for f in pairs(lang['en'][n][t]) do
  if not lang.fa[n][t][f] then
    nu = nu + 1
  text = text..nu..'- '..n..'.'..t..'.'..f..'\n'
  lang.fa[n][t][f] = lang.en[n][t][f]
  end
  end
  end
  end
  end
  end
  if nu == 0 then
  text = text..'not thing fixed\n'
  end
        local infile = io.open('langs/fa.lua', "r")
        local instr = infile:read("*a")
        infile:close()
        local outfile = io.open('langs/fa_backup.lua', "w")
        outfile:write(instr)
        outfile:close()
		local infile = io.open('langs/en.lua', "r")
        local instr = infile:read("*a")
        infile:close()
        local outfile = io.open('langs/en_backup.lua', "w")
        outfile:write(instr)
        outfile:close()
        serialize_to_file(lang['fa'], 'langs/fa.lua')
		serialize_to_file(lang['en'], 'langs/en.lua')
return text
end
end
return {
run = run,
patterns = {
'^[!/](psearch) (.+)$',
'^[!/](psearch2) (.+)$',
'^[!/](prename) ([%w_%-]+) ([%w_%-]+)$',
'^[!/](pdel) ([%w_%-]+)$',
'^[!/](pget) ([%w_%-]+)$',
'^[!/](pshow) ([%w_%-]+)$',
'^[!/](cplug)$',
'^[!/](cplug) ([%w_%-]+)$',
'^[!/](cplug) ([%w_%-]+) %+ (.+)$',
'^[!/](pedit)$',
'^[!/](pedit) ([%w_%-]+)$',
'^[!/](pedit) ([%w_%-]+) %+ (.+)$',
'^[!/](cfa) (.*) %+ (.*) %+ (.*)$',
'^[!/](cfa) (.*) %+ (.*)$',
'^[!/](fixlang)$',
'^[!/](faedit) (.*) %+ (.*) %+ (.*) %+ (.*)$',
'^[!/](faedit) (.*) %+ (.*) %+ (.*)$',
'^[!/](faedit) (.*) %+ (.*)$',
'^[!/](faget) (.*) %+ (.*) %+ (.*)$',
'^[!/](faget) (.*) %+ (.*)$',
'^[!/](faget) (.*)$',
'^[!/](faget)$',
'^[!/](fasearch) (.*)',
'^[!/](fasearch2) (.*)'
}
}