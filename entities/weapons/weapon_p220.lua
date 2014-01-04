AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'SIG-SAUER P220'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 70
SWEP.Slot				= 1
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/weapons/cstrike/c_pist_p228.mdl'
SWEP.WorldModel			= 'models/weapons/w_pist_p228.mdl'
SWEP.IconLetter			= '\x61'
SWEP.FontOverride		= 'CSS'
SWEP.DistantSound		= 'Distant.Light_Pistol'
SWEP.JamChance			= 130
SWEP.Price				= 600
SWEP.Level				= 1
SWEP.Gaben				= 'The SIG Sauer P220 is a semi-automatic pistol made by SIG Sauer.'
SWEP.PistolMovement		= true
SWEP.CSS				= true
SWEP.DenyDryAnim		= true
SWEP.AnimWithSights		= true

SWEP.Attachments		=
{
	{
		silent =
		{
			vm =
			{
				bone = 'v_weapon.p228_parent',
				pos = Vector( 0, -3.9, -4.5 ),
				ang = Angle( -90, 0, 0 ),
				
				scale = Vector( 1.2, 1.2, 1.2 )
			},
			wm =
			{
				pos = Vector( 7, 0, 3.8 ),
				ang = Angle( 1, 3, 0 )
			},
			init = { sound = 'Weapon_M16.Silent' }
		}
	},
	{
		laser =
		{
			vm =
			{
				bone = 'v_weapon.p228_parent',
				pos = Vector( 0, -3, -3 )
			},
			wm =
			{
				pos = Vector( 7, 0, 2.5 ),
				ang = Angle( 91, 3, 0 )
			}
		}
	}
}

SWEP.Melee_V			= Vector()
SWEP.Melee_A			= Angle( 25, 15, 0 )

SWEP.Sights_V			= Vector( -11, 6, 2.95 )
SWEP.Sights_A			= Angle( -0.8, 0.075, 0 )

SWEP.Run_V				= Vector( -13, 0, -7 )
SWEP.Run_A				= Angle( 45, 0, 0 )

SWEP.Walk_V				= Vector( -9, 1, -1 )
SWEP.Idle_V				= Vector( -9, 1, 0 )
SWEP.Idle_A				= Angle()

SWEP.SlideBone			= 'v_weapon.p228_slide'
SWEP.SlideDirection		= Vector( 0, 0, 2 )
SWEP.DryAnimSim			= true

SWEP.Recoil 			=
{
	Single = true,
	Punch = Angle( 1.3, 0, 0 ),
	Real = Angle( 0.2, 0, 0 )
}

SWEP.HoldTypes 			=
{
	Running = 'normal',
	Sights = 'revolver',
	Idle = 'slam',
	Reload = 'pistol'
}

AddSound( 'Weapon_P220.Shot', 'weapons/p220_shot.wav' )

SWEP.PistolMovement		= true
SWEP.Primary.Sound		= 'Weapon_P220.Shot'
SWEP.Primary.Ammo		= '.45 ACP'
SWEP.Primary.Cone		= 0.08
SWEP.Primary.Damage		= 15
SWEP.Primary.Delay		= 0.1
SWEP.Primary.ClipSize	= 10
SWEP.Primary.DefaultClip= 10