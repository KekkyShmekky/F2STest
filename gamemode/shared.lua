--[[

	Digital Insanity/DI/Spirit:
	
		Андрей, если ты это читаешь, выйди из моего кода
		И вернись к работе по сосанию хуев :v
]]

GM.Name 	= 'F2S: Classic'
GM.Author 	= 'NanoCat'
GM.Email 	= ''
GM.Website 	= ''
GM.Weather	= 0
GM.WindDir	= Vector()

--[[ Credits:
	
	NanoCat
	Dark Herald
	ώħèâţļèy
	Python1320
	CapsAdmin
	CSPSpy
	Capster
	
	Digital Insanity
	
]]

TEAM_CONNECTING = -1
BULLET_SPEED = 10240

WEATHER_NORMAL = 0
WEATHER_RAIN = 1

local f2s_physbullets = CreateConVar( 'f2s_physbullets', 1, bit.bor( FCVAR_REPLICATED, FCVAR_ARCHIVE ) )
local ammos =
{
	'frag_grenade',
	'machinegun',
	'medpack',
	'buzzsaw',
	'tripmine',
	'sentry',
	'5.45x39mm',
	'5.56x45mm NATO',
	'40x60 grenade',
	'.45 ACP',
	'HK 4.6x30mm',
	'308'
}

local bullets = {}

for _, v in pairs( ammos ) do
	game.AddAmmoType( {
		name		= v,
		dmgtype 	= 0,
		force 		= 0,
		maxsplash 	= 0,
		minsplash 	= 0,
		npcdmg 		= 0,
		plydmg 		= 0,
		tracer 		= 0
	} )
end

GM.Ammo		=
{	
	frag_grenade = { 'Grenades', 1, 60, 5 },
	medpack = { 'Medkits', 1, 15, 3 },
	buzzsaw = { 'Buzzsaws', 1, 800, 1 },
	tripmine = { 'Trip mines', 1, 110, 8 },
	sentry = { 'Sentries', 1, 1000, 1 },
	machinegun = { '7.62x51mm NATO', 200, 350, 1000 },
	
	[ '5.45x39mm' ] = { '5.45x39mm', 45, 40 },
	[ '5.56x45mm NATO' ] = { '5.56x45mm NATO', 45, 55 },
	[ '40x60 grenade' ] = { '40x60 grenade', 1, 70, 20 },
	[ '357' ] = { '.357 magnum', 6, 12, 36 },
	[ '308' ] = { '.308 magnum', 10, 15, 50 },
	[ '.45 ACP' ] = { '.45 ACP', 15, 20, 250 },
	[ 'HK 4.6x30mm' ] = { 'HK 4.6x30mm', 45, 50 },
	
	ar2altfire = { 'Dark energy balls', 1, 120, 5 },
	ar2 = { 'Dark energy', 30, 90, 300 },
	buckshot = { '12 gauge', 10, 15, 150 },
	xbowbolt = { 'Bolts', 1, 30, 30 }
}

GM.Parts	=
{
	laser = { 'Laser sight', 150 },
	silent = { 'Suppressor', 300 },
	launcher = { 'Grenade launcher', 1200 },
	pistreflex = { 'Reflex sight', 400 },
	rifleflex = { 'Reflex sight', 1000 },
	holosight = { 'Holographic sight', 700 },
	eotech = { 'EOTech 557 sight', 800 },
	acog = { 'ACOG scope', 1000 },
	longmag = { 'Extended magazine', 100 },
	fragmode = { 'Frag round modification', 200 },
	revscope = { 'Revolver scope', 1100 }
}

