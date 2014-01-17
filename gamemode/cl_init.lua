include 'cl_hud.lua'
include 'cl_lens.lua'
include 'cl_menu.lua'
include 'cl_deathnotice.lua'
include 'cl_spawnmenu.lua'
include 'cl_legs.lua'
include 'cl_scoreboard.lua'

include 'shared.lua'

FLARES = {}
GM.LastDamaged = 0

bloodoverlay = Material( 'overlay/neardeath.png' )

f2s_lowerrain = CreateConVar( 'f2s_lowerrain', 0 )
f2s_statichud = CreateConVar( 'f2s_statichud', 0 )
f2s_disableblur = CreateConVar( 'f2s_disableblur', 0 )
f2s_disablemuzzle = CreateConVar( 'f2s_disablemuzzle', 0 )
f2s_reduceheadbob = CreateConVar( 'f2s_reduceheadbob', 0 )
f2s_disabledistantsounds = CreateConVar( 'f2s_disabledistantsounds', 0 )

surface.CreateFont( 'WASTED', {
	font		= 'arial black',
	size		= 150,
	weight		= 5000,
	bold		= true,
	outline		= true
} )

local thunder =
{
	'ambient/ambience/rainscapes/thunder_close01.wav',
	'ambient/ambience/rainscapes/thunder_close02.wav',
	'ambient/ambience/rainscapes/thunder_close03.wav',
	'ambient/ambience/rainscapes/thunder_close04.wav',
}

local pp_colorcorrection =
{
	[ '$pp_colour_addr' ] = -0.1,
	[ '$pp_colour_addg' ] = -0.1,
	[ '$pp_colour_addb' ] = -0.1,
	[ '$pp_colour_contrast' ] = 2,
	[ '$pp_colour_colour' ] = 0,
	[ '$pp_colour_mulr' ] = 0.1,
	[ '$pp_colour_mulg' ] = 0.1,
	[ '$pp_colour_mulb' ] = 0.1
}

usermessage.Hook( 'death', function( um )
	GAMEMODE.DeathTime = CurTime() + um:ReadFloat()
end )

usermessage.Hook( 'advert', function( um )
	GAMEMODE.Advert = CurTime() + 8
	GAMEMODE.AdvertText = um:ReadString()
	GAMEMODE.AdvertColor = Color( um:ReadShort(), um:ReadShort(), um:ReadShort() )
end )

usermessage.Hook( 'weather', function( um )
	GAMEMODE.Weather = um:ReadShort()
end )

usermessage.Hook( 'thunder', function( um )
	surface.PlaySound( table.Random( thunder ) )
	
	GAMEMODE.Lighting = math.Rand( 0.8, 1.5 )
	GAMEMODE.EmitLightingParticle = true
end )

usermessage.Hook( 'winddir', function( um )
	GAMEMODE.Wind = true
	GAMEMODE.WindDir = um:ReadVector()
end )

net.Receive( 'menu_mkteam', function()
	team.SetUp( unpack( net.ReadTable() ) )
	WAIT_FOR_LOCALPLAYER = true
end )

net.Receive( 'teams_update', function()
	local tbl = net.ReadTable()
	if type( tbl ) == 'table' then
		for _, v in pairs( tbl ) do
			team.SetUp( unpack( v[3] ) )
		end
	end
	
	WAIT_FOR_LOCALPLAYER = true
end )

local plain = Material( 'pp/texturize/plain.png' )
function GM:RenderScreenspaceEffects()
	cam.Start2D() self:RenderLens() cam.End2D()
	
	local ply = LocalPlayer()
	if not ply:Alive() then return DrawTexturize( 1, plain ) end
	
	self.Weather_Rain = self.Weather_Rain or 0
	self:Legs_Render( ply )
	
	if ply:Health() < 40 then
		pp_colorcorrection[ '$pp_colour_brightness' ] = math.sin( CurTime() * 8 ) * 0.03
		pp_colorcorrection[ '$pp_colour_contrast' ] = math.Approach( pp_colorcorrection[ '$pp_colour_contrast' ], 2, FrameTime() )
	else
		pp_colorcorrection[ '$pp_colour_brightness' ] = math.Approach( pp_colorcorrection[ '$pp_colour_brightness' ] or 0, 0.02, FrameTime() * 0.5 )
		pp_colorcorrection[ '$pp_colour_contrast' ] = math.Approach( pp_colorcorrection[ '$pp_colour_contrast' ], 1.1 - self.Weather_Rain * 0.03, FrameTime() * 0.5 )
	end
	
	pp_colorcorrection[ '$pp_colour_colour' ] = math.Approach( pp_colorcorrection[ '$pp_colour_colour' ], ( ply:Health() < 20 ) and 0.1 or 1 - self.Weather_Rain * 0.3, FrameTime() * 0.5 )
	pp_colorcorrection[ '$pp_colour_brightness' ] = math.max( pp_colorcorrection[ '$pp_colour_brightness' ] - self.LensContrast - self.Weather_Rain, -0.09 )
	self.LensContrast = 0
	
	DrawColorModify( pp_colorcorrection )
end

function GM:PrePlayerDraw( pl )
end

function GM:PostPlayerDraw( pl )
end

local sky = CreateMaterial( 'WhiteMaterial', 'UnlitGeneric', {
	[ '$basetexture' ] = 'color/white',
	[ '$vertexcolor' ] = 1,
	[ '$vertexalpha' ] = 1,
	[ '$model' ] = 1
} )

