AddCSLuaFile()

ENT.Spawnable		= true
ENT.Base			= 'base_anim'
ENT.PrintName		= 'Buzzsaw pickupable'

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
function ENT:Initialize()	
	if SERVER then
		self:SetModel( 'models/w_models/weapons/w_smg_uzi.mdl' ) -- small hack for servers that don't have css
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:GetPhysicsObject():Wake()
	else
		self:SetModel( 'models/props/cs_militia/circularsaw01.mdl' )
	end
end

function ENT:Draw()
	if self:GetModel() ~= 'models/props/cs_militia/circularsaw01.mdl' then
		self:SetModel( 'models/props/cs_militia/circularsaw01.mdl' )
	end
	
	self:DrawModel()
end

function ENT:PhysicsCollide( data )
	if SERVER and IsValid( data.HitEntity ) and data.HitEntity:IsPlayer() and data.HitEntity:GetAmmoCount( 'buzzsaw' ) < 2 then
		data.HitEntity:SetAmmo( data.HitEntity:GetAmmoCount( 'buzzsaw' ) + 1, 'buzzsaw' )
		data.HitEntity:SendLua( 'surface.PlaySound("items/ammo_pickup.wav")' )
		self:Remove()
	end
end