GM.PropPatch=
{
	[ 'models/hunter/plates/plate1x1.mdl' ] = { Angle( -90, 0, 0 ), 24 },
	[ 'models/hunter/plates/plate1x2.mdl' ] = { Angle( -90, 0, 0 ), 24 },
	[ 'models/hunter/plates/plate1x4.mdl' ] = { Angle( -90, 0, 0 ), 24 },
	[ 'models/hunter/plates/plate2x2.mdl' ] = { Angle( -90, 0, 0 ), 48 },
	[ 'models/hunter/plates/plate2x3.mdl' ] = { Angle( -90, 0, 0 ), 48 },
	[ 'models/hunter/plates/plate3x3.mdl' ] = { Angle( -90, 0, 0 ), 72 },
	[ 'models/hunter/plates/plate3x4.mdl' ] = { Angle( -90, 0, 0 ), 72 },
	[ 'models/props_phx/construct/windows/window1x1.mdl' ] = { Angle( -90, 0, 0 ), 24 },
	[ 'models/props_phx/construct/metal_plate1.mdl' ] = { Angle( -90, 0, 0 ), 24 },
	[ 'models/props_phx/construct/metal_plate1x2.mdl' ] = { Angle( -90, 0, 0 ), 24 },
	[ 'models/props_phx/construct/metal_plate2x2.mdl' ] = { Angle( -90, 0, 0 ), 48 },
}

GM.Props	=
{
	'models/props_phx/construct/metal_plate1.mdl',
	'models/props_phx/construct/metal_plate1x2.mdl',
	'models/props_phx/construct/metal_plate2x2.mdl',
	'models/props_phx/construct/windows/window1x1.mdl',
	'models/props_phx/construct/windows/window1x2.mdl',
	'models/props_phx/construct/windows/window2x2.mdl',
	'models/props_phx/construct/metal_tube.mdl',
	'models/props_phx/construct/metal_tubex2.mdl',
	'models/props_c17/concrete_barrier001a.mdl',
	'models/props_wasteland/kitchen_counter001b.mdl',
	'models/props_wasteland/kitchen_counter001d.mdl',
	'models/props_c17/lockers001a.mdl',
	'models/props_interiors/vendingmachinesoda01a.mdl',
	'models/props_interiors/vendingmachinesoda01a_door.mdl',
	'models/props_lab/lockerdoorleft.mdl',
	'models/props_borealis/borealis_door001a.mdl',
	'models/props_junk/trashdumpster02b.mdl',
	'models/props_c17/signpole001.mdl',
	'models/props_junk/ibeam01a.mdl',
	'models/props_docks/dock01_pole01a_128.mdl',
	'models/props_docks/dock03_pole01a_256.mdl',
	'models/props_c17/fence01a.mdl',
	'models/props_c17/fence01b.mdl',
	'models/props_c17/fence03a.mdl',
	'models/props_wasteland/interior_fence001a.mdl',
	'models/props_wasteland/interior_fence001b.mdl',
	'models/props_wasteland/interior_fence001c.mdl',
	'models/props_wasteland/interior_fence001d.mdl',
	'models/props_wasteland/interior_fence001g.mdl',
	'models/props_wasteland/interior_fence002a.mdl',
	'models/props_wasteland/interior_fence002b.mdl',
	'models/props_wasteland/interior_fence002c.mdl',
	'models/props_wasteland/interior_fence002d.mdl',
	'models/props_wasteland/interior_fence002f.mdl',
	'models/hunter/plates/plate1x1.mdl',
	'models/hunter/plates/plate1x2.mdl',
	'models/hunter/plates/plate1x4.mdl',
	'models/hunter/plates/plate2x2.mdl',
	'models/hunter/plates/plate2x3.mdl',
	'models/hunter/plates/plate3x3.mdl',
	'models/hunter/plates/plate3x4.mdl',
	'models/hunter/blocks/cube025x2x025.mdl',
	'models/hunter/blocks/cube025x4x025.mdl',
	'models/hunter/blocks/cube1x1x1.mdl',
	'models/hunter/tubes/tube2x2x1.mdl',
	'models/hunter/tubes/tube2x2x1b.mdl',
	'models/hunter/tubes/tube2x2x1c.mdl',
	'models/hunter/tubes/tube2x2x1d.mdl'
}

function AddSound( fs, snd, sndlvl, chan )
	local arg =
	{
		channel = chan or CHAN_WEAPON,
		volume = 1,
		soundlevel = sndlvl or 100,
		pitchstart = 100,
		pitchend = 100,
		sound = snd,
		name = fs
	}
	
	sound.Add( arg )
