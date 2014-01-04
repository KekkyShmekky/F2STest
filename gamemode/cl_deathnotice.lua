local hud_deathnotice_time = 6

surface.CreateFont( 'death_notice', {
	font = 'arial',
	size = 16,
	weight = 1,
	blursize = 1,
	scanlines = 0,
	antialias = 1
} )

surface.CreateFont( 'feed_big', {
	font = 'arial',
	size = 24,
	weight = 1000,
	blursize = 1,
	scanlines = 0,
	antialias = 1
} )

local bar = surface.GetTextureID( 'effects/lensflare/bar' )
local grad = surface.GetTextureID( 'gui/center_gradient' )

local Color_Icon = Color( 255, 80, 0, 255 ) 
local NPC_Color = Color( 250, 50, 50, 255 ) 
local Deaths = {}

local function PlayerIDOrNameToString( var )
	if type( var ) == 'string' then 
		if var == '' then return '' end
		return '#'..var 
	end
	
	local ply = Entity( var )
	
	if ply == NULL then return 'NULL!' end
	
	return ply:Name()
end

local function RecvPlayerKilledByPlayer( message )
	local victim 	= message:ReadEntity()
	local inflictor	= message:ReadString()
	local attacker 	= message:ReadEntity()
	local headshot 	= message:ReadBool()

	if !IsValid( attacker ) then return end
	if !IsValid( victim ) then return end
			
	GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim:Name(), victim:Team(), headshot )
end
usermessage.Hook( 'PlayerKilledByPlayer', RecvPlayerKilledByPlayer )

local function RecvPlayerKilledSelf( message )
	local victim = message:ReadEntity()
	if !IsValid( victim ) then return end
	GAMEMODE:AddDeathNotice( nil, 0, 'suicide', victim:Name(), victim:Team() )
end
usermessage.Hook( 'PlayerKilledSelf', RecvPlayerKilledSelf )

local function RecvPlayerKilled( message )
	local victim 	= message:ReadEntity()
	if !IsValid( victim ) then return end
	local inflictor	= message:ReadString()
	local attacker 	= '#' .. message:ReadString()
			
	GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim:Name(), victim:Team() )
end
usermessage.Hook( 'PlayerKilled', RecvPlayerKilled )

local function RecvPlayerKilledNPC( message )
	local victimtype = message:ReadString()
	local victim 	= '#' .. victimtype
	local inflictor	= message:ReadString()
	local attacker 	= message:ReadEntity()

	--
	-- For some reason the killer isn't known to us, so don't proceed.
	--
	if !IsValid( attacker ) then return end
			
	GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim, -1 )
	
	local bIsLocalPlayer = (IsValid(attacker) and attacker == LocalPlayer())
	
	local bIsEnemy = IsEnemyEntityName( victimtype )
	local bIsFriend = IsFriendEntityName( victimtype )
	
	if bIsLocalPlayer and bIsEnemy then
		achievements.IncBaddies()
	end
	
	if bIsLocalPlayer and bIsFriend then
		achievements.IncGoodies()
	end
	
	if bIsLocalPlayer and (!bIsFriend and !bIsEnemy) then
		achievements.IncBystander()
	end
end
usermessage.Hook( 'PlayerKilledNPC', RecvPlayerKilledNPC )

local function RecvNPCKilledNPC( message )
	local victim 	= '#' .. message:ReadString()
	local inflictor	= message:ReadString()
	local attacker 	= '#' .. message:ReadString()
			
	GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim, -1 )
end
usermessage.Hook( 'NPCKilledNPC', RecvNPCKilledNPC )

--[[---------------------------------------------------------
   Name: gamemode:AddDeathNotice( Victim, Attacker, Weapon )
   Desc: Adds an death notice entry
-----------------------------------------------------------]]

local codenames =
{
	grenade_ar2 = '40x60 GRENADE',
	sent_m79_grenade = '40x60 GRENADE',
	prop_combine_ball = 'DARK ENERGY BALL',
	npc_grenade_frag = 'MK3A2 GRENADE',
	env_explosion = 'TRIP MINE',
	prop_physics = 'SENTRY GUN',
	crossbow_bolt = 'CROSSBOW'
}

