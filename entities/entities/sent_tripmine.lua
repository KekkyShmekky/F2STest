AddCSLuaFile()

ENT.Spawnable		= true
ENT.Base			= 'base_anim'
ENT.PrintName		= 'Trip mine'

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
function ENT:Initialize()
	self:SetModel( 'models/weapons/w_slam.mdl' )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
	if SERVER then
		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then phys:EnableMotion( false ) end
		
		self.AutoTurnOn = CurTime() + 1
		self:SetUseType( SIMPLE_USE )
		self:EmitSound( 'weapons/tripwire/hook.wav', 50 )
	end
end

function ENT:Explode()
	if CLIENT then return end
	if self.Removed then return end
		self.Removed = true
	
	local bum = ents.Create( 'env_explosion' )
		bum:SetOwner( self:GetNWEntity( 'owner' ) )
		bum:SetPos( self:GetPos() )
		bum:SetAngles( self:GetAngles() )
		bum:SetKeyValue( 'imagnitude', 280 )
		bum:SetKeyValue( 'iradiusoverride', 180 )
		bum:Spawn()
		bum:Activate()
		bum:Fire( 'explode' )
	self:Remove()
	
	timer.Simple( 1, function() if IsValid( bum ) then bum:Remove() end end )
end

function ENT:OnTakeDamage( dmg )
	self:Explode()
end

function ENT:Use( ply )
	if IsValid( self:GetNWEntity( 'owner' ) ) and GAMEMODE:IsFriendOf( self:GetNWEntity( 'owner' ), ply ) and ( self.NextUse or 0 ) < CurTime() then
		self.NextUse = CurTime() + 0.5
		self:SetNWBool( 'on', not self:GetNWBool( 'on' ) )
		
		if self:GetNWBool( 'on' ) then
			local tr = util.TraceLine( {
				start = self:GetPos() - self:GetRight() * 3.35 - self:GetForward() * 2.2,
				endpos = self:GetPos() - self:GetRight() * 3.35 - self:GetForward() * 2.2 + self:GetUp() * 200,
				filter = self.Filters,
				mask = MASK_SHOT
			} )
			
			self.DefaultPos = tr.HitPos
			self:EmitSound( 'weapons/tripwire/mine_activate.wav', 50 )
		else
			self:EmitSound( 'weapons/slam/mine_mode.wav', 50 )
		end
	end
end

function ENT:Think()
	if self.AutoTurnOn and self.AutoTurnOn < CurTime() then
		self.AutoTurnOn = nil
		self:SetNWBool( 'on', true )
		self:EmitSound( 'weapons/tripwire/mine_activate.wav', 50 )
		
		local tr = util.TraceLine( {
			start = self:GetPos() - self:GetRight() * 3.35 - self:GetForward() * 2.2,
			endpos = self:GetPos() - self:GetRight() * 3.35 - self:GetForward() * 2.2 + self:GetUp() * 200,
			filter = self.Filters,
			mask = MASK_SHOT
		} )
		
		self.DefaultPos = tr.HitPos
	end
	
	if ( self.NextUpdateFilters or 0 ) < CurTime() then
		self.NextUpdateFilters = CurTime() + 1
		self.Filters = { self }
		
		local owner = self:GetNWEntity( 'owner' )
		if IsValid( owner ) then
			for _, v in pairs( player.GetAll() ) do
				if GAMEMODE:IsFriendOf( v, owner ) then
					table.insert( self.Filters, v )
				end
			end
		end
	end
	
	if SERVER and self.Filters and self:GetNWBool( 'on' ) then
		local tr = util.TraceLine( {
			start = self:GetPos() - self:GetRight() * 3.35 - self:GetForward() * 2.2,
			endpos = self:GetPos() - self:GetRight() * 3.35 - self:GetForward() * 2.2 + self:GetUp() * 200,
			filter = self.Filters,
			mask = MASK_SHOT
		} )
		
		if self.DefaultPos ~= tr.HitPos then self:Explode() end
		
		self:NextThink( CurTime() )
		return true
	end
end

local beam = Material( 'effects/laser' )
local red = Color( 255, 0, 0 )
function ENT:Draw()
	self:DrawModel()
	
	if self.Filters and self:GetNWBool( 'on' ) and IsValid( self:GetNWEntity( 'owner' ) ) and IsValid( LocalPlayer() ) and GAMEMODE:IsFriendOf( self:GetNWEntity( 'owner' ), LocalPlayer() ) then
		render.SetMaterial( beam )
		render.DrawBeam( self:GetPos() - self:GetRight() * 3.35 - self:GetForward() * 2.2, self:GetPos() - self:GetRight() * 3.35 - self:GetForward() * 2.2 + self:GetUp() * 200, 0.15, 0, 0.99, red )
	end
end