local random = math.random
local skybox_size = 10240
function GM:PostDrawSkyBox()	
	local ply = LocalPlayer()
	if not self.EM or not self.EM3D then return end
	
	self.Lighting = math.Approach( self.Lighting or 0, 0, FrameTime() * 5 )
	self.Weather_Rain = math.Approach( self.Weather_Rain or 0, ( self.Weather == WEATHER_RAIN ) and 1 or 0, FrameTime() )
	
	local a = math.min( 225 + 25 * self.Lighting, 255 ) * self.Weather_Rain
	local c = 255 * self.Lighting
	local color = Color( c, c, c, a )
	
	if self.Weather_Rain > 0 then
		render.SuppressEngineLighting( true )
		cam.Start3D( EyePos(), EyeAngles() )
			render.SetMaterial( sky )
			render.DrawQuadEasy( Vector( 0, 0, skybox_size ), Vector( 0, 0, -1 ), skybox_size * 2, skybox_size * 2, color, 90 )
			render.DrawQuadEasy( Vector( 0, skybox_size, 0 ), Vector( 0, -1, 0 ), skybox_size * 2, skybox_size * 2, color, 90 )
			render.DrawQuadEasy( Vector( 0, -skybox_size, 0 ), Vector( 0, 1, 0 ), skybox_size * 2, skybox_size * 2, color, 90 )
			render.DrawQuadEasy( Vector( skybox_size, 0, 0 ), Vector( -1, 0, 0 ), skybox_size * 2, skybox_size * 2, color, 90 )
			render.DrawQuadEasy( Vector( -skybox_size, 0, 0 ), Vector( 1, 0, 0 ), skybox_size * 2, skybox_size * 2, color, 90 )
		cam.End3D()
		render.SuppressEngineLighting( false )
		
		if ( self.NextCloud or 0 ) < CurTime() then
			local ptcl = self.EM3D:Add( 'particle/smokesprites_000' .. random( 1, 9 ), Vector( random( -8000, 8000 ), random( -8000, 8000 ), 5000 ) )
				ptcl:SetColor( 50, 50, 50 )
				ptcl:SetLifeTime( 0 )
				ptcl:SetDieTime( 30 )
				ptcl:SetStartSize( 10500 )
				ptcl:SetEndSize( 0 )
				ptcl:SetStartAlpha( 0 )
				ptcl:SetEndAlpha( 180 )
				ptcl:SetRoll( random( 0, 360 ) )
				ptcl:SetAngles( Angle( 90, 0, 0 ) )
			self.NextCloud = CurTime() + math.Rand( 0.3, 0.5 )
		end
		
		if self.EmitLightingParticle then
			self.EmitLightingParticle = false
			
			local ptcl = self.EM3D:Add( 'particle/smokesprites_000' .. random( 1, 9 ), Vector( random( -8000, 8000 ), random( -8000, 8000 ), 4900 ) )
				ptcl:SetColor( 255, 255, 255 )
				ptcl:SetLifeTime( 0 )
				ptcl:SetDieTime( 0.1 )
				ptcl:SetStartSize( 5500 )
				ptcl:SetEndSize( 0 )
				ptcl:SetStartAlpha( 255 )
				ptcl:SetEndAlpha( 0 )
				ptcl:SetRoll( random( 0, 360 ) )
				ptcl:SetAngles( Angle( 90, 0, 0 ) )
		end
	end
end

function GM:PlayerStartVoice( ply )
	if ( self.NextVoiceSoundPlay or 0 ) < CurTime() then
		self.NextVoiceSoundPlay = CurTime() + 0.5
		surface.PlaySound( 'npc/metropolice/vo/on' .. random( 1, 2 ) .. '.wav' )
	end
	
	return self.BaseClass.PlayerStartVoice( self, ply )
end

function GM:PlayerEndVoice( ply )
	if ( self.NextVoiceSoundPlay or 0 ) < CurTime() then
		self.NextVoiceSoundPlay = CurTime() + 0.5
		surface.PlaySound( 'npc/metropolice/vo/off' .. random( 1, 4 ) .. '.wav' )
	end
	
	return self.BaseClass.PlayerEndVoice( self, ply )
end

local CollideCallback = function( part, hitpos, normal )
	local ply = LocalPlayer()
	if normal.z == 1 then
		for i2 = 1, random( 2, 5 ) do
			p = GAMEMODE.EM:Add( 'particle/snow', hitpos )
			p:SetLifeTime( 0 )
			p:SetDieTime( math.Rand( 0.1, 0.5 ) )
			p:SetStartSize( 1 )
			p:SetStartAlpha( 100 )
			p:SetEndAlpha( 0 )
			p:SetColor( 200, 200, 200 )
			p:SetStartLength( 5 )
			p:SetEndLength( 0 )
			p:SetVelocity( Vector( 0, 0, 10 ) + ( VectorRand() * 5 ) )
			p:SetGravity( Vector( 0, 0, -100 ) )
		end
		
		if random( 0, 70 ) == 0 then
			local size = math.Rand( 180, 480 )
			
			p = GAMEMODE.EM:Add( 'particle/smokesprites_000' .. random( 1, 9 ), hitpos + normal * size )
			p:SetLifeTime( 0 )
			p:SetDieTime( random( 4, 10 ) )
			p:SetStartSize( size )
			p:SetEndSize( random( 180, 480 ) )
			p:SetStartAlpha( 10 )
			p:SetEndAlpha( 0 )
			p:SetRoll( random( 0, 360 ) )
			p:SetRollDelta( math.Rand( -0.2, 0.2 ) )
		end
		
		part:SetDieTime( 0 )
	end
