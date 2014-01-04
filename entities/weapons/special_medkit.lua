AddCSLuaFile()

SWEP.PrintName				= 'MEDICAL KIT'
SWEP.Spawnable 				= false
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV			= 50
SWEP.Slot					= -1
SWEP.ViewModel				= 'models/weapons/c_medkit.mdl'
SWEP.WorldModel				= 'models/weapons/w_medkit.mdl'

SWEP.IconLetter				= '\x2B'
SWEP.Primary.Ammo			= 'medpack'
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1

SWEP.Secondary.Ammo			= 'none'
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultSize	= -1

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

function SWEP:DoHealing()
	local healed
	local ent = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 65,
		filter = self.Owner
	} ).Entity
	
	if IsValid( ent ) and ent:IsPlayer() and GAMEMODE:IsFriendOf( ent, self.Owner ) then
		ent:SetHealth( ent:Health() + ( 100 - ent:Health() ) * 0.95 )
		ent:EmitSound( 'items/smallmedkit1.wav' )
		healed = true
		
		umsg.Start( 'feed', self.Owner )
			umsg.String( 'TEAM ASSIST 50' )
		umsg.End()
		
		self.Owner.StreaksTime = CurTime() + 6
		self.Owner:SetNWInt( 'livexp', self.Owner:GetNWInt( 'livexp' ) + 50 )
	end
	
	if not healed and self.Owner:Health() < 95 then
		self.Owner:SetHealth( self.Owner:Health() + ( 100 - self.Owner:Health() ) * 0.95 )
		self.Owner:EmitSound( 'items/smallmedkit1.wav' )
		healed = true
	end
	
	if healed then
		self.Owner:SetAmmo( self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) - 1, self:GetPrimaryAmmoType() )
		self.Owner:DrawWorldModel( false )
		
		umsg.Start( 'mk3a2_throw' )
			umsg.Entity( self.Owner )
		umsg.End()
	end
end

function SWEP:Think()
	if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then self.Holstering = 0 end
	if self.Holstering and self.Holstering < CurTime() then return self:SelectWeapon( self.OldWeapon ) end
	
	if self.AnimTime and self.AnimTime < CurTime() then
		self.AnimTime = nil
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end
	
	if self.Heal and self.Heal < CurTime() then
		self.Heal = nil
		self.Holstering = CurTime() + 0.6
		
		self:DoHealing()
	end
end

function SWEP:Holster()
	if SERVER then self.Owner:DrawWorldModel( true ) end
	if self.Holstering and self.Holstering < CurTime() then return true end
end

function SWEP:Deploy()
	self.Owner:DrawWorldModel( true )
	self:SendWeaponAnim( ACT_VM_DRAW )
	self.Heal = CurTime() + 1
	self.AnimTime = CurTime() + 0.8
	self.Holstering = nil
	
	umsg.Start( 'hl2_draw', self.Owner )
		umsg.Entity( self )
	umsg.End()
end

function SWEP:Initialize()
	self:SetWeaponHoldType( 'slam' )
end