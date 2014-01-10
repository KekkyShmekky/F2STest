AddCSLuaFile()

SWEP.BobScale = 0
SWEP.SwayScale = 0

SWEP.Primary.SoundLevel		= 100
SWEP.Primary.Sound 			= 'Weapon_SMG1.Single'
SWEP.Primary.Cone 			= 0.1
SWEP.Primary.Delay 			= 0.1
SWEP.Primary.Damage 		= 11
SWEP.Primary.NumShots		= 1
SWEP.Primary.Automatic	  	= false
SWEP.Primary.ClipSize	   	= 15
SWEP.Primary.DefaultClip	= 15
SWEP.Primary.ClipsMax		= 3
SWEP.AcogFOVOffset			= 0

SWEP.IronSightsVec		= Vector()
SWEP.IronSightsSmooth	= Angle()
SWEP.Delta				= Angle()

SWEP.Melee_V			= Vector()
SWEP.Melee_A			= Angle()

SWEP.Sights_V			= Vector()
SWEP.Sights_A			= Angle()

SWEP.Run_V				= Vector()
SWEP.Run_A				= Angle()

SWEP.Idle_V				= Vector()
SWEP.Idle_A				= Angle()

SWEP.Melee_Dir			= 0
SWEP.Melee_Anim			= 0

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.ClipsMax		= 0

SWEP.JamChance				= 0
SWEP.JamSound				= 'Weapon_Pistol.Empty'

SWEP.ShellInterval			= 0.4

SWEP.Hint = 0
SWEP.Hint_Time = 0
SWEP.Hint_Attachment = 0
SWEP.Hint_Text = ''

SWEP.ContRecoil				= 0
SWEP.HolsteringTime			= 1
SWEP.Spawnable 				= false
SWEP.ShotgunReload			= false
SWEP.Chambering 			= true
SWEP.DeploySpeed			= 0.8
SWEP.Recoil 				=
{
	Single = false,
	Min = 0,
	Max = 5,
	ContRecoil = 0.1,
	Punch = Angle( 0.8, 0, 0 ),
	Real = Angle( 0.08, 0, 0 )
}

SWEP.HoldTypes 				=
{
	Running = 'passive',
	Sights = 'ar2',
	Idle = 'shotgun',
	Reload = 'smg1'
}

SWEP.Multipliers 			=
{
	Fly = 2,
	Walk = 1.3,
	Idle = 1,
	Crouch = 0.8,
	Sights = 0.05
}

local eotech = Material( 'effects/reflex' )
local eotechcolor = Color( 255, 255, 255 )

local reflex = Material( 'effects/dot' )
local reflexcolor = Color( 255, 65, 65 )

