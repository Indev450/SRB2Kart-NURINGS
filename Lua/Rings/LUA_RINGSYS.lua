--Rings original by unknown
--Stuff rewritten and modified by NepDisk and Indev

freeslot("SPR_RNGS", "SPR_RGFD", "S_RINGSO", "S_V2RFDE", "S_USERNG", "MT_RINGSO", "MT_RINGSOMAP", "MT_RINGGET", "MT_RINGUSE","MT_RINGPOINT")

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

-- colorize sticker
local cv_colorizeringbar = CV_RegisterVar({
	name = "ring_barcolourize",
	defaultvalue = "Off",
	flags = CV_SHOWMODIF,
	possiblevalue = CV_OnOff,
}) -- colorize sticker, reversed if client suppors colorized hud

local cv_ringbarx = CV_RegisterVar({
    name = "ring_barxoffset",
    defaultvalue = "0",
    flags = CV_SHOWMODIF,
}) -- bar x offset

local cv_ringbary = CV_RegisterVar({
    name = "ring_baryoffset",
    defaultvalue = "0",
    flags = CV_SHOWMODIF,
}) -- bar y offset
 
COM_AddCommand("ring_button", function(p, bname)
    local buttonnames = {
        [BT_ATTACK] = "item",
        [BT_CUSTOM1] = "custom 1",
        [BT_CUSTOM2] = "custom 2",
        [BT_CUSTOM3] = "custom 3",
    }

    if not bname then
        local button = buttonnames[p.ringButton or BT_ATTACK]
        
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
    
    p.ringButton = button
    
    CONS_Printf(p, "Set ring use button to \131"..buttonnames[p.ringButton or BT_ATTACK])
end)

COM_AddCommand("ring_itemcheck", function(p, docheck)
    if not docheck then
        CONS_Printf(p, "Item check for ring use is "..(p.ringNoItemCheck and "\133disabled" or "\131enabled"))
        return
    end

    local itemCheck = {
        yes = true,
        ["1"] = true,
        on = true,
    }
    
    p.ringNoItemCheck = not itemCheck[docheck:lower()]
    
    CONS_Printf(p, "Item check for ring use is "..(p.ringNoItemCheck and "\133disabled" or "\131enabled"))
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
	spawnstate = S_INVISIBLE,
	spawnhealth = 1000,
	radius = 8*FRACUNIT,
	height = 8*FRACUNIT,
	displayoffset = -1,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_DONTENCOREMAP
	
}


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

local intToBattlePointState = {
	S_BATTLEPOINT1A,
	S_BATTLEPOINT2A,
	S_BATTLEPOINT3A,
	S_BATTLEPOINT4A,
	S_BATTLEPOINT5A,
	S_BATTLEPOINT6A,
	S_BATTLEPOINT7A,
	S_BATTLEPOINT8A,
	S_BATTLEPOINT9A,
	S_BATTLEPOINT10A,
}

local function spawnRingPoint(source, amount)
	source.ringpt = P_SpawnMobj(source.mo.x, source.mo.y, source.mo.z, MT_RINGPOINT)
	source.ringpt.target = source.mo
	source.ringpt.state = intToBattlePointState[amount]
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
			source.ringpt.target = nil
			spawnRingPoint(source, source.ringpt.ringCount + amount - 10)
			return
		end

		source.ringpt.ringCount = source.ringpt.ringCount + amount
		source.ringpt.state = intToBattlePointState[source.ringpt.ringCount]

		return
	end

	spawnRingPoint(source, amount)
end

