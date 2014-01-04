AddCSLuaFile()

ENT.MaxHealth		= 500
ENT.Spawnable		= true
ENT.Base			= 'base_destructable'
ENT.PrintName		= 'Sentry'
ENT.TurretZ			= 0
ENT.Angles			= Angle()
ENT.Cone			= 0.08
ENT.Box				= 250
ENT.Primary			= { SoundLevel = 100 }
ENT.DistantSound	= 'Distant.Heavy_Sniper'

AddSound( 'SENTRY.FIRE', 'weapons/sentry.wav', nil, CHAN_STATIC )

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
function ENT:Initialize()
	self:SetNWInt( 'hp', self.MaxHealth )
	self:SetModel( 'models/props_phx/construct/metal_plate1.mdl' )
	self.Construct = true
	
	if SERVER then
		self.AutoTurnOn = CurTime() + 1
		self:SetUseType( SIMPLE_USE )
		
		self.Shake = ents.Create( 'env_shake' )
		self.Shake:SetPos( self:GetPos() )
		self.Shake:Spawn()
		self.Shake:SetKeyValue( 'amplitude', 12 )
		self.Shake:SetKeyValue( 'radius', 256 )
		self.Shake:SetKeyValue( 'duration', 0.5 )
		self.Shake:SetKeyValue( 'frequency', 255 )
		
		self.Turret = ents.Create( 'prop_physics' )
		self.Turret:SetPos( self:GetPos() )
		self.Turret:SetAngles( self:GetAngles() + Angle( 0, 0, 180 ) )
		self.Turret:SetModel( 'models/combine_turrets/ground_turret.mdl' )
		self.Turret:DeleteOnRemove( self )
		self.Turret:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		self:DeleteOnRemove( self.Turret )
		self:DeleteOnRemove( self.Shake )
		self:SetNWEntity( 'turret', self.Turret )
		
		local ammopack = ents.Create( 'prop_physics' )
			ammopack:SetPos( self.Turret:GetPos() - self.Turret:GetForward() * 4 + self.Turret:GetRight() * 8 - self.Turret:GetUp() * 8 )
			ammopack:SetAngles( self.Turret:GetAngles() - Angle( 0, 0, 180 ) )
			ammopack:SetModel( 'models/items/boxmrounds.mdl' )
			ammopack:SetParent( self.Turret )
			ammopack:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			ammopack:Spawn()
		self.Turret.Ammopack = ammopack
	end
	
	self.BaseClass.Initialize( self )
end

function ENT:OnRemove()
	if SERVER and not self.ReloadedOnce and IsValid( self:GetNWEntity( 'owner' ) ) and self:GetNWEntity( 'owner' ):IsPlayer() then
		local items = GAMEMODE:GetItems( self:GetNWEntity( 'owner' ) )
		if self.Box == 250 then
			items.money = items.money + 1000
		else
			items.money = items.money + self.Box * 3
		end
	end
end

function ENT:Use( ply )
	if IsValid( self:GetNWEntity( 'owner' ) ) and GAMEMODE:IsFriendOf( self:GetNWEntity( 'owner' ), ply ) then
		if ( self.NextUse or 0 ) < CurTime() then
			self.NextUse = CurTime() + 0.5
			self:SetNWBool( 'on', not self:GetNWBool( 'on' ) )
			self:EmitSound( self:GetNWBool( 'on' ) and 'weapons/tripwire/mine_activate.wav' or 'weapons/slam/mine_mode.wav', 50 )
		elseif self.Box < 250 then
			self.NextUse = CurTime() + 3
			self:SetNWBool( 'on', false )
			
			local items = GAMEMODE:GetItems( ply )
			if items.money >= 250 then
				local diff = math.min( math.ceil( ( 250 - self.Box ) * 1.5 ), items.money )
				items.money = items.money - diff
				
				self.ReloadedOnce = true
				self.Box = 250
				self:EmitSound( 'items/ammo_pickup.wav' )
				
				ply:ChatPrint( 'Reloaded sentry for $' .. diff )
			else
				ply:ChatPrint( 'You don\'t have enough money' )
			end
		end
	end
end

function ENT:Sign( num )
	if num > 0 then return 1 end
	if num < 0 then return -1 end
	
	return 0
end

function ENT:CheckFriendship( ent )
	local owner = self:GetNWEntity( 'owner' )
	if owner == ent then return false end
	if owner:Team() == 0 then return true end
	if ent:Team() == 0 then return true end
	
	return owner:Team() ~= ent:Team()
end

