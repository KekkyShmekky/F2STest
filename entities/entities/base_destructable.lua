AddCSLuaFile()
DEFINE_BASECLASS( 'base_anim' )

ENT.Blowtorch		= true
ENT.Spawnable		= true

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
function ENT:Initialize()
	self.ConstructTime = CurTime() + 1
	self:SetNWInt( 'hp', self.MaxHealth )
end

function ENT:OnTakeDamage( dmg )
	local a = dmg:GetAttacker()
	if dmg:GetDamageType() == DMG_BLAST then dmg:ScaleDamage( 3 ) end
	if IsValid( a ) and a ~= self:GetNWEntity( 'owner' ) and GAMEMODE:IsFriendOf( a, self:GetNWEntity( 'owner' ) ) then
		dmg:SetDamage( 0 )
	end
	
	self:SetNWInt( 'hp', math.max( self:GetNWInt( 'hp' ) - dmg:GetDamage(), 0 ) )
	self.Attacker = a
end

function ENT:Destroy()
	if self.AlreadyDestroyed or CLIENT then return end
	
	if self.Attacker and IsValid( self.Attacker ) and not GAMEMODE:IsFriendOf( self.Attacker, self:GetNWEntity( 'owner' ) ) then
		umsg.Start( 'feed', self.Attacker )
			umsg.String( 'ENEMY STRUCTURE DESTROYED 10' )
		umsg.End()
		
		self.Attacker.StreaksTime = CurTime() + 6
		self.Attacker:SetNWInt( 'livexp', self.Attacker:GetNWInt( 'livexp' ) + 10 )
	end
	
	self.AlreadyDestroyed = true
	self:SetKeyValue( 'targetname', 'destructable' )
	sound.Play( 'physics/metal/metal_box_break1.wav', self:GetPos() + self:OBBCenter(), 100, 100, 1 )
	
	local dslv = ents.Create( 'env_entity_dissolver' )
		dslv:Spawn()
		dslv:SetKeyValue( 'dissolvetype', 2 )
		dslv:Fire( 'Dissolve', 'destructable' )
	self:DeleteOnRemove( dslv )
end

function ENT:Think()
		self.Owner = self:GetNWEntity( 'owner' )
	if not IsValid( self.Owner ) then return SERVER and self:Remove() end
	if SERVER and self:GetNWInt( 'hp' ) <= 0 then self:Destroy() end
end

function ENT:SpawnFunction()
end