end

function GM:Think()
	local ply = LocalPlayer()
	local spec = ply:GetNWString( 'special' )
	
	ply:DrawViewModel( not ply:InVehicle() )
	
	if self.WeaponSelectionTrigger and self.WeaponSelectionTrigger < CurTime() then
		if IsValid( self.SelectedWeapon ) then
			local deploy = true
			if self.SelectedWeapon.CanDeploy then deploy = self.SelectedWeapon:CanDeploy() end
			if deploy then RunConsoleCommand( 'use', self.SelectedWeapon:GetClass() ) end
		end
		
		self.WeaponSelectionTrigger = nil
	end
	
	if ( not self.EM or not self.EM3D ) and IsValid( ply ) then
		self.EM = ParticleEmitter( ply:GetPos() )
		self.EM3D = ParticleEmitter( ply:GetPos(), true )
	end
	
	local tr = util.TraceLine( {
		start = ply:GetPos(),
		endpos = ply:GetPos() + Vector( 0, 0, 1500 ),
		filter = ply,
		mask = MASK_SHOT
	} )
	
	if self.Wind then
		self.Wind = false
		sound.Play( 'ambient/wind/windgust.wav', ply:GetPos(), 510, tr.Hit and not tr.HitSky and 70 or 100 )
	end
	
	if ( not self.SND1 or not self.SND2 ) and IsValid( ply ) then
		self.SND1 = CreateSound( ply, Sound( 'ambient/ambience/rainscapes/crucial_waterrain_light_loop.wav' ) )
		self.SND2 = CreateSound( ply, Sound( 'ambient/ambience/rainscapes/interior_rain_med_loop.wav' ) )
		self.SND1:Play()
		self.SND2:Play()
	elseif self.SND1 and self.SND2 then
		if self.Weather == WEATHER_NORMAL then
			self.SND1:ChangeVolume( 0, 0.1 )
			self.SND2:ChangeVolume( 0, 0.1 )
		else			
			if tr.Hit and not tr.HitSky then
				self.SND1:ChangeVolume( 0, 0.1 )
				self.SND2:ChangeVolume( 1, 0.1 )
			else
				self.SND1:ChangeVolume( 1, 0.1 )
				self.SND2:ChangeVolume( 0, 0.1 )
			end
		end
	end
	
	if self.Weather == WEATHER_RAIN and ( self.NextDrip or 0 ) < CurTime() then
		self.NextDrip = CurTime() + 0.05
		
		local p
		local abs = ply:GetPos() + ply:GetVelocity() * 0.5 + Vector( 0, 0, 1500 )
		if tr.Hit and tr.HitSky then abs.z = tr.HitPos.z end
		
		local vec = Vector( self.WindDir.x * 300, self.WindDir.y * 300, -1000 )
		if f2s_lowerrain:GetBool() then
			for i = 1, 10 do
				p = self.EM:Add( 'particle/snow', abs + Vector( random( -1000, 1000 ), random( -1000, 1000 ), 0 ) )
				p:SetCollide( true )
				p:SetLifeTime( 0 )
				p:SetDieTime( 4 )
				p:SetStartSize( 1 )
				p:SetStartAlpha( 100 )
				p:SetEndAlpha( 100 )
				p:SetColor( 200, 200, 200 )
				p:SetStartLength( 50 )
				p:SetEndLength( 50 )
				p:SetVelocity( vec )
			end
		else
			for i = 1, 40 do
				p = self.EM:Add( 'particle/snow', abs + Vector( random( -1000, 1000 ), random( -1000, 1000 ), 0 ) )
				p:SetCollide( true )
				p:SetLifeTime( 0 )
				p:SetDieTime( 4 )
				p:SetStartSize( 1 )
				p:SetStartAlpha( 100 )
				p:SetEndAlpha( 100 )
				p:SetColor( 200, 200, 200 )
				p:SetStartLength( 50 )
				p:SetEndLength( 50 )
				p:SetVelocity( vec * random( 1, 3 ) )
				p:SetCollideCallback( CollideCallback )
			end
		end
	end
	
	if input.IsKeyDown( KEY_G ) and gui.MouseX() == 0 and gui.MouseY() == 0 then
		if not self.Key_G then
			self.Key_G = true
			
			local wep = NULL
			for _, v in pairs( ply:GetWeapons() ) do
				if v:GetClass() == spec then
					wep = v
					break
				end
			end
			
			local w = weapons.Get( spec )
			if IsValid( wep ) and w and w.CanDeploy and w.CanDeploy( wep ) then
				RunConsoleCommand( 'use', spec )
			end
		end
	elseif self.Key_G then
		self.Key_G = false
	end
	
	if WAIT_FOR_LOCALPLAYER and IsValid( ply ) and ply.Team then
		WAIT_FOR_LOCALPLAYER = UpdateTeamList()
	end
end

local purple = Color( 255, 0, 255 )
function GM:PreDrawHalos( ... )
	local lp = LocalPlayer()
	if not lp:GetNWBool( 'maniac' ) or not lp:Alive() then return end
	
	local players = {}
	for _, pl in pairs( player.GetAll() ) do
		if pl ~= lp and pl:Alive() then
			table.insert( players, pl )
		end
	end
	
	effects.halo.Add( players, purple, 1, 1, 1, true, true )
end

