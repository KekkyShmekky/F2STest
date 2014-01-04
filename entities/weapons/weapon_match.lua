AddCSLuaFile()

SWEP.Base				= 'hl2_base'
SWEP.PrintName			= 'HK USP MATCH'
SWEP.Author				= 'NanoCat'
SWEP.DrawCrosshair		= true
SWEP.ViewModelFlip 		= false
SWEP.Spawnable 			= true
SWEP.ViewModelFOV		= 70
SWEP.Slot				= 1
SWEP.SlotPos			= 1
SWEP.ViewModel			= 'models/weapons/v_match2.mdl'
SWEP.WorldModel			= 'models/weapons/w_pistol.mdl'
SWEP.IconLetter			= '\x25'
SWEP.DistantSound		= 'Distant.Light_Pistol'
SWEP.JamChance			= 256
SWEP.PistolMovement		= true

SWEP.Attachments		=
{
	{
		laser =
		{
			vm =
			{
				bone = 'USP',
				pos = Vector( 0.2, -3, -1 ),
				ang = Angle( 0, 0, 90 )
			},
			wm =
			{
				pos = Vector( 7, -1, 2.5 ),
				ang = Angle( 95, 0, 0 )
			}
		}
	},
	{
		pistreflex =
		{
			wm =
			{
				pos = Vector( 0, 0, 4 ),
				ang = Angle( 0, 90, 0 )
			},
			init =
			{
				Sights_V = Vector( -7, 3.73, 1.96 ),
				Sights_A = Angle( 1, 0, 0 )
			}
		}
	}
}

SWEP.Melee_V			= Vector( 0, 0, 0 )
SWEP.Melee_A			= Angle( 20, 10, 0 )

SWEP.Sights_V			= Vector( -5, 3.75, 2.4 )
SWEP.Sights_A			= Angle( 0, 0.05, 0 )

SWEP.Run_V				= Vector( -9, 0, -5 )
SWEP.Run_A				= Angle( 30, 0, 0 )

SWEP.Walk_V				= Vector( -6, 0, -1 )
SWEP.Idle_V				= Vector( -6, 0, 0 )
SWEP.Idle_A				= Angle()

SWEP.Recoil 			=
{
	Single = true,
	Punch = Angle( 0.8, 0, 0 ),
	Real = Angle( 0.08, 0, 0 )
}

SWEP.HoldTypes 			=
{
	Running = 'normal',
	Sights = 'revolver',
	Idle = 'slam',
	Reload = 'pistol'
}

AddSound( 'Weapon_Pistol.Match', 'weapons/match_shot.wav' )
AddSound( 'Weapon_Pistol.MatchReload', 'weapons/match_reload.wav' )

SWEP.Primary.Sound		= 'Weapon_Pistol.Match'
SWEP.Primary.Ammo		= '.45 ACP'
SWEP.Primary.Cone		= 0.06
SWEP.Primary.Damage		= 15
SWEP.Primary.Delay		= 0.1
SWEP.Primary.ClipSize	= 12
SWEP.Primary.DefaultClip= 12
SWEP.ReloadSound		= 'Weapon_Pistol.MatchReload'

function SWEP:PrimaryAttack( ... )
	self.BaseClass.PrimaryAttack( self, ... )
	self.Owner:GetViewModel():SetPlaybackRate( 1.8 )
end

local reflex = Material( 'effects/dot' )
local reflexcolor = Color( 255, 65, 65, 255 )
function SWEP:ViewModelDrawn( vm )
	if self.Owner:GetNWString( 'sgroup2' ) == 'pistreflex' then
		if not self.USP then self.USP = vm:LookupBone( 'USP' ) end
		if self.USP then
			local off = 3.3
			local act = vm:GetSequenceActivity( vm:GetSequence() )
			if act == ACT_VM_DRYFIRE or act == ACT_VM_RELOAD and vm:GetCycle() < 0.74 or act == ACT_VM_PRIMARYATTACK and vm:GetCycle() < 0.06 then off = 5.07 end
			
			local pos, ang = vm:GetBonePosition( self.USP )
				pos = pos + ang:Right() * off - ang:Up() * 2.9 - ang:Forward() * 0.39
				ang:RotateAroundAxis( ang:Up(), 180 )
				ang:RotateAroundAxis( ang:Right(), 180 )
				
			render.Model( { model = 'models/wystan/attachments/2octorrds.mdl', pos = pos, angle = ang } )
			
			local size = math.Clamp( 1 - self.IronSightsVec:Distance( self.Sights_V ), 0, 1 ) * 0.15
			
			render.SetMaterial( reflex )
			render.DrawSprite( pos + ang:Up() * 0.43 + ang:Forward() * 0.255 + ang:Right() * 10.6, size, size, reflexcolor )
		end
	end
	
	return self.BaseClass.ViewModelDrawn( self, vm )
end