end

local ent = FindMetaTable( 'Entity' )
local ply = FindMetaTable( 'Player' )
	orgFireBullets = orgFireBullets or ent.FireBullets

local trace = { mask = MASK_SHOT }
local util_traceline = util.TraceLine
local cos, sin = math.cos, math.sin
local randomseed = math.randomseed
local random = math.random

function ent:FireBullets( fb )
	local singleton = table.Copy( fb )
		singleton.Num = 1
		
	if f2s_physbullets:GetBool() then
		for i = 1, ( fb.Num or 1 ) do
			randomseed( self:GetCurrentCommand():CommandNumber() + i )
			
			local rand = random( -180, 180 )
			local cone = ( fb.Dir:Angle() + Angle( fb.Spread.x * cos( rand ), fb.Spread.y * sin( rand ), 0 ) * ( rand / 6 ) ):Forward()
			
				trace.start = fb.Src
				trace.endpos = fb.Src + cone * 8192
				trace.filter = self
				trace.mask = MASK_SHOT
			local tr = util_traceline( trace )
			
			if tr.Hit and tr.HitPos:Distance( fb.Src ) < BULLET_SPEED * 0.35 then
				singleton.Dir = cone
				orgFireBullets( self, singleton )
			else
				local w = self:GetActiveWeapon()
				local fx = EffectData()
					fx:SetStart( fb.Src )
					fx:SetOrigin( tr.HitPos )
					fx:SetAttachment( 1 )
					fx:SetFlags( 2 )
					fx:SetScale( BULLET_SPEED )
				if SERVER then fx:SetEntIndex( w:EntIndex() )
				else fx:SetEntity( w ) end
				
				util.Effect( fb.TracerName or 'Tracer', fx )
				
				if CLIENT then return end
				
				table.insert( bullets, {
					fb.Weapon,
					self,
					fb.Src,
					fb.Src,
					cone,
					fb.Damage,
					fb.Force,
					self or fb.Attacker,
					fb.Callback,
					CurTime() + 3
				} )
			end
		end
	else return orgFireBullets( self, fb ) end
end

function GM.BulletCallbackOverride( ply, tr, dmg )
	if orgstartpos then tr.StartPos = orgstartpos end
	if orgcallback then orgcallback( ply, tr, dmg ) end
end

local util_IsInWorld = util.IsInWorld
local trace = { mask = MASK_SHOT }
local nullvec = Vector()
function GM:BulletsThink()
	local ct = CurTime()
	local ft = FrameTime()
	local step = BULLET_SPEED * ft * 1.5
	local falloff = Vector( self.WindDir.x * -50, self.WindDir.y * -50, 55 ) * ft
	
	for i, b in pairs( bullets ) do
		trace.start = b[4]
		trace.endpos = b[4] + b[5] * step
		trace.filter = b[2]
		
		if util_traceline( trace ).Hit then
			orgcallback = b[9]
			orgstartpos = b[3]
			
			orgFireBullets( b[2], {
				Num = 1,
				Src = b[4],
				Dir = b[5],
				Spread = nullvec,
				Tracer = 0,
				Damage = b[6],
				Force = b[7],
				Callback = self.BulletCallbackOverride,
				Attacker = b[8]
			} )
			
			table.remove( bullets, i )
		elseif not util_IsInWorld( b[4] ) or b[10] < ct then table.remove( bullets, i )
		else b[4] = b[4] + b[5] * step - falloff end
	end
end

function ply:MuzzleFlash()
	local fx = EffectData()
		fx:SetEntity( self:GetActiveWeapon() )
	util.Effect( 'hl2_distantsound', fx )
end

function ply:IsPremium()
	return true
end

local def = Vector( 1, 1, 0.392 )
function ply:GetPlayerColor()
	local sqd = self:Team()
	if sqd == 0 then return def end
	
	local col = team.GetColor( sqd )
	return Vector( col.r / 255, col.g / 255, col.b / 255 )
end

