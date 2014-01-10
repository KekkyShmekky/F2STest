AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'OVERWATCH STANDARD ISSUE PULSE RIFLE'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 60
SWEP.Slot				= 0
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/weapons/c_irifle.mdl'
SWEP.WorldModel			= 'models/weapons/w_irifle.mdl'
SWEP.IconLetter			= '\x3A'
SWEP.DistantSound		= 'Distant.Rifle'
SWEP.JamChance			= 2048
SWEP.Price				= 8000
SWEP.Level				= 6
SWEP.Gaben				= 'Combine\'s pulse rifle. New-tech weapon. Has short barrel that doesn\'t give much accuracy.\nHas no chamber, very reliable. Has built-in energy ball launcher.\nThat\'s all I can say about it.'
SWEP.Chambering			= false
SWEP.NoCustomMuzzle		= true
SWEP.NoIdleAfterReload	= true
SWEP.NoViewBob			= true
SWEP.AcogFOVOffset		= -3

SWEP.CanBeReloadedWhileRunning = true
SWEP.Attachments		=
{
	{
		laser =
		{
			vm =
			{
				bone = 'Base',
				pos = Vector( 0.3, -1.8, 12 ),
				ang = Angle( 0, 90, 180 )
			},
			wm =
			{
				pos = Vector( 10, -0.2, 6 ),
				ang = Angle( 102.5, 0, 0 )
			}
		}
	},
	{
		holosight =
		{
			vm =
			{
				bone = 'Base',
				pos = Vector( 0.02, -2.6, 7.3 ),
				ang = Angle( 0, 0, -90 )
			},
			wm =
			{
				pos = Vector( 13, 1, 7.4 ),
				ang = Angle( 10, 90, 0 )
			},
			init =
			{
				Sights_V = Vector( -5, 5.85, 0.42 ),
				Sights_A = Angle( 1.2, 0.08, 0 )
			}
		},
		acog =
		{
			vm =
			{
				bone = 'Base',
				pos = Vector( -0.34, 2.9, -2.8 ),
				ang = Angle( 0, 0, -90 ),
				
				scope = Angle( 0, -90, -90 )
			},
			wm =
			{
				pos = Vector( 3, 1.6, 1.3 ),
				ang = Angle( 10, 90, 0 )
			},
			init = { Sights_V = Vector( -6, 5.85, 0.1 ) }
		}
	}
}

SWEP.Melee_V			= Vector( -10, -10, -15 )
SWEP.Melee_A			= Angle( 0, 90, -50 )

SWEP.Primary.Tracer		= 'AirboatGunTracer'
SWEP.Primary.Damage 	= 19
SWEP.Primary.Automatic	= true
SWEP.Primary.ClipSize	= 30
SWEP.Primary.DefaultClip= 30
SWEP.Primary.Delay		= 0.09
SWEP.Primary.Cone		= 0.1
SWEP.Primary.Ammo		= 'ar2'

SWEP.Secondary.SoundLevel= 100
SWEP.Secondary.Sound	= 'Weapon_CombineGuard.Special1'
SWEP.Secondary.Ammo		= 'ar2altfire'

AddSound( 'Weapon_AR2.Shotgun', 'weapons/shotgun_silent.wav' )

SWEP.Primary.Sound		= 'Weapon_Functank.Single'

SWEP.Sights_V			= Vector( -5, 5.83, 1.25 )
SWEP.Sights_A			= Angle()

SWEP.Run_V				= Vector( 0, -5, -2 )
SWEP.Run_A				= Angle( -5, -40, 10 )

SWEP.Walk_V				= Vector( 0, 0, -2 )
SWEP.Idle_V				= Vector( 0, 0, -1 )
SWEP.Idle_A				= Angle()

SWEP.DeployTime			= 0.1

SWEP.Multipliers 			=
{
	Fly = 2,
	Walk = 1.3,
	Idle = 1,
	Crouch = 0.8,
	Sights = 0.15
}

SWEP.Recoil 			=
{
	Single = false,
	Min = 0,
	Max = 8,
	ContRecoil = 0.1,
	Punch = Angle( 0.7, 0, 0 ),
	Real = Angle( 0.07, 0, 0 )
}

SWEP.HoldTypes 			=
{
	Running = 'passive',
	Sights = 'ar2',
	Idle = 'shotgun',
	Reload = 'ar2'
}

hook.Add( 'EntityTakeDamage', 'AR2_Ball', function( ent, dmg )
	if IsValid( dmg:GetInflictor() ) and dmg:GetInflictor():GetClass() == 'prop_combine_ball' then
		dmg:ScaleDamage( 3 )
		
		local owner = dmg:GetInflictor():GetNWEntity( 'owner' )
		if IsValid( owner ) then dmg:SetAttacker( owner ) end
	end
end )

hook.Add( 'OnEntityCreated', 'AR2_Ball', function( ent )
	if SERVER and ent:GetClass() == 'prop_combine_ball' then
		local ents = ents.FindInSphere( ent:GetPos(), 1 )
		for _, v in pairs( ents ) do
			if v:IsPlayer() then
				ent:SetNWEntity( 'owner', v )
				ent:SetCollisionGroup( COLLISION_GROUP_PLAYER )
			end
		end
	end
end )

