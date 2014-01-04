AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'FN SCAR-L'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 65
SWEP.Slot				= 0
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/v_models/v_desert_rifle.mdl'
SWEP.WorldModel			= 'models/w_models/weapons/w_desert_rifle.mdl'
SWEP.IconLetter			= '\x76'
SWEP.FontOverride		= 'CSS'
SWEP.DistantSound		= 'Distant.Rifle'
SWEP.JamChance			= 800
SWEP.Price				= 3700
SWEP.Level				= 2
SWEP.Gaben				= 'The FN SCAR-L is a lightweight, air-cooled, gas-operated, STANAG magazine box feeded\nmedium to long range rifle. Very accurate.'
SWEP.L4D				= true
SWEP.AnimWithSights		= true
SWEP.NoIdleAfterReload	= true

SWEP.Chambering			= true
SWEP.Attachments		=
{
	{
		laser =
		{
			vm =
			{
				bone = 'ValveBiped.weapon_bone',
				pos = Vector( 0.3, -1.2, 20 ),
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

SWEP.Primary.Damage 	= 13
SWEP.Primary.Automatic	= true
SWEP.Primary.ClipSize	= 20
SWEP.Primary.DefaultClip= 20
SWEP.Primary.Delay		= 0.1
SWEP.Primary.Cone		= 0.04
SWEP.Primary.Ammo		= '5.56x45mm NATO'

SWEP.SlideBone			= 'ValveBiped.weapon_bolt'
SWEP.SlideDirection		= Vector( 0, 0, -5 )

AddSound( 'Weapon_SCAR.Single', 'weapons/scar_shot.wav' )

SWEP.Primary.Sound		= 'Weapon_SCAR.Single'

SWEP.Sights_V			= Vector( -9, 6.962, -0.97 )
SWEP.Sights_A			= Angle( 0, 0, 4 )

SWEP.Run_V				= Vector( -3, -4, -1.5 )
SWEP.Run_A				= Angle( -12, -40, 20 )

SWEP.Walk_V				= Vector( 0, 0, -3 )
SWEP.Idle_V				= Vector( 0, 0, -2 )
SWEP.Idle_A				= Angle()

SWEP.DeployTime			= 0.1

SWEP.Recoil 			=
{
	Single = false,
	Min = 0,
	Max = 3,
	ContRecoil = 0.04,
	Punch = Angle( -0.3, 0, 0 ),
	Real = Angle( 0.13, 0, 0 )
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
	{ 1.5, 'weapons/rifle_cliplock.wav' },
	{ 2.4, 'weapons/rifle_clipout.wav' }
}

function SWEP:PrimaryAttack( ... )
	if self.Owner:GetNWString( 'pgroup1' ) == 'laser' then
		self.Multipliers.Walk = 0.4
		self.Multipliers.Crouch = 0.3
	end
	
	self.BaseClass.PrimaryAttack( self, ... )
	
	self.Owner:GetViewModel():SetPlaybackRate( 1.3 )
end

function SWEP:FireMode()
	self.Owner:SendLua( 'surface.PlaySound("suit/switch.wav")' )
	self:SetAuto( not self:GetAuto() )
	
	umsg.Start( 'hl2_priammo' )
		umsg.Entity( self )
		umsg.String( 'smg1' )
	umsg.End()
end