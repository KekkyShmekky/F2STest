AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'AK-74'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 60
SWEP.Slot				= 0
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/v_models/v_rifle_ak47.mdl'
SWEP.WorldModel			= 'models/w_models/weapons/w_rifle_ak47.mdl'
SWEP.IconLetter			= '\x62'
SWEP.FontOverride		= 'CSS'
SWEP.DistantSound		= 'Distant.Rifle'
SWEP.JamChance			= 2000
SWEP.Price				= 1300
SWEP.Gaben				= 'Cheap and pretty reliable USSR assault rifle. Has average accuracy, given by its long barrel\nAs the legend says, the first bullet fired from AK will hit directly in the bullseye'
SWEP.L4D				= true
SWEP.AnimWithSights		= true
SWEP.NoIdleAfterReload	= true
SWEP.AcogFOVOffset		= -2

SWEP.Chambering			= true
SWEP.Attachments		=
{
	{
		laser =
		{
			vm =
			{
				bone = 'ValveBiped.weapon_bone',
				pos = Vector( 0.3, -0.8, 20 ),
				ang = Angle( 0, 90, 180 )
			},
			wm =
			{
				pos = Vector( 20, 0, 0.8 ),
				ang = Angle( 90, 0, 0 )
			}
		}
	},
	{
		eotech =
		{
			vm =
			{
				bone = 'ValveBiped.weapon_bone',
				pos = Vector( 0.29, 6.1, -8 ),
				ang = Angle( 90, -90, 0 )
			},
			wm =
			{
				pos = Vector( -6.8, -0.3, -6.8 )
			},
			init = { Sights_V = Vector( -7, 6.91, 1.1 ) }
		},
		acog =
		{
			vm =
			{
				bone = 'ValveBiped.weapon_bone',
				pos = Vector( -0.35, 1.13, -3 ),
				ang = Angle( 0, 0, -90 ),
				
				scope = Angle( 0, -90, -90 )
			},
			wm =
			{
				pos = Vector( -3, -0.5, -1.7 ),
				ang = Angle( 0, 90, 0 )
			},
			init = { Sights_V = Vector( -8, 6.91, 0.9 ) }
		}
	}
}

SWEP.Melee_V			= Vector( -10, -10, -15 )
SWEP.Melee_A			= Angle( 0, 90, -50 )

SWEP.Primary.Damage 	= 11
SWEP.Primary.Automatic	= true
SWEP.Primary.ClipSize	= 30
SWEP.Primary.DefaultClip= 30
SWEP.Primary.Delay		= 0.12
SWEP.Primary.Cone		= 0.06
SWEP.Primary.Ammo		= '5.45x39mm'

SWEP.SlideBone			= 'ValveBiped.weapon_bolt'
SWEP.SlideDirection		= Vector( 0, 0, -5 )

AddSound( 'Weapon_AK74.Single', 'weapons/ak74_shot.wav' )

SWEP.Primary.Sound		= 'Weapon_AK74.Single'

SWEP.Sights_V			= Vector( -8, 6.9, 1.5 )
SWEP.Sights_A			= Angle( 0.1, -0.08, 4 )

SWEP.Run_V				= Vector( -3, -5, 0 )
SWEP.Run_A				= Angle( -15, -40, 20 )

SWEP.Walk_V				= Vector( 0, 0, -1 )
SWEP.Idle_V				= Vector( 0, 0, -0.7 )
SWEP.Idle_A				= Angle()

SWEP.DeployTime			= 0.1

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

SWEP.Recoil 			=
{
	Single = false,
	Min = 0,
	Max = 4,
	ContRecoil = 0.03,
	Punch = Angle( -0.5, 0, 0 ),
	Real = Angle( 0.1, 0, 0 )
}

SWEP.HoldTypes 			=
{
	Running = 'passive',
	Sights = 'ar2',
	Idle = 'shotgun',
	Reload = 'smg'
}