addHook("MobjThinker", function(mo)
	if not ringsOn return end
	if not (mo and mo.valid and mo.target and mo.target.valid) then return end
	K_MatchGenericExtraFlags(mo, mo.target)
	if (mo.target.player != thisplayer and (not splitscreen)) then mo.flags2 = $|MF2_DONTDRAW else mo.flags2 = $&(~MF2_DONTDRAW) end
	
	if (mo.movefactor < 48*mo.target.scale)
		
		mo.movefactor = $ + (48*mo.target.scale)/6
			if (mo.movefactor > mo.target.height)
				mo.movefactor = mo.target.height
			end
			
	elseif (mo.movefactor > 48*mo.target.scale)
		mo.movefactor =  $ - (48*mo.target.scale)/6
			if (mo.movefactor < mo.target.height)
				mo.movefactor = mo.target.height
			end
	end
	P_MoveOrigin(mo, mo.target.x, mo.target.y, mo.target.z + (mo.target.height/2)*P_MobjFlip(mo.target) + mo.movefactor)
end, MT_RINGPOINT)


local cv_colorizedhud, cv_colorizedhudcolor, cv_kartdisplayspeed

local function drawRingHud(v, p)
	--Checks
	if not ringsOn return end
	if not (p.mo and p.mo.valid) then return end
	
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
	
	local plrRings = p.numRings
	
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
	
	--Flags
	local vflags = V_HUDTRANS
	local flags  = V_HUDTRANS
		
	--Actually draw the hud
	if (ringHud) then
		v.draw((11-(rgHudOffset+ssxoffset))-left+cv_ringbarx.value, spRgHudYOff+ssyoffset+windiff+cv_ringbary.value, ringHud, vflags,cmap)
	end
	
	--Negative sign
	if (plrRings < 0) then
		v.draw((6-(rgHudOffset))-left+cv_ringbarx.value, (spRgHudYOff+ssyoffset+6)+windiff+cv_ringbary.value, negaSign, flags)
	end
	
	--If you have an spb on your tail or use too many rings show that your rings are locked.
	if (p.rgUsed and p.rgUsed > rings.ringusecap) then
		v.draw((9-(rgHudOffset+ssxoffset))-left+cv_ringbarx.value, spRgHudYOff+ssyoffset+windiff-1+cv_ringbary.value, ringLock, vflags)
	end
		
	--Number drawing	
	v.draw((13-(rgHudOffset+ssxoffset))-left+cv_ringbarx.value, (spRgHudYOff+ssyoffset+6)+windiff+cv_ringbary.value, v.cachePatch(font.."0"..nums[1]), flags)
	v.draw((19-(rgHudOffset+ssxoffset))-left+cv_ringbarx.value, (spRgHudYOff+ssyoffset+6)+windiff+cv_ringbary.value, v.cachePatch(font.."0"..nums[2]), flags)
				
	--For loop to draw bars on ring meter
	for i = 1,min(plrRings,20)
		v.draw((30-(rgHudOffset+ssxoffset))-left + ( 2 * i)+cv_ringbarx.value, spRgHudYOff+ssyoffset+windiff+6+cv_ringbary.value, yellowBar, vflags)
	end
	
	--Check for negative rings todo ringsting stuff
	if plrRings < 0 then
		for n = -1,max(plrRings,-20),-1
			if sting then v.draw((30-(rgHudOffset+ssxoffset))-left + ( 2 * n * -1)+cv_ringbarx.value, spRgHudYOff+ssyoffset+windiff+6+cv_ringbary.value, redBar, vflags) end
		end
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
		
		local dontBoost = ((not P_IsObjectOnGround(mo)) or p.kartstuff[k_rocketsneakertimer])
		
		if (p.rgSetUp ~= true)
			p.numRings = 5 -- start the player off with 5 rings
			p.ringsToAward = 0
			p.rgAtkDownTime = 0
			p.rgTimedOut = 0
			p.spillRefuseDelay = 0
			p.rgs_bumpspin = false
			p.ringSpill = false
			p.rgSpeedFactor = 0
			p.rgTimedOut = 0 -- player runs out of "ring juice"
			p.rgUsed = 0 -- can't use any more than 10 rings
			p.ringAwardTimer = 0 -- increment when you have rings being awarded
			p.ringBoost = 0
			p.rgSetUp = true
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
		
		if ((p.stingAlertMobj == nil) and (spawnTimer <= 1) and (mo.justSpawnedBuffer <= 0))
			p.stingAlertMobj = P_SpawnMobj(mo.x,mo.y,mo.z+mo.height,MT_STINGALERT) -- "!" icon for when you have 0- rings with ring sting on
			p.stingAlertMobj.target = mo
		end
		
		if ((ringsting.value == 0) and (p.numRings < 0))
			p.numRings = 0 -- reset to 0
		end
		
		if (p.ringBoost)
			p.ringBoost = ($ - 1)
			p.kartstuff[k_offroad] = 0
		end
		
		local starTimer = p.kartstuff[k_invincibilitytimer]
		local growTimer = p.kartstuff[k_growshrinktimer]
		
		local inInvinc = (starTimer or growTimer)
		
		if (p.ringFlash)
			p.ringFlash = ($ - 1)
			
			if ((p.ringFlash > 0) and (not inInvinc) ) //stars and growth already colorize you
				mo.colorized = ((p.ringFlash % 2 == 0) and true or false)
			end
			
			if ((p.ringFlash == 1) and (not inInvinc))
				mo.colorized = false // un-colorize yourself
			end
		end
		
		
		
		if ((bumped) and (starTimer <= 1) and (growTimer == 0) and (p.rgBumpDrop ~= true) and (p.numRings > 0) and (p.v2r_bumped))
			local mos = mapobjectscale
			local bumpRings = ((p.speed/mos)/20)
			
			if ((bumpRings == 0) and (starTimer <= 1) and (growTimer == 0)) then bumpRings = 1 end
			
			local ringSpillAng = (45/bumpRings)
				
			local ringSpawnAng = (ringSpillAng*bumpRings)
			if (p.numRings > 0)
				for i = 1, bumpRings
					local plrRing = P_SpawnMobj(mo.x, mo.y, mo.z+(5*mos), MT_RINGSO)
					plrRing.momx = 9*cos((mo.angle-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1))
					plrRing.momy = 9*sin((mo.angle-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1))
					plrRing.momz = ((14+i)*P_MobjFlip(mo))*mos
					plrRing.fuse = 20*TICRATE
					plrRing.grabBuffer = 45
					p.numRings = $1 - 1
				end
			end
			mos = nil
			ringSpillAng = nil
			ringSpawnAng = nil
			bumpRings = nil
			p.rgBumpDrop = true
		end
		
		if (not bumped)
			p.rgBumpDrop = false
			p.v2r_bumped = nil
		end
		
		if ((ringsting.value == 1))
			
			if (p.numRings < -10)
				p.numRings = -10
			end
			
			
			
			if ((bumped) and (p.numRings <= 0) and (p.rgs_bumpspin == false) and (p.rgBumpDrop == false))
					if ((starTimer <= 1) and (growTimer == 0))
						p.kartstuff[k_spinouttimer] = $1 + 10
						if ((v2hitlag) and (v2hitlag.value))
							BLHL_doHitlag(p,0,0)
						end
					end
				if (hitfeed) then
					local plr = rgs_generateHFForPlayer(p)
					HF_SendHitMessage(nil, plr, "HFRSTNG")
					plr = nil
				end
				
				p.rgs_bumpspin = true
			end
			
			
			if ((p.rgs_bumpspin == true) and (spinTimer <= 0))
				p.rgs_bumpspin = false
			end
		end
		
		starTimer = nil
		growTimer = nil
		
		if (dfBoost == 0)
			p.rgSpeedFactor = 0
			p.rgUsed = 0
			if (p.rgTimedOut < 18)
				p.rgTimedOut = $1 + 1
			end
		end
		
		if (p.ringsToAward ~= nil)
			if (p.ringsToAward > 0)
				p.ringAwardTimer = $1 + 1
				if ((p.ringAwardTimer % 4) == 0)
					local mos = mapobjectscale
					local awardRing = P_SpawnMobj(mo.x, mo.y, mo.z+(24*mos), MT_RINGGET)
					awardRing.target = mo
					p.ringsToAward = $1 - 1
				end
			elseif (p.ringAwardTimer > 0)
				p.ringAwardTimer = 0
			end
		end
        
        local BT_USERING = p.ringButton or BT_ATTACK
        local itemCheck = p.ringNoItemCheck or BT_USERING ~= BT_ATTACK or (p.kartstuff[k_itemroulette] == 0) and (p.kartstuff[k_itemamount] <= 0)
        local spinCheck = P_PlayerInPain(p) or p.kartstuff[k_spinouttimer] or p.kartstuff[k_wipeoutslow]
        
		if ((p.cmd.buttons & BT_USERING) and not (p.kartstuff[k_growshrinktimer] > 0))
			p.rgAtkDownTime = $1 + 1
		else
			p.rgAtkDownTime = -10 -- preventing instant use after using an item
		end
        
		if ((p.cmd.buttons & BT_USERING) and itemCheck and (not spinCheck) and (((p.rgAtkDownTime % 4) == 0))  and (p.rgAtkDownTime >= 0) and (leveltime >= 268))
			local mos = mapobjectscale
			if ((p.numRings > 0) and (not dontBoost) and (p.rgUsed <= rings.ringusecap))
				local useRing = P_SpawnMobj(mo.x, mo.y, mo.z+(24*mos), MT_RINGUSE)
				useRing.target = mo
				p.numRings = $1 - 1
			end
		end
		
		if ((spinTimer == 0) and (flatTimer == 0))
			p.ringSpill = false
			if (p.spillRefuseDelay > 0)
				p.spillRefuseDelay = $1 - 1
			else
				p.nospill = false
			end
		else
			if (p.ringSpill ~= true)
				local mos = mapobjectscale
				local numRingsDrop = 1
				local ringSpillAng = 0
				
				if (p.numRings > 5)
					numRingsDrop = 5
				elseif (p.numRings > 0)
					numRingsDrop = p.numRings
				end
				
				ringSpillAng = (45/numRingsDrop)
				
				local ringSpawnAng = (ringSpillAng*numRingsDrop)
				
				local stungAmount = 5
				
				if (p.rgs_bumpspin == true)
					stungAmount = 1
				end
				
				if (p.nospill ~= true)
					if (p.numRings > 0)
						S_StartSound(mo,rings.spillsound)
						for i = 1, numRingsDrop
							local plrRing = P_SpawnMobj(mo.x, mo.y, mo.z+(5*mos), MT_RINGSO)
							plrRing.momx = 9*cos((mo.angle-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1))
							plrRing.momy = 9*sin((mo.angle-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1))
							plrRing.momz = ((14+i)*P_MobjFlip(mo))*mos
							plrRing.fuse = 20*TICRATE
							plrRing.grabBuffer = 45
							p.numRings = $1 - 1
						end
					else
						if (ringsting.value == 1)
							for i = 1, stungAmount
								local plrSpike = P_SpawnMobj(mo.x, mo.y, mo.z+(5*mos), MT_STINGSPIKE)
								plrSpike.momx = 9*cos((mo.angle-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1))
								plrSpike.momy = 9*sin((mo.angle-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1))
								plrSpike.momz = (9*sin(((90*ANG1)-(ringSpawnAng*ANG1))+((ringSpillAng*i)*ANG1)))*P_MobjFlip(mo)
								plrSpike.fuse = 26
							end
							p.numRings = $1 - stungAmount
							S_StartSound(mo,rings.stingsound)
						end
					end
				end
				
				p.ringSpill = true
			end
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
			
			S_StartSound(mo.target,rings.grabsound)
			if (p.numRings < rings.ringcap)
				p.numRings = $1 + 1
			end
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
			S_StartSound(mo.target,rings.usesound)
			
			if (p.strongermt and (p.rgUsed < 5))
				p.strongermt = false
			end
			
			P_SpawnRingSparkle(mo.target)
			
			if (p.rgSpeedFactor < 3)
				p.rgSpeedFactor = $1 + 1
			end
			p.rgTimedOut = 0
			p.kartstuff[k_startboost] = $1 + 10
			p.ringBoost = $1 + 10
			p.ringFlash = 10
			p.rgUsed = $1 + 1
			
			p = nil
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
            spbring.scale = 3*FRACUNIT/2
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
	if (ringsting.value == 0)
		mo.flags = $ | MF2_DONTDRAW
		return
	else
		if (mo.flags & MF2_DONTDRAW)
			mo.flags = ($ & ~MF2_DONTDRAW)
		end
	end
	
	if ((p.playerstate ~= PST_DEAD) and (p.kartstuff[k_respawn] <= 1))
		//print((mo.flags & MF2_DONTDRAW))
		if (p.numRings <= 0)
			if (mo.flags & MF2_DONTDRAW)
				mo.flags = ($ & ~MF2_DONTDRAW)
			end
		else
			if ((mo.flags & MF2_DONTDRAW) == 0)
				mo.flags = $ | MF2_DONTDRAW
			end
			return
		end
	end
	
	if (splitscreen == 0)
		if (p == displayplayers[0])
			if ((mo.flags & MF2_DONTDRAW) == 0)
				mo.flags = $ | MF2_DONTDRAW
			end
			return
		else
			if (mo.flags & MF2_DONTDRAW)
				mo.flags = ($ & ~MF2_DONTDRAW)
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

