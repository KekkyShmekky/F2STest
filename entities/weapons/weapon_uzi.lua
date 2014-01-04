AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'IMI UZI'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 60
SWEP.Slot				= 1
SWEP.SlotPos			= 2
SWEP.ViewModel			= 'models/v_models/v_smg.mdl'
SWEP.WorldModel			= 'models/w_models/weapons/w_smg_uzi.mdl'
SWEP.IconLetter			= '\x64'
SWEP.FontOverride		= 'CSS'
SWEP.DistantSound		= 'Distant.Light_Pistol'
SWEP.JamChance			= 900
SWEP.Price				= 800
SWEP.Level				= 1
SWEP.Gaben				= 'Controls are relatively simple. Short barrel, simple magazine, can be reloaded while running.'
SWEP.L4D				= true
SWEP.NoIdleAfterReload	= true
SWEP.AnimWithSights		= true
SWEP.Chambering			= true
SWEP.MuzzleAttachment	= 4

SWEP.Attachments		=
{
	{
		silent =
		{
			vm =
			{
				bone = 'ValveBiped.weapon_bone',
				pos = Vector( 0, -2.3, 10 ),
				ang = Angle( 0, 90, 90 ),
				
				scale = Vector( 2.2, 2.2, 2.2 )
			},
			wm =
			{
				pos = Vector( 11, 0, 2.88 ),
				scale = Vector( 2, 1.6, 2 )
			},
			init = { sound = 'Weapon_M16.Silent' }
		}
	},
	{
		laser =
		{
			vm =
			{
				bone = 'ValveBiped.weapon_bone',
				pos = Vector( -1.15, -2.5, 10 ),
				ang = Angle( 0, 90, 180 )
			},
			wm =
			{
				pos = Vector( 9, 1, 3.7 ),
				ang = Angle( 90, 0, 0 )
			}
		}
	}
}

SWEP.Melee_V			= Vector( 0, -9, -15 )
SWEP.Melee_A			= Angle( 0, 90, -50 )

SWEP.Primary.Damage 	= 11
SWEP.Primary.Automatic	= true
SWEP.Primary.ClipSize	= 62
SWEP.Primary.DefaultClip= 62
SWEP.Primary.Delay		= 0.075
SWEP.Primary.Cone		= 0.075
SWEP.Primary.Ammo		= '.45 ACP'
SWEP.CanBeReloadedWhileRunning = true

AddSound( 'Weapon_UZI.Single', 'weapons/uzi_shot.wav' )

SWEP.Primary.Sound		= 'Weapon_UZI.Single'

SWEP.Sights_V			= Vector( -3, 6.671, 1.47 )
SWEP.Sights_A			= Angle( 0, -0.4, 2.4 )

SWEP.Run_V				= Vector( -2, -3, -3 )
SWEP.Run_A				= Angle( 5, -40, 0 )

SWEP.Walk_V				= Vector( 3, 1, -3 )
SWEP.Idle_V				= Vector( 3, 1, -2 )
SWEP.Idle_A				= Angle()

SWEP.DeployTime			= 0.1

SWEP.Multipliers 			=
{
	Fly = 2.2,
	Walk = 1.4,
	Idle = 1,
	Crouch = 0.9,
	Sights = 0.3
}

SWEP.Recoil 			=
{
	Single = false,
	Min = 0,
	Max = 3,
	ContRecoil = 0.05,
	Punch = Angle( 0.4, 0, 0 ),
	Real = Angle( 0.2, 0, 0 )
}

SWEP.HoldTypes 			=
{
	Running = 'normal',
	Sights = 'pistol',
	Idle = 'slam',
	Reload = 'pistol'
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

function SWEP:FireMode()
	self.Owner:SendLua( 'surface.PlaySound("suit/switch.wav")' )
	self:SetAuto( not self:GetAuto() )
end