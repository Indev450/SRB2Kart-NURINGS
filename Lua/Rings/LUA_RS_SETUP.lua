// freeslots and thinker for the sparkles

freeslot("SPR_RGSB", "SPR_RGSS", "MT_RINGSPARKLE");

freeslot(
	"S_RNGSPARK1",
	"S_RNGSPARK2",
	"S_RNGSPARK3",
	"S_RNGSPARK4",
	"S_RNGSPARK5",
	"S_RNGSPARK6",
	"S_RNGSPARK7",
	"S_RNGSPARK8",
	"S_RNGSPARK9",
	"S_RNGSPRK10",
	"S_RNGSPRK11"
)


// set up myriad of states
states[S_RNGSPARK1] = {SPR_RGSB, A|FF_FULLBRIGHT|FF_PAPERSPRITE|FF_ANIMATE, 8, nil, 3, 1, S_RNGSPARK5}
states[S_RNGSPARK2] = {SPR_RGSB, B|FF_FULLBRIGHT|FF_PAPERSPRITE, 1, nil, 0, 0, S_RNGSPARK3}
states[S_RNGSPARK3] = {SPR_RGSB, C|FF_FULLBRIGHT|FF_PAPERSPRITE, 1, nil, 0, 0, S_RNGSPARK4}
states[S_RNGSPARK4] = {SPR_RGSB, D|FF_FULLBRIGHT|FF_PAPERSPRITE, 1, nil, 0, 0, S_RNGSPARK5}
states[S_RNGSPARK5] = {SPR_RGSB, A|FF_FULLBRIGHT|FF_PAPERSPRITE, 1, nil, 0, 0, S_RNGSPARK6}
states[S_RNGSPARK6] = {SPR_RGSB, B|FF_FULLBRIGHT|FF_PAPERSPRITE, 1, nil, 0, 0, S_RNGSPARK7}
states[S_RNGSPARK7] = {SPR_RGSS, C|FF_FULLBRIGHT|FF_PAPERSPRITE, 1, nil, 0, 0, S_RNGSPARK8}
states[S_RNGSPARK8] = {SPR_RGSS, D|FF_FULLBRIGHT|FF_PAPERSPRITE, 1, nil, 0, 0, S_RNGSPARK9}
states[S_RNGSPARK9] = {SPR_RGSS, A|FF_FULLBRIGHT|FF_PAPERSPRITE, 1, nil, 0, 0, S_RNGSPRK10}
states[S_RNGSPRK10] = {SPR_RGSS, B|FF_FULLBRIGHT|FF_PAPERSPRITE, 1, nil, 0, 0, S_RNGSPRK11}
states[S_RNGSPRK11] = {SPR_RGSS, E|FF_FULLBRIGHT|FF_PAPERSPRITE, 1, nil, 0, 0, S_NULL}

mobjinfo[MT_RINGSPARKLE] = {
	doomednum = -1,
	spawnstate = S_RNGSPARK1,
	spawnhealth = 1000,
	radius = 19*FRACUNIT,
	height = 40*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOCLIPTHING|MF_NOGRAVITY|MF_DONTENCOREMAP
}

addHook("MobjThinker", function(mo)
	mo.momz = ($ - ((12*mo.scale)/10));
end, MT_RINGSPARKLE)

local function flipFromObject(mo, master)
	mo.eflags = (mo.eflags & ~MFE_VERTICALFLIP)|(master.eflags & MFE_VERTICALFLIP);
	mo.flags2 = (mo.flags2 & ~MF2_OBJECTFLIP)|(master.flags2 & MF2_OBJECTFLIP);

	if (mo.eflags & MFE_VERTICALFLIP)
		mo.z = $1 + master.height - FixedMul(master.scale, mo.height)
	end
end

local function matchGenericExtraFlags(mo, master)
	// flipping
	// handle z shifting from there too. This is here since there's no reason not to flip us if needed when we do this anyway;
	flipFromObject(mo, master);

	// visibility (usually for hyudoro)
	mo.flags2 = (mo.flags2 & ~MF2_DONTDRAW)|(master.flags2 & MF2_DONTDRAW);
	mo.eflags = (mo.eflags & ~MFE_DRAWONLYFORP1)|(master.eflags & MFE_DRAWONLYFORP1);
	mo.eflags = (mo.eflags & ~MFE_DRAWONLYFORP2)|(master.eflags & MFE_DRAWONLYFORP2);
	mo.eflags = (mo.eflags & ~MFE_DRAWONLYFORP3)|(master.eflags & MFE_DRAWONLYFORP3);
	mo.eflags = (mo.eflags & ~MFE_DRAWONLYFORP4)|(master.eflags & MFE_DRAWONLYFORP4);
end

rawset(_G, "P_SpawnRingSparkle", function(mo)
	local newx //fixed_t
	local newy //fixed_t
	
	local nmomx
	local nmomy
	
	local spark //mobj_t
	local travelangle //angle_t
	local turnangle;
	
	if ((not mo and mo.valid)) then return end

	travelangle = mo.angle;
	
	if (mo.player)
		turnangle = ((mo.player.cmd.driftturn >= 0) and 1 or -1);
	else
		turnangle = 1;
	end
	

	newx = mo.x + P_ReturnThrustX(mo, travelangle + (turnangle*ANGLE_90), FixedMul(24*FRACUNIT, mo.scale));
	newy = mo.y + P_ReturnThrustY(mo, travelangle + (turnangle*ANGLE_90), FixedMul(24*FRACUNIT, mo.scale));
	spark = P_SpawnMobj(newx, newy, mo.z+mo.height, MT_RINGSPARKLE);

	spark.angle = travelangle+(turnangle*ANGLE_90);
	spark.destscale = ((5*mo.scale)>>2)
	P_SetScale(spark, (spark.destscale));

		//P_InstaThrust(spark, travelangle+(turnangle*ANGLE_90), FixedMul(2*FRACUNIT, mo.scale));
	nmomx = FixedMul(8*cos(travelangle+(turnangle*ANGLE_90)), mo.scale);
	nmomy = FixedMul(8*sin(travelangle+(turnangle*ANGLE_90)), mo.scale);
		
	spark.momx = mo.momx + nmomx;
	spark.momy = mo.momy + nmomy;
		
		
	spark.momz = (mo.momz)+(((96*mo.scale)/10)*P_MobjFlip(mo));
		
	matchGenericExtraFlags(spark, mo);
end)
