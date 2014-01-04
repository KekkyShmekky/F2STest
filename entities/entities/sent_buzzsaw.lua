AddCSLuaFile()

ENT.Spawnable		= true
ENT.Base			= 'base_anim'
ENT.PrintName		= 'Buzzsaw'

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
function ENT:Initialize()	
	if SERVER then
		self:SetModel( 'models/w_models/weapons/w_smg_uzi.mdl' )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetAngles( self:LocalToWorldAngles( Angle( 26.5, -58, -38 ) ) )
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		self.SoundChan = CreateSound( self, 'ambient/machines/spin_loop.wav' )
		self.SoundChan:Play()
		self.SoundChan:ChangeVolume( 0.5, 0 )
	end
end

function ENT:OnRemove()
	if self.SoundChan then self.SoundChan:Stop() end
	if SERVER then
		local ent = ents.Create( 'sent_buzzsaw_pickupable' )
			ent:SetPos( self:GetPos() )
			ent:SetAngles( self:GetAngles() )
			ent:Spawn()
		timer.Simple( 12, function() if IsValid( ent ) then ent:Remove() end end )
	end
end

function ENT:OnTakeDamage()
	sound.Play( 'ambient/machines/spinup.wav', self:GetPos(), 100 )
	self:Remove()
end

function ENT:Draw()
	self:SetModel( 'models/props/cs_militia/circularsaw01.mdl' )
	self:DrawModel()
end

function ENT:Think()
	if CLIENT then
		self:SetRenderOrigin( self:GetPos() + VectorRand() * 0.1 )
		
		local fx = EffectData()
			fx:SetOrigin( self:GetPos() )
			fx:SetNormal( -self:GetRight() )
		util.Effect( 'cball_bounce', fx )
	elseif SERVER and ( self.DestroyTick or 0 ) < CurTime() then
		self.DestroyTick = CurTime() + 0.1
		
		local par = self.SawEntity
		if IsValid( par ) then
			par:SetNWInt( 'hp', math.max( par:GetNWInt( 'hp' ) - 75, 0 ) )
			par.Attacker = self:GetNWEntity( 'owner' )
			
			if par:GetNWInt( 'hp' ) <= 0 then
				par:Destroy()
				sound.Play( 'ambient/machines/spindown.wav', self:GetPos(), 100 )
				self:Remove()
			end
		else
			sound.Play( 'ambient/machines/spindown.wav', self:GetPos(), 100 )
			self:Remove()
		end
	end
end