function GM:AddDeathNotice( Victim, team1, Inflictor, Attacker, team2, headshot )
	local Death = {}
	Death.victim 	= 	Victim
	Death.attacker	=	Attacker
	Death.time		=	CurTime()
	
	Death.left		= 	Victim
	Death.right		= 	Attacker
	
	local lteam = LocalPlayer():Team()
	
	Death.color1 = ( LocalPlayer():Nick() == Victim or team1 == lteam and team1 ~= 0 and lteam ~= 0 ) and Color( 0, 180, 255 ) or Color( 255, 180, 0 )
	Death.color2 = ( LocalPlayer():Nick() == Attacker or team2 == lteam and team2 ~= 0 and lteam ~= 0 ) and Color( 0, 180, 255 ) or Color( 255, 180, 0 )
	
	if Inflictor then
		if codenames[ Inflictor ] then
			Death.center = '[' .. codenames[ Inflictor ] .. ']'
		else
			local wep = weapons.Get( Inflictor )
			if wep then
				Death.center = '[' .. ( wep and wep.PrintName and wep.PrintName ) .. ']'
			end
		end
		
		Death.color3 = table.Copy( color_white )
	end
	
	table.insert( Deaths, Death )
end

local function DrawDeath( x, y, death, hud_deathnotice_time )
	local fadeout = ( death.time + hud_deathnotice_time ) - CurTime()
	
	local alpha = math.Clamp( fadeout * 255, 0, 255 )
	death.color1.a = alpha
	death.color2.a = alpha
	if death.color3 then death.color3.a = alpha end
	
	draw.SimpleText( death.right, 'death_notice', x, y, death.color2, TEXT_ALIGN_RIGHT )
	
		surface.SetFont( 'death_notice' )
	x = x - surface.GetTextSize( death.right ) - 10
	
	if death.center then
		draw.SimpleText( death.center, 'death_notice', x, y, death.color3, TEXT_ALIGN_RIGHT )
		
		x = x - surface.GetTextSize( death.center ) - 10
	end
	
	if death.left then
		draw.SimpleText( death.left, 'death_notice', x, y, death.color1, TEXT_ALIGN_RIGHT )
	end
	
	return y + 16
end

function GM:DrawDeathNotice( x, y )

	x = x * ScrW()
	y = y * ScrH()
	
	-- Draw
	for k, Death in pairs( Deaths ) do

		if (Death.time + hud_deathnotice_time > CurTime()) then
	
			if (Death.lerp) then
				x = x * 0.3 + Death.lerp.x * 0.7
				y = y * 0.3 + Death.lerp.y * 0.7
			end
			
			Death.lerp = Death.lerp or {}
			Death.lerp.x = x
			Death.lerp.y = y
		
			y = DrawDeath( x, y, Death, hud_deathnotice_time )
		
		end
		
	end
	
	-- We want to maintain the order of the table so instead of removing
	-- expired entries one by one we will just clear the entire table
	-- once everything is expired.
	for k, Death in pairs( Deaths ) do
		if (Death.time + hud_deathnotice_time > CurTime()) then
			return
		end
	end
	
	Deaths = {}
end

GM.Feed = ''
GM.Feed2 = 'DOUBLE KILL'
GM.FeedProc = 0
GM.FeedTime = 0

usermessage.Hook( 'feed', function( um )
	GAMEMODE.Feed = um:ReadString()
	GAMEMODE.Feed2 = um:ReadString()
	
	GAMEMODE.FeedProc = 0
	GAMEMODE.FeedTime = CurTime() + hud_deathnotice_time
end )

function GM:RenderFeed()
	local x, y = ScrW() / 2, ScrH() - 256
	local feed = string.sub( self.Feed, 1, self.FeedProc * #self.Feed )
	
	self.FeedProc = math.Approach( self.FeedProc, self.FeedTime > CurTime() and 1 or 0, FrameTime() * 3 )
	
	surface.SetDrawColor( 255, 255, 0 )
	
	surface.SetFont( 'feed_big' )
	surface.SetTextColor( 255, 255, 0 )
	surface.SetTextPos( x - surface.GetTextSize( feed ) / 2, y )
	surface.DrawText( feed )
	
	if self.FeedProc == 1 then
		local wid = surface.GetTextSize( feed ) / 2
		
		surface.SetFont( 'death_notice' )
		surface.SetTextPos( x + wid - surface.GetTextSize( self.Feed2 ), y - 16 )
		surface.DrawText( self.Feed2 )
		
		if ( CurTime() % 0.9 ) > 0.3 then
			surface.SetTexture( grad )
			surface.DrawTexturedRectRotated( x + wid + 10, y + 12, 23, 17, 90 )
		end
	end
	
	surface.SetTexture( bar )
	surface.DrawTexturedRect( x - surface.GetTextSize( feed ) * 2.2, y - 1010, surface.GetTextSize( feed ) * 6, 2048 )
end