local attachments =
{
-- laser sight:
	laser =
	{
		vm = function( self, args, vm )
			if not args.bone then return end
			if not args.tbone then args.tbone = vm:LookupBone( args.bone ) end
			
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			if not args.dir then args.dir = args.ang:Forward() end
			
			if not args.v_model then
				args.v_model = ClientsideModel( 'models/props_c17/furnitureboiler001a.mdl' )
				args.v_model:SetNoDraw( true )
				
				local mat = Matrix()
					mat:Scale( args.scale or Vector( 0.03, 0.03, 0.03 ) )
				args.v_model:EnableMatrix( 'RenderMultiply', mat )
			else
				if args.tbone then
					local pos, ang = vm:GetBonePosition( args.tbone )
						pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
					
					ang:RotateAroundAxis( ang:Forward(), args.ang.r )
					ang:RotateAroundAxis( ang:Up(), args.ang.y )
					ang:RotateAroundAxis( ang:Right(), args.ang.p )
					
					self:DrawLaser( pos + ang:Right() * 0.2, ang )
					
					args.v_model:SetRenderOrigin( pos )
					args.v_model:SetRenderAngles( ang )
					args.v_model:DrawModel()
				end
			end
		end,
		wm = function( self, args, pos, ang )
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			
			pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
			
			ang:RotateAroundAxis( ang:Forward(), args.ang.r )
			ang:RotateAroundAxis( ang:Up(), args.ang.y )
			ang:RotateAroundAxis( ang:Right(), args.ang.p )
			
			self:DrawLaser( pos, ang )
		end,
		init = function( self ) self.LASER = true end
	},
	
-- sights:
	pistreflex =
	{
		wm = function( self, args, pos, ang )
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			
			pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
			
			ang:RotateAroundAxis( ang:Forward(), args.ang.r )
			ang:RotateAroundAxis( ang:Up(), args.ang.y )
			ang:RotateAroundAxis( ang:Right(), args.ang.p )
			
			render.Model( { model = 'models/wystan/attachments/2octorrds.mdl', pos = pos, angle = ang } )
		end,
		init = function( self, args )
			self.Sights_V = args.Sights_V or self.Sights_V
			self.Sights_A = args.Sights_A or self.Sights_A
		end
	},
	holosight =
	{
		vm = function( self, args, vm )
			if not args.bone then return end
			if not args.tbone then args.tbone = vm:LookupBone( args.bone ) end
			
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			
			if args.tbone then
				local pos, ang = vm:GetBonePosition( args.tbone )
					pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
					
				ang:RotateAroundAxis( ang:Forward(), args.ang.r )
				ang:RotateAroundAxis( ang:Up(), args.ang.y )
				ang:RotateAroundAxis( ang:Right(), args.ang.p )
				
				render.Model( { model = 'models/attachments/kascope.mdl', pos = pos, angle = ang } )
				
				local size = math.Clamp( 1 - self.IronSightsVec:Distance( self.Sights_V ), 0, 1 ) * 0.2
				
				render.SetMaterial( reflex )
				render.DrawSprite( pos + ang:Up() * 0.59 + ang:Forward() * 0.05 + ang:Right() * 12.5, size, size, reflexcolor )
			end
		end,
		wm = function( self, args, pos, ang )
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			
			pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
			
			ang:RotateAroundAxis( ang:Forward(), args.ang.r )
			ang:RotateAroundAxis( ang:Up(), args.ang.y )
			ang:RotateAroundAxis( ang:Right(), args.ang.p )
			
			render.Model( { model = 'models/attachments/kascope.mdl', pos = pos, angle = ang } )
		end,
		init = function( self, args )
			self.Sights_V = args.Sights_V or self.Sights_V
			self.Sights_A = args.Sights_A or self.Sights_A
		end
	},
	eotech =
	{
		vm = function( self, args, vm )
			if not args.bone then return end
			if not args.tbone then args.tbone = vm:LookupBone( args.bone ) end
			
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			
			if args.tbone then
				local pos, ang = vm:GetBonePosition( args.tbone )
					pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
					
				ang:RotateAroundAxis( ang:Forward(), args.ang.r )
				ang:RotateAroundAxis( ang:Up(), args.ang.y )
				ang:RotateAroundAxis( ang:Right(), args.ang.p )
				
				render.Model( { model = 'models/wystan/attachments/2otech557sight.mdl', pos = pos, angle = ang } )
				
				local size = math.Clamp( 1 - self.IronSightsVec:Distance( self.Sights_V ), 0, 1 )
				
				render.SetMaterial( eotech )
				render.DrawSprite( pos + ang:Forward() * 30 + ang:Up() * 11.87 + ang:Right() * 0.258, size, size, eotechcolor )
			end
		end,
		wm = function( self, args, pos, ang )
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			
			pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
			
			ang:RotateAroundAxis( ang:Forward(), args.ang.r )
			ang:RotateAroundAxis( ang:Up(), args.ang.y )
			ang:RotateAroundAxis( ang:Right(), args.ang.p )
			
			render.Model( { model = 'models/wystan/attachments/2otech557sight.mdl', pos = pos, angle = ang } )
		end,
		init = function( self, args )
			self.Sights_V = args.Sights_V or self.Sights_V
			self.Sights_A = args.Sights_A or self.Sights_A
		end
	},
	acog =
	{
		vm = function( self, args, vm )
			if not args.bone then return end
			if not args.tbone then args.tbone = vm:LookupBone( args.bone ) end
			
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			if not args.scope then args.scope = Angle() end
			
			if args.tbone then
				local pos, ang = vm:GetBonePosition( args.tbone )
					self.ScopeAngles = ang * 1
					pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
					
				ang:RotateAroundAxis( ang:Forward(), args.ang.r )
				ang:RotateAroundAxis( ang:Up(), args.ang.y )
				ang:RotateAroundAxis( ang:Right(), args.ang.p )
				
				self.ScopeAngles:RotateAroundAxis( self.ScopeAngles:Forward(), args.scope.r )
				self.ScopeAngles:RotateAroundAxis( self.ScopeAngles:Up(), args.scope.y )
				self.ScopeAngles:RotateAroundAxis( self.ScopeAngles:Right(), args.scope.p )
				
				render.Model( { model = 'models/wystan/attachments/2cog.mdl', pos = pos, angle = ang } )
			end
		end,
		wm = function( self, args, pos, ang )
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			
			pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
			
			ang:RotateAroundAxis( ang:Forward(), args.ang.r )
			ang:RotateAroundAxis( ang:Up(), args.ang.y )
			ang:RotateAroundAxis( ang:Right(), args.ang.p )
			
			render.Model( { model = 'models/wystan/attachments/2cog.mdl', pos = pos, angle = ang } )
		end,
		init = function( self, args )
			self.EnableAcog	= true
			
			self.Sights_V = args.Sights_V or self.Sights_V
			self.Sights_A = args.Sights_A or self.Sights_A
		end
	},
	revscope =
	{
		vm = function( self, args, vm )
			if not args.bone then return end
			if not args.tbone then args.tbone = vm:LookupBone( args.bone ) end
			
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			if not args.scope then args.scope = Angle() end
			
			if args.tbone then
				local pos, ang = vm:GetBonePosition( args.tbone )
					self.ScopeAngles = ang * 1
					pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
					
				ang:RotateAroundAxis( ang:Forward(), args.ang.r )
				ang:RotateAroundAxis( ang:Up(), args.ang.y )
				ang:RotateAroundAxis( ang:Right(), args.ang.p )
				
				self.ScopeAngles:RotateAroundAxis( self.ScopeAngles:Forward(), args.scope.r )
				self.ScopeAngles:RotateAroundAxis( self.ScopeAngles:Up(), args.scope.y )
				self.ScopeAngles:RotateAroundAxis( self.ScopeAngles:Right(), args.scope.p )
				
				render.Model( { model = 'models/bunneh/scope01.mdl', pos = pos, angle = ang } )
			end
		end,
		wm = function( self, args, pos, ang )
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			
			pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
			
			ang:RotateAroundAxis( ang:Forward(), args.ang.r )
			ang:RotateAroundAxis( ang:Up(), args.ang.y )
			ang:RotateAroundAxis( ang:Right(), args.ang.p )
			
			render.Model( { model = 'models/bunneh/scope01.mdl', pos = pos, angle = ang } )
		end,
		init = function( self, args )
			self.EnableAcog	= true
			
			self.Sights_V = args.Sights_V or self.Sights_V
			self.Sights_A = args.Sights_A or self.Sights_A
		end
	},
	
-- suppressor:
	silent =
	{
		vm = function( self, args, vm )
			if not args.bone then return end
			if not args.tbone then args.tbone = vm:LookupBone( args.bone ) end
			
			if not args.scale then args.scale = Vector( 1, 1, 1 ) end
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			
			if not args.v_model then
				args.v_model = ClientsideModel( 'models/attachments/suppressor.mdl' )
				args.v_model:SetNoDraw( true )
				
				local mat = Matrix()
					mat:Scale( args.scale )
				args.v_model:EnableMatrix( 'RenderMultiply', mat )
			else
				if args.tbone then
					local pos, ang = vm:GetBonePosition( args.tbone )
						pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
					
					ang:RotateAroundAxis( ang:Forward(), args.ang.r )
					ang:RotateAroundAxis( ang:Up(), args.ang.y )
					ang:RotateAroundAxis( ang:Right(), args.ang.p )
					
					args.v_model:SetRenderOrigin( pos )
					args.v_model:SetRenderAngles( ang )
					args.v_model:DrawModel()
				end
			end
		end,
		wm = function( self, args, pos, ang )
			if not args.scale then args.scale = Vector( 1, 1, 1 ) end
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			
			if not args.w_model then
				args.w_model = ClientsideModel( 'models/attachments/suppressor.mdl' )
				args.w_model:SetNoDraw( true )
				
				local mat = Matrix()
					mat:Scale( args.scale )
				args.w_model:EnableMatrix( 'RenderMultiply', mat )
			else
				pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
				
				ang:RotateAroundAxis( ang:Forward(), args.ang.r )
				ang:RotateAroundAxis( ang:Up(), args.ang.y )
				ang:RotateAroundAxis( ang:Right(), args.ang.p )
				
				args.w_model:SetRenderOrigin( pos )
				args.w_model:SetRenderAngles( ang )
				args.w_model:DrawModel()
			end
		end,
		init = function( self, args )
			self.NoMuzzleflash = true
			
			if args.sound then self.Primary.Sound = args.sound end			
			if not args.sniper then self.Primary.SoundLevel = 35 end
		end
	},
	longmag =
	{
		vm = function( self, args, vm )
			if not args.bone then return end
			if not args.tbone then args.tbone = vm:LookupBone( args.bone ) end
			
			if not args.scale then args.scale = Vector( 1, 1, 1 ) end
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			
			if not args.v_model then
				args.v_model = ClientsideModel( 'models/attachments/suppressor.mdl' )
				args.v_model:SetNoDraw( true )
				
				local mat = Matrix()
					mat:Scale( args.scale )
				args.v_model:EnableMatrix( 'RenderMultiply', mat )
			else
				if args.tbone then
					local pos, ang = vm:GetBonePosition( args.tbone )
						pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
					
					ang:RotateAroundAxis( ang:Forward(), args.ang.r )
					ang:RotateAroundAxis( ang:Up(), args.ang.y )
					ang:RotateAroundAxis( ang:Right(), args.ang.p )
					
					args.v_model:SetRenderOrigin( pos )
					args.v_model:SetRenderAngles( ang )
					args.v_model:DrawModel()
				end
			end
		end,
		wm = function( self, args, pos, ang )
			if not args.scale then args.scale = Vector( 1, 1, 1 ) end
			if not args.pos then args.pos = Vector() end
			if not args.ang then args.ang = Angle() end
			
			if not args.w_model then
				args.w_model = ClientsideModel( 'models/attachments/suppressor.mdl' )
				args.w_model:SetNoDraw( true )
				
				local mat = Matrix()
					mat:Scale( args.scale )
				args.w_model:EnableMatrix( 'RenderMultiply', mat )
			else
				pos = pos + ang:Forward() * args.pos.x + ang:Right() * args.pos.y + ang:Up() * args.pos.z
				
				ang:RotateAroundAxis( ang:Forward(), args.ang.r )
				ang:RotateAroundAxis( ang:Up(), args.ang.y )
				ang:RotateAroundAxis( ang:Right(), args.ang.p )
				
				args.w_model:SetRenderOrigin( pos )
				args.w_model:SetRenderAngles( ang )
				args.w_model:DrawModel()
			end
		end,
		init = function( self, args )
			if not args.clip then return end
			
			self.Primary.ClipSize = args.clip
			self:SetClip1( args.clip )
		end
	}
}

