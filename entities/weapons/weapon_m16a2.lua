AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'M16A2'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 60
SWEP.Slot				= 0
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/v_models/v_rifle.mdl'
SWEP.WorldModel			= 'models/w_models/weapons/w_rifle_m16a2.mdl'
SWEP.IconLetter			= '\x77'
SWEP.FontOverride		= 'CSS'
SWEP.DistantSound		= 'Distant.Rifle'
SWEP.JamChance			= 480
SWEP.Price				= 2500
SWEP.Gaben				= 'The M16A2 is a lightweight, air-cooled, gas-operated rifle with a rotating bolt, actuated\nby direct impingement gas operation.'
SWEP.L4D				= true
SWEP.AnimWithSights		= true
SWEP.NoIdleAfterReload	= true
SWEP.AcogFOVOffset		= -2

SWEP.Chambering			= true
SWEP.Attachments		=
{
	{
		silent =
		{
			vm =
			{
				bone = 'ValveBiped.weapon_bone',
				pos = Vector( 0, -3.7, 33 ),
				ang = Angle( 0, 90, 90 ),
				scale = Vector( 2.2, 3.6, 2.2 )
			},
			wm =
			{
				pos = Vector( 30, 0, 4 )
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
				pos = Vector( -0.2, -1.8, 25 ),
				ang = Angle( 0, 90, 180 )
			},
			wm =
			{
				pos = Vector( 24.5, 0, 2.3 ),
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
				pos = Vector( 0.26, 4.2, -7 ),
				ang = Angle( 0, -90, -90 )
			},
			wm =
			{
				pos = Vector( -5.3, -0.5, -4.1 )
			},
			init =
			{
				Sights_V = Vector( -8, 6.965, -0.8 ),
				Sights_A = Angle( 0, 0, 4 )
			}
		},
		acog =
		{
			vm =
			{
				bone = 'ValveBiped.weapon_bone',
				pos = Vector( -0.37, -0.5, -3.3 ),
				ang = Angle( 0, 0, -90 ),
				
				scope = Angle( 0, -90, -90 )
			},
			wm =
			{
				pos = Vector( -0.3, -0.5, 0.5 ),
				ang = Angle( 0, 90, 0 )
			},
			init = { Sights_V = Vector( -7.5, 6.965, -0.73 ) }
		}
	}
}

SWEP.Melee_V			= Vector( -10, -10, -15 )
SWEP.Melee_A			= Angle( 0, 90, -50 )

SWEP.Primary.Damage 	= 11
SWEP.Primary.Automatic	= false
SWEP.Primary.ClipSize	= 30
SWEP.Primary.DefaultClip= 30
SWEP.Primary.Delay		= 0.08
SWEP.Primary.Cone		= 0.05
SWEP.Primary.Ammo		= '5.56x45mm NATO'

SWEP.Primary.Sound		= 'Weapon_M16.Single'

SWEP.Sights_V			= Vector( -8, 6.965, 0.34 )
SWEP.Sights_A			= Angle( 0, 0, 4 )

SWEP.Run_V				= Vector( -3, -5, -1 )
SWEP.Run_A				= Angle( -15, -40, 20 )

SWEP.Walk_V				= Vector( 0, 0, -1 )
SWEP.Idle_V				= Vector( 0, 0, -0.7 )
SWEP.Idle_A				= Angle()

SWEP.DeployTime			= 0.1

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

SWEP.CustomDrawSequence =
{
	{ 0.2, 'weapons/rifle_pull.wav' },
	{ 0.5, 'weapons/rifle_release.wav' }
}

SWEP.CustomReloadSoundSequence =
{
	{ 0.4, 'weapons/rifle_clipout.wav' },
	{ 0.9, 'weapons/rifle_clipin.wav' },
	{ 1.5, 'weapons/rifle_cliplock.wav' }
}

function SWEP:PrimaryAttack( ... )	
	if self:IsRunning() then return end
	if self:GetNWBool( 'burst' ) and self:Clip1() > 0 then
		self.NextBurstShot = CurTime() + 0.08
		self.Burst = 2
	end
	
	self.Primary.Delay = self:GetNWBool( 'burst' ) and 0.2 or 0.08
	
	return self:ShootBullet()
end

function SWEP:Think()
	if self.Burst and self.Burst > 0 and self.NextBurstShot < CurTime() then
		self.NextBurstShot = CurTime() + 0.08
		self.Burst = self.Burst - 1
		
		if self:Clip1() > 0 and not self:GetNWBool( 'jammed' ) then
			self:ShootBullet()
		end
	end
	
	self.BaseClass.Think( self )
end

function SWEP:FireMode()
	self.Owner:SendLua( 'surface.PlaySound("suit/switch.wav")' )
	self:SetNWBool( 'burst', not self:GetNWBool( 'burst' ) )
end