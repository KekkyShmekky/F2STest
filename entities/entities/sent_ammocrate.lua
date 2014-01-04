AddCSLuaFile()

local open			= 'AmmoCrate.Open'
local close 		= 'AmmoCrate.Close'

ENT.MaxHealth		= 1000
ENT.Spawnable		= true
ENT.Base			= 'base_destructable'
ENT.PrintName		= 'Ammo crate'

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end

local models =
{
	{
		'models/weapons/w_toolgun.mdl',
		Vector( -9, 17, 1 ),
		Angle( 0, 29, 0 )
	},
	{
		'models/weapons/w_grenade.mdl',
		Vector( -13, 11, 2 ),
		Angle( 0, 37, 0 )
	},
	{
		'models/weapons/w_grenade.mdl',
		Vector( 11, 8, 2 ),
		Angle( 0, -67, 0 )
	},
	{
		'models/weapons/w_grenade.mdl',
		Vector( 3, 27, 2 ),
		Angle( 0, -113, 0 )
	},
	{
		'models/weapons/w_smg1.mdl',
		Vector( -5, -2, 0 ),
		Angle()
	},
	{
		'models/weapons/w_pistol.mdl',
		Vector( 8, -4, 0 ),
		Angle( 180, 0, 0 )
	}
}

function ENT:Initialize()
	self.ConstructTime = CurTime() + 1
	self:SetModel( 'models/items/ammocrate_smg1.mdl' )
	
	self.BaseClass.Initialize( self )
end

function ENT:Open()
	self:EmitSound( open )
	self:SetSequence( 2 )
end

function ENT:Close()
	self:EmitSound( close )
	self:SetSequence( 3 )
end

function ENT:Callback()
	if self.Crate then
		self.Crate:Close()
		self.Crate.User = nil
		self.Crate = nil
		self.MenuCallback = nil
		
		local items = GAMEMODE:GetItems( self )	
		for k in pairs( items.groups ) do
			self:SetNWString( k, 'none' )
		end
		
		hook.Call( 'PlayerLoadout', GAMEMODE, self )
	end
end

function ENT:OnRemove()
	if IsValid( self.User ) then
		self.Callback( self.User )
	end
end

function ENT:Use( ply )
	if ply:IsPlayer() and not self.User then
		self:Open()
		
		ply.MenuCallback = self.Callback
		ply.Crate = self
		self.User = ply
		
		local inv = GAMEMODE:GetItems( ply )
		
		for k, v in pairs( inv.ammocount ) do
			inv.ammocount[ k ] = ply:GetAmmoCount( k ) + inv.ammobuy[ k ]
			inv.ammobuy[ k ] = 0
		end
		
		for k in pairs( inv.groups ) do
			ply:SetNWString( k, 'none' )
		end
		
		ply:StripWeapons()
		GAMEMODE:OpenMenu( ply, 3 )
	end
end

function ENT:Think()
	if self.ConstructTime and CLIENT then self:SetModelScale( 1 - math.Clamp( self.ConstructTime - CurTime(), 0, 1 ), 0 ) end
	if self.ConstructTime and self.ConstructTime < CurTime() then
		if SERVER then
			for _, v in pairs( ents.FindInSphere( self:GetPos() + self:OBBCenter(), self:BoundingRadius() ) ) do
				if v:IsPlayer() and ( GAMEMODE:IsColliding( v, self ) or GAMEMODE:IsColliding( self, v ) ) then
					return v:SetVelocity( ( v:GetPos() - self:GetPos() ):GetNormal() * 512 )
				end
			end
			
			self:SetSolid( SOLID_VPHYSICS )
		end
		
		self.ConstructTime = nil
	end
	
	if SERVER then
		if IsValid( self.User ) and not self.User:Alive() then
			self.User.MenuCallback = nil
			self.User.Crate = nil
			self.User = nil
			self:Close()
		end
	end
	
	self.BaseClass.Think( self )
end

function ENT:Draw()
	if not self.ConstructTime then
		local args = {}
		for _, v in pairs( models ) do
			args.model = v[1]
			args.pos = self:LocalToWorld( ( v[2] or Vector() ) - Vector( 0, 20, 0 ) )
			args.angle = self:LocalToWorldAngles( ( v[3] or Angle() ) + Angle( 0, 0, 90 ) )
			
			render.Model( args )
		end
	end
	
	self:DrawModel()
end