function SWEP:IsRunning( nohitwall )
	if self.Owner:GetMoveType() == MOVETYPE_LADDER then return true end
	if self.Slot == 0 and self.Owner:GetNWBool( 'sliding' ) then
		self:SetNextPrimaryFire( CurTime() + 0.1 )
		self:SetNextSecondaryFire( self:GetNextPrimaryFire() )
		
		return true
	end
	
	if nohitwall or not util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 32,
		filter = player.GetAll()
	} ).Hit then self.HitWall = CurTime() + 0.3 end
	
	return ( self.HitWall or 0 ) < CurTime() or self.Holstering or not self.Owner:GetNWBool( 'sliding' ) and self.Owner:KeyDown( IN_SPEED ) and self.Owner:GetVelocity():Length2D() > self.Owner:GetWalkSpeed() * 0.9 and self.Owner:IsOnGround()
end

function SWEP:IsReloading( purecheck )
	if not IsValid( self.Owner:GetViewModel() ) then return end
	if self.NextInsertShell then return true end 
	
	local activ = self.Owner:GetViewModel():GetSequenceActivity( self.Owner:GetViewModel():GetSequence() )
	return not ( self.CanBeReloadedWhileRunning and not purecheck ) and ( activ == ACT_VM_RELOAD or activ == ACT_VM_RELOAD_SILENCED ) and self.ReloadingSequence and self.ReloadingSequence > CurTime()
end

function SWEP:PrimaryAttack()
	if self:IsRunning() then return end
	return self:ShootBullet()
end

function SWEP:SecondaryAttack()
	if self:IsRunning() then return end
	
	self:SetIronsights( not self:GetIronsights() )
end

function SWEP:Reload()
	if self.PressedR then return end
		self.PressedR = true
		
	if self.Sniper and self:Clip1() > 0 and not self:GetNWBool( 'onebullet' ) then
		if ( self.AllowPump or 0 ) > CurTime() then return end
		
		self:SetNWBool( 'onebullet', true )
		self:SetClip1( self:Clip1() - 1 )
		self:SetNextPrimaryFire( CurTime() + 0.45 )
		self:SetIronsights( false )
		self.ReloadDelay = CurTime() + 0.5
		
		if self.BoltFunction then self:BoltFunction() end
	end
		
	if self.ShotgunReload and self:Clip1() > 0 and not self:GetNWBool( 'onebullet' ) then
		if ( self.AllowPump or 0 ) > CurTime() then return end
		if self.PumpSound then self:EmitSound( self.PumpSound ) end
		
		self.NextInsertShell = nil
		self:SendWeaponAnim( ACT_SHOTGUN_PUMP )
		self:SetNWBool( 'onebullet', true )
		self:SetClip1( self:Clip1() - 1 )
		self:SetNextPrimaryFire( CurTime() + 0.45 )
		self.ReloadDelay = CurTime() + 0.5
		
		return
	end
	
	if self.ReloadDelay and self.ReloadDelay > CurTime() then return end	
	if self:Clip1() >= self.Primary.ClipSize or self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then return end
	
	if SERVER then
		local more
		for _, pl in pairs( ents.FindInSphere( self.Owner:GetShootPos(), 512 ) ) do
			if pl ~= self.Owner and pl:IsPlayer() and GAMEMODE:IsFriendOf( pl, self.Owner ) then
				more = true
				break
			end
		end
		
		if more then
			local mdl = GAMEMODE:CheckModel( self.Owner:GetModel() )
			if mdl == 'combine' then self:EmitSound( 'npc/combine_soldier/vo/coverme.wav', SNDLVL_IDLE ) end
			if mdl == 'female' then self:EmitSound( 'vo/npc/female01/coverwhilereload0' .. math.random( 1, 2 ) .. '.wav', SNDLVL_IDLE ) end
			if mdl == 'male' then self:EmitSound( 'vo/npc/male01/coverwhilereload0' .. math.random( 1, 2 ) .. '.wav', SNDLVL_IDLE ) end
		end
	end
	
	if self.ShotgunReload then
		if not self.NextInsertShell then
			if self:Clip1() > 0 and not self:GetNWBool( 'onebullet' ) and self.Chambering then
				self:SetClip1( self:Clip1() - 1 )
				self:SetNWBool( 'onebullet', true )
			end
			
			self.NextInsertShell = CurTime() + 0.3
			self:SetIronsights( false )
			self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_START )
			self:SetNextPrimaryFire( CurTime() + 0.3 )
			self:SetNextSecondaryFire( CurTime() + 0.3 )
			
			self.Owner:SetAnimation( PLAYER_RELOAD )
		end
	else
		if self:Clip1() > 0 and not self:GetNWBool( 'onebullet' ) and self.Chambering then
			self:SetClip1( self:Clip1() - 1 )
			self:SetNWBool( 'onebullet', true )
		end
		
		self.BoltAnim = 0
		self:SetIronsights( false )
		self:SetNWBool( 'jammed', false )
		self:SendWeaponAnim( ACT_VM_RELOAD )
		
		if self.L4D then self:SendWeaponAnim( ACT_VM_IDLE ) end		
		if SERVER then
			if not self.NoIdleAfterReload then self.TurnToIdle = CurTime() + self.Owner:GetViewModel():SequenceDuration() / self.Owner:GetViewModel():GetPlaybackRate() end
			
			self.ReloadingSequence = CurTime() + self.Owner:GetViewModel():SequenceDuration() / self.Owner:GetViewModel():GetPlaybackRate() - 0.3
			self:DefaultReload( ACT_VM_RELOAD )
			
			umsg.Start( 'hl2_reload' )
				umsg.Entity( self )
				umsg.String( self.HoldTypes.Reload )
				umsg.String( self.HoldTypes.Idle )
			umsg.End()
		end
	end
