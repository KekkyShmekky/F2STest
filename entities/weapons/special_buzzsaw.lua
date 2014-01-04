AddCSLuaFile()

SWEP.PrintName				= 'BUZZSAW'
SWEP.Spawnable 				= false
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV			= 0
SWEP.Slot					= -1
SWEP.ViewModel				= ''
SWEP.WorldModel				= 'models/props/cs_militia/circularsaw01.mdl'

SWEP.IconLetter				= ''
SWEP.Primary.Ammo			= 'buzzsaw'
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
	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 65,
		filter = self.Owner
	} )
	
	return self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 and tr.Hit and IsValid( tr.Entity ) and tr.Entity:GetClass() == 'prop_destructable' and not GAMEMODE:IsFriendOf( tr.Entity:GetNWEntity( 'owner' ), self.Owner )
end

function SWEP:SelectWeapon( wep )
	if not wep then return end
	if SERVER then self.Owner:SelectWeapon( wep ) end
end

function SWEP:Think() if SERVER then self.Owner:SelectWeapon( self.OldWeapon ) end end
function SWEP:Holster() return true end

function SWEP:Deploy()
	if not self:CanDeploy() then return end
	
	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 65,
		filter = self.Owner
	} )
	
	if tr.Hit and IsValid( tr.Entity ) and tr.Entity:GetClass() == 'prop_destructable' and not GAMEMODE:IsFriendOf( tr.Entity:GetNWEntity( 'owner' ), self.Owner ) then
		local ent = ents.Create( 'sent_buzzsaw' )
			ent:SetPos( tr.HitPos )
			ent:SetAngles( tr.HitNormal:Angle() )
			ent:Spawn()
			ent:SetNWEntity( 'owner', self.Owner )
			ent.SawEntity = tr.Entity
		self.Owner:SetAmmo( self.Owner:GetAmmoCount( 'buzzsaw' ) - 1, 'buzzsaw' )
		self:EmitSound( 'weapons/tripwire/hook.wav', 50 )
	end
end

function SWEP:Initialize()
	self:SetWeaponHoldType( 'slam' )
end