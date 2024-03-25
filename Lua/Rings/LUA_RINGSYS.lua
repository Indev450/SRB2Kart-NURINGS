--Rings original by unknown
--Stuff rewritten and modified by NepDisk, Indev and Callmore

freeslot("SPR_RNGS", "SPR_RGFD", "S_RINGSO", "S_V2RFDE", "S_USERNG", "MT_RINGSO", "MT_RINGSOMAP", "MT_RINGGET", "MT_RINGUSE","MT_RINGPOINT", "S_RINGPOINT")

freeslot("SPR_HIT4","SPR_HIT5","SPR_HIT6","SPR_HIT7","SPR_HIT8","SPR_HIT9","SPR_HITX")

freeslot("SPR_STSP", "S_STGSPK", "S_STGSP1", "S_STGSP2", "MT_STINGSPIKE")
freeslot("SPR_STAL", "S_STALR1", "S_STALR2", "MT_STINGALERT")

freeslot("sfx_stgram")
sfxinfo[sfx_stgram].flags = $|SF_X8AWAYSOUND -- unique "BLAM" sound for a ring-sting ram

rawset(_G, "rings", {
	grabsound = sfx_s227,
	usesound = sfx_s1ce,
	spillsound = sfx_s1c6,
	stingsound = sfx_s1a6,
	customrgsprite = nil,
	ringcap = 20,
	ringusecap = 15,
})

rawset(_G, "ringCrossmod", {
	mapSoundData = {} // array with 4 values, should be your custom sound values
})

rawset(_G, "ringsOn", false)
rawset(_G, "mapRingsPresent", false)

rawset(_G, "cv_mrRespawnTics", 10)



local ringsting = CV_RegisterVar({
  name = "ringsting",
  defaultvalue = "Off",
  flags = CV_NETVAR|CV_CALL,
  PossibleValue = CV_OnOff,
  func = function(cv)
		local ringstingonoff = (cv.value == 0) and "\x82 Off" or "\x85 On"
		print("\131* Rings Sting has been turned" .. ringstingonoff .. "\131.")
   end 
}) -- toggle Ring Sting/negative rings
 
local cv_dorings = CV_RegisterVar({
  name = "rings",
  defaultvalue = "Off",
  flags = CV_NETVAR|CV_CALL,
  PossibleValue = CV_OnOff,
  func = function(cv)
		local ringonoff = (cv.value == 0) and "\x85 Off" or "\x82 On"
		print("\131* Rings will be turned" .. ringonoff .. "\131 next round.")
   end 
}) -- toggle Rings

local cv_ringcap = CV_RegisterVar({
    name = "ringsmaxcap",
    defaultvalue = "20",
    flags = CV_NETVAR|CV_CALL,
	possiblevalue =  {MIN = 1, MAX = 999},
	func = function(cv)
		print("\131* Ring cap has been set to \x82" .. cv.value .. "\131 rings.")
		rings.ringcap = cv.value
    end 
}) -- maximum ring cap

local cv_ringusecap = CV_RegisterVar({
    name = "ringsusecap",
    defaultvalue = "15",
    flags = CV_NETVAR|CV_CALL,
	possiblevalue =  {MIN = 1, MAX = 999},
	func = function(cv)
		print("\131* Ring usage cap has been set to \x82" .. cv.value .. "\131.")
		rings.ringusecap = cv.value
    end 
}) -- ring use cap

local cv_ignoremaprules = CV_RegisterVar({
  name = "ringsignoremaprules",
  defaultvalue = "Off",
  flags = CV_NETVAR|CV_CALL,
  PossibleValue = CV_OnOff,
  func = function(cv)
		local ringmapleruleonoff = (cv.value == 0) and "\x85 Off" or "\x82 On"
		print("\131* Ignoring ring map rules has been turned" .. ringmapleruleonoff .. "\131.")
   end 
}) -- ignore custom ring caps from maps

local cv_allowitembox = CV_RegisterVar({
  name = "ringsallowitembox",
  defaultvalue = "Off",
  flags = CV_NETVAR|CV_CALL,
  PossibleValue = CV_OnOff,
  func = function(cv)
		local ringmapleruleonoff = (cv.value == 0) and "\x85 Off" or "\x82 On"
		print("\131* Getting rings from itemboxes on ring maps has been turned" .. ringmapleruleonoff .. "\131.")
   end 
}) -- Allow getting rings on maps with itemboces

local cv_bumploserings = CV_RegisterVar({
  name = "ringsbump",
  defaultvalue = "Off",
  flags = CV_NETVAR|CV_CALL,
  PossibleValue = CV_OnOff,
  func = function(cv)
		local onoff = (cv.value == 0) and "\x85 Off" or "\x82 On"
		print("\131* Losing rings on bump has been turned" .. onoff .. "\131.")
   end
}) -- Allow getting rings on maps with itemboces

-- colorize sticker
local cv_colorizeringbar = CONFIG_RegisterVar({
	name = "ring_barcolourize",
	defaultvalue = "Off",
	possiblevalue = CV_OnOff,

	config_menu = "Rings",
	displayname = "Ring Bar Color",
	description = "Colorize ring bar (inverted on clients that support colorized hud)",
}) -- colorize sticker, reversed if client suppors colorized hud

local cv_ringbarx = CONFIG_RegisterVar({
    name = "ring_barxoffset",
    defaultvalue = "0",

	config_menu = "Rings",
	displayname = "Ring Bar Offsets",
	description = "Change the offsets for ring bar.",
	config_hudmove = "ring_baryoffset",
}) -- bar x offset

local cv_ringbary = CV_RegisterVar({
    name = "ring_baryoffset",
    defaultvalue = "0",
}) -- bar y offset

local function getRingstuff(p)
	if not p.ringstuff then
		p.ringstuff = {}
	end

	return p.ringstuff
end

local function tutorialFileExists()
	local file = io.open("ringstutorial.txt")
	
	if not file then return false end
	
	return true
end

local sawtutorial = tutorialFileExists()

COM_AddCommand("ring_notutorial", function()
	sawtutorial = true
	
	local file, err = io.open("ringstutorial.txt", "w")
	
	if file then
		print("You won't see rings tutorial again")
		file:write("Delete this file to re-enable rings tutorial")
		file:close()
	else
		print("Failed to create ringstutorial.txt: "..err)
	end
end, COM_LOCAL)
 
COM_AddCommand("ring_button", function(p, bname)
	local rs = getRingstuff(p)

    local buttonnames = {
        [BT_ATTACK] = "item",
        [BT_CUSTOM1] = "custom 1",
        [BT_CUSTOM2] = "custom 2",
        [BT_CUSTOM3] = "custom 3",
    }

    if not bname then
        local button = buttonnames[rs.button or BT_ATTACK]
        
        CONS_Printf(p, "Ring use button: \131"..button.."\n")
        CONS_Printf(p, "Usage: ring_button <button name>")
        CONS_Printf(p, "Available button names: item (i), custom1 (c1), custom2 (c2), custom3 (c3)")
        return
    end
    
    local buttons = {
        item = BT_ATTACK,
        i = BT_ATTACK,
        custom1 = BT_CUSTOM1,
        c1 = BT_CUSTOM1,
        custom2 = BT_CUSTOM2,
        c2 = BT_CUSTOM2,
        custom3 = BT_CUSTOM3,
        c3 = BT_CUSTOM3,
    }
    
    local button = buttons[bname:lower()]
    
    if not button then
        CONS_Printf(p, "Invalid button name. For list of available button names, use this command without arguments")
        return
    end
    
    rs.button = button
    
    CONS_Printf(p, "Set ring use button to \131"..buttonnames[rs.button or BT_ATTACK])

	updateRingsConfig()
end)

