local config = "nurings.cfg"

local function loadConfig()
	local file = io.open(config)

	if not file then return end -- No config created yet

	for line in file:lines() do
		COM_BufAddText(consoleplayer, line)
	end

	file:close()
end

local function getRingstuff(player)
	if not player.ringstuff then player.ringstuff = {} end

	return player.ringstuff
end

local function saveConfig()
	if not consoleplayer then return end

	local rs = getRingstuff(consoleplayer)

	local file, err = io.open(config, "w")

	if not file then
		print(string.format("\130WARNING:\128 failed to open %s: %s", config, err))
		return
	end

	local buttonnames = {
        [BT_ATTACK] = "item",
        [BT_CUSTOM1] = "custom1",
        [BT_CUSTOM2] = "custom2",
        [BT_CUSTOM3] = "custom3",
    }

	local button = buttonnames[rs.button or BT_ATTACK]
	local itemcheck = (not rs.noItemCheck) and "1" or "0"

	file:write(string.format("ring_button %s\n", button))
	file:write(string.format("ring_itemcheck %s\n", itemcheck))
	file:write(string.format("ring_usedelay %d\n", rs.useDelay))

	file:close()
end

addHook("PlayerJoin", function(pnum)
	if not (consoleplayer and pnum == #consoleplayer) then return end

	loadConfig()
end)

-- Only save config if we aren't loading it already
-- Used to do that... Can't really do that now because COM_BufAddText won't execute stuff immediately.
-- Its not really a bad thing for just 2 lines, but will eventually need to fix it... Maybe
rawset(_G, "updateRingsConfig", function()
	saveConfig()
end)

-- Support for config script by GenericHeroGuy

-- the queue, and a helper for simplifying cvar registration

rawset(_G, "CONFIG_Queue", CONFIG_Queue or {})

rawset(_G, "CONFIG_RegisterVar", function(var)
	table.insert(CONFIG_Queue, var)
	return CV_RegisterVar(var)
end)
