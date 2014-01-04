AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'AWM'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 65
SWEP.Slot				= 0
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/weapons/cstrike/c_snip_awp.mdl'
SWEP.WorldModel			= 'models/weapons/w_snip_awp.mdl'
SWEP.IconLetter			= '\x72'
SWEP.FontOverride		= 'CSS'
SWEP.DistantSound		= 'Distant.Heavy_Sniper'
SWEP.JamChance			= 300
SWEP.Price				= 4200
SWEP.Level				= 2
SWEP.Gaben				= 'The Accuracy International AWM (Arctic Warfare Magnum) is a bolt-action sniper rifle\nmanufactured by Accuracy International designed for magnum rifle cartridge chamberings.'
SWEP.Chambering			= true
SWEP.Sniper				= true
SWEP.EnableAcog			= true
SWEP.CSS				= true
SWEP.AcogFOVOffset		= -2.5

SWEP.Attachments		=
{
	{
		silent =
		{
			vm =
			{
				bone = 'v_weapon.awm_parent',
				pos = Vector( -0.3, -4.5, -48 ),
				ang = Angle( 0, 90, 90 ),
				scale = Vector( 2.2, 3.6, 2.2 )
			},
			wm =
			{
				pos = Vector( 36, 1, 10.9 ),
				ang = Angle( 10.8, 0, 0 ),
				scale = Vector( 2.2, 2.6, 2.2 )
			},
			init =
			{
				sound = 'Weapon_AWM.Silent',
				sniper = true
			}
		}
	},
	{
		laser =
		{
			vm =
			{
				bone = 'v_weapon.awm_parent',
				pos = Vector( 0, -2.5, -20 ),
				ang = Angle( 0, 90, 0 )
			},
			wm =
			{
				pos = Vector( 21, 0, 6.3 ),
				ang = Angle( 100.8, 0, 0 )
			}
		}
	},
	{
		longmag = { init = { clip = 20 } }
	}
}

SWEP.Melee_V			= Vector( -10, -10, -15 )
SWEP.Melee_A			= Angle( 0, 90, -50 )

SWEP.Primary.Damage 	= 76
SWEP.Primary.Automatic	= false
SWEP.Primary.ClipSize	= 10
SWEP.Primary.DefaultClip= 10
SWEP.Primary.Delay		= 0.5
SWEP.Primary.Cone		= 0.04
SWEP.Primary.Ammo		= '308'

AddSound( 'Weapon_AWM.Silent', 'weapons/sniper_silent.wav' )
AddSound( 'Weapon_AWM.Single', 'weapons/awm_shot.wav' )

SWEP.Primary.Sound		= 'Weapon_AWM.Single'

SWEP.Sights_V			= Vector( -10, 7.37, 2.3 )
SWEP.Sights_A			= Angle( 0.8, -0.36, 0 )

SWEP.Run_V				= Vector( -3, -3, -0.5 )
SWEP.Run_A				= Angle( -15, -40, 20 )

SWEP.Walk_V				= Vector( 1, 0, -3 )
SWEP.Idle_V				= Vector( 1, 0, -2 )
SWEP.Idle_A				= Angle()

SWEP.DeployTime			= 0.1

SWEP.Recoil 			=
{
	Single = true,
	Punch = Angle( 4.3, 0, 0 ),
	Real = Angle( 0.9, 0, 0 )
}

SWEP.HoldTypes 			=
{
	Running = 'passive',
	Sights = 'ar2',
	Idle = 'shotgun',
	Reload = 'smg'
}

function SWEP:Think()
	local vm = self.Owner:GetViewModel()
	if vm:GetSequenceActivity( vm:GetSequence() ) == ACT_VM_PRIMARYATTACK and vm:GetCycle() > 0.05 and vm:GetCycle() < 0.1 and not self.Bolting then
		self:SendWeaponAnim( ACT_VM_IDLE )
	end
	
	self.BaseClass.Think( self )
end

function SWEP:Initialize()
	if CLIENT then
		self.Scope = ClientsideModel( 'models/wystan/attachments/2cog.mdl' )
		self.Scope:SetNoDraw( true )
		
		local mat = Matrix()
			mat:Scale( Vector( 1.8, 1.8, 1.8 ) )
		self.Scope:EnableMatrix( 'RenderMultiply', mat )
	end
	
	self.WaitForUpdate = true
	self.BaseClass.Initialize( self )
end

function SWEP:BoltFunction()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetNextPrimaryFire( CurTime() + 1.3 )
	self.Bolting = true
	
	local vm = self.Owner:GetViewModel()
		vm:SetCycle( 0.4 )
	
	if game.SinglePlayer() then
		umsg.Start( 'sp_bolt', self.Owner )
			umsg.Entity( self )
			umsg.Bool( true )
		umsg.End()
	end
end

function SWEP:ViewModelDrawn( vm )
	if IsValid( self.Scope ) then
		local bone = vm:LookupBone( 'v_weapon.awm_parent' )
		
		if bone then
			local pos, ang = vm:GetBonePosition( bone )
				pos = pos + ang:Up() * 6.22 + ang:Right() * 6.3 + ang:Forward() * 0.7
			
			self.ScopeAngles = ang * 1
			self.ScopeAngles:RotateAroundAxis( self.ScopeAngles:Forward(), -90 )
			self.ScopeAngles:RotateAroundAxis( self.ScopeAngles:Up(), 90 )
			self.ScopeAngles = self.ScopeAngles + self.Sights_A
			
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 180 )
			
			self.Scope:SetPos( pos )
			self.Scope:SetAngles( ang )
			self.Scope:DrawModel()
		end
	end
	
	self.BaseClass.ViewModelDrawn( self, vm )
end

function SWEP:AdjustMouseSensitivity()
	if self:GetIronsights() then return 0.3 end
end

function SWEP:PrimaryAttack( ... )
	self.BaseClass.PrimaryAttack( self, ... )
	self.Bolting = false
	
	if game.SinglePlayer() then
		umsg.Start( 'sp_bolt', self.Owner )
			umsg.Entity( self )
			umsg.Bool( false )
		umsg.End()
	end
end

if CLIENT and game.SinglePlayer() then
	usermessage.Hook( 'sp_bolt', function( um )
		local ent = um:ReadEntity()
		if not IsValid( ent ) then return end
		
		ent.Bolting = um:ReadBool()
		
		if ent.Bolting then
			ent:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
			ent:SetNextPrimaryFire( CurTime() + 1.3 )
			
			local vm = ent.Owner:GetViewModel()
				vm:SetCycle( 0.4 )
		end
	end )
end