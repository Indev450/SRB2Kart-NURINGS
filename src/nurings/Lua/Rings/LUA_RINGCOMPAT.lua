-- Allow rings to extend sneaker if you use a different stacking system that doesn't allow startboost to extend sneakers

local cv_ringextend = CV_RegisterVar({
    name = "ringssneakerextend",
    defaultvalue = "Off",
    possiblevalue = CV_OnOff,
    flags = CV_NETVAR,
})

local function getRingstuff(p)
	if not p.ringstuff then
		p.ringstuff = {}
	end

	return p.ringstuff
end

addHook("PlayerThink", function(p)
    if not ringsOn then return end
	if not cv_ringextend.value return end
		
	local rs = getRingstuff(p)
	
	if rs.lfstartboost then
		if rs.lfsneakertimer then
			p.kartstuff[k_sneakertimer] = max(p.kartstuff[k_sneakertimer],1)
		end
	end

	rs.lfstartboost = p.kartstuff[k_startboost]
	rs.lfsneakertimer = p.kartstuff[k_sneakertimer]
end)