end

local swep
local function baseCallback( ply, tr, dmg )
		dmg:ScaleDamage( math.min( 4096 / tr.HitPos:Distance( tr.StartPos ), 1 ) )
		dmg:SetDamage( math.max( dmg:GetDamage(), 1 ) )
	if swep.Callback then swep:Callback( ply, tr, dmg ) end
end

function SWEP:ShootBullet()
	if self:Clip1() == 0 and not self:GetNWBool( 'onebullet' ) or self:GetNWBool( 'jammed' ) or ( self.ShotgunReload or self.Sniper ) and not self:GetNWBool( 'onebullet' ) then
		if SERVER then
			local hint
			if self:GetNWBool( 'jammed' ) then hint = 'Your weapon has jammed, reload to fix'
			elseif ( self.ShotgunReload or self.Sniper ) and not self:GetNWBool( 'onebullet' ) and self:Clip1() > 0 then hint = 'Use [R] key to ' .. ( self.Sniper and 'bolt' or 'pump' ) .. ' the weapon' end
			
			if hint then
				umsg.Start( 'hl2_weaponhint', self.Owner )
					umsg.Entity( self )
					umsg.Short( self.MuzzleAttachment or ( self.L4D and 3 or 1 ) )
					umsg.Float( 2 )
					umsg.String( hint )
				umsg.End()
			end
		end
		
		self:SetNextPrimaryFire( CurTime() + 0.3 )
		return self:EmitSound( self.JamSound )
	end
	
	self.NextInsertShell = nil
	
	if not self.AnimWithSights or not self:GetIronsights() then self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	else
		if CLIENT then
			self.PseudoDir = 1
			self.PseudoAnim = 0
		elseif game.SinglePlayer() then
			umsg.Start( 'hl2_pseudoanim' )
				umsg.Entity( self )
			umsg.End()
		end
	end
	
	self:EmitSound( self.Primary.Sound, self.Primary.SoundLevel )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self.AllowPump = CurTime() + 0.4
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	if not self.NoMuzzleflash then
		self.Owner:MuzzleFlash()
		
		if not self.NoCustomMuzzle and CLIENT then
			local fx = EffectData()
				fx:SetEntity( self.Owner:GetViewModel() )
				fx:SetAttachment( self.MuzzleAttachment or ( self.L4D and 3 or 1 ) )
				fx:SetScale( self.CSS and 1 or 0 )
			util.Effect( 'hl2_muzzle', fx )
		end
	end
	
	--if CLIENT then BLURAMOUNT = 1
	--else umsg.Start( 'hl2_blur', self.Owner ) umsg.End() end
	
	if game.SinglePlayer() then umsg.Start( 'hl2_blur', self.Owner ) umsg.End()
	elseif CLIENT then BLURAMOUNT = 1 end
	
	if SERVER and not self:GetNWBool( 'onebullet' ) and self.JamChance > 1 and math.random( 0, self.JamChance ) == math.floor( self.JamChance / 2 ) then
		self:SetNWBool( 'jammed', true )
		if not self.DenyDryAnim then self:SendWeaponAnim( ACT_VM_DRYFIRE ) end
	end
	
	local comp = 1
	if self:GetIronsights() then comp = 0.4 end
	if not self.Recoil.Single then
		self.ContRecoil = math.Clamp( self.ContRecoil + self.Recoil.ContRecoil * comp, self.Recoil.Min or 0, self.Recoil.Max or 5 )
	end
	
	if not IsFirstTimePredicted() then return end
	
	self.Owner:ViewPunch( ( -self.Recoil.Punch or Angle() ) * comp - Angle( self.ContRecoil, 0, math.Rand( -0.5, 0.5 ) ) )
	
	local cone = self.Multipliers.Idle * ( self.SILENT and 0.8 or 1 )
	if not self.DisableConeMultipliers then
		if not self.Owner:IsOnGround() then cone = cone * self.Multipliers.Fly * ( self.LASER and 0.8 or 1 ) end
		if self.Owner:GetVelocity():Length2D() > 50 then cone = cone * self.Multipliers.Walk * ( self.LASER and 0.8 or 1 ) end
		if self.Owner:Crouching() and self.Owner:IsOnGround() then cone = cone * self.Multipliers.Crouch * ( self.LASER and 0.8 or 1 ) end
		if self:GetIronsights() then cone = cone * self.Multipliers.Sights end
	end
	
	self.Owner:FireBullets( {
		Src = self.Owner:GetShootPos(),
		Dir = ( self.Owner:EyeAngles() + self.Owner:GetPunchAngle() ):Forward(),
		Num = self.Primary.NumShots,
		Spread = Vector( self.Primary.Cone, self.Primary.Cone, self.Primary.Cone ) * cone,
		Tracer = 1,
		TracerName = self.Primary.Tracer,
		Force = self.Primary.Force,
		Damage = self.Primary.Damage * ( self.SILENT and 0.75 or 1 ),
		Callback = function( ... )
				swep = self
			return baseCallback( ... )
		end
	} )
	
	local snip = self.Sniper or self.SniperPistol
	if not snip and ( CLIENT or game.SinglePlayer() ) or snip and SERVER then self.Owner:SetEyeAngles( self.Owner:EyeAngles() - ( self.Recoil.Real or Angle() ) * comp ) end
	
	if self:GetNWBool( 'onebullet' ) then
		self:SetNWBool( 'onebullet', false )
	else
		self:TakePrimaryAmmo( self.Primary.TakeAmmo or 1 )
		
		if self:Clip1() == 0 and not self.DenyDryAnim then
			self:SendWeaponAnim( ACT_VM_DRYFIRE )
		end
	end
	
	if not self:GetNWBool( 'pump' ) and self.ShotgunReload and not self:GetNWBool( 'onebullet' ) and self:Clip1() > 0 then
		self:SetClip1( self:Clip1() - 1 )
		self:SetNWBool( 'onebullet', true )
	end
	
	return true
end

local beam = Material( 'effects/laser' )
local dot = Material( 'effects/dot' )
local red = Color( 255, 0, 0 )