function GM:PreDrawViewModel( vm, ply, w )
	if not IsValid( w ) then return end
	
	player_manager.RunClass( ply, 'PreDrawViewModel', vm, w )
	
	if IsValid( vm ) and ply == LocalPlayer() then
		local muz = vm:GetAttachment( 1 )
		if muz then
			self.LastMuzUp = CurTime() + 0.2
			self.MuzzleAngle = muz.Ang
			self.MuzzleAngle.y = math.abs( self.MuzzleAngle.y )
		end
		
		if w.ViewModel and vm:GetModel() ~= w.ViewModel then vm:SetModel( w.ViewModel ) end
	end
	
	if not w.PreDrawViewModel then return false end
	return w:PreDrawViewModel( vm, w, ply )
end

local dbg_a, dbg_b
if CLIENT then
	dbg_a = CreateConVar( '__debug.attachments', 0 )
	dbg_b = CreateConVar( '__debug.bones', 0 )
end

function GM:PostDrawViewModel( vm, ply, w )
	if IsValid( ply:GetHands() ) and not IsValid( ply:GetVehicle() ) then ply:GetHands():DrawModel() end
	
	player_manager.RunClass( ply, 'PostDrawViewModel', vm, w )
	
	if dbg_a and dbg_a:GetBool() then
		cam.Start2D()
			surface.SetFont( 'DermaDefault' )
			surface.SetDrawColor( color_white )
			surface.SetTextColor( color_white )
			
			local i = 1
			local a = vm:GetAttachment( i )
			while a do
				local pos = a.Pos:ToScreen()
				local pos2 = ( a.Pos + a.Ang:Forward() * 16 ):ToScreen()
				
				surface.DrawRect( pos.x - 2, pos.y - 2, 4, 4 )
				surface.DrawLine( pos.x, pos.y, pos2.x, pos2.y )
				
				surface.SetTextPos( pos.x + 2, pos.y + 2 )
				surface.DrawText( i )
				
				i = i + 1
				a = vm:GetAttachment( i )
			end
			
		cam.End2D()
	end
	
	if dbg_b and dbg_b:GetBool() then
		cam.Start2D()
			surface.SetFont( 'DermaDefault' )
			surface.SetDrawColor( color_white )
			surface.SetTextColor( color_white )
			
			for i = 0, vm:GetBoneCount() - 1 do
				local pos, ang = vm:GetBonePosition( i )					
				local pos2 = ( pos + ang:Forward() * 16 ):ToScreen()
					pos = pos:ToScreen()
				
				surface.DrawRect( pos.x - 2, pos.y - 2, 4, 4 )
				surface.DrawLine( pos.x, pos.y, pos2.x, pos2.y )
				
				surface.SetTextPos( pos.x + 2, pos.y + 2 )
				surface.DrawText( '[' .. i .. '] ' .. vm:GetBoneName( i ) )
			end
		cam.End2D()
	end
	
	if not w.PostDrawViewModel then return false end		
	return w:PostDrawViewModel( vm, w, ply )
end

-- code below this line works on magic, do NOT edit!!

local enabled
local d3d2 = { pos = Vector(), ang = Angle() }
local offset
function GM:hud_update_parameters()
	local ply = LocalPlayer()
	local vec = f2s_statichud:GetBool() and EyeAngles() or ply:EyeAngles()
	
	local ang = vec * 1
	if not f2s_statichud:GetBool() then
		ang.r = ang.r * 0.3
	end
	
		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )
		
	offset = 0
	d3d2.pos, d3d2.ang = EyePos() + vec:Forward() * ScrW() / 136.6 - vec:Right() * 6.67 * ScrW() / 1366 + vec:Up() * ScrH() / 201, ang
end

-- !!!EVIL NUMBERS BELOW!!! --
-- WORKS ON MAGIC, DO NOT EDIT

function GM:HUD3DY( yaw )
	offset = yaw
	self:HUD3DEX()
	self:HUD3DEN()
end

function GM:HUD3DEN()
	if enabled then return end	
		enabled = true
	
	local ang = d3d2.ang * 1
		ang:RotateAroundAxis( ang:Right(), offset )
	
	local ratio = ScrW() * 0.000099
	
	cam.Start3D( EyePos(), EyeAngles(), 75 )
	cam.Start3D2D( d3d2.pos - d3d2.ang:Up() * offset * ratio, ang, 0.01 )
end

function GM:HUD3DEX()
	if not enabled then return end
		enabled = false
	
	cam.End3D2D()
	cam.End3D()
end

