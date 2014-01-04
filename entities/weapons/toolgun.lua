/****************************************************************************
*                                                                           *
* toolgun.lua -- Windows-based toolgun for making things in f2s classic     *
*                                                                           *
* Copyleft (c) NanoCat. All rights free bitches.                            *
*                                                                           *
****************************************************************************/

AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'TOOL GUN'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= false
SWEP.ViewModelFOV		= 60
SWEP.Slot				= 3
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/weapons/c_toolgun.mdl'
SWEP.WorldModel			= 'models/weapons/w_toolgun.mdl'

SWEP.Chambering			= false
SWEP.NoVMBlur			= true
SWEP.Melee_V			= Vector( 0, 0, -5 )
SWEP.Melee_A			= Angle( 25, 30, 0 )

SWEP.Primary.Automatic	= false
SWEP.Primary.ClipSize	= 1
SWEP.Primary.DefaultClip= 1
SWEP.Primary.Delay		= 0.3
SWEP.Primary.Ammo		= 'none'

AddSound( 'Weapon_Toolgun.Single', 'weapons/toolgun.wav' )

SWEP.Primary.Sound		= 'Weapon_Toolgun.Single'

SWEP.Sights_V			= Vector( -10, 6, -6.5 )
SWEP.Sights_A			= Angle( 50, 0, 0 )

SWEP.Run_V				= Vector( 0, 0, -8 )
SWEP.Run_A				= Angle( 30, 0, 0 )

SWEP.Walk_V				= Vector( -2, 1, -2 )
SWEP.Idle_V				= Vector( -2, 1, -1 )
SWEP.Idle_A				= Angle( 0, 0, -5 )

SWEP.DeploySpeed		= 1

SWEP.HoldTypes 			=
{
	Running = 'normal',
	Sights = 'revolver',
	Idle = 'slam'
}

CreateConVar( 'f2s_maxprops', 12, { FCVAR_REPLICATED, FCVAR_ARCHIVE } )

if SERVER then
	concommand.Add( 'f2s_constructor', function( ply, _, args )
		ply.f2s_constructor = args[1]
		ply:SelectWeapon( 'toolgun' )
		ply:GetWeapon( 'toolgun' ):SetNWBool( 'mode', 4 )
	end )
end