rawset(_G, "doRingAward", function(p, amt,disp)
	if (p.numRings < rings.ringcap)
		if ((p.numRings + amt) <= rings.ringcap)
			if (ringsting.value == 0)
				p.ringsToAward = $1 + amt
				if disp
					K_RingGainEFX(p,amt)
				end
			else
				if (p.numRings >= 0)
					p.ringsToAward = $1 + amt
					if disp
						K_RingGainEFX(p,amt)
					end
				else
					p.ringsToAward = $1 + (amt*2)
					if disp
						K_RingGainEFX(p,amt*2)
					end
				end
			end
		else
			p.ringsToAward = $1 + (rings.ringcap - p.numRings)
			if disp
				K_RingGainEFX(p,(rings.ringcap - p.numRings))
			end
		end
	end
end)

addHook("PlayerSpawn", function(p)
	p.ringsToAward = 0 // reset the rings you're getting

	if ((leveltime < TICRATE*6) or (not p.firstSpawn))
		p.numRings = 5
		p.firstSpawn = true
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
		brg_alertVisibilityLogic(mo.target.player, mo)
		mo.noTargBuffer = 0
		mo.colorized = true
		mo.color = targ.color
		P_SetOrigin(mo,finX,finY,finZ)
		mos = nil
		finX = nil
		finY = nil
		finZ = nil
		if (mo.target.player.playerstate == PST_DEAD)
			mo.target.player.stingAlertMobj = nil
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
	// why can't S_sfx use freeslots, WHY
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
		for p in players.iterate
			if ((p.mo) and (p.mo.valid))
				//local actor = p.mo // too lazy to not make a macro
				//local testing = P_SpawnMobj(actor.x, actor.y, actor.z, MT_RINGSO)
				p.numRings = 5
				p.stingAlertMobj = nil
			end
		end
		
		--map ring setup
		for mo in thinkers.iterate("mobj") do
			if not mo or not mo.valid continue end
			
			
			if (mapheaderinfo[gamemap].hasrings == "true")
				if (mo.type == MT_SUPERRINGBOX)
					local replaceRing = P_SpawnMobj(mo.x, mo.y, mo.z, MT_RINGSOMAP)
					mapRingsPresent = true
					replaceRing.ismapring = true
					P_RemoveMobj(mo)
				end
				
				
			end
		end
	else
		for p in players.iterate
			if ((p.mo) and (p.mo.valid))
				p.numRings = nil
			end
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
	if ((t) and (t.player))
		local p = t.player
		if ((p.numRings ~= nil) and (p.numRings < rings.ringcap))
			doRingAward(p, 1, true)
		end
		p = nil
	end
end, MT_RINGSO)