COM_AddCommand("ring_itemcheck", function(p, docheck)
	local rs = getRingstuff(p)

    if not docheck then
        CONS_Printf(p, "Item check for ring use is "..(rs.noItemCheck and "\133disabled" or "\131enabled"))
        return
    end

    local itemCheck = {
        yes = true,
        ["1"] = true,
        on = true,
    }
    
    rs.noItemCheck = not itemCheck[docheck:lower()]

    CONS_Printf(p, "Item check for ring use is "..(rs.noItemCheck and "\133disabled" or "\131enabled"))

	updateRingsConfig()
end)

COM_AddCommand("ring_usedelay", function(p, dodelay)
	local rs = getRingstuff(p)

    if not dodelay then
        CONS_Printf(p, "Delay before ring use is "..(rs.useDelay and "\131enabled" or "\133disabled"))
        return
    end

    local useDelay = {
        yes = true,
        ["1"] = true,
        on = true,
    }
    
    rs.useDelay = useDelay[dodelay:lower()]

    CONS_Printf(p, "Delay before ring use is "..(rs.useDelay and "\131enabled" or "\133disabled"))

	updateRingsConfig()
end)

states[S_RINGSO] = {SPR_RNGS, FF_ANIMATE, -1, nil, 23, 2, S_RINGSO}
states[S_V2RFDE] = {SPR_RGFD, FF_ANIMATE|FF_TRANS50, -1, nil, 23, 2, S_V2RFDE}
states[S_USERNG] = {SPR_RNGS, FF_ANIMATE, -1, nil, 23, 1, S_USERNG}

-- ring sting hit effect

states[S_STGSPK] = {SPR_STSP, A, 5, nil, 0, 0, S_STGSP1}
states[S_STGSP1] = {SPR_STSP, A, 1, nil, 0, 0, S_STGSP2}
states[S_STGSP2] = {SPR_NULL, A, 1, nil, 0, 0, S_STGSP1}
states[S_STALR1] = {SPR_STAL, A, 10, nil, 0, 0, S_STALR2}
states[S_STALR2] = {SPR_STAL, B, 10, nil, 0, 0, S_STALR1}

mobjinfo[MT_RINGSO] = {
	doomednum = -1,
	spawnstate = S_RINGSO,
	spawnhealth = 1000,
	radius = 40*FRACUNIT,
	height = 40*FRACUNIT
}

mobjinfo[MT_RINGSOMAP] = {
	doomednum = -1,
	spawnstate = S_RINGSO,
	spawnhealth = 1000,
	radius = 19*FRACUNIT,
	height = 40*FRACUNIT,
	flags = MF_PUSHABLE|MF_NOGRAVITY
}

mobjinfo[MT_RINGGET] = {
	doomednum = -1,
	spawnstate = S_RINGSO,
	spawnhealth = 1000,
	radius = 19*FRACUNIT,
	height = 40*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOCLIPTHING|MF_NOGRAVITY
}

mobjinfo[MT_RINGUSE] = {
	doomednum = -1,
	spawnstate = S_USERNG,
	spawnhealth = 1000,
	radius = 19*FRACUNIT,
	height = 40*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOCLIPTHING|MF_NOGRAVITY
}

mobjinfo[MT_STINGSPIKE] = {
	doomednum = -1,
	spawnstate = S_STGSPK,
	spawnhealth = 1000,
	radius = 19*FRACUNIT,
	height = 40*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOCLIPTHING|MF_NOGRAVITY
}

mobjinfo[MT_STINGALERT] = {
	doomednum = -1,
	spawnstate = S_STALR1,
	spawnhealth = 1000,
	radius = 19*FRACUNIT,
	height = 40*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOCLIPTHING|MF_NOGRAVITY
}

mobjinfo[MT_RINGPOINT] = {
	doomednum = -1,
	spawnstate = S_RINGPOINT,
	spawnhealth = 1000,
	radius = 8*FRACUNIT,
	height = 8*FRACUNIT,
	displayoffset = -1,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_DONTENCOREMAP
	
}

-- Setup the animation frame offsets by code because i don't want to type those out.
local ringPointAnimationFrames = {}
local rintPointAnimationResetFrame = 8
do
	for _ = 1, 7 do
		table.insert(ringPointAnimationFrames, 0)
	end
	table.insert(ringPointAnimationFrames, 2)
	table.insert(ringPointAnimationFrames, 4)
	table.insert(ringPointAnimationFrames, 3)
	table.insert(ringPointAnimationFrames, 2)
	table.insert(ringPointAnimationFrames, 1)
    for _ = 1, TICRATE do
        table.insert(ringPointAnimationFrames, 2)
    end
	table.insert(ringPointAnimationFrames, 5)
	table.insert(ringPointAnimationFrames, 6)