local tools =
{
	{
		name = 'Ammo crate spawner',
		fire = function( self, tr )
			for _, v in pairs( ents.FindByClass( 'sent_ammocrate' ) ) do
				if v:GetNWEntity( 'owner' ) == self.Owner then
					return SERVER and self.Owner:ChatPrint( 'You already have an ammo crate elsewhere' )
				end
			end
			
			if SERVER then
				local ang = tr.HitNormal:Angle()
					ang:RotateAroundAxis( ang:Right(), -90 )
					ang:RotateAroundAxis( ang:Up(), 180 )
					ang:RotateAroundAxis( ang:Up(), self:GetOwnerAngles() )
					
				local crate = ents.Create( 'sent_ammocrate' )
					crate:SetNWEntity( 'owner', self.Owner )
					crate:SetPos( tr.HitPos + ang:Up() * 15 )
					crate:SetAngles( ang )
					crate:Spawn()
					
				for _, v in pairs( ents.FindInSphere( crate:GetPos() + crate:OBBCenter(), crate:BoundingRadius() ) ) do
					if v:IsPlayer() and ( GAMEMODE:IsColliding( v, crate ) or GAMEMODE:IsColliding( crate, v ) ) then
						self.Owner:ChatPrint( 'Obstruction detected, building canceled.' )
						crate:Remove()
						
						return false
					end
				end
				
				undo.Create( 'sent_ammocrate' )
					undo.AddEntity( crate )
					undo.SetPlayer( self.Owner )
				undo.Finish()
			end
			
			return true
		end,
		preview = function( self, tr )
			local ang = tr.HitNormal:Angle()
				ang:RotateAroundAxis( ang:Right(), -90 )
				ang:RotateAroundAxis( ang:Up(), 180 )
				ang:RotateAroundAxis( ang:Up(), self:GetOwnerAngles() )
			
			return 'models/items/ammocrate_smg1.mdl', tr.HitPos + ang:Up() * 15, ang
		end
	},
	{
		name = 'Spawn beacon creator',
		fire = function( self, tr )
			if math.abs( tr.HitNormal.z ) < 0.7 then return end
			
			local count = 0
			for _, v in pairs( ents.FindByClass( 'sent_radar' ) ) do
				if v:GetNWEntity( 'owner' ) == self.Owner or v:GetOwner() == self.Owner then
					count = count + 1
					
					if count > 4 then
						return SERVER and self.Owner:ChatPrint( 'You have used all of your spawn beacons already' )
					end
				end
			end
			
			if SERVER then
				local ang = tr.HitNormal:Angle()
					ang:RotateAroundAxis( ang:Right(), -90 )
					ang:RotateAroundAxis( ang:Up(), 180 )
					ang:RotateAroundAxis( ang:Up(), self:GetOwnerAngles() )
					
				local radar = ents.Create( 'sent_radar' )
					radar:SetPos( tr.HitPos - ang:Up() )
					radar:SetAngles( ang )
					radar:SetOwner( self.Owner )
					radar:SetNWEntity( 'owner', self.Owner )
					radar:Spawn()
					
				for _, v in pairs( ents.FindInSphere( radar:GetPos() + radar:OBBCenter(), radar:BoundingRadius() ) ) do
					if v:IsPlayer() and ( GAMEMODE:IsColliding( v, radar ) or GAMEMODE:IsColliding( radar, v ) ) then
						self.Owner:ChatPrint( 'Obstruction detected, building canceled.' )
						radar:Remove()
						
						return false
					end
				end
				
				undo.Create( 'sent_radar' )
					undo.AddEntity( radar )
					undo.SetPlayer( self.Owner )
				undo.Finish()
			end
			
			return true
		end,
		preview = function( self, tr )
			local ang = tr.HitNormal:Angle()
				ang:RotateAroundAxis( ang:Right(), -90 )
				ang:RotateAroundAxis( ang:Up(), 180 )
				ang:RotateAroundAxis( ang:Up(), self.Owner:EyeAngles().y )
			
			return 'models/props_combine/combine_mine01.mdl', tr.HitPos - ang:Up(), ang
		end
	},
	{
		name = 'Stacker',
		fire = function( self, tr )
			local ent = tr.Entity
			if not IsValid( ent ) or ent:GetClass() ~= 'prop_destructable' then return end
			
			local count = 0
			local max = GetConVarNumber( 'f2s_maxprops' )
			for _, v in pairs( ents.FindByClass( 'prop_destructable' ) ) do
				if v:GetNWEntity( 'owner' ) == self.Owner then
					count = count + 1
					if count >= max then return SERVER and self.Owner:ChatPrint( 'You have used all of your props already' ) end
				end
			end
			
			local obb, ang = Vector(), ent:GetAngles()
			local mins, maxs = Vector(), Vector()
			
			if SERVER then
				local prop = ents.Create( 'prop_destructable' )
					prop:SetNWEntity( 'owner', self.Owner )
					prop:SetPos( ent:GetPos() )
					prop:SetAngles( ent:GetAngles() )
					prop:SetModel( ent:GetModel() )
					prop:Spawn()
				
				if IsValid( prop ) then
					mins = prop:OBBMins()
					maxs = prop:OBBMaxs()
				end
				
				local dir = self:GetNWInt( 'stack' )
				if dir == 0 then
					obb = ( maxs.x - mins.x - 1 ) * ang:Forward()
				elseif dir == 1 then
					obb = ( maxs.x - mins.x - 1 ) * ang:Forward() * -1
				elseif dir == 2 then
					obb = ( maxs.y - mins.y - 1 ) * ang:Right()
				elseif dir == 3 then
					obb = ( maxs.y - mins.y - 1 ) * ang:Right() * -1
				elseif dir == 4 then
					obb = ( maxs.z - mins.z - 1 ) * ang:Up()
				elseif dir == 5 then
					obb = ( maxs.z - mins.z - 1 ) * ang:Up() * -1
				end
				
				prop:SetPos( prop:GetPos() + obb )
				
				undo.Create( 'prop_destructable' )
					undo.AddEntity( prop )
					undo.SetPlayer( self.Owner )
				undo.Finish()
			end
			
			return true
		end,
		preview = function( self, tr )
			local ent = tr.Entity
			if not IsValid( ent ) or ent:GetClass() ~= 'prop_destructable' then return end
			
			local obb, ang = Vector(), ent:GetAngles()
			local mins, maxs = Vector(), Vector()
			
			if IsValid( self.Preview ) then
				self.Preview:SetModel( ent:GetModel() )
				
				mins = self.Preview:OBBMins()
				maxs = self.Preview:OBBMaxs()
			end
			
			local dir = self:GetNWInt( 'stack' )
			if dir == 0 then
				obb = ( maxs.x - mins.x - 1 ) * ang:Forward()
			elseif dir == 1 then
				obb = ( maxs.x - mins.x - 1 ) * ang:Forward() * -1
			elseif dir == 2 then
				obb = ( maxs.y - mins.y - 1 ) * ang:Right()
			elseif dir == 3 then
				obb = ( maxs.y - mins.y - 1 ) * ang:Right() * -1
			elseif dir == 4 then
				obb = ( maxs.z - mins.z - 1 ) * ang:Up()
			elseif dir == 5 then
				obb = ( maxs.z - mins.z - 1 ) * ang:Up() * -1
			end
			
			return ent:GetModel(), ent:GetPos() + obb, ent:GetAngles()
		end,
		reload = function( self )
			if SERVER then
				self.Owner:SendLua( 'surface.PlaySound("suit/switch.wav")' )
				
				self:SetNWInt( 'stack', self:GetNWInt( 'stack' ) + 1 )
				if self:GetNWInt( 'stack' ) > 5 then self:SetNWInt( 'stack', 0 ) end
			end
		end
	},
	{
		name = 'Constructor',
		fire = function( self, tr )
			local mdl = self.Owner.f2s_constructor or 'models/props_phx/construct/metal_plate1.mdl'
			if not table.HasValue( GAMEMODE.Props, mdl ) then return end
			
			local count = 0
			local max = GetConVarNumber( 'f2s_maxprops' )
			for _, v in pairs( ents.FindByClass( 'prop_destructable' ) ) do
				if v:GetNWEntity( 'owner' ) == self.Owner then
					count = count + 1
					if count >= max then return SERVER and self.Owner:ChatPrint( 'You have used all of your props already' ) end
				end
			end
			
			local ang = ( self.EAngle or Angle() ) * 1
				ang.y = ang.y + self.Owner:EyeAngles().y
				--ang:RotateAroundAxis( Vector( 1, 0, 0 ), 90 )
				
			if self.Owner:KeyDown( IN_SPEED ) then
				ang.p = math.Round( ang.p / 45 ) * 45
				ang.y = math.Round( ang.y / 45 ) * 45
				ang.r = math.Round( ang.r / 45 ) * 45
			else
				ang.p = math.Round( ang.p / 5 ) * 5
				ang.y = math.Round( ang.y / 5 ) * 5
				ang.r = math.Round( ang.r / 5 ) * 5
			end
			
			if SERVER then
				local prop = ents.Create( 'prop_destructable' )
					prop:SetNWEntity( 'owner', self.Owner )
					prop:SetModel( mdl )
					prop:Spawn()
				
				if GAMEMODE.PropPatch[ mdl ] then
					local patch = table.Copy( GAMEMODE.PropPatch[ prop:GetModel() ] )
						ang:RotateAroundAxis( ang:Forward(), patch[1].r )
						ang:RotateAroundAxis( ang:Up(), patch[1].y )
						ang:RotateAroundAxis( ang:Right(), patch[1].p )
					tr.HitPos = tr.HitPos + tr.HitNormal * patch[2]
				end
				
				local mins, maxs, center = prop:OBBMins(), prop:OBBMaxs(), prop:OBBCenter()
				if math.abs( tr.HitNormal.z ) > 0.7 then
					if tr.HitNormal.z > 0 then
						tr.HitPos = tr.HitPos - ( ang:Forward() * center.x + ang:Right() * center.y + ang:Up() * mins.z )
					else
						tr.HitPos = tr.HitPos - ( ang:Forward() * center.x + ang:Right() * center.y + ang:Up() * maxs.z )
					end
				else
					tr.HitPos = tr.HitPos - ( ang:Forward() * center.x + ang:Right() * center.y + ang:Up() * center.z )
				end
				
				prop:SetPos( tr.HitPos )
				prop:SetAngles( ang )
				
				undo.Create( 'prop_destructable' )
					undo.AddEntity( prop )
					undo.SetPlayer( self.Owner )
				undo.Finish()
			end
			
			return true
		end,
		preview = function( self, tr )
			local ang = ( self.EAngle or Angle() ) * 1
				ang.y = ang.y + self.Owner:EyeAngles().y
			
			if self.Owner:KeyDown( IN_SPEED ) then
				ang.p = math.Round( ang.p / 45 ) * 45
				ang.y = math.Round( ang.y / 45 ) * 45
				ang.r = math.Round( ang.r / 45 ) * 45
			else
				ang.p = math.Round( ang.p / 5 ) * 5
				ang.y = math.Round( ang.y / 5 ) * 5
				ang.r = math.Round( ang.r / 5 ) * 5
			end
			
			local prop = self.Preview
			if IsValid( self.Preview ) then
				prop:SetModel( f2s_constructor )
				
				if GAMEMODE.PropPatch[ f2s_constructor ] then
					local patch = table.Copy( GAMEMODE.PropPatch[ prop:GetModel() ] )
						ang:RotateAroundAxis( ang:Forward(), patch[1].r )
						ang:RotateAroundAxis( ang:Up(), patch[1].y )
						ang:RotateAroundAxis( ang:Right(), patch[1].p )
					tr.HitPos = tr.HitPos + tr.HitNormal * patch[2]
				end
				
				local mins, maxs, center = prop:OBBMins(), prop:OBBMaxs(), prop:OBBCenter()
				if math.abs( tr.HitNormal.z ) > 0.7 then
					if tr.HitNormal.z > 0 then
						tr.HitPos = tr.HitPos - ( ang:Forward() * center.x + ang:Right() * center.y + ang:Up() * mins.z )
					else
						tr.HitPos = tr.HitPos - ( ang:Forward() * center.x + ang:Right() * center.y + ang:Up() * maxs.z )
					end
				else
					tr.HitPos = tr.HitPos - ( ang:Forward() * center.x + ang:Right() * center.y + ang:Up() * center.z )
				end
			end
			
			return f2s_constructor, tr.HitPos, ang
		end
	},
	{
		name = 'Destructor',
		fire = function( self, tr )
			local ent = tr.Entity
			if not IsValid( ent ) then return end
			if ent:GetNWEntity( 'owner' ) ~= self.Owner then return end
			
			ent:Destroy()
			
			return true
		end,
		preview = function() end
	},
	{
		name = 'Blowtorch',
		fire = function( self, tr )
		end,
		preview = function( self )
			cam.Start2D()
			
			for _, e in pairs( ents.FindInSphere( self.Owner:GetShootPos(), 256 ) ) do
				if e.Blowtorch then
					local v = ( e:GetPos() + e:OBBCenter() ):ToScreen()
					
					surface.SetDrawColor( color_white )
					surface.DrawOutlinedRect( v.x - 24, v.y - 9, 48, 18 )
					
					local p = e:GetNWInt( 'hp' ) / e.MaxHealth
					
					surface.SetDrawColor( 255 * ( 1 - p ), 255 * p, 0 )
					surface.DrawRect( v.x - 22, v.y - 7, 44 * p, 14 )
				end
			end
			
			cam.End2D()
		end,
		think = function( self )
			if not self.Owner:KeyDown( IN_ATTACK ) or self:IsRunning() or self:GetIronsights() or ( self.NextTorchEffect or 0 ) > CurTime() then return end
				self.NextTorchEffect = CurTime() + 0.05
				
			local tr = util.TraceLine( {
				start = self.Owner:GetShootPos(),
				endpos = self.Owner:GetShootPos() + ( self.Owner:EyeAngles() + self.Owner:GetPunchAngle() ):Forward() * 64,
				filter = self.Owner
			} )
			
			local ent = tr.Entity
			if not IsValid( ent ) or not ent.Blowtorch and not ent:IsPlayer() and not ent:IsNPC() then return end
			
			local friendly
			if not ent:IsPlayer() and not ent:IsNPC() then
					friendly = GAMEMODE:IsFriendOf( ent:GetNWEntity( 'owner' ), self.Owner )
				if friendly and ent:GetNWInt( 'hp' ) >= ent.MaxHealth or not friendly and ent:GetNWInt( 'hp' ) <= 0 then return end
			end
			
			if SERVER then
				if ent:IsPlayer() or ent:IsNPC() then
					local dmg = DamageInfo()
						dmg:SetDamageType( DMG_SHOCK )
						dmg:SetDamage( 2 )
						dmg:SetAttacker( self.Owner )
						dmg:SetInflictor( self )
						ent:TakeDamageInfo( dmg )
				elseif friendly then
					ent:SetNWInt( 'hp', ent:GetNWInt( 'hp' ) + math.min( ent.MaxHealth - ent:GetNWInt( 'hp' ), 25 ) )
				else
					ent.Attacker = self.Owner
					ent:SetNWInt( 'hp', ent:GetNWInt( 'hp' ) - math.min( ent:GetNWInt( 'hp' ), 10 ) )
				end
			end
			
			local fx = EffectData()
				fx:SetOrigin( tr.HitPos )
				fx:SetNormal( tr.HitNormal )
			util.Effect( 'hl2_blowtorch', fx )
			
			self.Owner:MuzzleFlash()
			self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
			sound.Play( 'weapons/blowtorch.wav', tr.HitPos, 50 )
		end
	},
	{
		name = 'Door module',
		fire = function( self, tr )
			if not tr.Hit then return end
			if not IsValid( tr.Entity ) then return end
			
			local ent = tr.Entity
			if ent:GetClass() ~= 'prop_destructable' then return end
			if not GAMEMODE:IsFriendOf( ent:GetNWEntity( 'owner' ), self.Owner ) then return end
			
			for _, e in pairs( ents.FindByClass( 'prop_physics' ) ) do
				if e:GetParent() == ent and e:GetModel() == 'models/weapons/w_slam.mdl' then return end
			end
			
			if SERVER then
				local ang = tr.HitNormal:Angle()
					ang:RotateAroundAxis( ang:Right(), -90 )
					
				local slam = ents.Create( 'prop_physics' )
					slam:SetPos( tr.HitPos + tr.HitNormal * 1.9 )
					slam:SetAngles( ang )
					slam:SetParent( ent )
					slam:SetModel( 'models/weapons/w_slam.mdl' )
					slam:Spawn()
					slam:SetNotSolid( true )
					
				ent.DoorModule = slam
				
				undo.Create( 'prop_destructable' )
					undo.AddEntity( slam )
					undo.SetPlayer( self.Owner )
				undo.Finish()
			end
			
			return true
		end,
		preview = function() end
	}
}