local y = Vector( 0, 0, 1 )
local trace = { mask = bit.band( MASK_SHOT, bit.bnot( CONTENTS_WINDOW ) ) }
function SWEP:DrawLaser( pos, ang )	
	local off = -ang:Up()
	
	trace.start = pos
	trace.endpos = pos + off * 8192
	trace.filter = self.Owner
	
	local tr = util.TraceLine( trace )
	
	render.SetMaterial( beam )
	render.DrawBeam( pos, pos + off * math.min( tr.HitPos:Distance( pos ), 48 ), 0.15, 0, 0.99, red )
	
	if tr.Hit and not tr.HitSky and self.LastHitPos then
		local up = tr.HitNormal:Angle():Up()
		
		render.SetMaterial( dot )
		render.DrawBeam( tr.HitPos - up, self.LastHitPos + up, 2, 0, 1, red )
	end
	
	self.LastHitPos = tr.HitPos
	
	local lp = LocalPlayer()
	if not self:IsRunning() and self.Owner ~= lp then
		local ep = EyePos()
		local sp = self.Owner:GetShootPos()
		local av = self.Owner:GetAimVector()
		local ang = ( sp - ep ):Angle() - av:Angle()
			ang.p = math.abs( math.NormalizeAngle( ang.p ) )
			ang.y = math.abs( math.NormalizeAngle( ang.y + 180 ) )
			
		if ang.p < 10 and ang.y < 10 then
			trace.start = sp
			trace.endpos = sp + av * sp:Distance( ep )
			trace.filter = self.Owner
			
			tr = util.TraceLine( trace )
			
			local d = tr.HitPos:Distance( ep )
			if tr.HitPos:Distance( ep ) < 192 and ( not tr.Hit or tr.Entity == lp ) then
				table.insert( FLARES, pos )
				table.insert( FLARES, d )
			end
		end
	end
end

function SWEP:Think()
	local ctime = CurTime()
	
	if self.ADrawAnimRestart then
		self:SendWeaponAnim( self.L4D and ACT_VM_DEPLOY or ACT_VM_DRAW )
		self.ADrawAnimRestart = false
	end
	
	if not self.AttachmentsInit and self.AInitDelay and self.AInitDelay < ctime then
		self.AttachmentsInit = true
		
		if not self.Attachments then return end
		
		for k, v in pairs( self.Attachments ) do
			local g = self.Owner:GetNWString( ( self.Slot == 0 and 'p' or 's' ) .. 'group' .. k )
			
			for n, a in pairs( v ) do
				if n == g then
					if attachments[ n ] and attachments[ n ].init then
						attachments[ n ].init( self, a.init or {} )
					end
					break
				end
			end
		end
	end
	
	if self.PressedR and not self.Owner:KeyDown( IN_RELOAD ) then self.PressedR = false end
	if SERVER and self.Holstering and self.Holstering <= ctime then self.Owner:SelectWeapon( self.HolsteringWep ) end
	if ( self:IsRunning() or self.Owner:GetNWBool( 'sliding' ) ) and self:GetIronsights() then self:SetIronsights( false ) end
	if not self.Owner:KeyDown( IN_ATTACK ) then self.ContRecoil = 0 end
	if not self.Owner:KeyDown( IN_ATTACK2 ) and self:GetIronsights() then self:SetIronsights( false ) end
	
	if CLIENT and ( self.PseudoDir or self.DryAnimSim and ( self:Clip1() <= 0 or self:GetNWBool( 'jammed' ) ) and not self:IsReloading() ) and self.SlideBone and self.SlideDirection then
		local dry = self.DryAnimSim and ( self:Clip1() <= 0 or self:GetNWBool( 'jammed' ) ) and not self:IsReloading()
			self.BoltAnim = math.Approach( self.BoltAnim or 0, dry and 1 or self.PseudoDir, FrameTime() * ( ( self.PseudoDir == 1 or dry ) and 10 or 2 ) )
		
		local vm = self.Owner:GetViewModel()
		if IsValid( vm ) then
			local bolt = vm:LookupBone( self.SlideBone )
			if bolt then
				vm:ManipulateBonePosition( bolt, self.SlideDirection * self.BoltAnim )
			end
		end
	end
	
	if self.TurnToIdle and self.TurnToIdle < ctime then
		self.TurnToIdle = nil
		self:SendWeaponAnim( ACT_VM_IDLE )
	end
	
	if self.NextPump and self.NextPump < ctime then
		self.NextPump = nil
		self:SendWeaponAnim( ACT_SHOTGUN_PUMP )
		self.Owner:ViewPunch( Angle( -3, 3, 3 ) )
		
		if self.PumpSound then self:EmitSound( self.PumpSound ) end
	end
	
	if self.NextInsertShell and self.NextInsertShell < ctime then
		self.NextInsertShell = ctime + self.ShellInterval
		self:SendWeaponAnim( ACT_VM_RELOAD )
		self:SetClip1( self:Clip1() + 1 )
		self:SetNWBool( 'jammed', false )
		self.Owner:SetAmmo( self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) - 1, self:GetPrimaryAmmoType() )
		
		if self:Clip1() >= self.Primary.ClipSize or self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
			self.NextInsertShell = nil
			self:SetNWBool( 'onebullet', true )
			self:SetNextPrimaryFire( ctime + self.ShellInterval + 0.6 )
			self:SetNextSecondaryFire( ctime + self.ShellInterval + 0.6 )
			self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
		elseif self.InsertShellSound then self:EmitSound( self.InsertShellSound ) end
	end
	
	if CLIENT and self.Holstering and self.Holstering < ctime then self.Holstering = nil end
	if self:IsRunning() then
		if not self.RunningHT then
			self.RunningHT = true
			
			if SERVER then
				umsg.Start( 'hl2_holdtype' )
					umsg.Entity( self )
					umsg.String( self.HoldTypes.Running )
				umsg.End()
			else
				self:SetWeaponHoldType( self.HoldTypes.Running )
				self:EmitSound( 'suit/sights_on.wav' )
			end
		end
	elseif self.Owner:Crouching() then
		if not self.CrouchHT or self.RunningHT then
			self.CrouchHT = true
			self.RunningHT = false
			self:SetNextPrimaryFire( ctime + 0.1 )
			self:SetNextPrimaryFire( ctime + 0.1 )
			
			if SERVER then
				umsg.Start( 'hl2_holdtype' )
					umsg.Entity( self )
					umsg.String( self.HoldTypes.Sights )
				umsg.End()
			else self:SetWeaponHoldType( self.HoldTypes.Sights ) end
		end
	elseif self.RunningHT or self.CrouchHT then		
		if SERVER then
			umsg.Start( 'hl2_holdtype' )
				umsg.Entity( self )
				umsg.String( self:GetIronsights() and self.HoldTypes.Sights or self.HoldTypes.Idle )
			umsg.End()
		else
			self:SetWeaponHoldType( self:GetIronsights() and self.HoldTypes.Sights or self.HoldTypes.Idle )
			if self.RunningHT then self:EmitSound( 'suit/sights_off.wav' ) end
		end
		
		self.CrouchHT = false
		self.RunningHT = false
	end