local sv_cheats = GetConVar( 'sv_cheats' )
function GM:HUDPaint()
	self:DrawDeathNotice( 0.98, 0.04 )
	self:hud_update_parameters()
	
	local ply = LocalPlayer()
	local w, h = ScrW(), ScrH()
	local inv = ply:GetNWInt( 'invite' )
	
	if sv_cheats:GetBool() then
		surface.SetDrawColor( color_white )
		surface.DrawRect( w / 2 - 1, h / 2 - 1, 2, 2 )
	end
	
	if inv ~= 0 then
		surface.SetDrawColor( 0, 0, 0, 127 )
		surface.DrawRect( 0, h / 2 - 64, 256, 95 )
		
		surface.SetFont( 'ScoreboardDefault' )
		surface.SetTextColor( 255, 255, 0 )
		surface.SetTextPos( 5, h / 2 - 60 )
		surface.DrawText( 'TEAM INVITE' )
		
		surface.SetFont( 'HUD' )
		surface.SetTextColor( color_white )
		surface.SetTextPos( 15, h / 2 - 38 )
		surface.DrawText( team.GetName( inv ) )
		
		surface.SetTextPos( 5, h / 2 - 8 )
		surface.DrawText( 'F1 - accept' )
		surface.SetTextPos( 5, h / 2 + 8 )
		surface.DrawText( 'F2 - ignore' )
	end
	
	if not ply:Alive() then
		if not self.DeadSound then
			self.DeadSound = true
			surface.PlaySound( 'suit/death.mp3' )
		end
		
		surface.SetDrawColor( color_black )
		surface.DrawRect( 0, 0, w, 86 )
		surface.DrawRect( 0, h - 86, w, 86 )
		
		local spec = ply:GetNWEntity( 'killer' )
		
		surface.SetFont( 'ScoreboardDefaultTitle' )
		surface.SetTextColor( color_white )
		surface.SetTextPos( ( w - surface.GetTextSize( 'YOU ARE DEAD' ) ) / 2, 16 )
		surface.DrawText( 'YOU ARE DEAD' )
		
		local text = 'Press [SPACE] key to respawn'
		if self.DeathTime and ( self.DeathTime - CurTime() ) > 0 then
			text = 'Deploying in ' .. math.floor( self.DeathTime - CurTime() ) + 1
		end
		
		surface.SetFont( 'ScoreboardDefaultTitle' )
		surface.SetTextColor( color_white )
		surface.SetTextPos( ( w - surface.GetTextSize( text ) ) / 2, h - 56 )
		surface.DrawText( text )
		
		local text = IsValid( spec ) and spec ~= ply and spec:IsPlayer() and ( 'You were killed by ' .. spec:Nick() ) or ''
		
		surface.SetFont( 'ScoreboardDefault' )
		surface.SetTextColor( color_white )
		surface.SetTextPos( ( w - surface.GetTextSize( text ) ) / 2, 48 )
		surface.DrawText( text )
		
		surface.SetFont( 'WASTED' )
		surface.SetTextColor( 255, 255, 255, math.Clamp( self.DeathCam / 50, 0, 1 ) * 255 )
		surface.SetTextPos( ( ScrW() - surface.GetTextSize( 'WASTED!' ) ) / 2, ScrH() / 2 - 48 )
		surface.DrawText( 'WASTED!' )
		
		return
	end
	
	self.DeadSound = false
	
	local a = ( CurTime() % 0.5 ) * 2.5
	local x = a * 64
	
	surface.SetFont( 'Default' )
	
	for _, pl in pairs( player.GetAll() ) do
		if pl ~= ply then
			if self:IsFriendOf( ply, pl ) then
				local alive = pl:Alive()
				local rag = pl:GetNWEntity( 'player' )
				local pos
				if alive then
					pos = ( pl:GetPos() + Vector( 0, 0, pl:OBBMaxs().z ) ):ToScreen()
				elseif IsValid( rag ) then
					pos = rag:GetPos():ToScreen()
				else
					pos = pl:GetPos():ToScreen()
				end
				
				local text = pl:Nick()
				local w = surface.GetTextSize( text ) / 2
				
				if alive then surface.SetDrawColor( 0, 180, 255 ) else surface.SetDrawColor( color_black ) end
				surface.DrawRect( pos.x - w - 5, pos.y - 10, 2, 24 )
				surface.DrawRect( pos.x - w - 5, pos.y, w * 2 + 5, 2 )
				
				if alive then surface.SetTextColor( 0, 180, 255 ) else surface.SetTextColor( color_black ) end
				surface.SetTextPos( pos.x - w, pos.y - 12 )
				surface.DrawText( text )
				
				surface.SetTextPos( pos.x - w, pos.y + 2 )
				surface.DrawText( pl:GetNWInt( 'lvl' ) )
			elseif pl.Spot and pl.Spot > CurTime() and pl:Alive() then
				local pos = ( pl:GetPos() + Vector( 0, 0, pl:OBBMaxs().z ) ):ToScreen()
				local text = pl:Nick()
				local w = surface.GetTextSize( text ) / 2
				local a = math.Clamp( pl.Spot - CurTime(), 0, 0.2 ) * 1275
				
				surface.SetDrawColor( 255, 160, 0, a )
				surface.DrawRect( pos.x - w - 5, pos.y - 10, 2, 12 )
				surface.DrawRect( pos.x - w - 5, pos.y, w * 2 + 5, 2 )
				
				surface.SetTextColor( 255, 160, 0, a )
				surface.SetTextPos( pos.x - w, pos.y - 12 )
				surface.DrawText( text )
			elseif pl:GetNWBool( 'highvalue' ) then
				local pos = ( pl:GetPos() + pl:OBBCenter() ):ToScreen()
				
				surface.SetDrawColor( 0, 0, 0 )
				surface.DrawRect( pos.x - 16, pos.y - 16, 32, 32 )
				
				surface.SetDrawColor( 0, 255, 0 )
				surface.DrawRect( pos.x - 12, pos.y - 12, 24, 24 )
				
				surface.SetDrawColor( 0, 255, 0, ( 1 - a ) * 255 )
				surface.DrawRect( pos.x - x / 2, pos.y - x / 2, x, x )
			end
		end
	end
	
	for _, e in pairs( ents.FindByClass( 'sent_sentry' ) ) do
		local owner = e:GetNWEntity( 'owner' )
		local turret = e:GetNWEntity( 'turret' )
		if self:IsFriendOf( ply, owner ) and IsValid( turret ) then
			local pos = ( turret:GetPos() + turret:OBBCenter() ):ToScreen()
			local text = owner:Nick()
			local w = surface.GetTextSize( text ) / 2
			
			surface.SetDrawColor( 0, 180, 255 )
			surface.DrawRect( pos.x - w - 5, pos.y - 10, 2, 24 )
			surface.DrawRect( pos.x - w - 5, pos.y, w * 2 + 5, 2 )
			
			surface.SetTextColor( 0, 180, 255 )
			surface.SetTextPos( pos.x - w, pos.y - 12 )
			surface.DrawText( text )
			
			surface.SetTextPos( pos.x - w, pos.y + 2 )
			surface.DrawText( 'SENTRY' )
		end
	end
	
	if ply:Armor() > 100 then
		surface.SetDrawColor( 255, 160, 0, math.random( 5, 7 ) )
		surface.DrawRect( 0, 0, w, h )
	end
	
	cam.End2D()
	
	local ctime = CurTime()
	if nv then
		surface.SetDrawColor( 0, 0, 0, 60 )
		
		for i = 1, h, 5 do
			surface.DrawRect( 0, i, w, 2 )
		end
	end
	
	self.DeathAlpha = self.DeathAlpha or 0
	
	if ply:Health() < 40 and ply:Health() > 0 then
		if self.HeartBeat then
			self.HeartBeat:ChangeVolume( 1, 1 )
			self.HeartBeat:ChangePitch( 150, 1 )
		else
			self.HeartBeat = CreateSound( ply, 'player/heartbeat1.wav' )
			self.HeartBeat:Play()
		end
		
		self.DeathAlpha = math.Approach( self.DeathAlpha, 255, 2.55 )
	elseif ply:Health() < 80 and ply:Health() > 0 then
		if self.HeartBeat then
			self.HeartBeat:ChangeVolume( 1 - math.Clamp( ply:Health() / 100, 0.3, 0.8 ), 1 )
			self.HeartBeat:ChangePitch( 120, 1 )
		else
			self.HeartBeat = CreateSound( ply, 'player/heartbeat1.wav' )
			self.HeartBeat:Play()
		end
		
		self.DeathAlpha = math.Approach( self.DeathAlpha, math.Clamp( ply:Health() / 100, 0.2, 0.9 ) * 128, 1.28 )
	else
		if self.HeartBeat then
			self.HeartBeat:ChangeVolume( 0, 1 )
			self.HeartBeat:ChangePitch( 100, 1 )
		end
		
		self.DeathAlpha = self.DeathAlpha - self.DeathAlpha * 0.1
	end
	
	surface.SetMaterial( bloodoverlay )
	surface.SetDrawColor( 255, 255, 255, self.DeathAlpha )
	surface.DrawTexturedRect( 0, 0, w, h )
	
	self:HUD3DEN()
	
	local ok, fail = pcall( self.RenderHUD, self )
	if not ok then
		ErrorNoHalt( fail )
	end
	
	self:HUD3DEX()
	
	cam.Start2D()
	
	surface.SetDrawColor( 0, 0, 0, 200 )
	surface.DrawRect( 0, 0, w, 20 )
	
	surface.SetDrawColor( 255, 255, 0 )
	surface.DrawRect( 0, 20, w, 2 )
	
	local text = 'F1 - Help        F2 - Teams        F3 - Loadout        F4 - Shop'
	surface.SetFont( 'HUD' )
	surface.SetTextPos( 5, 2 )
	surface.SetTextColor( 255, 255, 0 )
	surface.DrawText( text )
	
	local off = surface.GetTextSize( text ) + 10
	surface.DrawRect( off, 0, 2, 20 )
	off = off + 2
	
	if self.AdvertColor then
		local dest = self.Advert and self.Advert > CurTime() and 1 or 0
			self.AdvertPos = self.AdvertPos or 0
			self.AdvertPos = math.Approach( self.AdvertPos, dest, ( self.AdvertPos - dest ) * FrameTime() * 3 )
			self.AdvertColor.a = math.abs( math.sin( CurTime() * 3 ) ) * 200 + 55
			
		if self.AdvertText and self.AdvertPos > 0.1 then		
			surface.SetTextPos( ( w + off - surface.GetTextSize( self.AdvertText ) ) / 2, self.AdvertPos * 15 - 13 )
			surface.SetTextColor( self.AdvertColor )
			surface.DrawText( self.AdvertText )
		end
	end