if CLIENT then
	usermessage.Hook( 'eang', function( um )
		um:ReadEntity().EAngle = um:ReadAngle()
	end )
	
	hook.Add( 'CreateMove', 'TOOLGUN', function( cmd )
		if not game.SinglePlayer() then return end
		
		local w = LocalPlayer():GetActiveWeapon()
		if IsValid( w ) and w:GetClass() == 'toolgun' and cmd:KeyDown( IN_USE ) then
			w.EAngle = w.EAngle or Angle()
			w.EAngle:RotateAroundAxis( Vector( 0, 0, 1 ), cmd:GetMouseX() * 0.02 )
			w.EAngle:RotateAroundAxis( Vector( 0, -1, 0 ), cmd:GetMouseY() * 0.02 )
		end
	end )
	
	hook.Add( 'PlayerDisconnect', 'ONDISCONNECT', function( ply )
		for _, e in pairs( ents.GetAll() ) do
			if e:GetNWEntity( 'owner' ) == ply then e:Remove() end
		end
	end )
end

function SWEP:Initialize()
	if CLIENT then
		self.Screen = GetRenderTarget( 'Toolscreen', 256, 256 )
			Material( 'models/weapons/v_toolgun/screen' ):SetTexture( '$basetexture', self.Screen )
	end
	
	return self.BaseClass.Initialize( self )
