AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'FRANCHI SPAS-12'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 50
SWEP.Slot				= 0
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/weapons/c_shotgun.mdl'
SWEP.WorldModel			= 'models/weapons/w_shotgun.mdl'
SWEP.JamChance			= 512
SWEP.JamSound			= 'Weapon_Shotgun.Empty'
SWEP.ShotgunReload		= true
SWEP.DenyDryAnim		= true
SWEP.AcogFOVOffset		= -2

SWEP.Secondary.Ammo		= '40x60 grenade'

SWEP.Attachments		=
{
	{
		silent =
		{
			vm =
			{
				bone = 'ValveBiped.Gun',
				pos = Vector( 0.05, -0.475, 21 ),
				ang = Angle( 90, 0, 0 ),
				
				scale = Vector( 2.2, 4.4, 2.2 )
			},
			wm =
			{
				pos = Vector( 28, 0.9, 7.55 ),
				ang = Angle( 6, 0, 0 ),
				
				scale = Vector( 1.6, 2.2, 1.6 )
			},
			init = { sound = 'Weapon_AR2.Shotgun' }
		},
		fragmode = {}
	},
	{
		longmag =
		{
			vm =
			{
				bone = 'ValveBiped.Gun',
				pos = Vector( 0.05, 1.525, 21 ),
				ang = Angle( 90, 0, 0 ),
				
				scale = Vector( 1.8, 3, 1.8 )
			},
			wm =
			{
				pos = Vector( 27.5, 0.9, 6.08 ),
				ang = Angle( 6, 0, 0 ),
				
				scale = Vector( 1.2, 1.2, 1.2 )
			},
			init = { clip = 11 }
		},
		laser =
		{
			vm =
			{
				bone = 'ValveBiped.Gun',
				pos = Vector( -0.32, 1.4, 22 ),
				ang = Angle( 90, 90, 90 ),
				scale = Vector( 0.075, 0.075, 0.075 )
			},
			wm =
			{
				pos = Vector( 27, 0.5, 5.8 ),
				ang = Angle( 95.8, 0, 0 )
			}
		}
	},
	{
		eotech =
		{
			vm =
			{
				bone = 'ValveBiped.Gun',
				pos = Vector( 0.28, 9, -18 ),
				ang = Angle( 0, -90, -90 )
			},
			wm =
			{
				pos = Vector( -1, 0.16, -5 ),
				ang = Angle( 6, 0, 0 )
			},
			init =
			{
				Sights_V = Vector( -10, 8.997, 3.43 ),
				Sights_A = Angle()
			}
		},
		acog =
		{
			vm =
			{
				bone = 'ValveBiped.Gun',
				pos = Vector( -0.32, 4, -12 ),
				ang = Angle( 0, 0, -90 ),
				
				scope = Angle( 0, -90, -90 )
			},
			wm =
			{
				pos = Vector( 4, 1, 0.8 ),
				ang = Angle( 90, 90, -90 )
			},
			init = { Sights_V = Vector( -10, 8.97, 3.2 ) }
		}
	}
}

SWEP.Price				= 3500
SWEP.Level				= 3
SWEP.Gaben				= 'Special pump action shotgun. It weighs 5 kg and has 2 firemodes: pump action and semi-auto,\nsupports frag rounds and is pretty reliable.'

SWEP.Melee_V			= Vector( -20, -12, -20 )
SWEP.Melee_A			= Angle( 0, 90, -50 )

SWEP.Primary.NumShots	= 11
SWEP.Primary.Damage		= 9
SWEP.Primary.Automatic	= false
SWEP.Primary.ClipSize	= 8
SWEP.Primary.DefaultClip= 8
SWEP.Primary.Cone		= 0.1
SWEP.Primary.Delay		= 0.25
SWEP.Primary.Ammo		= 'buckshot'

SWEP.DisableConeMultipliers = true
SWEP.IconLetter			= '\x28'

AddSound( 'Weapon_SPAS.Single', 'weapons/spas_shot.wav' )
AddSound( 'Weapon_SPAS.Pump', 'weapons/spas_pump.wav' )
AddSound( 'Weapon_SPAS.Shell', 'weapons/spas_insertshell.wav' )

