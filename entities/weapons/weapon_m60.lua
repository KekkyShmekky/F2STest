AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'M60'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 60
SWEP.Slot				= 0
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/v_models/v_m60.mdl'
SWEP.WorldModel			= 'models/w_models/weapons/w_m60.mdl'
SWEP.IconLetter			= '\x7A'
SWEP.FontOverride		= 'CSS'
SWEP.DistantSound		= 'Distant.Rifle'
SWEP.JamChance			= 256
SWEP.Price				= 7000
SWEP.Level				= 3
SWEP.Gaben				= 'YATATATA YATATATA UTATATATA KA-BOOM! KA-BOOM!'
SWEP.L4D				= true
SWEP.NoIdleAfterReload	= true
SWEP.AnimWithSights		= true
SWEP.Chambering			= false
SWEP.MuzzleAttachment	= 4

SWEP.Attachments		=
{
	{
		laser =
		{
			vm =
			{
				bone = 'ValveBiped.weapon_bone',
				pos = Vector( 0.3, -0.3, 22 ),
				ang = Angle( 0, 90, 180 )
			},
			wm =
			{
				pos = Vector( 18, -1, 2.3 ),
				ang = Angle( 90, 0, 0 )
			}
		}
	}
}

SWEP.Melee_V			= Vector( -10, -10, -15 )
SWEP.Melee_A			= Angle( 0, 90, -50 )

SWEP.Primary.Damage 	= 15
SWEP.Primary.Automatic	= true
SWEP.Primary.ClipSize	= 200
SWEP.Primary.DefaultClip= 200
SWEP.Primary.Delay		= 0.12
SWEP.Primary.Cone		= 0.08
SWEP.Primary.Ammo		= 'machinegun'
SWEP.JamSound			= 'Weapon_Shotgun.Empty'

AddSound( 'Weapon_M60.Single', 'weapons/m60_shot.wav' )

SWEP.Primary.Sound		= 'Weapon_M60.Single'

SWEP.Sights_V			= Vector( -5, 7.13, 0.6 )
SWEP.Sights_A			= Angle( 1, 0, 4 )

SWEP.Run_V				= Vector( -2, -5, -1 )
SWEP.Run_A				= Angle( -10, -40, 20 )

SWEP.Walk_V				= Vector( 0, 0, -3 )
SWEP.Idle_V				= Vector( 0, 0, -2 )
SWEP.Idle_A				= Angle()

SWEP.DeployTime			= 0.1

SWEP.Recoil 			=
{
	Single = false,
	Min = 0,
	Max = 2,
	ContRecoil = 0.02,
	Punch = Angle( 0.4, 0, 0 ),
	Real = Angle( 0.2, 0, 0 )
}

SWEP.HoldTypes 			=
{
	Running = 'passive',
	Sights = 'ar2',
	Idle = 'shotgun',
	Reload = 'smg'
}

SWEP.CustomDrawSequence =
{
	{ 0.2, 'weapons/rifle_pull.wav' },
	{ 0.5, 'weapons/rifle_release.wav' }
}

SWEP.CustomReloadSoundSequence =
{
	{ 0.4, 'weapons/rifle_clipout.wav' },
	{ 1, 'weapons/rifle_clipin.wav' },
	{ 1.5, 'weapons/rifle_pull.wav' },
	{ 1.7, 'weapons/rifle_release.wav' }
}

function SWEP:PrimaryAttack( ... )
	if self.Owner:GetNWString( 'pgroup1' ) == 'laser' then
		self.Multipliers.Walk = 0.4
		self.Multipliers.Crouch = 0.3
	end
	
	self.BaseClass.PrimaryAttack( self, ... )
	self.Owner:GetViewModel():SetPlaybackRate( 2 )
end