function ENT:Think()
	if SERVER and self.Construct then
		for _, v in pairs( ents.FindInSphere( self:GetPos() + self:OBBCenter(), self:BoundingRadius() ) ) do
			if v:IsPlayer() and ( GAMEMODE:IsColliding( v, self ) or GAMEMODE:IsColliding( self, v ) ) then
				return v:SetVelocity( ( v:GetPos() - self:GetPos() ):GetNormal() * 512 )
			end
		end
		
		self.Construct = nil
		self:SetSolid( SOLID_VPHYSICS )
		
		if IsValid( self.Turret ) then
			self.Turret:Spawn()
			self.Turret:SetMoveType( MOVETYPE_NONE )
		end
	end
	
	if self.RetireTime and CLIENT then
		if self.RetireTime < CurTime() or not self:GetNWBool( 'on' ) then
			self.RetireTime = nil
			self:EmitSound( 'NPC_FloorTurret.Retire' )
		end
	end
	
	if self.AutoTurnOn and self.AutoTurnOn < CurTime() then
		self.AutoTurnOn = nil
		self:SetNWBool( 'on', true )
	end
	
	
	if self:GetNWInt( 'hp' ) <= 0 then return self:Destroy() end
	if self:GetNWBool( 'on' ) and SERVER then
		if ( self.TargetSearch or 0 ) < CurTime() then
			self.TargetSearch = CurTime() + 0.75
			
			local turret = self:GetNWEntity( 'turret' )
			local trace = 
			{
				start = self:GetPos() + self:GetUp() * 5,
				filter = { self, turret, turret.Ammopack, self:GetNWEntity( 'owner' ) },
				mask = bit.band( MASK_SHOT, bit.bnot( CONTENTS_WINDOW ) )
			}
			
			local owner = self:GetNWEntity( 'owner' )
			local sp = self:GetPos()
			local closest
			local closest_dist = 9999
			for _, e in pairs( ents.FindInSphere( self:GetPos(), 768 ) ) do
				if ( e:IsPlayer() and self:CheckFriendship( e ) or e:IsNPC() ) and e:Health() > 0 then
						trace.endpos = e:GetPos() + e:OBBCenter()
					local dst = e:GetPos():Distance( self:GetPos() )
					local tr = util.TraceLine( trace )
					local p = ( ( trace.start - tr.HitPos ):Angle() - self:GetAngles() ).p
					
					if p < 70 and p > -30 and tr.Entity == e and dst < closest_dist then
						closest = e
						closest_dist = dst
					end
				end
			end
			
			if self.TurretTarget ~= closest then
				self.TurretTarget = closest
				self:SetNWEntity( 'target', closest )
				
				if closest then self:EmitSound( 'NPC_FloorTurret.Activate' ) end
			end
		end
	end
	
	if self:GetNWBool( 'on' ) then
		local turret = self:GetNWEntity( 'turret' )
		local target = self:GetNWEntity( 'target' )
		if IsValid( target ) and IsValid( turret ) then
			local org = turret:GetPos()
			local dest = target:GetPos() + target:OBBCenter() - Vector( 0, 0, 10 )
			local ang = ( dest - org ):Angle()
				ang.p = math.Clamp( math.NormalizeAngle( ang.p ), self:GetAngles().p - 20, self:GetAngles().p + 10 )
			
			for i = 1, 10 do
				local dir = ( math.NormalizeAngle( ang.y ) - self.Angles.y )
				local sign = self:Sign( dir )
				if math.abs( sign ) <= math.abs( dir ) then dir = sign else dir = dir * 0.25 end
				
				self.Angles.y = self.Angles.y + dir
			end
			
			self.Angles.p = math.Approach( self.Angles.p, ang.p, 7.5 )
			self.Angles.r = 180
			self.RetireTime = CurTime() + 3
			
			turret:SetAngles( self.Angles )
			
			local i = turret:LookupAttachment( 'eyes' )
			if i and ( self.NextShot or 0 ) < CurTime() and target:Health() > 0 then
				self.NextShot = CurTime() + 0.1
				
				local a = turret:GetAttachment( i )
				local tr = util.TraceLine( {
					start = a.Pos,
					endpos = a.Pos + a.Ang:Forward() * a.Pos:Distance( dest ),
					filter = { self, turret, self:GetNWEntity( 'owner' ) },
					mask = bit.band( MASK_SHOT, bit.bnot( CONTENTS_WINDOW ) )
				} )
				
				if SERVER and ( tr.HitPos:Distance( dest ) < 32 or tr.Entity == self:GetNWEntity( 'target' ) ) then
					if self.Box > 0 then
						self:EmitSound( 'SENTRY.FIRE' )
						self.Shake:Fire( 'startshake' )
						self.Box = self.Box - 1
						
						orgFireBullets( turret, {
							Num = 1,
							Src = a.Pos,
							Dir = a.Ang:Forward(),
							Spread = Vector( self.Cone, self.Cone, self.Cone ),
							Force = 2048,
							Damage = 15,
							Attacker = self:GetNWEntity( 'owner' )
						} )
						
						local fx = EffectData()
							fx:SetEntity( turret )
							fx:SetAttachment( i )
						util.Effect( 'hl2_muzzle_sentry', fx )
						util.Effect( 'hl2_distantsound', fx )
					else
						self:EmitSound( 'Weapon_AR2.Empty' )
					end
				end
			end
			
			self:NextThink( CurTime() )
			return true
		end
	end
end

local beam = Material( 'effects/laser' )
function ENT:Draw()
	self:DrawModel()
	
	local turret = self:GetNWEntity( 'turret' )
	if IsValid( turret ) then		
		if self:GetNWBool( 'on' ) then
			local a = turret:LookupAttachment( 'light' )
			if a then
				local a = turret:GetAttachment( a )
				
				render.SetMaterial( beam )
				render.DrawBeam( a.Pos, a.Pos + a.Ang:Forward() * ( self.RetireTime and 200 or 100 ), 0.15, 0, 0.99, Color( 255, 0, 0, self.RetireTime and 255 or 60 ) )
			end
		end
	end
end