SWEP.PumpSound			= 'Weapon_SPAS.Pump'
SWEP.InsertShellSound	= 'Weapon_SPAS.Shell'
SWEP.Primary.Sound		= 'Weapon_SPAS.Single'

SWEP.Sights_V			= Vector( -8, 8.97, 4.3 )
SWEP.Sights_A			= Angle( -0.3, 0, 0 )

SWEP.Run_V				= Vector( -5, -7, -1 )
SWEP.Run_A				= Angle( -10, -40, 20 )

SWEP.Walk_V				= Vector( 0, 3, -1.7 )
SWEP.Idle_V				= Vector( 0, 3, -0.3 )
SWEP.Idle_A				= Angle()

SWEP.DeployTime			= 0.1

SWEP.Recoil 			=
{
	Punch = Angle( 8, 0, 0 ),
	Real = Angle( 1, 0, 0 )
}

SWEP.HoldTypes 			=
{
	Running = 'passive',
	Sights = 'ar2',
	Idle = 'shotgun',
	Reload = 'shotgun'
}

SWEP.Multipliers 			=
{
	Fly = 1.7,
	Walk = 1.3,
	Idle = 1,
	Crouch = 0.7,
	Sights = 0.7
}

function SWEP:ShootBullet2()
	if self:Clip1() == 0 and not self:GetNWBool( 'onebullet' ) or self:GetNWBool( 'jammed' ) or self.ShotgunReload and not self:GetNWBool( 'onebullet' ) then
		if SERVER and self.ShotgunReload and not self:GetNWBool( 'onebullet' ) and self:Clip1() > 0 then
			umsg.Start( 'hl2_weaponhint', self.Owner )
				umsg.Entity( self )
				umsg.Short( self.MuzzleAttachment or ( self.L4D and 3 or 1 ) )
				umsg.Float( 2 )
				umsg.String( 'Use RELOAD key to pump weapon' )
			umsg.End()
		end
		
		self:SetNextPrimaryFire( CurTime() + 0.3 )
		return self:EmitSound( self.JamSound )
	end
	
	self.Primary.Ammo = self.Secondary.Ammo
	self:SetNWBool( 'pump', true )
	self:SetNWBool( 'onebullet', false )
	self:SetNextPrimaryFire( CurTime() + 0.8 )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:EmitSound( 'Weapon_SMG1.Launch' )
	
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:ViewPunch( Angle( -8, 0, 0 ) )
	
	if SERVER then
		local gren = ents.Create( 'sent_m79_grenade' )
			gren:SetPos( self.Owner:GetShootPos() )
			gren:SetAngles( self.Owner:EyeAngles() )
			gren:SetOwner( self.Owner )
			gren:Spawn()
			gren:GetPhysicsObject():SetVelocity( self.Owner:GetAimVector() * 4096 + VectorRand() * 16 )
			gren.UnderPower = true
	else
		self.Owner:SetEyeAngles( self.Owner:EyeAngles() - Angle( 3, 0, 0 ) )
	end
	
	return true
end

function SWEP:Think()
	if self.Owner:GetNWString( 'pgroup1' ) == 'fragmode' then
		self.ShootBullet = self.ShootBullet2
		self.Primary.Ammo = self.Secondary.Ammo
	end
	
	return self.BaseClass.Think( self )
end

function SWEP:FireMode()
	if self.Owner:GetNWString( 'pgroup1' ) == 'fragmode' then return end
	
	self.Owner:SendLua( 'surface.PlaySound("suit/switch.wav")' )
	self:SetNextPrimaryFire( CurTime() + 0.3 )
	self:SetNextSecondaryFire( CurTime() + 0.3 )
	self:SetNWBool( 'pump', not self:GetNWBool( 'pump' ) )
end

function SWEP:Initialize()
	if self.Primary.Ammo == self.Secondary.Ammo then
		self:Clip1( 0 )
		self:SetNWBool( 'onebullet', false )
	end
	
	self.BaseClass.Initialize( self )
end