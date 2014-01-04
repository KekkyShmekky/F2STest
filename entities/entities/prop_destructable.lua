AddCSLuaFile()

ENT.MaxHealth		= 2000
ENT.Spawnable		= true
ENT.Base			= 'base_destructable'
ENT.PrintName		= 'Wall prop'

function ENT:Initialize()
	self.Constructing = true
	self:SetNWInt( 'hp', 1 )
	
	if CLIENT then return end
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_NONE )
	
	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:EnableMotion( false )
	end
end

function ENT:Use( ply )
	if not self.Constructing and ply:IsPlayer() and GAMEMODE:IsFriendOf( self:GetNWEntity( 'owner' ), ply ) and IsValid( self.DoorModule ) then
		self.BackLockTime = CurTime() + 1.5
		self:SetNWBool( 'unlocked', true )
		self:SetSolid( SOLID_NONE )
	end
end

function ENT:Think()
	if self.Constructing and ( self.NextConstructStep or 0 ) < CurTime() then
		self.NextConstructStep = CurTime() + 0.1
		self:SetNWInt( 'hp', math.min( self:GetNWInt( 'hp' ) + 200, self.MaxHealth ) )
		self:EmitSound( 'weapons/blowtorch.wav' )
		
		if self:GetNWInt( 'hp' ) == self.MaxHealth or self:GetNWBool( 'constint' ) then
			if SERVER then
				for _, v in pairs( ents.FindInSphere( self:GetPos() + self:OBBCenter(), self:BoundingRadius() ) ) do
					if v:IsPlayer() and ( GAMEMODE:IsColliding( v, self ) or GAMEMODE:IsColliding( self, v ) ) then
						return v:SetVelocity( ( v:GetPos() - self:GetPos() ):GetNormal() * 512 )
					end
				end
			end
			
			self:SetSolid( SOLID_VPHYSICS )
			self.Constructing = nil
		end
	end
	
	if SERVER and self.BackLockTime and ( self.BackLockTime < CurTime() or not IsValid( self.DoorModule ) ) then		
		for _, v in pairs( ents.FindInSphere( self:GetPos() + self:OBBCenter(), self:BoundingRadius() ) ) do
			if v:IsPlayer() and ( GAMEMODE:IsColliding( v, self ) or GAMEMODE:IsColliding( self, v ) ) then
				return v:SetVelocity( ( v:GetPos() - self:GetPos() ):GetNormal() * 512 )
			end
		end
		
		self.BackLockTime = nil
		self:SetNWBool( 'unlocked', false )
		self:SetSolid( SOLID_VPHYSICS )
	end
	
	self.BaseClass.Think( self )
end

function ENT:OnTakeDamage( dmg )
		self:SetNWBool( 'constint', true )
	return self.BaseClass.OnTakeDamage( self, dmg )
end

function ENT:Draw()
	local c = self:GetNWInt( 'hp' ) / self.MaxHealth
	if self.Constructing then
		render.SetBlend( c )
	else
			c = c * 255
		self:SetColor( Color( c, c, c ) )
	end
	
	if self:GetNWBool( 'unlocked' ) then render.SetBlend( math.Rand( 0.3, 0.7 ) ) end
	self:DrawModel()
	render.SetBlend( 1 )
end