end

function SWEP:Deploy()
	umsg.Start( 'tool_draw', self.Owner )
		umsg.Entity( self )
	umsg.End()
	
	if self:GetNWInt( 'mode' ) == 0 then self:SetNWInt( 'mode', 1 ) end
	return self.BaseClass.Deploy( self )
end

function SWEP:GetOwnerAngles()
	return self.Owner:KeyDown( IN_SPEED ) and self.Owner:EyeAngles().y or math.Round( self.Owner:EyeAngles().y / 45 ) * 45
end

if CLIENT then
	surface.CreateFont( 'WINDOWS', {
		font		= 'arial',
		size		= 52,
		weight		= 1000,
		bold		= true
	} )
end

SWEP.Time = 0

local grad = CLIENT and surface.GetTextureID( 'gui/center_gradient' )
local left = CLIENT and surface.GetTextureID( 'gui/gradient_down' )
local right = CLIENT and surface.GetTextureID( 'gui/gradient_up' )

function SWEP:DrawBar( x, y, w, h )
	w = w - 4
	
	surface.SetDrawColor( 10, 35, 105 )
	surface.DrawRect( x + 2, y + 2, w, h )
	
	surface.SetTexture( right )
	surface.SetDrawColor( 165, 200, 240 )
	surface.DrawTexturedRectRotated( x + 2 + w / 2, y + 2 + h / 2, h, w, 90 )
