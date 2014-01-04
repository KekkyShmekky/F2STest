AddCSLuaFile()

SWEP.PrintName				= 'DEFIBRILLATOR'
SWEP.Spawnable 				= false
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV			= 60
SWEP.Slot					= -1
SWEP.ViewModel				= 'models/v_models/v_defibrillator.mdl'
SWEP.WorldModel				= 'models/w_models/weapons/w_eq_defibrillator_paddles.mdl'
SWEP.HolsteringTime			= 1

AddSound( 'Discharge', 'weapons/discharge.wav' )

SWEP.IconLetter				= '\x2A'
SWEP.Primary.Ammo			= nil
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1

SWEP.Secondary.Ammo			= 'none'
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultSize	= -1

local positions = {}
for i = 0, 360, 30 do table.insert( positions, Vector( math.cos( i ), math.sin( i ), 0 ) ) end
	table.insert( positions, Vector( 0, 0, 1 ) )

function SWEP:FindPosition( vec )
	local hull = Vector( 16, 16, 36 )
	local start = vec + Vector( 0, 0, hull.z )
	
	for _, v in pairs( positions ) do
		local pos = start + v * hull * 3
		if not util.TraceHull( {
			start = pos,
			endpos = pos,
			mins = hull * -1,
			maxs = hull,
		} ).Hit then
			return pos - Vector( 0, 0, hull.z )
		end
	end
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:CanDeploy()
	if true then return true end
	
	local ent = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
		filter = self.Owner
	} ).Entity
	
	if not IsValid( ent ) then return end
	if ent:IsPlayer() or ent:IsNPC() then
		return true
	end
	
	if ent:GetClass() == 'prop_physics' then
		for _, e in pairs( ents.FindByClass( 'sent_sentry' ) ) do
			if e:GetNWEntity( 'turret' ) == ent then
				ent = e
				break
			end
		end
	end
	
	if ent:GetClass() == 'sent_sentry' then
		return true
	end
	
	if ent:GetClass() == 'prop_ragdoll' then
		local ply = ent:GetNWEntity( 'player' )
		if IsValid( ply ) and ply:IsPlayer() and GAMEMODE:IsFriendOf( ply, self.Owner ) then
			return true
		end
	end
end

function SWEP:SelectWeapon( wep )
	if not wep then return end
	if SERVER then self.Owner:SelectWeapon( wep ) end
end

function SWEP:GetViewModelPosition( pos, ang )
	if self.ForwardOffset then
		pos = pos + ang:Forward() * self.ForwardOffset
		self.ForwardOffset = math.max( self.ForwardOffset - FrameTime() * 6, 0 )
	end
	
	return self.BaseClass.GetViewModelPosition( self, pos, ang )
end