addHook("MobjCollide", function(tm, mo)
	if mo and mo.valid then
		if (mo.type == MT_RINGSOMAP)
			if ((tm) and (tm.player))
				local p = tm.player
				
				if ((p.numRings ~= nil) and (p.numRings < rings.ringcap))
					if (tm.momz < 0)
						if (tm.z + tm.momz > mo.z + mo.height) then return end
					elseif (tm.z > mo.z + mo.height) 
						return 
					end

					if (tm.momz > 0)
						if (tm.z + tm.height + tm.momz < (mo.z-(mo.height/4))) then return end -- extra leeway
					elseif (tm.z + tm.height < (mo.z-(mo.height/4)))
						return
					end
					
					if (mo.justTouched == p) then return end -- you already touched this ring get lost!
					
					if (mo.removeTouchLimit <= 0)
						doRingAward(p, 1 + (mo.extraamt and mo.extraamt or 0), true)
						mo.justTouched = p
						mo.removeTouchLimit = cv_mrRespawnTics
						
						if ((not mo.ismapring) or (mapheaderinfo[gamemap].noringrespawn == "true"))
							P_RemoveMobj(mo)
							return
						end
					end
				end
				p = nil
			end
		elseif (mo.type == MT_PLAYER)
			if ((tm) and (tm.player))
				local p = tm.player
				
				if (tm.momz < 0)
					if (tm.z + tm.momz > mo.z + mo.height) then return end
				elseif (tm.z > mo.z + mo.height) 
					return 
				end

				if (tm.momz > 0)
					if (tm.z + tm.height + tm.momz < (mo.z)) then return end
				elseif (tm.z + tm.height < (mo.z))
					return
				end
				
				if (mo.player)
					p.v2r_bumped = mo.player
				end
			end
		end
	end
end, MT_PLAYER)