end

function GM:GetMotionBlurValues( x, y, f, s )
	if f2s_disableblur:GetBool() then return x, y, f, s end
	
	local ply = LocalPlayer()
	if not ply:Alive() then return x, y, f, s end
	
	local w = ply:GetActiveWeapon()
	
	self.MBSpeed = self.MBSpeed or 0
	
	local cf = 1
	if IsValid( w ) then
		if w.GetIronsights and w:GetIronsights() then
			cf = 10
		end
	end
	
	local vel = ply:WorldToLocal( ply:GetVelocity() + ply:GetPos() )
		vel.y = vel.y * 0.1
		
	local vel = vel:Length() * 0.012
	
	self.MBSpeed = math.Approach( self.MBSpeed, vel, ( vel - self.MBSpeed ) * FrameTime() * 20 )
	
	cf = math.max( cf, self.MBSpeed )
	
	local lowh = 0
	if ply:Health() < 30 and ply:Health() > 0 then
		local rate = 1 - ply:Health() / 20
			lowh = math.sin( CurTime() * 6 ) * rate * 0.3
	end
	
	if BLURAMOUNT then BLURAMOUNT = BLURAMOUNT * FrameTime() * 3 end
	return x * 5, y * 5 + math.Rand( -0.1, 0.1 ) * math.Clamp( ( self.LastDamaged or 0 ) + 0.3 - CurTime(), 0, 0.5 ) * 3, f + cf / 200 + lowh + ( BLURAMOUNT or 0 ) * 0.8, s
