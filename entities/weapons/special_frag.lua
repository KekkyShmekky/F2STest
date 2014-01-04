AddCSLuaFile()

SWEP.PrintName				= 'MK3A2 GRENADE'
SWEP.Spawnable 				= false
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV			= 60
SWEP.Slot					= -1
SWEP.ViewModel				= 'models/weapons/c_grenade.mdl'
SWEP.WorldModel				= 'models/weapons/w_grenade.mdl'

SWEP.IconLetter				= '\x5F'
SWEP.Primary.Ammo			= 'frag_grenade'
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1

SWEP.Secondary.Ammo			= 'none'
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultSize	= -1

AddSound( 'Weapon_Frag.PullPin', 'weapons/frag_pin.wav' )
AddSound( 'Weapon_Frag.Throw', 'weapons/frag_throw.wav' )

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:CanDeploy()
	return self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0
end

function SWEP:SelectWeapon( wep )
	if not wep then return end
	if SERVER then self.Owner:SelectWeapon( wep ) end
end

function SWEP:Think()
	if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then self.Holstering = 0 end
	if self.Holstering and self.Holstering < CurTime() then return self:SelectWeapon( self.OldWeapon ) end
	
	if self.TurnToSlam and self.TurnToSlam < CurTime() then
		self.TurnToSlam = nil
		self:EmitSound( 'Weapon_Frag.PullPin' )
		
		umsg.Start( 'mk3a2_sfx' )
			umsg.Entity( self )
			umsg.String( 'Weapon_Frag.PullPin' )
		umsg.End()
	end
	
	if self.Pin and self.Pin < CurTime() then
		self.Pin = nil
		self.Throw = CurTime() + 0.3
		self:SendWeaponAnim( ACT_VM_PULLBACK_HIGH )
		self.Owner:ViewPunch( Angle( -4, 3, 0 ) )
		
		umsg.Start( 'hl2_holdtype' )
			umsg.Entity( self )
			umsg.String( 'grenade' )
		umsg.End()
	end
	
	if self.Throw and self.Throw < CurTime() then
		self.Throw = nil
		self.Holstering = CurTime() + 0.6
		self:SendWeaponAnim( ACT_VM_THROW )
		self:EmitSound( 'Weapon_Frag.Throw' )
		self.Owner:DrawWorldModel( false )
		self.Owner:ViewPunch( Angle( 2, -6, 0 ) )
		
		umsg.Start( 'mk3a2_sfx' )
			umsg.Entity( self )
			umsg.String( 'Weapon_Frag.Throw' )
		umsg.End()
		
		umsg.Start( 'mk3a2_throw' )
			umsg.Entity( self.Owner )
		umsg.End()
		
		local frag = ents.Create( 'npc_grenade_frag' )
			frag:SetPos( self.Owner:GetShootPos() )
			frag:SetAngles( VectorRand():Angle() )
			frag:SetOwner( self.Owner )
			frag:Spawn()
			frag:Fire( 'settimer', 2 )
			frag:GetPhysicsObject():AddAngleVelocity( VectorRand() * 256 )
			frag:GetPhysicsObject():AddVelocity( self.Owner:GetAimVector() * 1430 + Vector( 0, 0, 160 ) )
		self.Owner:SetAmmo( self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) - 1, self:GetPrimaryAmmoType() )
	end
end

function SWEP:Holster()
	if SERVER then self.Owner:DrawWorldModel( true ) end
	if self.Holstering and self.Holstering < CurTime() then return true end
end

function SWEP:Deploy()
	self.Owner:DrawWorldModel( true )
	self:SendWeaponAnim( ACT_VM_DRAW )
	self.Pin = CurTime() + 0.6
	self.Holstering = nil
	self.TurnToSlam = CurTime() + 0.1
	
	umsg.Start( 'hl2_holdtype' )
		umsg.Entity( self )
		umsg.String( 'slam' )
	umsg.End()
	
	umsg.Start( 'hl2_draw', self.Owner )
		umsg.Entity( self )
	umsg.End()
end

function SWEP:Initialize()
	self:SetWeaponHoldType( 'slam' )
end

if CLIENT then	
	usermessage.Hook( 'mk3a2_throw', function( um )
		um:ReadEntity():SetAnimation( PLAYER_ATTACK1 )
	end )
	
	usermessage.Hook( 'mk3a2_sfx', function( um )
		um:ReadEntity():EmitSound( um:ReadString() )
	end )
end