end
states[S_RINGPOINT] = { SPR_UNKN, FF_FULLBRIGHT, #ringPointAnimationFrames, nil, 0, 0, S_NULL }

local function rgs_generateHFForPlayer(p)
    if p and p.valid and p.mo and p.mo.valid then
        return {{p.name, p.skincolor}, {skins[p.mo.skin].facemmap, p.skincolor}, p}
    else
        return {{}, {}}
    end
end

local function rgs_hideAlert(mo, p)
	local doHide = false
	local i=0 while i<4
		if (p == displayplayers[i])
			doHide = true
		end
		i=$+1
	end
	
	if (doHide == true)
		mo.state = S_INVISIBLE
	end
end

local thisplayer

hud.add(function(v, p, c)
	thisplayer = p
end)

local function spawnRingPoint(source, amount)
	source.ringpt = P_SpawnMobj(source.mo.x, source.mo.y, source.mo.z, MT_RINGPOINT)
	source.ringpt.target = source.mo
	source.ringpt.color = source.skincolor
	source.ringpt.ringCount = amount
end

local function K_RingGainEFX(source, amount)
	if not (source.mo and source.mo.valid) then return end
	if not (source or source.mo) then return end

	if amount <= 0 then
		return
	end

	amount = min(amount, 10)

	if source.ringpt and source.ringpt.valid
		-- Increase ringCount and reset state

		if source.ringpt.ringCount + amount > 10 then
			source.ringpt.ringCount = 10
			source.ringpt.tics = max(source.ringpt.tics, states[S_RINGPOINT].tics - rintPointAnimationResetFrame)
			spawnRingPoint(source, source.ringpt.ringCount + amount - 10)
			return
		end

		source.ringpt.ringCount = source.ringpt.ringCount + amount
		source.ringpt.tics = max(source.ringpt.tics, states[S_RINGPOINT].tics - rintPointAnimationResetFrame)

		return
	end

	spawnRingPoint(source, amount)
end

local intToRingPointGraphicOffset = {
	{sprite=SPR_HIT1, frame=0},
	{sprite=SPR_HIT2, frame=0},
	{sprite=SPR_HIT3, frame=0},
	{sprite=SPR_HIT4, frame=0},
	{sprite=SPR_HIT5, frame=0},
	{sprite=SPR_HIT6, frame=0},
	{sprite=SPR_HIT7, frame=0},
	{sprite=SPR_HIT8, frame=0},
	{sprite=SPR_HIT9, frame=0},
	{sprite=SPR_HITX, frame=0},
}

local function encoreflip(mo) end

if FF_HORIZONTALFLIP then
	encoreflip = function(mo)
		if encoremode then mo.frame = mo.frame | FF_HORIZONTALFLIP end
	end
end

addHook("MobjThinker", function(mo)
	if not (mo and mo.valid) then return end

	mo.sprite = intToRingPointGraphicOffset[mo.ringCount].sprite
	mo.frame = (mo.frame & ~FF_FRAMEMASK) | ringPointAnimationFrames[(#ringPointAnimationFrames - mo.tics) + 1] + intToRingPointGraphicOffset[mo.ringCount].frame
	encoreflip(mo)

	if not ringsOn return end
	if not (mo.target and mo.target.valid) then return end
	if not (mo.target.player and mo.target.player.valid) then return end
	K_MatchGenericExtraFlags(mo, mo.target)
	if (mo.target.player != thisplayer and (not splitscreen)) then mo.flags2 = $|MF2_DONTDRAW else mo.flags2 = $&(~MF2_DONTDRAW) end
	
	local targetHeight = min(48 * mo.target.scale, mo.target.height)
	if mo.target.player.ringpt ~= mo then
		targetHeight = targetHeight + 32 * mo.target.scale
	end

	if (mo.movefactor < targetHeight)
		
		mo.movefactor = $ + (targetHeight)/6
			if (mo.movefactor > targetHeight)
				mo.movefactor = targetHeight
			end
			
	elseif (mo.movefactor > targetHeight)
		mo.movefactor =  $ - (targetHeight)/6
			if (mo.movefactor < targetHeight)
				mo.movefactor = targetHeight
			end
	end
	P_MoveOrigin(mo, mo.target.x, mo.target.y, mo.target.z + (mo.target.height/2)*P_MobjFlip(mo.target) + mo.movefactor)
end, MT_RINGPOINT)


local cv_colorizedhud, cv_colorizedhudcolor, cv_kartdisplayspeed

local function drawRingHud(v, p)
	--Checks
	if not ringsOn return end
	if not (p.mo and p.mo.valid) then return end

	local rs = getRingstuff(p)

	-- cache cvars
	if cv_colorizedhud == nil then
		cv_colorizedhud = CV_FindVar("colorizedhud")
		cv_colorizedhudcolor = CV_FindVar("colorizedhudcolor")
		cv_kartdisplayspeed = CV_FindVar("kartdisplayspeed")

		-- don't check again if they weren't found
		cv_colorizedhud = $ or false
	end
	
	local colorbg = cv_colorizeringbar.value ~= (cv_colorizedhud and cv_colorizedhud.value or 0)
	local cmap
	
	if colorbg then
		cmap = v.getColormap(p.mo.skin, cv_colorizedhudcolor and cv_colorizedhudcolor.value or p.skincolor)
	else
		cmap = v.getColormap(p.mo.skin, SKINCOLOR_NICKEL)
	end
	
	local thisPlayer 	 = p.splitscreenindex + 1
	
	local ssxoffset,ssyoffset = 0,0
	local rgHudOffset = -77
	local spRgHudYOff = 172
	local f = 0
	
	local plrRings = rs.numRings
	
	local scrwidth 	= v.width()/v.dupx()
	local winheight = v.height()/v.dupy()
	local windiff 	= ((winheight-200)/2)
	local left 		= (scrwidth - 320)/2

	if (plrRings == nil) then plrRings = 0 end
	local sting = ((leveltime%10 >= 5) and (plrRings <= 0) and (ringsting.value == 1))
		
	--Splitscreen code	
	if splitscreen == 1 
		if	thisPlayer % 1 == 0 then
			ssyoffset = $ - 93
		end
		
		if	thisPlayer % 2 == 0 then
				ssyoffset = $ + 100
		end
	end
	
	if splitscreen >= 2 then
		if thisPlayer % 1 == 0 or  thisPlayer % 2 == 0 then
			ssyoffset = $ - 93
		end
		
		if thisPlayer % 3 == 0 or  thisPlayer % 4 == 0 then
			ssyoffset = $ + 100
		end
		
		if thisPlayer % 1 == 0 or thisPlayer % 3 == 0 then
			ssxoffset = $ + 45
		end	
		
		if thisPlayer % 4 == 0 or thisPlayer % 2 == 0 then
			ssxoffset = $ - 172
		end	
	end
				
	-- get numbers
	local s = tostring(abs(plrRings))
	local nums = {}

	if (abs(plrRings) >= 10)	-- more than 10, use 2 numbers
		nums = {tonumber(s:sub(1, 1)), tonumber(s:sub(2, 2))}
	else	-- only 1 number
		nums = {0, abs(plrRings)}
	end
	-- get font
	local font = (sting) and "STFONT" or "OPPRNK"
	local negaSign = ((sting) and v.cachePatch("STMINRED") or v.cachePatch("STMINUS"))
	if ((sting) and (f == 1)) then f = 10 end
	
	--cache patches needed for drawing
	local ringHud 	= v.cachePatch(colorbg and "RINGBC" or "RINGBG")
	local yellowBar = v.cachePatch("RINGB1")
	local redBar 	= v.cachePatch("RINGB2")
	local ringLock 	= v.cachePatch("K_NOBLNS")	
	local maxText   = v.cachePatch("RINGTMAX")
	
	--Flags
	local vflags = V_HUDTRANS
	local flags  = V_HUDTRANS
		
	--Actually draw the hud
	if (ringHud) then
		v.draw((11-(rgHudOffset+ssxoffset))-left+cv_ringbarx.value, spRgHudYOff+ssyoffset+windiff+cv_ringbary.value, ringHud, vflags,cmap)

		if rs.numRings >= rings.ringcap then
			v.draw((10-(rgHudOffset+ssxoffset))-left+cv_ringbarx.value+20, spRgHudYOff+ssyoffset+windiff+cv_ringbary.value - 4, maxText, vflags)
		end
	end
	
	--Negative sign
	if (plrRings < 0) then
		v.draw((6-(rgHudOffset))-left+cv_ringbarx.value, (spRgHudYOff+ssyoffset+6)+windiff+cv_ringbary.value, negaSign, flags)
	end
	
	--If you have an spb on your tail or use too many rings show that your rings are locked.
	if (rs.ringsUsed and rs.ringsUsed > rings.ringusecap) then
		v.draw((9-(rgHudOffset+ssxoffset))-left+cv_ringbarx.value, spRgHudYOff+ssyoffset+windiff-1+cv_ringbary.value, ringLock, vflags)
	end
		
	--Number drawing
	local numoffset = 0
	if (rs.numRings > 9 and rs.numRings < 20) or (rs.numRings < -9) then
		numoffset = 1
	else
		numoffset = 0
    end
	
	v.draw((13-(rgHudOffset+numoffset+ssxoffset))-left+cv_ringbarx.value, (spRgHudYOff+ssyoffset+6)+windiff+cv_ringbary.value, v.cachePatch(font.."0"..nums[1]), flags)
	v.draw((19-(rgHudOffset+numoffset-ssxoffset))-left+cv_ringbarx.value, (spRgHudYOff+ssyoffset+6)+windiff+cv_ringbary.value, v.cachePatch(font.."0"..nums[2]), flags)
				
	--For loop to draw bars on ring meter
	for i = 1,min(plrRings,20)
		v.draw((29-(rgHudOffset+ssxoffset))-left + ( 2 * i)+cv_ringbarx.value, spRgHudYOff+ssyoffset+windiff+6+cv_ringbary.value, yellowBar, vflags)
	end
	
	--Check for negative rings todo ringsting stuff
	if plrRings < 0 then
		for n = -1,max(plrRings,-20),-1
			if sting then v.draw((29-(rgHudOffset+ssxoffset))-left + ( 2 * n * -1)+cv_ringbarx.value, spRgHudYOff+ssyoffset+windiff+6+cv_ringbary.value, redBar, vflags) end
		end
	end
end

local starttime = 6 * TICRATE + (3 * TICRATE / 4)
local function drawRingTutorial(v)
	if sawtutorial or not ringsOn then return end
	
	local buttonnames = {
        [BT_ATTACK] = "item",
        [BT_CUSTOM1] = "custom 1",
        [BT_CUSTOM2] = "custom 2",
        [BT_CUSTOM3] = "custom 3",
    }

    local button = consoleplayer and buttonnames[consoleplayer.button or BT_ATTACK] or "item"
	
	local buttontext = button.." button " -- :3
	
	if (leveltime > starttime - 3*TICRATE and leveltime < starttime + 3*TICRATE) then --tell players they can use rengs
		v.drawString(20+20, 30, " YOU CAN USE" ,V_SNAPTOTOP|V_HUDTRANS, "left")
		v.drawString(111+17, 30, " RINGS " ,V_SNAPTOTOP|V_YELLOWMAP|V_HUDTRANS, "left")
		v.drawString(155+20, 30, " to speed up" ,V_SNAPTOTOP|V_HUDTRANS, "left")
		v.drawString(20+10, 45, " HOLD ",V_SNAPTOTOP|V_HUDTRANS, "left")
		v.drawString(20+50, 45, buttontext,V_SNAPTOTOP|V_REDMAP|V_HUDTRANS, "left")
		v.drawString(20+50+v.stringWidth(buttontext), 45, " to use your " ,V_SNAPTOTOP|V_HUDTRANS, "left")
		v.drawString(20+220,45, " rings! " ,V_SNAPTOTOP|V_YELLOWMAP|V_HUDTRANS, "left")
	end
end

addHook("MobjThinker", function(mo)
	if (ringsOn == true)
		local p = mo.player
		local dfBoost = p.kartstuff[k_startboost]
		local spinTimer = p.kartstuff[k_spinouttimer]
		local flatTimer = p.kartstuff[k_squishedtimer]
		local spawnTimer = p.kartstuff[k_respawn]
		local bumped = p.kartstuff[k_justbumped]

		local rs = getRingstuff(p)
		
		local dontBoost = ((not P_IsObjectOnGround(mo)) or p.kartstuff[k_rocketsneakertimer])
		
		if not rs.init then
			rs.numRings = 5 -- start the player off with 5 rings
			rs.ringsToAward = 0
			rs.activeAwardRings = 0
			rs.atkDownTime = 0
			rs.timedOut = 0
			rs.bumpspin = false
			rs.spill = false
			rs.speedFactor = 0
			rs.timedOut = 0 -- player runs out of "ring juice"
			rs.ringsUsed = 0 -- can't use any more than 10 rings
			rs.awardTimer = 0 -- increment when you have rings being awarded
			rs.boost = 0
			rs.lfstartboost = 0 -- startboost from previous frame used for compat
			rs.lflfsneakertimer = 0 -- sneakertimer from previous frame used for compat
			rs.init = true
		end
		
		if (mo.justSpawnedBuffer == nil)
			mo.justSpawnedBuffer = 5
		else
			if (mo.justSpawnedBuffer > 0)
				mo.justSpawnedBuffer = $1 - 1
			end
		end
		
		if ((p.playerstate == PST_DEAD) or (spawnTimer > 7))
			mo.justSpawnedBuffer = 5
		end
		
		if ((rs.stingAlertMobj == nil) and (spawnTimer <= 1) and (mo.justSpawnedBuffer <= 0))
			rs.stingAlertMobj = P_SpawnMobj(mo.x,mo.y,mo.z+mo.height,MT_STINGALERT) -- "!" icon for when you have 0- rings with ring sting on
			rs.stingAlertMobj.target = mo
		end
		
		if ((ringsting.value == 0) and (rs.numRings < 0))
			rs.numRings = 0 -- reset to 0
		end
		
		if (rs.boost)
			rs.boost = ($ - 1)
			p.kartstuff[k_offroad] = 0
		end
		
		local starTimer = p.kartstuff[k_invincibilitytimer]
		local growTimer = p.kartstuff[k_growshrinktimer]
		
		local inInvinc = (starTimer or growTimer)
		
		if (rs.flash)
			rs.flash = ($ - 1)
			
			if ((rs.flash > 0) and (not inInvinc) ) //stars and growth already colorize you
				mo.colorized = ((rs.flash % 2 == 0) and true or false)
			end
			
			if ((rs.flash == 1) and (not inInvinc))
				mo.colorized = false // un-colorize yourself
			end
		end
		
		
		
		if ((bumped) and (starTimer <= 1) and (growTimer == 0) and (rs.rgBumpDrop ~= true) and (rs.numRings > 0) and (rs.bumped))
			local mos = mapobjectscale
			local bumpRings = ((p.speed/mos)/20)
			
			if ((bumpRings == 0) and (starTimer <= 1) and (growTimer == 0)) then bumpRings = 1 end
			
			local ringSpillAng = (45/bumpRings)
				
			local ringSpawnAng = (ringSpillAng*bumpRings)
			if (rs.numRings > 0)
				for i = 1, bumpRings
					local plrRing = P_SpawnMobj(mo.x, mo.y, mo.z+(5*mos), MT_RINGSO)
					plrRing.momx = 9*cos((mo.angle-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1))
					plrRing.momy = 9*sin((mo.angle-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1))
					plrRing.momz = ((14+i)*P_MobjFlip(mo))*mos
					plrRing.fuse = 20*TICRATE
					plrRing.grabBuffer = 7
					rs.numRings = $1 - 1
				end
			end
			mos = nil
			ringSpillAng = nil
			ringSpawnAng = nil
			bumpRings = nil
			rs.rgBumpDrop = true
		end
		
		if not bumped then
			rs.rgBumpDrop = false
			rs.bumped = nil
		end
		
		if ((ringsting.value == 1)) then
			
			if (rs.numRings < -10) then
				rs.numRings = -10
			end
			
			if bumped and rs.numRings <= 0 and not rs.bumpspin and not rs.rgBumpDrop == false then
				if ((starTimer <= 1) and (growTimer == 0)) then
					p.kartstuff[k_spinouttimer] = $1 + 10
				end
				if (hitfeed) then
					local plr = rgs_generateHFForPlayer(p)
					HF_SendHitMessage(nil, plr, "HFRSTNG")
					plr = nil
				end
				
				rs.bumpspin = true
			end
			
			
			if ((rs.bumpspin == true) and (spinTimer <= 0))
				rs.bumpspin = false
			end
		end
		
		starTimer = nil
		growTimer = nil
		
		if (dfBoost == 0)
			rs.speedFactor = 0
			rs.ringsUsed = 0
			if (rs.timedOut < 18)
				rs.timedOut = $1 + 1
			end
		end
		
		if (rs.ringsToAward ~= nil)
			if (rs.ringsToAward > 0)
				rs.awardTimer = $1 + 1
				if ((rs.awardTimer % 4) == 0)
					local mos = mapobjectscale
					local awardRing = P_SpawnMobj(mo.x, mo.y, mo.z+(24*mos), MT_RINGGET)
					awardRing.target = mo
					rs.ringsToAward = $1 - 1
					rs.activeAwardRings = rs.activeAwardRings + 1
				end
			elseif (rs.awardTimer > 0)
				rs.awardTimer = 0
			end
		end
        
        local BT_USERING = rs.button or BT_ATTACK
        local itemCheck = rs.noItemCheck or BT_USERING ~= BT_ATTACK or (p.kartstuff[k_itemroulette] == 0) and (p.kartstuff[k_itemamount] <= 0)
        local spinCheck = P_PlayerInPain(p) or p.kartstuff[k_spinouttimer] or p.kartstuff[k_wipeoutslow]
        
		if ((p.cmd.buttons & BT_USERING) and not (p.kartstuff[k_growshrinktimer] > 0))
			rs.atkDownTime = $1 + 1
		else
			rs.atkDownTime = rs.useDelay and -10 or -1 -- preventing instant use after using an item
			-- -1 when delay is disabled actually helps to avoid 4 tics delay because of '% 4' bellow
		end
        
		if ((p.cmd.buttons & BT_USERING) and itemCheck and (not spinCheck) and (((rs.atkDownTime % 4) == 0))  and (rs.atkDownTime >= 0) and (leveltime >= 268))
			local mos = mapobjectscale
			if ((rs.numRings > 0) and (not dontBoost) and (rs.ringsUsed <= rings.ringusecap))
				local useRing = P_SpawnMobj(mo.x, mo.y, mo.z+(24*mos), MT_RINGUSE)
				useRing.target = mo
				rs.numRings = $1 - 1
				sawtutorial = true
			end
		end
		
		if spinTimer == 0 and flatTimer == 0 then
			rs.spill = false -- Can take damage again
		end
	end
end, MT_PLAYER)

addHook("MobjThinker", function(mo)
	local mos = mapobjectscale

	if ((rings.customrgsprite) and (mo.state ~= rings.customrgsprite))
		mo.state = rings.customrgsprite
	end
	
	if (mo.distFromTarget == nil)
		mo.distFromTarget = 42*mos
		mo.angOffset = 0
		mo.subtractOffset = 0
		mo.actualDist = (((mo.distFromTarget)*mos)/10000)
	else
		local subval = ((mos*30)/11)
		local scalesub = ((mos/2)/11)
		if (mo.distFromTarget > (16*mos))
			mo.distFromTarget = ($1 - subval)
			mo.scale = ($1 - scalesub)
		end
		local tgDist = mo.distFromTarget
		mo.angOffset = $1 + 28
		if (mo.target ~= nil)
			local targ = mo.target
			local xdist = (tgDist/mos)*FixedMul(cos(targ.angle+(mo.angOffset*ANG1)), mos)
			local ydist = (tgDist/mos)*FixedMul(sin(targ.angle+(mo.angOffset*ANG1)), mos)
			P_MoveOrigin(mo,targ.x+(xdist),targ.y+(ydist),targ.z+(tgDist))
			xdist = nil
			ydist = nil
		end
		if (mo.distFromTarget <= (16*mos))
			local p = ((mo.target) and mo.target.player or nil)

			if (not p) then P_RemoveMobj(mo) return end

			local rs = getRingstuff(p)

			if (rs.numRings < rings.ringcap)
				rs.numRings = $1 + 1
			end

			S_StartSound(mo.target, rings.grabsound)
			if rs.numRings >= rings.ringcap then
				-- Make sure to only play it for the player who just maxed their rings to avoid giving away information
				S_StartSound(mo.target, sfx_s1c5, p)
			end

			rs.activeAwardRings = rs.activeAwardRings - 1
			p = nil
			P_RemoveMobj(mo)
		end
	end
end, MT_RINGGET)

addHook("MobjThinker", function(mo)
	local mos = mapobjectscale

	if ((rings.customrgsprite) and (mo.state ~= rings.customrgsprite))
		mo.state = rings.customrgsprite
	end
	
	if (mo.rgZOffDir == nil)
		mo.rgZOffDir = 0
	else
		if (mo.target ~= nil)
			local targ = mo.target
			mo.rgZOffDir = $1 + 11
			P_MoveOrigin(mo,targ.x,targ.y,targ.z+FixedMul(128*sin((mo.rgZOffDir*ANG1)), mos) * (targ.eflags & MFE_VERTICALFLIP and -1 or 1))
		end
		if (mo.rgZOffDir >= 180)
			local p = mo.target.player

			local rs = getRingstuff(p)

			S_StartSound(mo.target,rings.usesound)
			
			if (rs.strongermt and (rs.ringsUsed < 5))
				rs.strongermt = false
			end
			
			P_SpawnRingSparkle(mo.target)
			
			if (rs.speedFactor < 3)
				rs.speedFactor = $1 + 1
			end
			rs.timedOut = 0
			p.kartstuff[k_startboost] = $1 + 10
			rs.boost = $1 + 10
			rs.flash = 10
			rs.ringsUsed = $1 + 1
			
			P_RemoveMobj(mo)
		end
	end
end, MT_RINGUSE)

//FOR RING USE: do it based on a number mod 4

addHook("MobjThinker", function(mo)
	local mos = mapobjectscale

	if ((rings.customrgsprite) and (mo.state ~= rings.customrgsprite))
		mo.state = rings.customrgsprite
	end
	
	if (mo.valid)
		if (not P_IsObjectOnGround(mo))
			mo.momz = $1 - ((mos*3)/2)
		else
			if (mo.momz ~= 0)
				mo.momz = 0
				mo.momx = 0
				mo.momy = 0
			end
		end
		if (mo.grabBuffer ~= nil)
			if (mo.grabBuffer > 0)
				mo.grabBuffer = $1 - 1
			else
				if ((mo.flags & MF_SPECIAL) == 0)
					//print("setting special flag")
					mo.flags = $|MF_SPECIAL
				end
			end
		end
		if (mo.target ~= nil)
			local targ = mo.target
			P_InstaThrust(mo,R_PointToAngle2(mo.x,mo.y,targ.x,targ.y),R_PointToDist2(mo.x,mo.y,targ.x,targ.y))
			mo.momz = (((targ.z-(10*mos)) - mo.z)/2)
		end
	end
	//print(mo.grabBuffer)
end, MT_RINGSO)

addHook("MobjThinker", function(mo)
	if (ringsOn == true) and (mo.tracer)
		if (mo.chasetime == nil) then mo.chasetime = 0 else mo.chasetime = $ + 1 end
		
		if (mo.chasetime and (mo.chasetime % 12 == 0))
			local spbring = P_SpawnMobj(mo.x, mo.y, mo.z, MT_RINGSOMAP)
			spbring.colorized = true
			spbring.color = SKINCOLOR_RED
			spbring.extraamt = 1
            spbring.scale = 3*mapobjectscale/2
			spbring.fuse = 20*TICRATE
            spbring.flags = $|MF_NOCLIPHEIGHT
		end
	else
		mo.chasetime = 0
	end
end, MT_SPB)

addHook("MobjThinker", function(mo)
	local mos = mapobjectscale
	if (mo.valid)
		if (not P_IsObjectOnGround(mo))
			mo.momz = $1 - ((mos*3)/2)
		else
			mo.momz = (abs($1)/2)
		end
	end
	//print(mo.grabBuffer)
end, MT_STINGSPIKE)

local function brg_alertVisibilityLogic(p, mo)
	local rs = getRingstuff(p)

	if (ringsting.value == 0)
		mo.flags2 = $ | MF2_DONTDRAW
		return
	else
		if (mo.flags2 & MF2_DONTDRAW)
			mo.flags2 = ($ & ~MF2_DONTDRAW)
		end
	end
	
	if ((p.playerstate ~= PST_DEAD) and (p.kartstuff[k_respawn] <= 1))
		//print((mo.flags & MF2_DONTDRAW))
		if (rs.numRings <= 0)
			if (mo.flags2 & MF2_DONTDRAW)
				mo.flags2 = ($ & ~MF2_DONTDRAW)
			end
		else
			if ((mo.flags2 & MF2_DONTDRAW) == 0)
				mo.flags2 = $ | MF2_DONTDRAW
			end
			return
		end
	end
	
	if (splitscreen == 0)
		if (p == displayplayers[0])
			if ((mo.flags2 & MF2_DONTDRAW) == 0)
				mo.flags2 = $ | MF2_DONTDRAW
			end
			return
		else
			if (mo.flags2 & MF2_DONTDRAW)
				mo.flags2 = ($ & ~MF2_DONTDRAW)
			end
		end
	else
		if (p == displayplayers[0])
			mo.eflags = $|MFE_DRAWONLYFORP2|MFE_DRAWONLYFORP3|MFE_DRAWONLYFORP4
		elseif (p == displayplayers[1])
			mo.eflags = $|MFE_DRAWONLYFORP1|MFE_DRAWONLYFORP3|MFE_DRAWONLYFORP4
		elseif (p == displayplayers[2])
			mo.eflags = $|MFE_DRAWONLYFORP1|MFE_DRAWONLYFORP2|MFE_DRAWONLYFORP4
		elseif (p == displayplayers[3])
			mo.eflags = $|MFE_DRAWONLYFORP1|MFE_DRAWONLYFORP2|MFE_DRAWONLYFORP3
		else
			if (mo.eflags & MFE_DRAWONLYFORP1)
				mo.eflags = $ & ~MFE_DRAWONLYFORP1
			end
			if (mo.eflags & MFE_DRAWONLYFORP2)
				mo.eflags = $ & ~MFE_DRAWONLYFORP2
			end
			if (mo.eflags & MFE_DRAWONLYFORP3)
				mo.eflags = $ & ~MFE_DRAWONLYFORP3
			end
			if (mo.eflags & MFE_DRAWONLYFORP4)
				mo.eflags = $ & ~MFE_DRAWONLYFORP4
			end
		end
	end
	
	/*if (p.playerstate == PST_DEAD)
		mo.flags = $ | MF2_DONTDRAW
	end*/
end

-- Gets the total amount of rings a player holds including rings that are currently still being added.
rawset(_G, "getTotalRings", function (p)
	local rs = getRingstuff(p)

	return rs.numRings + rs.ringsToAward + rs.activeAwardRings
end)

rawset(_G, "doRingAward", function(p, amt,disp)
	local rs = getRingstuff(p)

	if rs.numRings < 0 and ringsting.value == 0 then
		amt = amt * 2
	end

	amt = min(amt, rings.ringcap - getTotalRings(p))

	if amt <= 0 then return end

	rs.ringsToAward = rs.ringsToAward + amt
	if disp then
		K_RingGainEFX(p, amt)
	end
end)

-- Spill players rings. If amount is -1, this will forcefully drop all rings player has
rawset(_G, "doRingSpill", function(p, amount)
	local rs = getRingstuff(p)
	local mo = p.mo

	if not mo then return end

	if not rs.spill then
		local mos = mapobjectscale
		local numRingsDrop = (ringsting.value == 1) and amount or min(amount, rs.numRings)
		local ringSpillAng = 0

		if amount == -1 then numRingsDrop = max(rs.numRings, 0) end

		if numRingsDrop == 0 then return end

		ringSpillAng = (45/numRingsDrop)

		local ringSpawnAng = (ringSpillAng*numRingsDrop)

		local stungAmount = amount

		if rs.bumpspin then
			stungAmount = 1
		end

		if rs.numRings > 0 then
			for i = 1, numRingsDrop do
				local plrRing = P_SpawnMobj(mo.x, mo.y, mo.z+(5*mos), MT_RINGSO)
				plrRing.momx = 9*cos((mo.angle-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1))
				plrRing.momy = 9*sin((mo.angle-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1))
				plrRing.momz = ((14+i)*P_MobjFlip(mo))*mos
				plrRing.fuse = 20*TICRATE
				plrRing.grabBuffer = 7
			end
			rs.numRings = $1 - numRingsDrop
			S_StartSound(mo, rings.spillsound)
		elseif ringsting.value == 1 then
			for i = 1, stungAmount do
				local plrSpike = P_SpawnMobj(mo.x, mo.y, mo.z+(5*mos), MT_STINGSPIKE)
				plrSpike.momx = 9*cos((mo.angle-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1))
				plrSpike.momy = 9*sin((mo.angle-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1))
				plrSpike.momz = (9*sin(((90*ANG1)-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1)))*P_MobjFlip(mo)
				plrSpike.fuse = 26
			end
			rs.numRings = $1 - stungAmount
			S_StartSound(mo,rings.stingsound)
		end

		rs.spill = true
	end
end)

addHook("PlayerSpawn", function(p)
	local rs = getRingstuff(p)

	rs.ringsToAward = 0 -- reset the rings you're getting
	rs.activeAwardRings = 0

	if ((leveltime < TICRATE*6) or (not rs.firstSpawn)) then
		rs.numRings = 5
		rs.firstSpawn = true
	end
end)

addHook("MobjThinker", function(mo)
	local jitter = 6

	if (mo.target)
		local targ = mo.target
		local p = targ.player
		local mos = mapobjectscale
		local finX = targ.x + (P_RandomRange(-jitter, jitter) * mos)
		local finY = targ.y + (P_RandomRange(-jitter, jitter) * mos)
		local finZ = targ.z + ((targ.height*3)/2) + (P_RandomRange(-jitter, jitter) * mos)
		//rgs_hideAlert(mo, p)
		brg_alertVisibilityLogic(p, mo)
		mo.noTargBuffer = 0
		mo.colorized = true
		mo.color = targ.color
		P_SetOrigin(mo,finX,finY,finZ)
		mos = nil
		finX = nil
		finY = nil
		finZ = nil
		if (p.playerstate == PST_DEAD)
			local rs = getRingstuff(p)
			rs.stingAlertMobj = nil
			P_RemoveMobj(mo)
		end
	else
		if (mo.noTargBuffer ~= nil)
			if (mo.noTargBuffer < 3)
				mo.noTargBuffer = $1 + 1
			else
				P_RemoveMobj(mo)
			end
		end
	end
	
	jitter = nil -- LOL DESYNC LOL DESYNC
end, MT_STINGALERT)

local function setRingSounds(mapnum)
	-- why can't S_sfx use freeslots, WHY
	rings.grabsound = sfx_s227
	rings.usesound = sfx_s1ce
	rings.spillsound = sfx_s1c6
	rings.stingsound = sfx_s1a6
	rings.customrgsprite = nil
	
	local customGrab
	local customUse
	local customSpill
	local customSting
	local socSprString = mapheaderinfo[gamemap].ringsprite
	
	if (ringCrossmod.mapSoundData[mapnum])
		customGrab = ringCrossmod.mapSoundData[mapnum][1]
		customUse = ringCrossmod.mapSoundData[mapnum][2]
		customSpill = ringCrossmod.mapSoundData[mapnum][3]
		customSting = ringCrossmod.mapSoundData[mapnum][4]
	end
	
	if (customGrab)
		rings.grabsound = customGrab
	end
	
	if (customUse)
		rings.usesound = customUse
	end
	
	if (customSpill)
		rings.spillsound = customSpill
	end
	
	if (customSting)
		rings.stingsound = customSting
	end
	
	if (socSprString)
		socSprString = string.gsub(socSprString, "SPR_", "") // remove the "sfx_" prefix
	end
	
	local soundsmax = ((#S_sfx)-1)
	local spritesmax = (#sprnames)-1
	local spritelog
	
	for i = 0, spritesmax
		if (sprnames[i] == socSprString)
			spritelog = i // log the ID
			break
		end
	end
	
	if (spritelog)
		for i = 0, (#states - 1)
			if (states[i].sprite == spritelog)
				rings.customrgsprite = i
				print("found state")
				break
			end
		end
	end
end

addHook("MapLoad", function()
	ringsOn = false
	mapRingsPresent = false
	rings.ringcap = cv_ringcap.value
	rings.ringusecap = cv_ringusecap.value
	
	if cv_dorings.value and not G_BattleGametype() then
		ringsOn = true
		--SOC-based adjustment
		setRingSounds(tonumber(gamemap))
		
		if (mapheaderinfo[gamemap].hasrings == "true")
			local rg2_mrNum = tonumber(mapheaderinfo[gamemap].ringrespawntics)
			if (rg2_mrNum ~= nil)
				if (rg2_mrNum > 0)
					cv_mrRespawnTics = rg2_mrNum
				else
					cv_mrRespawnTics = 1 // idiot proofing
					print("\x82".."WARNING: ".."\x80".."MapRings: RingRespawnTics cannot be zero or lower.")
				end
			else
				cv_mrRespawnTics = 10
			end
			
			if (cv_mrRespawnTics % TICRATE != 0)
				local ticString = (cv_mrRespawnTics != 1 and " tics." or " tic.")
				print("\x82".."Ring respawn rate is "..cv_mrRespawnTics..ticString.."\x80")
			else
				if ((cv_mrRespawnTics/TICRATE) == 1)
					print("\x82".."Ring respawn rate is 1 second.".."\x80")
				else
					print("\x82".."Ring respawn rate is "..(cv_mrRespawnTics/TICRATE).." seconds.".."\x80")
				end
			end
			rg2_mrNum = nil
		end
		if not cv_ignoremaprules.value then
			if mapheaderinfo[gamemap].ringcap then
				local num = tonumber(mapheaderinfo[gamemap].ringcap)
			
				if num and num > 0 then
					rings.ringcap = num
					chatprint("\131* Ring cap has been set to the map's ring cap of \x82" .. mapheaderinfo[gamemap].ringcap .. "\131 for this race.", 1)
				else
					rings.ringcap = 1
					print("\x82".."WARNING: ".."\x80".."MapRings: RingCap cannot be zero or lower.")
				end
			end
			
			if mapheaderinfo[gamemap].ringusecap then
				local num = tonumber(mapheaderinfo[gamemap].ringusecap)
			
				if num and num > 0 then
					rings.ringusecap = num
					chatprint("\131* Ring usage cap has been set to the map's usage cap of \x82" .. mapheaderinfo[gamemap].ringusecap .. "\131 for this race.", 1)
				else
					rings.ringusecap = 1
					print("\x82".."WARNING: ".."\x80".."MapRings: RingCap cannot be zero or lower.")
				end
			end
		end
		for p in players.iterate do
			local rs = getRingstuff(p)

			rs.numRings = 5
			rs.stingAlertMobj = nil
		end
		
		--map ring setup
		for mo in thinkers.iterate("mobj") do
			if not mo or not mo.valid continue end

			if (mapheaderinfo[gamemap].hasrings == "true") then
				if (mo.type == MT_SUPERRINGBOX) then
					local replaceRing = P_SpawnMobj(mo.x, mo.y, mo.z, MT_RINGSOMAP)
					mapRingsPresent = true
					replaceRing.ismapring = true
					P_RemoveMobj(mo)
				end
			end
		end
	else
		for p in players.iterate do
			getRingstuff(p).numRings = nil
		end
	end
end)

addHook("NetVars", function(n)
	rings = n($) // netvar for custom sprites and such
	ringCrossmod = n($)
	ringsOn = n($)
	mapRingsPresent = n($)
	cv_mrRespawnTics = n($)
end)

addHook("TouchSpecial", function(mo, t)
	if not ((t) and (t.player)) then
		return true
	end

	local p = t.player

	local rs = getRingstuff(p)

	if not ((rs.numRings ~= nil) and (getTotalRings(p) < rings.ringcap)) then
		return true
	end

	doRingAward(p, 1, true)
end, MT_RINGSO)

addHook("MobjCollide", function(tm, mo)
	if mo and mo.valid then
		if (mo.type == MT_RINGSOMAP) then
			if ((tm) and (tm.player)) then
				local p = tm.player
				local rs = getRingstuff(p)
				
				if ((rs.numRings ~= nil) and (getTotalRings(p) < rings.ringcap)) then
					if (tm.momz < 0) then
						if (tm.z + tm.momz > mo.z + mo.height) then return end
					elseif (tm.z > mo.z + mo.height) then
						return 
					end

					if (tm.momz > 0)
						if (tm.z + tm.height + tm.momz < (mo.z-(mo.height/4))) then return end -- extra leeway
					elseif (tm.z + tm.height < (mo.z-(mo.height/4))) then
						return
					end
					
					if (mo.justTouched == p) then return end -- you already touched this ring get lost!
					
					if not mo.removeTouchLimit then
						doRingAward(p, 1 + (mo.extraamt and mo.extraamt or 0), true)
						mo.justTouched = p
						mo.removeTouchLimit = cv_mrRespawnTics
						
						if ((not mo.ismapring) or (mapheaderinfo[gamemap].noringrespawn == "true")) then
							P_RemoveMobj(mo)
							return
						end
					end
				end
				p = nil
			end
		elseif (mo.type == MT_PLAYER) then
			if ((tm) and (tm.player))
				local p = tm.player
				local rs = getRingstuff(p)
				
				if (tm.momz < 0) then
					if (tm.z + tm.momz > mo.z + mo.height) then return end
				elseif (tm.z > mo.z + mo.height) then
					return 
				end

				if (tm.momz > 0) then
					if (tm.z + tm.height + tm.momz < (mo.z)) then return end
				elseif (tm.z + tm.height < (mo.z)) then
					return
				end
				
				if mo.player and cv_bumploserings.value then
					rs.bumped = mo.player
				end
			end
		end
	end
end, MT_PLAYER)

addHook("MobjThinker", function(mo)
	if not (mo.valid) then return end

	if mo.ismapring then
		if (not mo.gimmeshadow) then
			P_SpawnShadowMobj(mo)
			//print("I'm a map ring")
			mo.gimmeshadow = true
		end
	end
	
	if mo.removeTouchLimit then
		if (mo.state ~= S_INVISIBLE) then mo.state = S_INVISIBLE end
		mo.removeTouchLimit = max($ - 1, 0)
	else
		if ((mo.state ~= S_RINGSO) and (not rings.customrgsprite)) then mo.state = S_RINGSO end
		
		if ((rings.customrgsprite) and (mo.state ~= rings.customrgsprite))
			mo.state = rings.customrgsprite
		end
	end
	
	mo.momx = 0
	mo.momy = 0
	mo.momz = 0
	
    P_MoveOrigin(mo, mo.spawnx, mo.spawny, mo.spawnz) // you STAY PUT dammit
    
	if not (mo.valid) then return end
	
	local jt = mo.justTouched
	if (jt == nil) then return end
	
	local xydist = R_PointToDist2(mo.x,mo.y,jt.mo.x,jt.mo.y)
	local xyzdist = R_PointToDist2(mo.x+mo.y,mo.z,xydist,jt.mo.z)
	if (((xyzdist/155)*10) > ((mo.radius*5)/2))
		mo.justTouched = nil -- player is far away now, don't limit ring collecting
	end
end, MT_RINGSOMAP)

addHook("MobjSpawn", function(mo)
	mo.removeTouchLimit = 0
	mo.spawnx = mo.x
	mo.spawny = mo.y
	mo.spawnz = mo.z
	
end, MT_RINGSOMAP)


rawset(_G, "awardRingsFromObject", function(p, mo,disp)
    local mos = mapobjectscale
    local numRingsDrop = (1+P_RandomKey(2))
    local ringSpillAng = (360/numRingsDrop)
    
    for i = 1, numRingsDrop do
        local boxRing = P_SpawnMobj(mo.x, mo.y, mo.z+(5*mos), MT_RINGSO)
        boxRing.momx = 4*cos(mo.angle+((ringSpillAng*i)*ANG1))
        boxRing.momy = 4*sin(mo.angle+((ringSpillAng*i)*ANG1))
        boxRing.momz = 16*mos
        boxRing.fuse = 20*TICRATE
        boxRing.grabBuffer = 9
    end

	local awardamount = 10
	if p.kartstuff[k_position] == 1 then
		awardamount = 3
	elseif not K_IsPlayerLosing(p) then
		awardamount = 5
	end
	doRingAward(p, awardamount, disp)
end)

addHook("PlayerThink", function(p)
    if not ringsOn then return end
	if mapRingsPresent and cv_allowitembox.value == 0 then return end
    if not p.mo then return end
    
    if p.kartstuff[k_itemroulette] and not p.lastitemroulette and p.kartstuff[k_roulettetype] ~= 2 then
         awardRingsFromObject(p, p.mo,1)
    end
    
    p.lastitemroulette = p.kartstuff[k_itemroulette]
end)

addHook("PlayerSpin", function(p, inflictor)
	if not ringsOn then return end

	local amount

    local SPIN_AMOUNT = {
        [MT_BANANA] = 3,
        [MT_BANANA_SHIELD] = 3,
        [MT_ORBINAUT] = 5,
        [MT_ORBINAUT_SHIELD] = 5,
        [MT_JAWZ] = 5,
        [MT_JAWZ_DUD] = 5,
        [MT_JAWZ_SHIELD] = 5,
        [MT_BALLHOG] = 3,
        [MT_SPB] = 3,
        [MT_SPBEXPLOSION] = 5,
        [MT_MINEEXPLOSION] = 5,
        [MT_SSMINE] = 5,
        [MT_SSMINE_SHIELD] = 5,
    }

	if inflictor then
		if inflictor.type == MT_BANANA and inflictor.health > 1 then
			amount = 10
		elseif inflictor.type == MT_SPBEXPLOSION and not inflictor.extavalue1 then
			amount = 3
		elseif SPIN_AMOUNT[inflictor.type] then
			amount = SPIN_AMOUNT[inflictor.type]
		else
			if inflictor.player then
				if inflictor.player.kartstuff[k_invincibilitytimer] then
					amount = 5
				elseif inflictor.player.kartstuff[k_curshield] == 1 then
					amount = 3
				end
			else
				amount = 3
			end
		end
	else
		amount = 3
	end

	doRingSpill(p, amount)
end)

addHook("PlayerExplode", function(p, inflictor)
	if not ringsOn then return end
	if not inflictor then return end

	-- Mines and SPBs explosions
	local amount = 10

    if inflictor.type == MT_SPBEXPLOSION and not inflictor.extravalue1 then
        amount = 5 -- Eggman monitor explision
	end

	doRingSpill(p, amount)
end)

addHook("PlayerSquish", function(p, inflictor)
	if not ringsOn then return end
	if not inflictor then return end

    doRingSpill(p, inflictor and 5 or 3)
end)

addHook("MobjDamage", function(victim_mo, inflictor)
	if not ringsOn then return end
	if not (inflictor and victim_mo.player) then return end

    if inflictor.type == MT_SINK then
		doRingSpill(victim_mo.player, -1)
    end
end, MT_PLAYER)


local function fuseFlash(mo)
    if not (mo and mo.valid) then return end
	if mo.fuse <= 0 then return end

    if mo.fuse < 2*TICRATE then
        if mo.fuse % 2 == 0 then
            mo.flags2 = $ | MF2_DONTDRAW
        else
            mo.flags2 = $ & ~MF2_DONTDRAW
        end
    end
end

addHook("MobjThinker", fuseFlash, MT_RINGSO)
addHook("MobjThinker", fuseFlash, MT_RINGSOMAP)

hud.add(drawRingHud)
hud.add(drawRingTutorial)