end

function SWEP:Tick()
	if self:GetIronsights() then
			self.Mouse = math.Clamp( ( self.Mouse or 0 ) + self.Owner:GetCurrentCommand():GetMouseY() * 0.01, 1, #tools )
		if SERVER and self:GetNWInt( 'mode' ) ~= math.Round( self.Mouse ) then self:SetNWInt( 'mode', math.Round( self.Mouse ) ) end
		
		return
	end
	
	if self.Owner:KeyDown( IN_USE ) then
		self.EAngle = self.EAngle or Angle()
		self.EAngle:RotateAroundAxis( Vector( 0, 0, 1 ), self.Owner:GetCurrentCommand():GetMouseX() * 0.02 )
		self.EAngle:RotateAroundAxis( Vector( 0, -1, 0 ), self.Owner:GetCurrentCommand():GetMouseY() * 0.02 )
		
		if ( self.NextSend or 0 ) < CurTime() then
			self.NextSend = CurTime() + 0.1
			
			if SERVER then
				umsg.Start( 'eang', self.Owner )
					umsg.Entity( self )
					umsg.Angle( self.EAngle )
				umsg.End()
			end
		end
	end
end

function SWEP:Think()
	if self.Startup and self.Startup > CurTime() then return end
	local mode = tools[ self:GetNWInt( 'mode' ) ]
	
	if mode and mode.think then mode.think( self ) end
	if not self.Owner:KeyDown( IN_RELOAD ) then self.Reloaded = false end
	
	return self.BaseClass.Think( self )
end

function SWEP:RenderScreen()
	local w, h = ScrW(), ScrH()
	local oldrt = render.GetRenderTarget()
	
	if self.Screen then
		render.SetRenderTarget( self.Screen )
		render.SetViewPort( 0, 0, 256, 256 )
		cam.Start2D()
			if self.Startup and self.Startup > CurTime() then
				render.Clear( 0, 0, 0, 255 )
				
				surface.SetFont( 'HUD' )
				surface.SetTextColor( color_white )
				
				surface.SetTextPos( 5, 237 )
				surface.DrawText( 'Copyleft (C) NanoCat' )
				
				surface.SetFont( 'ScoreboardDefault' )
				surface.SetTextPos( 30, 105 )
				surface.DrawText( 'NanoCat' )
				
				surface.SetDrawColor( 255, 60, 10 )
				surface.DrawRect( 115, 20, 50, 50 )
				surface.SetDrawColor( 60, 255, 10 )
				surface.DrawRect( 170, 20, 50, 50 )
				
				surface.SetDrawColor( 30, 90, 255 )
				surface.DrawRect( 115, 75, 50, 50 )
				surface.SetDrawColor( 255, 255, 10 )
				surface.DrawRect( 170, 75, 50, 50 )
				
				surface.SetFont( 'WINDOWS' )
				surface.SetTextPos( 30, 125 )
				surface.DrawText( 'Wind0wz' )
				
				surface.SetDrawColor( 0, 0, 255 )
				
				local i = math.Round( self.Time )
				if i > -1 and i < 11 then surface.DrawRect( 35 + i * 17, 189, 15, 19 ) end
				if i > -2 and i < 10 then surface.DrawRect( 52 + i * 17, 189, 15, 19 ) end
				if i > -3 and i < 9 then surface.DrawRect( 69 + i * 17, 189, 15, 19 ) end
				
				surface.SetDrawColor( color_white )
				surface.DrawOutlinedRect( 32, 186, 192, 25 )
				
				surface.SetTexture( grad )
				surface.SetDrawColor( 255, 255, 255, 127 )
				
				if i > -1 and i < 11 then surface.DrawTexturedRectRotated( 43 + i * 17, 198, 21, 15, 90 ) end
				if i > -2 and i < 10 then surface.DrawTexturedRectRotated( 60 + i * 17, 198, 21, 15, 90 ) end
				if i > -3 and i < 9 then surface.DrawTexturedRectRotated( 77 + i * 17, 198, 21, 15, 90 ) end
				
				self.Time = self.Time + FrameTime() * 10
				
				if self.Time > 11 then self.Time = -3 end
			else
				render.Clear( 0, 78, 152, 255 )
				
				surface.SetFont( 'Default' )
				surface.SetTextColor( color_black )
				
				surface.SetDrawColor( 212, 208, 200 )
				surface.DrawRect( 0, 230, 256, 26 )
				
				surface.SetDrawColor( color_black )
				surface.DrawOutlinedRect( 4, 232, 40, 20 )
				
				local taskbar = 52
				
				if self:GetIronsights() then
					surface.DrawOutlinedRect( taskbar, 232, 80, 20 )
					surface.SetTextPos( taskbar + 40 - surface.GetTextSize( 'ToolGun mode' ) / 2, 235 )
					surface.DrawText( 'ToolGun mode' )
					
					surface.SetDrawColor( 212, 208, 200 )
					surface.DrawRect( 32, 38, 192, 166 )
					
					self:DrawBar( 32, 38, 192, 20 )
					
					surface.SetFont( 'HUD' )
					surface.SetTextPos( 38, 41 )
					surface.SetTextColor( color_white )
					surface.DrawText( 'ToolGun mode' )
					
					surface.SetDrawColor( 212, 208, 200 )
					surface.DrawRect( 200, 42, 20, 16 )
					
					surface.SetTexture( 0 )
					surface.SetDrawColor( color_black )
					surface.DrawTexturedRectRotated( 210, 50, 2, 16, 52 )
					surface.DrawTexturedRectRotated( 210, 50, 2, 16, -52 )
					
					surface.SetDrawColor( 160, 160, 160 )
					surface.DrawOutlinedRect( 200, 42, 20, 16 )
					surface.DrawOutlinedRect( 34, 68, 188, 134 )
					surface.DrawOutlinedRect( 38, 76, 180, 122 )
					
					surface.SetFont( 'DermaDefault' )
					surface.SetTextColor( color_black )
					surface.SetTextPos( 38, 61 )
					surface.DrawText( 'Select a mode from list below' )
					
					surface.SetDrawColor( color_white )
					surface.DrawRect( 39, 77, 178, 120 )
					
					surface.SetDrawColor( 10, 35, 105 )
					
					local revert = false
					for k, v in pairs( tools ) do
						if k == self:GetNWInt( 'mode' ) then
							surface.DrawRect( 39, 62 + k * 15, 178, 15 )
							surface.SetTextColor( color_white )
						end
						
						surface.SetTextPos( 42, 62 + k * 15 )
						surface.DrawText( v.name )
						surface.SetTextColor( color_black )
					end
					
					taskbar = taskbar + 85
				end
				
				surface.SetTextColor( color_black )
				surface.SetTextPos( 11, 235 )
				surface.DrawText( 'Start' )
			end
		cam.End2D()
		render.SetViewPort( 0, 0, w, h )
		render.SetRenderTarget( oldrt )
	end
end

function SWEP:ViewModelDrawn()
	if self.Startup and self.Startup > CurTime() then return end
	local mode = tools[ self:GetNWInt( 'mode' ) ]
	
	if mode and mode.preview then
		local tr = util.TraceLine( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + ( self.Owner:EyeAngles() + self.Owner:GetPunchAngle() ):Forward() * 128,
			filter = self.Owner
		} )
		
		local allowclick = tr.Hit and not tr.HitSky
		if not allowclick then tr.HitNormal = -tr.HitNormal:Angle():Forward() end
		if IsValid( tr.Entity ) and ( tr.Entity:GetClass() ~= 'prop_physics' and tr.Entity:GetClass() ~= 'prop_destructable' ) then allowclick = false end
		
		local mdl, pos, ang = mode.preview( self, tr )
		if not mdl then
			if IsValid( self.Preview ) then self.Preview:Remove() end
			return
		end
		
		if not pos or not ang then return end
		
		if not IsValid( self.Preview ) then
			self.Preview = ClientsideModel( mdl, RENDERGROUP_TRANSLUCENT )
			self.Preview:SetRenderMode( RENDERMODE_TRANSALPHA )
			self.Preview:SetColor( Color( 255, 255, 255, 225 ) )
		end
		
		if self.Preview:GetModel() ~= mdl then self.Preview:SetModel( mdl ) end
		
		self.Preview:SetPos( pos )
		self.Preview:SetAngles( ang )
		
		if allowclick then self.Preview:SetColor( Color( 255, 255, 255, 225 ) )
		else self.Preview:SetColor( Color( 255, 0, 0, 225 ) ) end			
	end