end

function SWEP:Deploy()
	self.Owner:DrawViewModel( true )
	
	self:SendWeaponAnim( self.L4D and ACT_VM_DEPLOY or ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self.DeploySpeed )
	self:SetNextSecondaryFire( CurTime() + self.DeploySpeed )
	
	umsg.Start( 'hl2_draw', self.Owner )
		umsg.Entity( self )
		umsg.String( self:GetClass() )
	umsg.End()
end

function SWEP:TranslateFOV( fov )
	self.OffsetFOV = self.OffsetFOV or 0
	self.OffsetFOV = math.Approach( self.OffsetFOV, ( self:GetIronsights() and 10 or 0 ), FrameTime() * 10 )
	
	return fov - self.OffsetFOV
end

function SWEP:ViewModelDrawn( vm )
	if self.Attachments then
		for k, v in pairs( self.Attachments ) do
			local g = self.Owner:GetNWString( ( self.Slot == 0 and 'p' or 's' ) .. 'group' .. k )
			
			for n, a in pairs( v ) do
				if n == g then
					if a.vm and attachments[ n ] and attachments[ n ].vm then
						attachments[ n ].vm( self, a.vm, vm )
					end
					break
				end
			end
		end
	end
end

function SWEP:DrawWorldModel()
	local a = self.Owner:LookupAttachment( 'anim_attachment_rh' )
	if a then
		a = self.Owner:GetAttachment( a )
		
		if a and ( self.WorldModelOriginFix or self.L4D ) and ( not IsValid( self.Owner ) or IsValid( self.Owner ) and not self.Owner:InVehicle() ) then
			a.Ang:RotateAroundAxis( a.Ang:Right(), 5 )
			self:SetRenderOrigin( a.Pos )
			self:SetRenderAngles( a.Ang )
			
			render.Model( { model = self.WorldModel, pos = a.Pos, angle = a.Ang } )
		end
	end
	
	if not ( self.WorldModelOriginFix or self.L4D ) then self:DrawModel() end
	if not a then return end
	
	if self.Attachments then		
		local pos, ang = a.Pos, a.Ang
		
		for k, v in pairs( self.Attachments ) do
			local g = self.Owner:GetNWString( ( self.Slot == 0 and 'p' or 's' ) .. 'group' .. k )
			
			for n, a in pairs( v ) do
				if n == g then
					if a.wm and attachments[ n ] and attachments[ n ].wm then
						attachments[ n ].wm( self, a.wm, pos * 1, ang * 1 )
					end
					break
				end
			end
		end
	end
end

function SWEP:AdjustMouseSensitivity()
	if self:GetIronsights() then return 0.7 end
end

function SWEP:Holster( ent )
	if not IsValid( ent ) then return end
	if self:IsReloading( true ) then return end
	
	if self.Holstering and self.Holstering < CurTime() then
		self.Holstering = nil
		return true
	elseif self.Holstering then return end
	
	self:SetIronsights( false )
	self:SetNextPrimaryFire( CurTime() + self.HolsteringTime * 0.3 )
	self:SetNextSecondaryFire( CurTime() + self.HolsteringTime * 0.3 )
	self.Holstering = CurTime() + self.HolsteringTime * 0.3
	self.HolsteringWep = ent:GetClass()
	self.NextInsertShell = nil
	
	if SERVER then
		umsg.Start( 'hl2_holster', self.Owner )
			umsg.Entity( self )
		umsg.End()
	end
end

function SWEP:Melee()
	if self:IsRunning( true ) or not self.Owner:IsOnGround() or ( self.NextMelee or 0 ) > CurTime() or self:GetNextPrimaryFire() > CurTime() or self:GetNextSecondaryFire() > CurTime() then return end
		self.NextMelee = CurTime() + 0.6
		
	if self:GetIronsights() then self:SetIronsights( false ) end
	
	self:SetNextPrimaryFire( CurTime() + 0.6 )
	self:SetNextSecondaryFire( CurTime() + 0.6 )
	
	local v = Vector( 2, 10, 10 )
	local tr = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 48,
		filter = self.Owner,
		mins = -v,
		maxs = v,
	} )
	
	self.Owner:ViewPunch( Angle( -5, 15, 0 ) )
	
	if SERVER then
		umsg.Start( 'hl2_melee' )
			umsg.Entity( self )
		umsg.End()
	end
	
	if tr.Hit then
		local ent = tr.Entity
		if IsValid( ent ) and SERVER then
			local dmg = DamageInfo()
				dmg:SetDamageType( DMG_CLUB )
				dmg:SetDamage( 50 )
				dmg:SetAttacker( self.Owner )
				dmg:SetInflictor( self )
				ent:TakeDamageInfo( dmg )
			
			if ent:IsPlayer() then ent:ViewPunch( Angle( 15, -11, 0 ) ) end
		end
		
		self:EmitSound( 'NPC_Combine.WeaponBash' )
	else
		self:EmitSound( 'Weapon_Crowbar.Miss' )
	end
end

function SWEP:SetIronsights( bool )
	if self.Owner:GetNWBool( 'sliding' ) then return end
	if self:GetNWBool( 'ironsights' ) == bool then return end
	if bool and ( self:IsRunning() or self.NextPump or self.NextInsertShell ) then return end
	
	if SERVER then
		self.Owner:SendLua( 'surface.PlaySound("suit/sights_' .. ( bool and 'on' or 'off' ) .. '.wav")' )
		
		umsg.Start( 'hl2_holdtype' )
			umsg.Entity( self )
			umsg.String( ( bool or self.Owner:Crouching() ) and self.HoldTypes.Sights or self.HoldTypes.Idle )
		umsg.End()
	end
	
	self:SetNWBool( 'ironsights', bool )
end

function SWEP:GetIronsights()
	return self:GetNWBool( 'ironsights' )
end

function SWEP:SetAuto( bool )
	self.Primary.Automatic = bool
	
	umsg.Start( 'hl2_firemode' )
		umsg.Entity( self )
		umsg.Bool( bool )
	umsg.End()
end

function SWEP:GetAuto() return self.Primary.Automatic end

local SIZE = 512
function SWEP:Initialize()
	if CLIENT then
		self.Acog = GetRenderTarget( 'acog_rt', SIZE, SIZE, true )
		
		local acog = Material( 'models/wystan/attachments/acog/lense' )
			acog:SetTexture( '$basetexture', self.Acog )
	end
	if self.Chambering then self:SetNWBool( 'onebullet', true ) end
	
	self.ADrawAnimRestart = true
	self.AInitDelay = CurTime() + 0.5
	self:SetWeaponHoldType( self.HoldTypes.Idle )
