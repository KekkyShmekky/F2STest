AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'CROSSBOW'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 60
SWEP.Slot				= 0
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/weapons/v_scopebow.mdl'
SWEP.WorldModel			= 'models/weapons/w_crossbow.mdl'
SWEP.IconLetter			= '\x29'
SWEP.JamChance			= 0
SWEP.Price				= 5000
SWEP.Level				= 4
SWEP.Gaben				= 'Perfect for distant dormant targets. Makes you silent, almost invisible killing machine.\nShoots heavy, ionized bolts that give huge impact on hit.'
SWEP.EnableAcog			= true
SWEP.NoIdleAfterReload	= true
SWEP.NoViewBob			= true
SWEP.Sniper				= true
SWEP.AcogFOVOffset		= -3

SWEP.Chambering			= false
SWEP.Attachments		=
{
	{
		laser =
		{
			vm =
			{
				bone = 'Crossbow_model.Crossbow_base',
				pos = Vector( 1.3, -2.4, 0 ),
				ang = Angle( 0, 90, 180 )
			},
			wm =
			{
				pos = Vector( 10, -0.2, 4 ),
				ang = Angle( 90, 0, -10 )
			}
		}
	}
}

SWEP.Melee_V			= Vector( -10, -10, -15 )
SWEP.Melee_A			= Angle( 0, 90, -50 )

SWEP.Primary.Automatic	= false
SWEP.Primary.ClipSize	= 1
SWEP.Primary.DefaultClip= 1
SWEP.Primary.Delay		= 1
SWEP.Primary.Ammo		= 'xbowbolt'

AddSound( 'Weapon_Xbow.BoltFired', 'weapons/crossbow_shot.wav' )
AddSound( 'Weapon_Xbow.Empty', 'weapons/crossbow_empty.wav' )

SWEP.JamSound			= 'Weapon_Xbow.Empty'
SWEP.Primary.Sound		= 'Weapon_Xbow.BoltFired'
SWEP.ReloadSound		= 'Weapon_Crossbow.Reload'

SWEP.Sights_V			= Vector( -8, 7.1, 3 )
SWEP.Sights_A			= Angle( 0, 0, 0 )

SWEP.Run_V				= Vector( -5, -5, -7 )
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
	Sights = 'ar2',
	Idle = 'crossbow',
	Reload = 'ar2'
}

function SWEP:PrimaryAttack()
	if self:Clip1() == 0 then
		return self:EmitSound( self.JamSound )
	end
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:EmitSound( self.Primary.Sound, self.Primary.SoundLevel )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	if not IsFirstTimePredicted() then return end
	
	if SERVER then
		local bolt = ents.Create( 'crossbow_bolt' )
			bolt:SetOwner( self.Owner )
			bolt:SetPos( self.Owner:GetShootPos() )
			bolt:SetAngles( self.Owner:EyeAngles() )
			bolt:Spawn()
			bolt:SetVelocity( self.Owner:GetAimVector() * 3072 )
			bolt:SetGravity( 0.01 )
	end
	
	if CLIENT then BLURAMOUNT = 2500
	else umsg.Start( 'hl2_blur', self.Owner ) umsg.Float( 2500 ) umsg.End() end
	
	local comp = 1
	if self:GetIronsights() then comp = 0.4 end
	
	self.Owner:ViewPunch( Angle( 3, math.random( -4, 4 ), 0 ) )
	if CLIENT or game.SinglePlayer() then self.Owner:SetEyeAngles( self.Owner:EyeAngles() - Angle( 1, math.random( -2, 2 ), 0 ) ) end
	
	self:TakePrimaryAmmo( 1 )
	
	if self:Clip1() == 0 then
		self:SendWeaponAnim( ACT_VM_DRYFIRE )
	end
end

function SWEP:ViewModelDrawn( vm )
	self.BaseClass.ViewModelDrawn( self, vm )
	
	local bone = vm:LookupBone( 'Crossbow_model.Crossbow_base' )
	if not bone then return end
	
	local _, ang = vm:GetBonePosition( bone )
		ang:RotateAroundAxis( ang:Right(), 90 )
		ang:RotateAroundAxis( ang:Forward(), -90 )
	self.ScopeAngles = ang
end

function SWEP:AdjustMouseSensitivity( ms )
	if self:GetIronsights() then return ms * 0.2 end
end

function SWEP:Initialize()
	self.BaseClass.Initialize( self )
	
	if CLIENT then self.Acog = GetRenderTarget( 'scopebow_rt', 512, 512, true ) end
end