end

function SWEP:Holster( ... )
	if IsValid( self.Preview ) then self.Preview:Remove() end
	return self.BaseClass.Holster( self, ... )
end

function SWEP:OnRemove()
	if IsValid( self.Preview ) then self.Preview:Remove() end
end

function SWEP:PrimaryAttack()
	if self:IsRunning() or self:GetIronsights() then return end
	local mode = tools[ self:GetNWInt( 'mode' ) ]
	
	if mode and mode.fire then
		local tr = util.TraceLine( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + ( self.Owner:EyeAngles() + self.Owner:GetPunchAngle() ):Forward() * 128,
			filter = self.Owner
		} )
		
		local allowclick = tr.Hit and not tr.HitSky
		if IsValid( tr.Entity ) and ( tr.Entity:GetClass() ~= 'prop_physics' and tr.Entity:GetClass() ~= 'prop_destructable' ) then allowclick = false end
		
		if allowclick and mode.fire( self, tr ) then
			self:EmitSound( self.Primary.Sound )
			self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
			
			local fx = EffectData()
				fx:SetOrigin( tr.HitPos )
				fx:SetNormal( tr.HitNormal )
			util.Effect( 'hl2_toolgunring', fx )
		end
	end
end

function SWEP:Reload()
	if self:IsRunning() or self:GetIronsights() or self.Reloaded then return end
	local mode = tools[ self:GetNWInt( 'mode' ) ]
	
	self.Reloaded = true
	
	if mode and mode.reload then
		mode.reload( self )
	end
end

function SWEP:FreezeMovement()
	return self:GetIronsights() or self.Owner:KeyDown( IN_USE )
end

if CLIENT then
	usermessage.Hook( 'tool_draw', function( um )
		um:ReadEntity().Startup = CurTime() + 1
	end )
end