AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'HK MP7'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 60
SWEP.Slot				= 0
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/weapons/c_smg1.mdl'
SWEP.WorldModel			= 'models/weapons/w_smg1.mdl'
SWEP.IconLetter			= '\x26'
SWEP.DistantSound		= 'Distant.Rifle'
SWEP.JamChance			= 1024
SWEP.DenyDryAnim		= true
SWEP.Price				= 1200
SWEP.Level				= 1
SWEP.Gaben				= 'The MP7 is a German Personal Defence Weapon manufactured by Heckler and Koch.'
SWEP.NoIdleAfterReload	= true

SWEP.Attachments		=
{
	{
		silent =
		{
			vm =
			{
				bone = 'ValveBiped.base',
				pos = Vector( 0.06, -0.3, 9 ),
				ang = Angle( 0, 90, 90 ),
				
				scale = Vector( 1.96, 1.96, 1.96 )
			},
			wm =
			{
				pos = Vector( 11.5, 0, 7 ),
				ang = Angle( 10.8, 0, 0 ),
				
				scale = Vector( 2, 1.25, 2 )
			},
			init = { sound = 'Weapon_SMG1.Silent' }
		},
		launcher = {}
	},
	{
		laser =
		{
			vm =
			{
				bone = 'ValveBiped.base',
				pos = Vector( 0.3, -1.6, 6 ),
				ang = Angle( 0, 90, 180 )
			},
			wm =
			{
				pos = Vector( 10, -1, 6 ),
				ang = Angle( 100, 0, 0 )
			}
		}
	}
}

SWEP.Melee_V			= Vector( -10, -10, -15 )
SWEP.Melee_A			= Angle( 0, 90, -50 )

SWEP.Primary.Damage 	= 9
SWEP.Primary.Automatic	= true
SWEP.Primary.ClipSize	= 40
SWEP.Primary.DefaultClip= 40
SWEP.Primary.Delay		= 0.07
SWEP.Primary.Cone		= 0.08
SWEP.Primary.Ammo		= 'HK 4.6x30mm'

SWEP.Secondary.SoundLevel= 100
SWEP.Secondary.Sound	= 'Weapon_SMG1.Launch'
SWEP.Secondary.Ammo		= '40x60 grenade'

AddSound( 'Weapon_SMG1.Launch', 'weapons/launcher.wav' )
AddSound( 'Weapon_SMG1.Silent', 'weapons/rifle_silent.wav' )
AddSound( 'Weapon_SMG1.MP7_Shot', 'weapons/mp7_shot.wav' )

SWEP.Primary.Sound		= 'Weapon_SMG1.MP7_Shot'
SWEP.ReloadSound		= 'Weapon_SMG1.Reload'

SWEP.Sights_V			= Vector( -5, 6.42, 1.04 )
SWEP.Sights_A			= Angle()

SWEP.Run_V				= Vector( -3, -7, -5 )
SWEP.Run_A				= Angle( 5, -40, 0 )

SWEP.Walk_V				= Vector( 0, 0, -1 )
SWEP.Idle_V				= Vector( 0, 0, -0.7 )
SWEP.Idle_A				= Angle()

SWEP.DeployTime			= 0.1

SWEP.Recoil 			=
{
	Single = false,
	Min = 0,
	Max = 3,
	ContRecoil = 0.03,
	Punch = Angle( 0.1, 0, 0 ),
	Real = Angle( 0.08, 0, 0 )
}

SWEP.HoldTypes 			=
{
	Running = 'passive',
	Sights = 'smg',
	Idle = 'shotgun',
	Reload = 'smg'
}

local reflex = Material( 'effects/dot' )
local reflexcolor = Color( 255, 40, 0, 180 )
function SWEP:ViewModelDrawn( vm )
	if not self.MP7 then self.MP7 = vm:LookupBone( 'ValveBiped.base' ) end
	if self.MP7 then
		local pos, ang = vm:GetBonePosition( self.MP7 )
		local size = math.Clamp( 1 - self.IronSightsVec:Distance( self.Sights_V ), 0, 1 ) * 0.15
		
		render.SetMaterial( reflex )
		render.DrawSprite( pos - ang:Right() * 2.79 + ang:Forward() * 0.05 - ang:Up() * 4.2, size, size, reflexcolor )
	end
	
	return self.BaseClass.ViewModelDrawn( self, vm )
end

function SWEP:PrimaryAttack( ... )
	if self.Owner:GetNWString( 'pgroup1' ) == 'launcher' and self:GetNWBool( 'launcher' ) and not self:IsRunning( true ) then
		if self.Owner:GetAmmoCount( self:GetSecondaryAmmoType() ) <= 0 then
				self:SetNextPrimaryFire( CurTime() + 0.3 )
			return self:EmitSound( self.JamSound )
		end
		
		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
		self:EmitSound( self.Secondary.Sound, self.Secondary.SoundLevel )
		self:SetNextPrimaryFire( CurTime() + 0.8 )
		
		if SERVER then
			local gren = ents.Create( 'sent_m79_grenade' )
				gren:SetPos( self.Owner:GetShootPos() )
				gren:SetAngles( self.Owner:EyeAngles() )
				gren:SetOwner( self.Owner )
				gren:Spawn()
				gren:GetPhysicsObject():SetVelocity( self.Owner:GetAimVector() * 1536 + Vector( 0, 0, 32 ) + VectorRand() * 48 )
				gren.UnderPower = true
		end
		
		if CLIENT then BLURAMOUNT = 2500
		else umsg.Start( 'hl2_blur', self.Owner ) umsg.Float( 2500 ) umsg.End() end
		
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Owner:ViewPunch( -Angle( 8, 0, math.Rand( -0.5, 0.5 ) ) )
		if CLIENT or game.SinglePlayer() then self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle( math.random( -2, 1 ), 0, 0 ) ) end
		
		return self:TakeSecondaryAmmo( 1 )
	end
	
	return self.BaseClass.PrimaryAttack( self, ... )
end

function SWEP:GetViewModelPosition( ... )
	if self:GetNWBool( 'launcher' ) then
		self.Walk_V = Vector( -2, 0, -2.3 )
		self.Idle_V = Vector( -5, 0, -1.7 )
		self.Idle_A = Angle( 6, 0, 0 )
	else
		self.Walk_V = Vector( 0, 0, -1 )
		self.Idle_V = Vector( 0, 0, -0.7 )
		self.Idle_A = Angle()
	end
	
	return self.BaseClass.GetViewModelPosition( self, ... )
end

function SWEP:FireMode()
	self.Owner:SendLua( 'surface.PlaySound("suit/switch.wav")' )
	
	if not self:GetAuto() and self.Owner:GetNWBool( 'pgroup1' ) == 'launcher' and not self:GetNWBool( 'launcher' ) then
		self:SetNWBool( 'launcher', true )
		
		umsg.Start( 'hl2_priammo' )
			umsg.Entity( self )
			umsg.String( 'smg1_grenade' )
		umsg.End()
	else
		self:SetNWBool( 'launcher', false )
		self:SetNWBool( 'taser', false )
		self:SetAuto( not self:GetAuto() )
		
		if self.OriginalClip then
			self:SetClip1( self.OriginalClip )
			self.OriginalClip = nil
		end
		
		umsg.Start( 'hl2_priammo' )
			umsg.Entity( self )
			umsg.String( 'smg1' )
		umsg.End()
	end
end