local male = { 'kleiner', 'barney', 'breen', 'odessa', 'gman', 'magnusson', 'urban', 'swat', 'arctic', 'gasmask', 'phoenix', 'riot', 'leet', 'guerilla', 'eli', 'monk', 'dod' }
local female = { 'mossman', 'alyx', 'chell' }

function GM:CheckModel( str )
	local str = string.lower( str )
	
	if string.find( str, 'combine' ) or string.find( str, 'police' ) then return 'combine' end
	if string.find( str, 'female' ) then return 'female' end
	if string.find( str, 'male' ) then return 'male' end
	if string.find( str, 'zomb' ) or string.find( str, 'charple' ) or string.find( str, 'stripped' ) or string.find( str, 'corpse' ) then return 'zombie' end
	
	for _, v in pairs( female ) do
		if string.find( str, v ) then
			return 'female'
		end
	end
	
	for _, v in pairs( male ) do
		if string.find( str, v ) then
			return 'male'
		end
	end
end

function GM:UpdateAnimation( ply, vel, seq )
	if CLIENT then self:LegsAnimation( ply, vel, seq ) end
	
	if ply:GetNWBool( 'sliding' ) then
		ply:DoAnimationEvent( ACT_HL2MP_RUN )
		ply:SetCycle( 0 )
		ply:SetPlaybackRate( 0 )
		
		return
	else
		local v2d = vel:Length2D()
		local rate = 1
		if v2d > 0.5 then rate = v2d / seq end
		
		ply:SetPlaybackRate( math.min( rate, 2 ) )
	end
	
	return self.BaseClass.UpdateAnimation( self, ply, vel, seq )
end

function GM:IsFriendOf( ply1, ply2 )
	if ply1 == ply2 then return true end
	if ply1:IsPlayer() and ply1:Team() == 0 or ply2:IsPlayer() and ply2:Team() == 0 then return false end
	if ply1:IsPlayer() and ply2:IsPlayer() and ply1:Team() == ply2:Team() then return true end
	
	return false
end

function GM:PlayerFootstep( ply, pos, foot, sound, volume, filter )
	if ply:GetNWBool( 'sliding' ) then return true end
	if CLIENT and ( self:CheckModel( ply:GetModel() ) == 'combine' or ply:GetModel() == 'models/player/zombie_soldier.mdl' ) then return not ply:EmitSound( 'npc/metropolice/gear' .. math.random( 1, 6 ) .. '.wav' ) end
end

function GM:IsColliding( ent1, ent2, filter )
		filter = table.Add( filter or {}, { ent1, game.GetWorld() } )
	local mins, maxs, center = ent1:OBBMins(), ent1:OBBMaxs(), ent1:OBBCenter()
	local hmins = Vector( -0.5, -0.5, -0.5 )
	local hmaxs = hmins * 1
	
	local rays =
	{
		{ start = mins, endpos = maxs, filter = filter, mins = hmins, maxs = hmaxs },
		{ start = Vector( mins.x, center.y, center.z ), endpos = Vector( maxs.x, center.y, center.z ), filter = filter, mins = hmins, maxs = hmaxs },
		{ start = Vector( center.x, mins.y, center.z ), endpos = Vector( center.x, maxs.y, center.z ), filter = filter, mins = hmins, maxs = hmaxs },
		{ start = Vector( center.x, center.y, mins.z ), endpos = Vector( center.x, center.y, maxs.z ), filter = filter, mins = hmins, maxs = hmaxs },
		{ start = Vector( maxs.x, mins.y, maxs.z ), endpos = Vector( mins.x, maxs.y, mins.z ), filter = filter, mins = hmins, maxs = hmaxs },
		{ start = Vector( mins.x, mins.y, maxs.z ), endpos = Vector( maxs.x, maxs.y, mins.z ), filter = filter, mins = hmins, maxs = hmaxs },
		{ start = Vector( maxs.x, mins.y, mins.z ), endpos = Vector( mins.x, maxs.y, maxs.z ), filter = filter, mins = hmins, maxs = hmaxs },
	}
	
	for _, v in pairs( rays ) do
		v.start = ent1:LocalToWorld( v.start )
		v.endpos = ent1:LocalToWorld( v.endpos )
		
		if util.TraceHull( v ).Entity == ent2 then return true end
	end
	
	return false