end

SWEP.View =
{
	fov = 8,
	drawviewmodel = false,
	w = SIZE,
	h = SIZE
}

function SWEP:DrawHUD()
	if not IsValid( self.Owner:GetViewModel() ) then return end
	
	self.Hint = math.Approach( self.Hint, ( self.Hint_Time > CurTime() ) and 1 or 0, FrameTime() )
	
	local a = self.Owner:GetViewModel():GetAttachment( self.Hint_Attachment )
	if self.Hint > 0 and a then
		local p = a.Pos:ToScreen()
		
		surface.SetFont( 'wephint' )
		surface.SetTextColor( 255, 255, 255, 255 * self.Hint )
		surface.SetTextPos( p.x - surface.GetTextSize( self.Hint_Text ), p.y )
		surface.DrawText( self.Hint_Text )
	end
end

local lense = Material( 'overlay/binocular.png' )
local red = Color( 255, 0, 0 )
function SWEP:RenderScreen()
	local w, h = ScrW(), ScrH()
	local oldrt = render.GetRenderTarget()
	
	if not self.EnableAcog then return end
	
	self.View.origin = self.Owner:GetShootPos()
	self.View.angles = self.ScopeAngles or EyeAngles()
	self.View.fov = self.View.fov + self.AcogFOVOffset
	
	self.Alpha = self.Alpha or 0
	self.Alpha = math.Approach( self.Alpha, self:GetIronsights() and 1 or 0, FrameTime() * 5 )
	
	if self.Acog then
		render.SetRenderTarget( self.Acog )
		render.SetViewPort( 0, 0, SIZE, SIZE )
		cam.Start2D()
			if self.Alpha > 0 then
				render.RenderView( self.View )
			end
			
			local c = SIZE * 0.5
			local h = SIZE / 32
			local s = SIZE / 256
			local p = ( SIZE - h + s ) * 0.5
			
			if self.Sniper or self.SniperPistol then				
				surface.SetDrawColor( color_black )
				surface.DrawRect( c, 0, s, SIZE )
				surface.DrawRect( 0, c, SIZE, s )
				
				for i = 0, SIZE, SIZE / 24 do
					surface.DrawRect( i, p, s, h )
					surface.DrawRect( p, i, h, s )
				end
			else
				local w = SIZE / 58
				
				surface.DrawCircle( c + s, c + s, w * 1.75, red )
				surface.SetDrawColor( color_black )
				surface.DrawRect( c, c, s * 2, c * 0.7 )
				surface.SetDrawColor( red )
				surface.DrawRect( c - w * 0.25, c - w * 0.25, w, w )
			end
			
			surface.SetTexture( surface.GetTextureID( 'models/wystan/attachments/acog/lense2' ) )
			surface.SetDrawColor( 255, 255, 255, math.Clamp( ( 1 - self.Alpha ) * 255, 10, 245 ) )
			surface.DrawTexturedRect( 0, 0, SIZE, SIZE )
			
			surface.SetMaterial( lense )
			surface.SetDrawColor( color_white )
			surface.DrawTexturedRect( 0, 0, SIZE, SIZE )
		cam.End2D()
		render.SetViewPort( 0, 0, w, h )
		render.SetRenderTarget( oldrt )
	end
	
	self.View.fov = self.View.fov - self.AcogFOVOffset
end

function SWEP:GetViewModelPosition( pos, ang )	
	local time = FrameTime() * 5
	local orgpos, organg = pos, ang
	
	self.FlyAngle = self.FlyAngle or 0
	self.YawAngle = self.YawAngle or 0
	self.RollAngle = self.RollAngle or 0
	ang.p = ang.p + self.FlyAngle
	
	local normal
	if self:GetIronsights() and not self:IsRunning() then
		self.IronSightsVec = self.IronSightsVec - ( self.IronSightsVec - self.Sights_V ) * time * 2
		self.FlyAngle = math.Approach( self.FlyAngle, -self.Sights_A.p, ( -self.Sights_A.p - self.FlyAngle ) * time )
		self.YawAngle = math.Approach( self.YawAngle, -self.Sights_A.y, ( -self.Sights_A.y - self.YawAngle ) * time )
		self.RollAngle = math.Approach( self.RollAngle, -self.Sights_A.r, ( -self.Sights_A.r - self.RollAngle ) * time * 0.3 )
	elseif self:IsRunning() and not self:IsReloading( true ) then
		self.IronSightsVec = self.IronSightsVec - ( self.IronSightsVec - self.Run_V ) * time
		self.FlyAngle = math.Approach( self.FlyAngle, -self.Run_A.p, ( -self.Run_A.p - self.FlyAngle ) * time )
		self.YawAngle = math.Approach( self.YawAngle, -self.Run_A.y, ( -self.Run_A.y - self.YawAngle ) * time )
		self.RollAngle = math.Approach( self.RollAngle, -self.Run_A.r, ( -self.Run_A.r - self.RollAngle ) * time )
	else
		local vec = self.Owner:GetVelocity():Length2D() > self.Owner:GetWalkSpeed() * 0.9 and self.Walk_V and self.Walk_V * 1 or self.Idle_V * 1
		self.vmcrouch = math.Approach( self.vmcrouch or 0, self.Owner:IsOnGround() and self.Owner:KeyDown( IN_DUCK ) and 1.8 or 0, time )
		vec = vec + Vector( -self.vmcrouch, self.vmcrouch, self.vmcrouch * 0.5 )
		
		self.IronSightsVec = self.IronSightsVec - ( self.IronSightsVec - vec ) * time
		self.FlyAngle = math.Approach( self.FlyAngle, -self.Idle_A.p, ( -self.Idle_A.p - self.FlyAngle ) * time * 2.5 )
		self.YawAngle = math.Approach( self.YawAngle, -self.Idle_A.y, ( -self.Idle_A.y - self.YawAngle ) * time * 2.5 )
		self.RollAngle = math.Approach( self.RollAngle, -self.Idle_A.r, ( -self.Idle_A.r - self.RollAngle ) * time )
		
		normal = true
	end
	
	local vec = self.IronSightsVec * 1
	vec:Rotate( ang )
	pos = pos + vec
	
	ang:RotateAroundAxis( ang:Up(), self.YawAngle )
	ang:RotateAroundAxis( ang:Forward(), self.RollAngle )
	
	local delta = self.Delta - ang
		self.Delta = ang
	
	local clamp = normal and 5 or 1
	if math.abs( math.NormalizeAngle( delta.y ) ) > math.abs( self.IronSightsSmooth.y ) then
		local dest = math.NormalizeAngle( delta.y )
		self.IronSightsSmooth.y = math.Clamp( math.Approach( self.IronSightsSmooth.y, dest, ( self.IronSightsSmooth.y - dest ) * FrameTime() * 0.4 ), -clamp, clamp )
	end
	
	if math.abs( math.NormalizeAngle( delta.p ) ) > math.abs( self.IronSightsSmooth.p ) then
		local dest = math.NormalizeAngle( delta.p )
		self.IronSightsSmooth.p = math.Clamp( math.Approach( self.IronSightsSmooth.p, dest, ( self.IronSightsSmooth.p - dest ) * FrameTime() * 0.4 ), -clamp, clamp * 0.3 )
	end
	
	if not self.Holstering and normal then		
		pos = pos - ang:Up() * math.Clamp( self.IronSightsSmooth.p * 3, -5, 5 )
		
		ang.y = ang.y - self.IronSightsSmooth.y * 5
		ang.p = ang.p + math.sin( CurTime() * 2 )
		ang.r = ang.r - 5
	else
		ang.p = ang.p + self.IronSightsSmooth.p * 2
		ang.y = ang.y - self.IronSightsSmooth.y * 2
		pos = pos - ang:Right() * self.IronSightsSmooth.y * 0.6
	end
	
	ang.p = math.Clamp( ang.p, -89, 89 )
	
	if self.Holstering then
		ang.p = ang.p + 90 - ( self.Holstering - CurTime() ) / self.HolsteringTime * 90
	end
	
	if self.PseudoAnim then
			self.PseudoAnim = math.Approach( self.PseudoAnim, self.PseudoDir, ( self.PseudoDir - self.PseudoAnim ) * FrameTime() * ( self.PseudoDir == 1 and 50 or 5 ) )
		if ( self.PseudoDir - self.PseudoAnim ) < 0.3 then self.PseudoDir = 0 end
	end
	
		self.Melee_Anim = math.Approach( self.Melee_Anim, self.Melee_Dir, ( self.Melee_Dir - self.Melee_Anim ) * FrameTime() * 8 )
	if ( self.Melee_Dir - self.Melee_Anim ) < 0.3 then self.Melee_Dir = 0 end
	if self.PseudoAnim then
		pos = pos - ang:Forward() * self.PseudoAnim
	end
	
	local a = self.Melee_A * self.Melee_Anim
	
	self.IronSightsSmooth.p = math.Approach( self.IronSightsSmooth.p, 0, self.IronSightsSmooth.p * time )
	self.IronSightsSmooth.y = math.Approach( self.IronSightsSmooth.y, 0, self.IronSightsSmooth.y * time )
	
	ang:RotateAroundAxis( ang:Right(), a.p )
	ang:RotateAroundAxis( ang:Up(), a.y )
	ang:RotateAroundAxis( ang:Forward(), a.r )
	
	local v = self.Melee_V * self.Melee_Anim
		v:Rotate( ang )
	
	return pos, ang
