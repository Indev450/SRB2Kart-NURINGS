local config_loading = false -- Don't update config when we already loading it
local config = "nurings.cfg"

local function loadConfig()
	if (not consoleplayer) or consoleplayer.ringsconfig_loaded then return end

	consoleplayer.ringsconfig_loaded = true

	local file = io.open(config)

	if not file then return end -- No config created yet

	config_loading = true
	for line in file:lines() do
		COM_BufAddText(consoleplayer, line)
	end
	config_loading = false

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

	file:close()
end

addHook("MapLoad", loadConfig)
addHook("NetVars", loadConfig)

-- Only save config if we aren't loading it already
rawset(_G, "updateRingsConfig", function()
	if not config_loading then saveConfig() end
end)

-- Support for config script by GenericHeroGuy

-- the queue, and a helper for simplifying cvar registration

rawset(_G, "CONFIG_Queue", CONFIG_Queue or {})

rawset(_G, "CONFIG_RegisterVar", function(var)
	table.insert(CONFIG_Queue, var)
	return CV_RegisterVar(var)
end)
