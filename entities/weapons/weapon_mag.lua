AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'COLT PYTHON'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 60
SWEP.Slot				= 1
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/weapons/c_357.mdl'
SWEP.WorldModel			= 'models/weapons/w_357.mdl'
SWEP.IconLetter			= '\x24'
SWEP.DistantSound		= 'Distant.357'
SWEP.JamChance			= 0
SWEP.Price				= 1000
SWEP.Level				= 2
SWEP.SniperPistol		= true
SWEP.Gaben				= '.357 Magnum revolver with 6-inch barrel. Literally, it\'s one-hand sniper weapon.'
SWEP.AcogFOVOffset		= -3.5

SWEP.Chambering			= false
SWEP.Attachments		=
{
	{
		revscope =
		{
			vm =
			{
				bone = 'Python',
				pos = Vector( -1.28, -2, -5.5 ),
				ang = Angle( 0, -90, -90 ),
				
				scope = Angle( 0, -90.2, -88.78 )
			},
			wm =
			{
				pos = Vector( 16.5, 0.3, 5.2 ),
				ang = Angle( 0, 180, 0 )
			},
			init =
			{
				Sights_V = Vector( -13, 4.63, 0.2 ),
				Sights_A = Angle( 0, 0, -1 )
			}
		}
	}
}

SWEP.Melee_V			= Vector( 0, 0, -5 )
SWEP.Melee_A			= Angle( 25, 30, 0 )

SWEP.Primary.Force		= 4489
SWEP.Primary.Damage 	= 67
SWEP.Primary.Automatic	= false
SWEP.Primary.ClipSize	= 6
SWEP.Primary.DefaultClip= 6
SWEP.Primary.Delay		= 0.55
SWEP.Primary.Cone		= 0.01
SWEP.Primary.Ammo		= '357'

AddSound( 'Weapon_Mag.Single', 'weapons/357_shot.wav' )

SWEP.Primary.Sound		= 'Weapon_Mag.Single'

SWEP.Sights_V			= Vector( -5, 4.68, 0.75 )
SWEP.Sights_A			= Angle( -0.2, 0.13, -1 )

SWEP.Run_V				= Vector( -11, 0, -10 )
SWEP.Run_A				= Angle( 45, 0, 0 )

SWEP.Walk_V				= Vector( 0, 0, -2 )
SWEP.Idle_V				= Vector( 0, 0, -1 )
SWEP.Idle_A				= Angle()

SWEP.DeployTime			= 0.1

SWEP.Recoil 			=
{
	Single = true,
	Punch = Angle( 8, 0, 0 ),
	Real = Angle( 4, 0, 0 )
}

SWEP.HoldTypes 			=
{
	Running = 'normal',
	Sights = 'revolver',
	Idle = 'slam',
	Reload = 'revolver'
}