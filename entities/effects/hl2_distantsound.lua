--[[
AddSound( 'Distant.Heavy_Pistol', 'effects/distant/pist_heavy.mp3' )
AddSound( 'Distant.Light_Pistol', 'effects/distant/pist_light.mp3' )
AddSound( 'Distant.Heavy_Sniper', 'effects/distant/sniper_heavy.mp3' )
AddSound( 'Distant.Light_Sniper', 'effects/distant/sniper_light.mp3' )
AddSound( 'Distant.Rifle', 'effects/distant/rifle.mp3' )
AddSound( 'Distant.Shotgun', 'effects/distant/shotgun.mp3' )
AddSound( 'Distant.357', 'effects/distant/357.wav' )
]]

local sounds =
{
	[ 'Distant.Heavy_Pistol' ] = 'effects/distant/pist_heavy.mp3',
	[ 'Distant.Light_Pistol' ] = 'effects/distant/pist_light.mp3',
	[ 'Distant.Heavy_Sniper' ] = 'effects/distant/sniper_heavy.mp3',
	[ 'Distant.Light_Sniper' ] = 'effects/distant/sniper_light.mp3',
	[ 'Distant.Rifle' ] = 'effects/distant/rifle.mp3',
	[ 'Distant.Shotgun' ] = 'effects/distant/shotgun.mp3',
	[ 'Distant.357' ] = 'effects/distant/357.wav',
}

function EFFECT:Init( fx )
	if f2s_disabledistantsounds:GetBool() then return end
	
	local ent = fx:GetEntity()
	if not IsValid( ent ) or ent.Primary and ent.Primary.SoundLevel and ent.Primary.SoundLevel < 90 or not ent.DistantSound then return end
	
	local org = ent:GetPos()
	local ply = LocalPlayer()
	
	if ply:GetPos():Distance( org ) > 512 and sounds[ ent.DistantSound ] then
		sound.Play( sounds[ ent.DistantSound ], org, 100, math.random( 98, 102 ), 1 )
	end
end

function EFFECT:Think()
end

function EFFECT:Render()
end