end

if CLIENT then
	surface.CreateFont( 'wephint', {
		font		= 'arial',
		size		= 32,
		weight		= 1000,
		bold		= true,
		outline		= true
	} )
	
	usermessage.Hook( 'hl2_holdtype', function( um )
		local ent = um:ReadEntity()
		if not IsValid( ent ) or not ent.SetWeaponHoldType then return end
		
		ent:SetWeaponHoldType( um:ReadString() )
	end )
	
	usermessage.Hook( 'hl2_holster', function( um )
		surface.PlaySound( 'weapons/holster.wav' )
		
		local w = um:ReadEntity()
		if not IsValid( w ) then return end
		
		w.Holstering = CurTime() + w.HolsteringTime
	end )
	
	usermessage.Hook( 'hl2_draw', function( um )
		surface.PlaySound( 'weapons/draw.wav' )
		
		local w, wt = um:ReadEntity(), weapons.Get( um:ReadString() )
		if wt and wt.CustomDrawSequence then
			for _, v in pairs( wt.CustomDrawSequence ) do timer.Simple( v[1], function() surface.PlaySound( v[2] ) end ) end
		end
		
		if not IsValid( w ) then return end
		
		w.Holstering = nil
	end )
	
	usermessage.Hook( 'hl2_melee', function( um )
		local w = um:ReadEntity()
		if not IsValid( w ) then return end
		
		local pl = w.Owner
		
		w.Melee_Dir = 1
		w.Melee_Anim = 0
		pl:DoAnimationEvent( ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND )
	end )
	
	usermessage.Hook( 'hl2_firemode', function( um )
		local ent = um:ReadEntity()
		if not IsValid( ent ) or not ent.Primary then return end
		
		ent.Primary.Automatic = um:ReadBool()
	end )
	
	usermessage.Hook( 'hl2_priammo', function( um )
		local ent = um:ReadEntity()
		if not IsValid( ent ) or not ent.Primary then return end
		
		ent.Primary.Ammo = um:ReadString()
	end )
	
	usermessage.Hook( 'hl2_pseudoanim', function( um )
		local ent = um:ReadEntity()
		if not IsValid( ent ) then return end
		local ov = um:ReadBool()
		if ov then
			ent.PseudoDir = um:ReadFloat()
			ent.PseudoAnim = um:ReadFloat()
		else
			ent.PseudoDir = 1
			ent.PseudoAnim = 0
		end
	end )
	
	usermessage.Hook( 'hl2_weaponhint', function( um )
		local ent = um:ReadEntity()
		if not IsValid( ent ) then return end
		
		ent.Hint_Attachment = um:ReadShort()
		ent.Hint_Time = CurTime() + um:ReadFloat()
		ent.Hint_Text = um:ReadString()
	end )
	
	usermessage.Hook( 'hl2_blur', function( um ) BLURAMOUNT = um:ReadFloat() or 1 end )
	
	usermessage.Hook( 'hl2_reload', function( um )
		local ent = um:ReadEntity()
		if not IsValid( ent ) then return end
		
		local wt = weapons.Get( ent:GetClass() )
		
		ent:SetWeaponHoldType( um:ReadString() )
		ent:DefaultReload( ACT_VM_RELOAD )
		
		if IsValid( ent.Owner ) and ent.Owner == LocalPlayer() then
			if wt.CustomReloadSoundSequence then
				for _, v in pairs( wt.CustomReloadSoundSequence ) do timer.Simple( v[1], function() surface.PlaySound( v[2] ) end ) end
			end
			
			if wt.ReloadSound then
				ent:EmitSound( wt.ReloadSound )
			end
			
			GAMEMODE.LastVMSeq = ACT_VM_IDLE
			if IsValid( ent.Owner:GetViewModel() ) then
				ent.ReloadingSequence = CurTime() + ent.Owner:GetViewModel():SequenceDuration() / ent.Owner:GetViewModel():GetPlaybackRate() - 0.3
				if not ent.NoIdleAfterReload then ent.TurnToIdle = ent.ReloadingSequence + 0.3 end
			end
		end
		
		local str = um:ReadString()
		timer.Simple( 1, function() if IsValid( ent ) then ent:SetWeaponHoldType( str ) end end )
	end )
end