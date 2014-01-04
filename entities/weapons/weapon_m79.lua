AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'M79'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 60
SWEP.Slot				= 0
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/v_models/v_grenade_launcher.mdl'
SWEP.WorldModel			= 'models/w_models/weapons/w_grenade_launcher.mdl'
SWEP.IconLetter			= '\x4A'
SWEP.FontOverride		= 'CSS'
SWEP.JamChance			= 0
SWEP.Price				= 4000
SWEP.Level				= 5
SWEP.Gaben				= 'The M79 grenade launcher is a single-shot, shoulder-fired, break-action grenade launcher that\nfires a 40x46mm grenade which uses what the US Army calls the High-Low Propulsion System\nto keep recoil forces low, and first appeared during the Vietnam War.'
SWEP.NoIdleAfterReload	= true
SWEP.L4D				= true

SWEP.Chambering			= false

SWEP.Melee_V			= Vector( -10, -10, -15 )
SWEP.Melee_A			= Angle( 15, 90, -50 )

SWEP.Primary.Automatic	= false
SWEP.Primary.ClipSize	= 1
SWEP.Primary.DefaultClip= 1
SWEP.Primary.Delay		= 1
SWEP.Primary.Ammo		= '40x60 grenade'

SWEP.JamSound			= 'Weapon_Xbow.Empty'
SWEP.Primary.Sound		= 'Weapon_SMG1.Launch'

SWEP.Sights_V			= Vector( -8, 3.77, 3.12 )
SWEP.Sights_A			= Angle( -6.75, -0.1, 0.8 )

SWEP.Run_V				= Vector( -5, -7, -7 )
SWEP.Run_A				= Angle( 15, -40, 10 )

SWEP.Walk_V				= Vector( 0, 0, -2 )
SWEP.Idle_V				= Vector( 0, 0, -1 )
SWEP.Idle_A				= Angle()

SWEP.DeployTime			= 1

SWEP.Recoil 			=
{
	Single = true,
	Punch = Angle( -2, 0, 0 ),
	Real = Angle( -0.3, 0.1, 0 )
}

SWEP.HoldTypes 			=
{
	Running = 'passive',
	Sights = 'rpg',
	Idle = 'shotgun',
	Reload = 'smg'
}

SWEP.CustomDrawSequence =
{
	{ 0.7, 'weapons/rifle_cliplock.wav' }
}

SWEP.CustomReloadSoundSequence =
{
	{ 0.4, 'weapons/rifle_clipout.wav' },
	{ 1, 'weapons/rifle_clipin.wav' },
	{ 2.4, 'weapons/rifle_cliplock.wav' },
	{ 2.9, 'weapons/rifle_clipout.wav' }
}

SWEP.Attachments =
{
	{
		eotech =
		{
			vm =
			{
				bone = 'ValveBiped.weapon_bolt',
				pos = Vector( 0.35, 7.6, -15 ),
				ang = Angle( 0, -90, -90 )
			},
			wm =
			{
				pos = Vector( -6, -0.5, -6.3 )
			},
			init =
			{
				Sights_V = Vector( -8, 3.77, 2.35 ),
				Sights_A = Angle( -6.1, -0.05, 0.8 )
			}
		}
	}
}

function SWEP:PrimaryAttack()
	if self:Clip1() == 0 then
		return self:EmitSound( self.JamSound )
	end
	
	if not self:GetIronsights() then self:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) end
	
	self:EmitSound( self.Primary.Sound, self.Primary.SoundLevel )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	local fx = EffectData()
		fx:SetEntity( self.Owner:GetViewModel() )
		fx:SetAttachment( 4 )
	util.Effect( 'hl2_muzzle', fx )
	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	if not IsFirstTimePredicted() then return end
	
	if SERVER then
		local gren = ents.Create( 'sent_m79_grenade' )
			gren:SetPos( self.Owner:GetShootPos() )
			gren:SetAngles( self.Owner:EyeAngles() )
			gren:SetOwner( self.Owner )
			gren:Spawn()
			gren:GetPhysicsObject():SetVelocity( self.Owner:GetAimVector() * 2048 + Vector( 0, 0, 64 ) + VectorRand() * 64 )
	end
	
	if CLIENT then BLURAMOUNT = 2500
	else umsg.Start( 'hl2_blur', self.Owner ) umsg.Float( 2500 ) umsg.End() end -- FLOAAAAAAAT
	
	local comp = 1
	if self:GetIronsights() then comp = 0.4 end
	
	self.Owner:ViewPunch( Angle( 4, math.random( -8, 8 ), 0 ) )
	if CLIENT or game.SinglePlayer() then self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle( 1, math.random( -4, 4 ), 0 ) ) end
	
	self:TakePrimaryAmmo( 1 )
	
	if self:Clip1() == 0 then
		self:SendWeaponAnim( ACT_VM_DRYFIRE )
	end
end