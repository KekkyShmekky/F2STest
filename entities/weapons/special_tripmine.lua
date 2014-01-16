AddCSLuaFile()

SWEP.PrintName				= 'TRIPMINE'
SWEP.Spawnable 				= false
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV			= 60
SWEP.Slot					= -1
SWEP.ViewModel				= 'models/weapons/c_slam.mdl'
SWEP.WorldModel				= 'models/weapons/w_slam.mdl'

SWEP.IconLetter				= '\x2A'
SWEP.FontOverride			= 'HL2MP'
SWEP.PosOffset				= { x = -3, y = 17 }
SWEP.Primary.Ammo			= 'tripmine'
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
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 52,
		filter = self.Owner
	} )
	
	return self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 and tr.Hit and ( not IsValid( tr.Entity ) or IsValid( tr.Entity ) and tr.Entity:GetClass() == 'prop_destructable' ) and self:CheckForOtherMines( tr.HitPos )
end

function SWEP:SelectWeapon( wep )
	if not wep then return end
	if SERVER then self.Owner:SelectWeapon( wep ) end
end

function SWEP:Think()
	if self.Holstering and SERVER then self.Owner:SelectWeapon( self.OldWeapon ) end
	
	if self.AnimTime and self.AnimTime < CurTime() then
		self.AnimTime = nil
		self:SendWeaponAnim( ACT_SLAM_TRIPMINE_ATTACH )
		
		umsg.Start( 'hl2_holdtype' )
			umsg.Entity( self )
			umsg.String( 'revolver' )
		umsg.End()
	end
	
	if self.AttachTime and self.AttachTime < CurTime() then
		self.AttachTime = nil
		self.Holstering = true
		
		if self.Owner:GetAmmoCount( 'tripmine' ) <= 0 then return end
		
		local tr = util.TraceLine( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 52,
			filter = self.Owner
		} )
		
		if tr.Hit and ( not IsValid( tr.Entity ) or IsValid( tr.Entity ) and tr.Entity:GetClass() == 'prop_destructable' ) and self:CheckForOtherMines( tr.HitPos ) then
			local ang = tr.HitNormal:Angle()
				ang:RotateAroundAxis( ang:Right(), -90 )
			
			local ent = ents.Create( 'sent_tripmine' )
				ent:SetPos( tr.HitPos + ang:Up() * 2 )
				ent:SetAngles( ang )
				ent:SetNWEntity( 'owner', self.Owner )
				ent:Spawn()
			self.Owner:SetAmmo( self.Owner:GetAmmoCount( 'tripmine' ) - 1, 'tripmine' )
		end
	end
end

function SWEP:CheckForOtherMines( vec )
	for _, e in pairs( ents.FindInSphere( vec, 12 ) ) do
		if e:GetClass() == 'sent_tripmine' then
			return false
		end
	end
	
	return true
end

function SWEP:Holster() return self.Holstering end
function SWEP:Deploy()
	self:SendWeaponAnim( ACT_SLAM_TRIPMINE_DRAW )
	self.Holstering = nil
	self.AnimTime = CurTime() + 0.4
	self.AttachTime = CurTime() + 0.67
	
	umsg.Start( 'hl2_holdtype' )
		umsg.Entity( self )
		umsg.String( 'slam' )
	umsg.End()
end

function SWEP:Initialize()
	self:SetWeaponHoldType( 'slam' )
end