function SWEP:DoImpactEffect( tr )
	local fx = EffectData()
		fx:SetOrigin( tr.HitPos )
		fx:SetNormal( tr.HitNormal )
	util.Effect( 'AR2Impact', fx )
end

function SWEP:PrimaryAttack( ... )	
	if not self.Primary.Automatic and self:Clip1() > 4 then
		self.Primary.TakeAmmo = 5
		self.Primary.NumShots = 5
		self.Primary.Delay = 0.2
		self.Primary.Cone = 0.15
		self.Recoil.Single = true
		self.Recoil.Real = Angle( 3, 0, 0 )
		self.Recoil.Punch = Angle( 6, 0, 0 )
		self.Primary.Sound = 'Weapon_AR2.Shotgun'
	else
		self.Primary.TakeAmmo = nil
		self.Primary.NumShots = 1
		self.Primary.Delay = 0.09
		self.Primary.Cone = 0.1
		self.Recoil.Single = false
		self.Recoil.Real = Angle( 0.1, 0, 0 )
		self.Recoil.Punch = Angle( 1, 0, 0 )
		self.Primary.Sound = 'Weapon_Functank.Single'
	end
	
	if self:GetNWBool( 'launcher' ) and not self:IsRunning( true ) then
		if self.Owner:GetAmmoCount( self:GetSecondaryAmmoType() ) <= 0 then
				self:SetNextPrimaryFire( CurTime() + 0.3 )
			return self:EmitSound( self.JamSound )
		end
		
		self:SendWeaponAnim( ACT_VM_FIDGET )
		self:EmitSound( self.Secondary.Sound, self.Secondary.SoundLevel )
		self:SetNextPrimaryFire( CurTime() + 1.7 )
		self.BallLaunch = CurTime() + 0.63
		
		return self:TakeSecondaryAmmo( 1 )
	end
	
	if not self.Primary.Automatic then self.DisableConeMultipliers = true end
	self.BaseClass.PrimaryAttack( self, ... )
	self.DisableConeMultipliers = false
end

function SWEP:Think()
	if self.BallLaunch and self.BallLaunch < CurTime() then
		self.BallLaunch = nil
		self:EmitSound( 'Weapon_IRifle.Single' )
		self:EmitSound( 'NPC_CombineBall.Launch' )
		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
		
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
		if not self:IsRunning() then
			if SERVER then
				self.Launcher:SetPos( self.Owner:GetShootPos() )
				self.Launcher:SetAngles( self.Owner:EyeAngles() + self.Owner:GetPunchAngle() )
				self.Launcher:SetKeyValue( 'ballrespawntime', -1 )
				self.Launcher:SetKeyValue( 'minspeed', 1000 )
				self.Launcher:SetKeyValue( 'maxspeed', 1000 )
				self.Launcher:SetKeyValue( 'maxballbounces', 5 )
				self.Launcher:Fire( 'LaunchBall' )
				
				self.Owner:SetEyeAngles( self.Owner:EyeAngles() - Angle( 3, 0, 0 ) )
			end
			
			if CLIENT then BLURAMOUNT = 50
			elseif game.SinglePlayer() then umsg.Start( 'hl2_blur', self.Owner ) umsg.Float( 50 ) umsg.End() end
			
			self.Owner:ViewPunch( Angle( -8, 0, 0 ) )
			self.Owner:SetVelocity( Angle( 0, self.Owner:EyeAngles().y, 0 ):Forward() * 100 )
		end
	end
	
	return self.BaseClass.Think( self )
end

function SWEP:GetViewModelPosition( ... )
	if self:GetNWBool( 'launcher' ) then
		self.Walk_V = Vector( -2, 0, 1.3 )
		self.Idle_V = Vector( -5, 0, 1.3 )
		self.Idle_A = Angle( 0, 0, 0 )
	else
		self.Walk_V = Vector( 0, 0, -2 )
		self.Idle_V = Vector( 0, 0, -1 )
		self.Idle_A = Angle()
	end
	
	return self.BaseClass.GetViewModelPosition( self, ... )
end

function SWEP:Initialize()
	if SERVER then
		if not self.Launcher then
			self.Launcher = ents.Create( 'point_combine_ball_launcher' )
			self.Launcher:Spawn()
			self.Launcher:DeleteOnRemove( self )
		end
	end
	
	self.BaseClass.Initialize( self )
end

function SWEP:Holster( ... )
	if self.BallLaunch then return end
	return self.BaseClass.Holster( self, ... )
end

function SWEP:FireMode()
	if self.BallLaunch then return end
	
	self.Owner:SendLua( 'surface.PlaySound("suit/switch.wav")' )
	
	if not self:GetAuto() and not self:GetNWBool( 'launcher' ) then
		self:SetNWBool( 'launcher', true )
		
		umsg.Start( 'hl2_priammo' )
			umsg.Entity( self )
			umsg.String( 'ar2altfire' )
		umsg.End()
	else
		self:SetNWBool( 'launcher', false )
		self:SetAuto( not self:GetAuto() )
		
		umsg.Start( 'hl2_priammo' )
			umsg.Entity( self )
			umsg.String( 'ar2' )
		umsg.End()
	end
end