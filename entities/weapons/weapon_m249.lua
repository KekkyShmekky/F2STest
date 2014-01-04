AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'FN MINIMI'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 60
SWEP.Slot				= 0
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/weapons/cstrike/c_mach_m249para.mdl'
SWEP.WorldModel			= 'models/weapons/w_mach_m249para.mdl'
SWEP.IconLetter			= '\x7A'
SWEP.FontOverride		= 'CSS'
SWEP.DistantSound		= 'Distant.Rifle'
SWEP.JamChance			= 500
SWEP.Price				= 3200
SWEP.Level				= 3
SWEP.Gaben				= 'The Minimi is a Belgian 5.56mm light machine gun developed by Fabrique Nationale (FN) in\nHerstal by Ernest Vervier.'
SWEP.CSS				= true
SWEP.NoViewBob			= true
SWEP.AnimWithSights		= true
SWEP.AcogFOVOffset		= -2

SWEP.Chambering			= false
SWEP.Attachments		=
{
	{
		laser =
		{
			vm =
			{
				bone = 'v_weapon.m249',
				pos = Vector( 0, 0.1, 25 ),
				ang = Angle( 0, 0, 180 )
			},
			wm = 
			{
				pos = Vector( 18, 1, 6.8 ),
				ang = Angle( 100.8, 0, 0 )
			}
		}
	},
	{
		eotech =
		{
			vm =
			{
				bone = 'v_weapon.receiver',
				pos = Vector( -18.75, 0.36, 10.25 ),
				ang = Angle( 0, 0, 180 )
			},
			wm =
			{
				pos = Vector( -9.3, 0.5, -5.3 ),
				ang = Angle( 10.8, 0, 0 )
			},
			init =
			{
				Sights_V = Vector( -4, 5.89, 1.9 ),
				Sights_A = Angle( 0.1, 0, 0 )
			}
		},
		acog =
		{
			vm =
			{
				bone = 'v_weapon.receiver',
				pos = Vector( -13.5, -0.27, 5.3 ),
				ang = Angle( 0, 90, 180 ),
				
				scope = Angle( 0, 0, 180 )
			},
			wm =
			{
				pos = Vector( -0.3, -0.5, 0.5 ),
				ang = Angle( 0, 90, 0 )
			},
			init = { Sights_V = Vector( -6.3, 5.91, 1.7 ) }
		}
	}
}

SWEP.Melee_V			= Vector( -10, -10, -15 )
SWEP.Melee_A			= Angle( 0, 90, -50 )

SWEP.Primary.Damage 	= 13
SWEP.Primary.Automatic	= true
SWEP.Primary.ClipSize	= 100
SWEP.Primary.DefaultClip= 100
SWEP.Primary.Delay		= 0.08
SWEP.Primary.Cone		= 0.1
SWEP.Primary.Ammo		= '5.56x45mm NATO'

AddSound( 'Weapon_M249.Shot', 'weapons/m249_shot.wav' )

SWEP.Primary.Sound		= 'Weapon_M249.Shot'

SWEP.Sights_V			= Vector( -5, 5.91, 2.5 )
SWEP.Sights_A			= Angle( -0.25, -0.08, 0 )

SWEP.Run_V				= Vector( -3, -5, 0 )
SWEP.Run_A				= Angle( -15, -40, 20 )

SWEP.Walk_V				= Vector( 0, 0, -3 )
SWEP.Idle_V				= Vector( 0, 0, -1 )
SWEP.Idle_A				= Angle()

SWEP.DeployTime			= 0.1

SWEP.Recoil 			=
{
	Single = false,
	Min = 0,
	Max = 2,
	ContRecoil = 0.04,
	Punch = Angle( 0.8, 0, 0 ),
	Real = Angle( 0.3, 0, 0 )
}

SWEP.HoldTypes 			=
{
	Running = 'passive',
	Sights = 'ar2',
	Idle = 'shotgun',
	Reload = 'smg'
}

SWEP.Multipliers 			=
{
	Fly = 2,
	Walk = 1.3,
	Idle = 1,
	Crouch = 0.8,
	Sights = 0.1
}