end

function GM:OnUndo( class )
	notification.AddLegacy( scripted_ents.Get( class ).PrintName, NOTIFY_UNDO, 3 )
	surface.PlaySound( 'buttons/button15.wav' )
end

GM.roll = 0
GM.AngleDelta = 0
GM.OldAngle = Angle()

local weaponcam =
{
	ACT_VM_DRAW,
	ACT_VM_DEPLOY,
	ACT_VM_DRAW_SILENCED,
	ACT_VM_RELOAD,
	ACT_VM_RELOAD_SILENCED,
	ACT_SHOTGUN_RELOAD_START,
	ACT_SHOTGUN_RELOAD_FINISH
}

local busy
function GM:CalcView( ply, origin, angles, ... )
	local v	= ply:GetVehicle()
	local w	= ply:GetActiveWeapon()
	local vm = ply:GetViewModel()
	local nobob = w.NoViewBob and not IsValid( v )
	
	local view = self.BaseClass:CalcView( ply, origin, angles, ... )
	
	if not ply:Alive() then
		local rag = ply:GetObserverTarget()
		if IsValid( rag ) then
			local rpos = rag:GetPos() + rag:OBBCenter()
			
			self.DeathCam = math.min( ( self.DeathCam or 0 ) + FrameTime() * 12, 230 )
			
			view.origin = rpos + Vector( 0, 0, 100 + self.DeathCam )
			view.angles = Angle( 90, 0, 0 )
			view.angles:RotateAroundAxis( Vector( 1, 0, 0 ), math.sin( CurTime() * 1.5 ) * 12 )
		end
		
		return view
	else
		self.DeathCam = 0
	end
	
	if IsValid( vm ) and IsValid( w ) and not nobob and ( busy and busy > CurTime() or self.ShotgunReloading ) and self.LastMuzUp and self.LastMuzUp > CurTime() and self.MuzzleAngle then -- :GetAttachment() bug
		if not self.EffectAngle then self.EffectAngle = Angle() end
		
		self.EffectAngle.p = math.Approach( self.EffectAngle.p, self.MuzzleAngle.p, ( self.EffectAngle.p - self.MuzzleAngle.p ) * FrameTime() * 15 )
		self.EffectAngle.y = math.Approach( self.EffectAngle.y, self.MuzzleAngle.y, ( self.EffectAngle.y - self.MuzzleAngle.y ) * FrameTime() * 15 )
	else
		self.EffectAngle = ( self.EffectAngle or Angle() ) * 0.8
	end
	
	if not f2s_reduceheadbob:GetBool() then
		view.angles.p = view.angles.p - self.EffectAngle.p / 16
		view.angles.y = view.angles.y - self.EffectAngle.y / 32
		view.angles.r = view.angles.r + self.EffectAngle.p / 8
	end
	
	local eyeang = ply:EyeAngles() + ply:GetPunchAngle()
	local ang = self.OldAngle - eyeang
		self.OldAngle = eyeang
	self.Tilt = math.Clamp( math.NormalizeAngle( ang.y ) * 16, -256, 256 )
	
	local time = FrameTime() * 7.5
	local DestY = ply:WorldToLocal( ply:GetVelocity() + ply:GetPos() ).y + self.Tilt + ( ply:GetNWBool( 'sliding' ) and 600 or 0 )
	
	self.VelY = math.Approach( self.VelY or 0, DestY, ( ( self.VelY or 0 ) - DestY ) * time )
	
	local allow = true
	if w.GetIronsights then allow = not w:GetIronsights() end
	
	if allow then view.angles.r = view.angles.r + math.Clamp( self.VelY * -0.03, -16, 16 ) * ( f2s_reduceheadbob:GetBool() and 0.5 or 1 ) end
	
	if view.vm_angles and view.vm_origin then
		local pitch = math.Clamp( ply:GetVelocity().z * 0.03, -5, 5 )
		
		self.AirPitch = self.AirPitch or 0
		self.AirPitch = math.Approach( self.AirPitch, pitch, ( self.AirPitch - pitch ) * FrameTime() * 10 )
		
		view.vm_angles:RotateAroundAxis( view.vm_angles:Right(), self.AirPitch * ( allow and 1 or 0.1 ) )
		
		local vel = ply:GetVelocity():Length2D()
		if ply:IsOnGround() and not ply:GetNWBool( 'sliding' ) then
			if vel > ply:GetRunSpeed() * 0.9 and ply:KeyDown( IN_SPEED ) then
				view.vm_angles.p = view.vm_angles.p + math.sin( CurTime() * 21 )
				view.vm_angles.y = view.vm_angles.y + math.sin( CurTime() * 12 ) * 2
			elseif vel > ply:GetWalkSpeed() * 0.9 and allow then
				view.vm_angles.y = view.vm_angles.y + math.sin( CurTime() * 8 ) * 0.6
				view.vm_origin = view.vm_origin + view.vm_angles:Up() * math.sin( CurTime() * 14 ) * 0.2
			end
		elseif ply:GetNWBool( 'sliding' ) then
			view.vm_origin = view.vm_origin - view.vm_angles:Up() * 3
		end
		
		if vel > ply:GetWalkSpeed() * 0.3 and ply:IsOnGround() then
			self.VMOffsetU = math.Approach( self.VMOffsetU or 0, math.sin( ( self.Flow or 0 ) * 0.01 ), FrameTime() * 5 )
			self.VMOffsetL = math.Approach( self.VMOffsetL or 0, math.sin( ( self.Flow or 0 ) * 0.04 ), FrameTime() * 12 )
		else
			self.VMOffsetU = math.Approach( self.VMOffsetU or 0, 0, ( self.VMOffsetU or 0 ) * FrameTime() * 10 )
			self.VMOffsetL = math.Approach( self.VMOffsetL or 0, 0, ( self.VMOffsetL or 0 ) * FrameTime() * 10 )
		end
		
		view.vm_origin = view.vm_origin + view.angles:Up() * ( self.VMOffsetU ) * 0.01 + view.angles:Right() * ( self.VMOffsetL ) * 0.04
	end
	
	self.AngleDelta = math.max( math.Approach( self.AngleDelta, math.min( math.NormalizeAngle( math.abs( ang.p ) + math.abs( ang.y ) - self.AngleDelta ), 3 ), FrameTime() * 5 ), 0 )
	
	local lowh = 0
	if ply:Health() < 40 and ply:Alive() then
		local rate = 1 - ply:Health() / 20
			lowh = math.sin( CurTime() * 12 ) * rate
	end
	
	local seq = IsValid( vm ) and vm:GetSequence()
	if not IsValid( self.SelectedWeapon ) then self.SelectedWeapon = w end
	if IsValid( vm ) and IsValid( w ) and self.LastVMSeq ~= seq or self.LastWP ~= w then
		self:VMSequenceUpdated( w, vm, self.LastVMSeq, seq )
		self.LastVMSeq = seq
		
		if self.LastWP ~= w then
			self.WeaponSelectionOpen = CurTime() + 0.5
			self.SelectedWeapon = w
			self.LastWP = w
			
			self.ReloadingInit = 0
			self.ReloadingSequenceLen = 0
			self.ReloadingSequence = 0
			
			busy = 0
		end
		
		if seq then
			local seq = vm:GetSequenceActivity( seq )
			
			if table.HasValue( weaponcam, seq ) then
				busy = CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate() - 0.3
			end
		end
	end
	
	self.Flow = ( self.Flow or 0 ) + ply:GetVelocity():Length2D() * FrameTime()
	if self.Flow > 65536 then self.Flow = -65536 end
	
	if not ply:Crouching() and ply:IsOnGround() and allow then
		if ply:GetVelocity():Length2D() > ply:GetRunSpeed() * 0.9 and ply:KeyDown( IN_SPEED ) then
			self.OffsetP = -math.abs( math.sin( CurTime() * 8 ) ) * 2
			self.OffsetY = -math.sin( CurTime() * 12 ) * 3
		elseif ply:GetVelocity():Length2D() > 40 then
			self.OffsetP = -math.abs( math.sin( self.Flow * 0.05 ) ) * 0.75
			self.OffsetY = 0
		else
			self.OffsetP = math.sin( CurTime() * 3 ) * 0.2
			self.OffsetY = math.sin( CurTime() * 1.5 ) * 0.2
		end
	else
		self.OffsetP, self.OffsetY = 0, 0
	end
	
	self.OffsetV = self.OffsetV or Vector()
	
	if self.OffsetP then
		self.OffsetV.x = math.Approach( self.OffsetV.x, self.OffsetP, ( self.OffsetV.x - self.OffsetP ) * FrameTime() * 10 )
		view.angles.p = view.angles.p + self.OffsetV.x * ( f2s_reduceheadbob:GetBool() and 0.5 or 1 )
	end
	
	if self.OffsetY then
		self.OffsetV.y = math.Approach( self.OffsetV.y, self.OffsetY, ( self.OffsetV.y - self.OffsetY ) * FrameTime() * 10 )
		view.angles.y = view.angles.y + self.OffsetV.y * ( f2s_reduceheadbob:GetBool() and 0.5 or 1 )
	end
	
	view.fov = math.max( view.fov + lowh, 0.001 )
	
	return view
end

function GM:AdjustMouseSensitivity()
	local ms = 1
	local ply = LocalPlayer()
	local w = ply:GetActiveWeapon()
	if IsValid( w ) and w.AdjustMouseSensitivity then
		local nms = w:AdjustMouseSensitivity( ms )
		if nms then ms = nms end
	end
	
	if ply:KeyDown( IN_SPEED ) and ply:GetVelocity():Length2D() > ply:GetWalkSpeed() * 0.9 and ply:IsOnGround() then ms = ms * 0.5 end
	return ms
end

function GM:CreateMove( cmd )
	local ang = cmd:GetViewAngles()
			ang.p = math.Clamp( ang.p, LocalPlayer():GetNWBool( 'sliding' ) and -50 or -80, LocalPlayer():GetNWBool( 'sliding' ) and 0 or 77 )
		cmd:SetViewAngles( ang )
		
	return self.BaseClass:CreateMove( cmd )
end

usermessage.Hook( 'spot', function( um )
	local ent = um:ReadEntity()
	if not IsValid( ent ) then return end
	
	ent.Spot = CurTime() + 3
end )