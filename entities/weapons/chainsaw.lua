--[[
	This weapon had to be main weapon of player "Maniac"
	If you finish this shit sometime, please, send NanoCat the sources and other shit you changed if you want me to add this shit to addon, also:
		-make a list of changes you did, tell me "critical" shit that can ruin your shit in a moment, you understand what i mean, eh?
		-umm, contact me on steam, not somewhere else like facepunch, okay? my steam profile link is in my facepunch profile, figure it out
	
	Maniac had to be player randomly selected from players list every 30 minutes with some conditions:
		Weather must be rain (GAMEMODE.Weather == 1)
		There's more than 3 players in total (#player.GetAll() > 3)
		The player must be different from last player that was maniac
		
	Actual maniac's properties:
		Maniac has the only weapon: chainsaw
		Maniac is slow (200 speed) until he turns his chainsaw on
		When he does it, his speed must be increased to 320
		Jump power: 300
		
		When maniac gets landed to ground he doesn't receive damage, instead
			effect thumper dust must be created (1-3 times)
			sound (woosh or bum) must be played
			players in radius 256 units must receive the damage, if:
				util.TraceLine from maniac to player doesn't hit world
			
			the damage is affected by distance:
				256 units: 7-11 damage
				closer than 64 units: 86-112 damage
]]

AddCSLuaFile()

SWEP.PrintName				= 'CHAINSAW'
SWEP.Spawnable 				= false
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV			= 60
SWEP.Slot					= -2
SWEP.ViewModel				= 'models/weapons/melee/v_chainsaw.mdl'
SWEP.WorldModel				= 'models/weapons/melee/w_chainsaw.mdl'
SWEP.Base					= 'hl2_base'

SWEP.IconLetter				= ''
SWEP.Primary.Ammo			= 'none'
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= true

SWEP.Secondary.Ammo			= 'none'
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultSize	= -1
SWEP.CustomDrawSequence = { { 0, 'friday13/start.wav' } }

SWEP.HoldTypes	=
{
	Running = 'physgun',
	Sights = 'physgun',
	Idle = 'physgun',
	Reload = 'physgun'
}

local sfx =
{
	'physics/body/body_medium_break2.wav',
	'physics/body/body_medium_break3.wav',
	'physics/body/body_medium_break4.wav'
}

local gibs =
{
	{ 
		name = 'models/gibs/antlion_gib_large_3.mdl',
		scale = true,
		material = 'models/flesh'
	},
	{
		name = 'models/Gibs/Antlion_gib_small_2.mdl',
		scale = true,
		material = 'models/flesh'
	},
	{
		name = 'models/Gibs/Antlion_gib_Large_1.mdl',
		scale = true,
		material = 'models/flesh'
	},
	{ name = 'models/gibs/hgibs.mdl' },
	{ name = 'models/gibs/hgibs_scapula.mdl' },
	{ name = 'models/gibs/hgibs_spine.mdl' }
}

function SWEP:Holster() end
function SWEP:Melee() end

function SWEP:OnRemove()
	if self.Rage then self.Rage:Stop() end
	if self.Idle then self.Idle:Stop() end
	
	self.BaseClass.OnRemove( self )
end

function SWEP:PrimaryAttack() self.Attack = CurTime() + 0.3 end
function SWEP:SecondaryAttack() end

function SWEP:FindVictims()
	local victims = {}
	for _, v in pairs( ents.FindInSphere( self.Owner:GetPos(), 80 ) ) do
		local tr, data = self:GetTraces( v, self.Owner )
		if tr and v ~= self.Owner and ( ( v:IsPlayer() or v:IsNPC() ) and v:Health() > 0 or v.Base == 'base_destructable' ) then table.insert( victims, v ) end
		if v:GetClass() == 'prop_ragdoll' then table.insert( victims, v ) end
	end
	
	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 80,
		filter = self.Owner
	} )
	
	local ent = tr.Entity
	if IsValid( ent ) and ( ( ent:IsPlayer() or ent:IsNPC() ) and ent:Health() > 0 or ent.Base == 'base_destructable' or ent:GetClass() == 'func_breakable' ) and not table.HasValue( victims, ent ) then
		table.insert( victims, ent )
	end
	
	return #victims > 0 and victims or nil
end

function SWEP:GetTraces( entity )
	local tr = util.TraceLine( { start = self.Owner:LocalToWorld( Vector( 0, 0, 50 ) ), endpos = entity:LocalToWorld( Vector( 0, 0, 50 ) ) } )
	if tr.Entity == entity then return true, tr end
	
	return false
