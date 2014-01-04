AddCSLuaFile()

SWEP.PrintName				= 'SENTRY'
SWEP.Spawnable 				= false
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV			= 0
SWEP.Slot					= -1
SWEP.ViewModel				= ''
SWEP.WorldModel				= 'models/combine_turrets/ground_turret.mdl'

SWEP.IconLetter				= ''
SWEP.Primary.Ammo			= 'sentry'
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1

SWEP.Secondary.Ammo			= 'none'
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultSize	= -1

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:CheckForOtherSentries()
	for _, e in pairs( ents.FindByClass( 'sent_sentry' ) ) do
		if e:GetNWEntity( 'owner' ) == self.Owner then
			return false
		end
	end
	
	for _, e in pairs( ents.FindInSphere( self.Owner:GetPos(), 256 ) ) do
		if e:GetClass() == 'sent_sentry' then
			return false
		end
	end
	
	return true
end

function SWEP:CanDeploy()
	return self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 and self.Owner:IsOnGround() and self:CheckForOtherSentries()
end

function SWEP:SelectWeapon( wep )
	if not wep then return end
	if SERVER then self.Owner:SelectWeapon( wep ) end
end

function SWEP:Think() if SERVER then self.Owner:SelectWeapon( self.OldWeapon ) end end
function SWEP:Holster() return true end

function SWEP:Deploy()
	if not self:CanDeploy() then return end
	
	if self.Owner:IsOnGround() and self:CheckForOtherSentries() then
		local ent = ents.Create( 'sent_sentry' )
			ent:SetPos( self.Owner:GetPos() + Vector( 0, 1, 0 ) )
			ent:SetAngles( Angle( 0, math.Round( self.Owner:EyeAngles().y / 45 ) * 45, 0 ) )
			ent:SetNWEntity( 'owner', self.Owner )
			ent:Spawn()
		self.Owner:SetAmmo( self.Owner:GetAmmoCount( 'sentry' ) - 1, 'sentry' )
		self:EmitSound( 'weapons/tripwire/hook.wav' )
		
		undo.Create( 'sent_sentry' )
			undo.AddEntity( ent )
			undo.SetPlayer( self.Owner )
		undo.Finish()
	end
end

function SWEP:Initialize()
	self:SetWeaponHoldType( 'normal' )
end