end

function GM:ShouldCollide( ply1, ply2 )
	if ply1:IsPlayer() and ply2:IsPlayer() then
		if ply1.SpawnProtection == -1 or ply2.SpawnProtection == -1 then return false end
	end
	
	return true
end

function GM:PlayerNoClip( ply )
	local w = ply:GetActiveWeapon()
	if w.Melee then w:Melee() end
	
	return false
end

function GM:Move( ply, move )
	local sliding = false -- ply.Sliding and ply.Sliding > 0 and ply:IsOnGround() or false
	if SERVER and ply:GetNWBool( 'sliding' ) ~= sliding then ply:SetNWBool( 'sliding', sliding ) end
	if ply:EyeAngles().p < -70 or ply:EyeAngles().p > 70 then move:SetMaxSpeed( move:GetMaxSpeed() * 0.6 ) end
	
	if ( ply.DelayJumping or 0 ) > CurTime() then
		move:SetMaxSpeed( move:GetMaxSpeed() * 0.5 )
	end
	
	if ply:IsOnGround() and ply.WasInAir then
		ply.WasInAir = false
		ply.DelayJumping = CurTime() + 0.5
	elseif not ply:IsOnGround() then ply.WasInAir = true end
	
	local w = ply:GetActiveWeapon()
	if IsValid( w ) and w.GetIronsights and w:GetIronsights() then move:SetMaxSpeed( ply:GetWalkSpeed() * 0.75 * ( ply:Crouching() and ply:GetCrouchedWalkSpeed() or 1 ) ) end
	if IsValid( w ) and ( w.IsReloading and w:IsReloading() or w.Slot == -1 and not w.CanRun ) then move:SetMaxSpeed( 160 * ( ply:Crouching() and ply:GetCrouchedWalkSpeed() or 1 ) ) end
	
	--[[
	if sliding then
		local offz = 0
		if ply.LastZ then
			offz = ply.LastZ - ply:GetPos().z
		end
		
		ply.Sliding = ply.Sliding - ( 48 - offz * ( offz < 0 and 50 or 8 ) ) * FrameTime()
		
		if not ply:GetNWBool( 'sliding' ) then ply:SetNWBool( 'sliding', false ) end
		ply:SetVelocity( ply:GetAngles():Forward() * ply.Sliding )
		
		if ply.SlidingSound then
			ply.SlidingSound:ChangePitch( math.min( ply:GetVelocity():Length2D() * 0.4, 100 ), 0 )
		end
	elseif ply.SlidingSound then
		ply.NextSliding = CurTime() + 1
		ply.SlidingSound:Stop()
		ply.SlidingSound = nil
		
		ply:ManipulateBoneAngles( BONE_USED_BY_HITBOX, Angle() )
		ply:ManipulateBonePosition( BONE_USED_BY_HITBOX, Vector() )
	end
	
	if move:KeyDown( IN_DUCK ) and ply:IsOnGround() and ply:GetVelocity():Length2D() > 250 and ( ply.NextSliding or 0 ) < CurTime() then
		if not ply.Sliding and move:KeyDown( IN_FORWARD ) and move:KeyDown( IN_SPEED ) then
			ply.Sliding = math.min( ply:GetVelocity():Length2D() * 0.22, 90 )
			ply:ManipulateBoneAngles( BONE_USED_BY_HITBOX, Angle( 0, 0, -70 ) )
			ply:ManipulateBonePosition( BONE_USED_BY_HITBOX, Vector( 0, 0, -25 ) )
			
			if not ply.SlidingSound then
				ply.SlidingSound = CreateSound( ply, 'physics/cardboard/cardboard_box_scrape_smooth_loop1.wav' )
				ply.SlidingSound:ChangePitch( 100, 0 )
				ply.SlidingSound:Play()
			end
		end
	elseif ply.Sliding then
		ply.Sliding = nil
	end
	]]
	
	ply.LastZ = ply:GetPos().z
end