addHook("MobjThinker", function(mo)
	if not (mo.valid) then return end

	if mo.ismapring then
		if (not mo.gimmeshadow)
			P_SpawnShadowMobj(mo)
			//print("I'm a map ring")
			mo.gimmeshadow = true
		end
	end
	
	if (mo.removeTouchLimit > 0)
		if (mo.state ~= S_INVISIBLE) then mo.state = S_INVISIBLE end
		mo.removeTouchLimit = $1 - 1
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
    if p.numRings < rings.ringcap then
        local awardamount = 10
        
        if p.kartstuff[k_position] == 1 then
            awardamount = 3
        elseif not K_IsPlayerLosing(p) then
            awardamount = 5
        end
    
        if (p.numRings + awardamount) <= rings.ringcap then
            if ringsting.value == 0 then
                p.ringsToAward = $1 + awardamount
				if disp
					K_RingGainEFX(p,awardamount)
				end
            else
                if (p.numRings >= 0)
                    p.ringsToAward = $1 + awardamount
					if disp
						K_RingGainEFX(p,awardamount)
					end
                else
                    p.ringsToAward = $1 + awardamount*2
					if disp
						K_RingGainEFX(p,awardamount*2)
					end
                end
            end
        else
            p.ringsToAward = $1 + (rings.ringcap - p.numRings)
			if disp
				K_RingGainEFX(p,(rings.ringcap - p.numRings))
			end
        end
    end
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

--[[
addHook("MobjDeath", function(mo, i, src)
	if ((ringsOn == true)
	if mapRingsPresent and cv_allowitembox.value == 0 then return end
		if (mo and mo.valid and (mo.type == MT_RANDOMITEM) and i and (i.valid) and (i == src) and (i.health) and i.player)
			local p = i.player
			
            awardRingsFromObject(p, mo)
		end
	end
end)

addHook("TouchSpecial", function(mo, pmo)
    if ringsOn and pmo.player and P_CanPickupItem(pmo.player, 1) then
		if mapRingsPresent and cv_allowitembox.value == 0 then return end
        -- Declare here because some of things (like MT_RANDOMITEMBOX) may not exist at script load yet
        local AWARDRINGMOBJS = {
            [MT_CDUFO] = true,
            [dynamicitems_initialized and MT_RANDOMITEMBOX or -1] = true,
        }
    
        if mo and mo.valid and AWARDRINGMOBJS[mo.type] then
            awardRingsFromObject(pmo.player, mo)
        end
    end
end)
--]]

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

hud.add(drawRingHud, game)