function SWEP:Punt()
	for _, e in pairs( ents.FindByClass( 'prop_ragdoll' ) ) do
		e.OldCollisionGroup = e:GetCollisionGroup()
		e:SetCollisionGroup( COLLISION_GROUP_NONE )
	end
	
	local ent = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
		filter = self.Owner
	} ).Entity
	
	for _, e in pairs( ents.FindByClass( 'prop_ragdoll' ) ) do
		if e.OldCollisionGroup then
			e:SetCollisionGroup( e.OldCollisionGroup )
			e.OldCollisionGroup = nil
		end
	end
	
	local pass
	if not IsValid( ent ) then return end
	if ent:IsPlayer() or ent:IsNPC() then
		local dmg = DamageInfo()
			dmg:SetDamageType( DMG_SHOCK )
			dmg:SetDamage( 300 )
			dmg:SetAttacker( self.Owner )
			dmg:SetInflictor( self )
			dmg:SetDamageForce( self.Owner:GetAimVector() * 4096 )
			ent:TakeDamageInfo( dmg )
		pass = true
	end
	
	if ent:GetClass() == 'prop_physics' then
		for _, e in pairs( ents.FindByClass( 'sent_sentry' ) ) do
			if e.Turret == ent then
				ent = e
				break
			end
		end
	end
	
	if ent:GetClass() == 'sent_sentry' then
		ent:Destroy()
		pass = true
	end
	
	local player, vec, ang
	if ent:GetClass() == 'prop_ragdoll' then
		local ply = ent:GetNWEntity( 'player' )
		if IsValid( ply ) and ply:IsPlayer() and GAMEMODE:IsFriendOf( ply, self.Owner ) then
			player = ply
			vec = self:FindPosition( ent:GetPos() )
			ang = Angle( 60, ent:GetAngles().y, 0 )
		end
		
		pass = true
	end
	
	if pass then
		local fx = EffectData()
			fx:SetEntity( ent )
			fx:SetMagnitude( 130 )
		util.Effect( 'TeslaHitBoxes', fx )
		
		self:EmitSound( 'Discharge' )
		self.Owner:ViewPunch( Angle( -7, 0, 0 ) )
		
		umsg.Start( 'discharge', self.Owner )
			umsg.Entity( self )
		umsg.End()
		
		umsg.Start( 'discharge_ent' )
			umsg.Entity( ent )
		umsg.End()
		
		if ent:GetClass() == 'prop_ragdoll' then
			for b = 0, ent:GetPhysicsObjectCount() - 1 do
				local phys = ent:GetPhysicsObjectNum( b )
				if IsValid( phys ) then
					phys:SetVelocity( VectorRand() * 256 )
				end
			end
		end
	end
	
	if player and vec and ang then
		if not ent:GetNWBool( 'headshot' ) and GAMEMODE:IsFriendOf( self.Owner, player ) then
			player:Spawn()
			player:SetPos( vec )
			player:SetEyeAngles( ang )
			player.SpawnProtection = CurTime()
			
			self.Owner:SetNWInt( 'livexp', self.Owner:GetNWInt( 'livexp' ) + 75 )
			self.Owner.StreaksTime = CurTime() + 6
			
			umsg.Start( 'feed', self.Owner )
				umsg.String( 'TEAM ASSIST 75' )
			umsg.End()
		end
	end
	
	return pass
end

function SWEP:Think()
	if self.Holstering and self.Holstering < CurTime() then return self:SelectWeapon( self.OldWeapon ) end
	
	if self.Discharge and self.Discharge < CurTime() then
		self.Discharge = nil
		self.Holstering = CurTime() + 0.6
		self.HoldPunt = true
	end
	
	if self.HoldPunt and ( self.NextPuntRetry or 0 ) < CurTime() then
		self.NextPuntRetry = CurTime() + 0.08
		
		if self:Punt() then
			self.HoldPunt = nil
			self.Holstering = CurTime() + 1
		end
	end
end

function SWEP:Holster()
	if SERVER then self.Owner:DrawWorldModel( true ) end
	if self.Holstering and self.Holstering < CurTime() then return true end
end

function SWEP:DrawWorldModel()
	local a = self.Owner:LookupAttachment( 'anim_attachment_rh' )
	
	if a and IsValid( self.WM ) then
		local a = self.Owner:GetAttachment( self.Owner:LookupAttachment( 'anim_attachment_rh' ) )
			a.Ang:RotateAroundAxis( a.Ang:Right(), 5 )
			a.Pos = a.Pos - a.Ang:Up() * 13 - a.Ang:Forward() * 2
			
		self.WM:SetPos( a.Pos )
		self.WM:SetAngles( a.Ang )
		self.WM:DrawModel()
	end
	
	self:DrawModel()
end

function SWEP:Deploy()
	if not self:CanDeploy() then return end
	
	self:SendWeaponAnim( ACT_VM_DEPLOY )
	self.Holstering = nil
	self.HoldPunt = nil
	self.ForwardOffset = nil
	self.Discharge = CurTime() + 0.8
end

if CLIENT then
	usermessage.Hook( 'discharge', function( um )
		local ent = um:ReadEntity()
		if not IsValid( ent ) then return end
		
		ent:EmitSound( 'Discharge' )
		ent.ForwardOffset = 8
		BLURAMOUNT = 300
	end )
	
	usermessage.Hook( 'discharge_ent', function( um )
		local ent = um:ReadEntity()
		if not IsValid( ent ) then return end
		
		local fx = EffectData()
			fx:SetEntity( ent )
			fx:SetMagnitude( 130 )
		util.Effect( 'TeslaHitBoxes', fx )
	end )
end

function SWEP:Initialize()
	if CLIENT then
		self.WM = ClientsideModel( self.WorldModel )
		self.WM:SetNoDraw( true )
	end
	
	self.Primary.Ammo = 'none'
	self:SetWeaponHoldType( 'duel' )
end