AddCSLuaFile()

ENT.Spawnable		= false
ENT.Base			= 'base_anim'
ENT.PrintName		= 'M79 grenade'

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
function ENT:Initialize()
	if SERVER then
		self:SetModel( 'models/items/ar2_grenade.mdl' ) 
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
		local phys = self:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:Wake()
			phys:SetMass( phys:GetMass() * 0.1 )
		end
		
		self.VelocitySimulate = CurTime() + 0.2
	else
		self.Emitter = ParticleEmitter( self:GetPos() )
	end
end

function ENT:OnTakeDamage( dmg )
end

function ENT:PhysicsCollide( tr )
	if CLIENT then return end
	if self:GetNWBool( 'misfire' ) then
		if tr.Speed > 25 then
			self:EmitSound( 'physics/metal/metal_grenade_impact_hard' .. math.random( 1, 3 ) .. '.wav', 80, 100 )
		end
		
		return
	end
	
	local e = tr.HitEntity
	local soft = self.VelocitySimulate <= CurTime() and IsValid( e ) and ( e:IsPlayer() or e:IsNPC() )
	if self.VelocitySimulate > CurTime() or soft then
		if not soft then
			self:SetNWBool( 'misfire', true )
			self.RemoveMe = CurTime() + 15
		end
		
		local nat
		if IsValid( e ) then
			local dmg = DamageInfo()
				dmg:SetDamageType( DMG_CLUB )
				dmg:SetDamage( 70 )
				dmg:SetAttacker( self:GetOwner() )
				dmg:SetInflictor( self )
			e:TakeDamageInfo( dmg )
			
			if e:IsPlayer() or e:IsNPC() then
				nat = true
			end
		end
		
		if nat then
			self:EmitSound( 'physics/body/body_medium_break' .. math.random( 2, 4 ) .. '.wav', 80, 100 )
		else
			self:EmitSound( 'physics/metal/metal_grenade_impact_hard' .. math.random( 1, 3 ) .. '.wav', 80, 100 )
		end
	else
		local bum = ents.Create( 'grenade_ar2' ) -- fuck off, i know what i'm doing
			bum:SetPos( self:GetPos() + self:GetVelocity():GetNormal() )
			bum:SetAngles( self:GetAngles() )
			bum:SetOwner( self:GetOwner() )
			bum:Spawn()
			bum:SetMoveType( MOVETYPE_NONE ) -- this will make this shit go bum
		self:Remove()
	end
end

function ENT:Use()
end

function ENT:Think()
	if not self:GetNWBool( 'misfire' ) and CLIENT then
		local ptcl = self.Emitter:Add( 'particle/smokesprites_000' .. math.random( 1, 9 ), self:GetPos() )
			ptcl:SetStartSize( math.random( 16, 24 ) )
			ptcl:SetEndSize( math.random( 28, 36 ) )
			ptcl:SetStartAlpha( 150 )
			ptcl:SetEndAlpha( 0 )
			ptcl:SetDieTime( math.Rand( 0.7, 1.2 ) )
			ptcl:SetRoll( math.random( -180, 180 ) )
			ptcl:SetRollDelta( 0.01 )
			ptcl:SetColor( 200, 200, 200 )
			ptcl:SetLighting( true )
			ptcl:SetVelocity( VectorRand() * 25 )
	end
	
	if SERVER and self.RemoveMe and self.RemoveMe < CurTime() then
		self.RemoveMe = nil
		self:Remove()
	end
end

--[[

function ENT:Initialize()
	self.Emitter = ptclicleEmitter(self:GetPos())
	self.ptclicleDelay = 0
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	if not self.dt.Misfire then
		local ptcl = self.Emitter:Add("ptclicle/smokesprites_000" .. math.random(1, 9), self:GetPos())
		ptcl:SetStartSize(12)
		ptcl:SetEndSize(16)
		ptcl:SetStartAlpha(150)
		ptcl:SetEndAlpha(0)
		ptcl:SetDieTime(1)
		ptcl:SetRoll(math.random(0, 360))
		ptcl:SetRollDelta(0.01)
		ptcl:SetColor(200, 200, 200)
		ptcl:SetLighting(true)
		ptcl:SetVelocity(VectorRand() * 25)
	end
end 

]]