end

function SWEP:MakeGibs( ent )
	for i = 1, math.random( 12, 23 ) do
		local gib = ents.Create( 'prop_physics' )
		local mdl = table.Random( gibs )
		
		gib:SetPos( ent:GetPos() + Vector( 0, 0, 40 ) )
		gib:SetModel( mdl.name )
		gib:DrawShadow( false )
		
		if mdl.scale then gib:SetModelScale( math.random( 0.25, 0.50 ), 0 ) end
		if mdl.material then gib:SetMaterial( mdl.material ) end
		
		gib:PhysicsInit( SOLID_VPHYSICS )
		gib:SetMoveType( MOVETYPE_VPHYSICS )
		gib:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		
		local phys = gib:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocity( ent:GetVelocity() + VectorRand() * 200 )
			phys:AddAngleVelocity( VectorRand() * gib:BoundingRadius() * 2 )
		end
		
		timer.Simple( 15, function() if IsValid( gib ) then gib:Remove() end end )
	end
	
	ent:EmitSound( table.Random( sfx ) )
end

function SWEP:Think()
	self.Run_V = VectorRand()
	self.Idle_V = VectorRand()
	
	local rage = ( self.Attack or 0 ) + 0.1 > CurTime()
	if rage then
		if self.Idle then self.Idle = self.Idle:Stop() end
		if not self.Rage then
			self.Rage = CreateSound( self, 'friday13/rage.wav' )
			self.Rage:Play()
			self:SendWeaponAnim( ACT_VM_SWINGHIT )
			self.StartSlashing = CurTime() + 0.3
		end
		
		local vm = self.Owner:GetViewModel()
		if IsValid( vm ) and vm:GetSequenceActivity( vm:GetSequence() ) == ACT_VM_SWINGHIT and vm:GetCycle() > 0.1 then
			self:SendWeaponAnim( ACT_VM_SWINGHIT )
		end
		
		if SERVER and self.StartSlashing and self.StartSlashing < CurTime() then
			self.StartSlashing = CurTime() + 0.2
			
			local targets = self:FindVictims()
			if targets then
				for _, v in pairs( targets ) do
					if v:GetClass() == 'prop_ragdoll' then
						umsg.Start( 'feed', self.Owner )
							umsg.String( 'SOUL ABSORBED 50' )
						umsg.End()
						
						self.Owner.StreaksTime = CurTime() + 6
						self.Owner:SetNWInt( 'livexp', self.Owner:GetNWInt( 'livexp' ) + 50 )
						self.Owner:SetHealth( math.min( self.Owner:Health() + math.random( 15, 50 ), 300 ) )
						self.Owner.LossRate = 0
						
						self:MakeGibs( v )
						v:Remove()
					else
						local dmg = DamageInfo()
							dmg:SetDamage( 120 )
							dmg:SetDamageType( DMG_SLASH )
							dmg:SetAttacker( self.Owner )
							dmg:SetInflictor( self )
						v:TakeDamageInfo( dmg )
						
						if ( v:IsPlayer() or v:IsNPC() ) and v:Health() <= 0 then
							self.Owner.LossRate = 0
							self.Owner:SetHealth( math.min( self.Owner:Health() - v:Health() * math.Rand( 0.7, 1.5 ), 300 ) )
						end
					end
				end
			end
		end
	else
		if self.Rage then
			self.Rage = self.Rage:Stop()
			self:SendWeaponAnim( ACT_VM_IDLE )
		end
		
		if not self.Idle then
			self.Idle = CreateSound( self, 'friday13/idle.wav' )
			self.Idle:Play()
			self.Idle:ChangeVolume( 0.5, 0 )
		end
	end
	
	self.BaseClass.Think( self )
end

function SWEP:DrawWorldModel()
	local a = self.Owner:LookupAttachment( 'anim_attachment_rh' )
	if a then
		a = self.Owner:GetAttachment( a )
		
		if a and IsValid( self.Owner ) and not self.Owner:InVehicle() then
			a.Ang:RotateAroundAxis( a.Ang:Right(), 190 )
			a.Ang:RotateAroundAxis( a.Ang:Forward(), 180 )
			a.Ang:RotateAroundAxis( a.Ang:Up(), 22 )
			
			a.Pos = a.Pos - a.Ang:Forward() * 10
			
			self:SetRenderOrigin( a.Pos )
			self:SetRenderAngles( a.Ang )
			
			render.Model( { model = self.WorldModel, pos = a.Pos, angle = a.Ang } )
		end
	end
end