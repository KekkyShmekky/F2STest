RunConsoleCommand( 'cl_drawownshadow', 1 )

f2s_legs = CreateConVar( 'f2s_legs', 1 )

local bones =
{
	default =
	{
		'ValveBiped.Bip01_Head1',
		'ValveBiped.Bip01_Neck1',
		'ValveBiped.Bip01_Spine4',
		'ValveBiped.Bip01_Spine2',
		'ValveBiped.Bip01_L_Hand',
		'ValveBiped.Bip01_L_ForeArm',
		'ValveBiped.Bip01_L_UpperArm',
		'ValveBiped.Bip01_L_Clavicle',
		'ValveBiped.Bip01_R_Hand',
		'ValveBiped.Bip01_R_ForeArm',
		'ValveBiped.Bip01_R_UpperArm',
		'ValveBiped.Bip01_R_Clavicle',
		'ValveBiped.Bip01_L_Finger4',
		'ValveBiped.Bip01_L_Finger41',
		'ValveBiped.Bip01_L_Finger42',
		'ValveBiped.Bip01_L_Finger3',
		'ValveBiped.Bip01_L_Finger31',
		'ValveBiped.Bip01_L_Finger32',
		'ValveBiped.Bip01_L_Finger2',
		'ValveBiped.Bip01_L_Finger21',
		'ValveBiped.Bip01_L_Finger22',
		'ValveBiped.Bip01_L_Finger1',
		'ValveBiped.Bip01_L_Finger11',
		'ValveBiped.Bip01_L_Finger12',
		'ValveBiped.Bip01_L_Finger0',
		'ValveBiped.Bip01_L_Finger01',
		'ValveBiped.Bip01_L_Finger02',
		'ValveBiped.Bip01_R_Finger4',
		'ValveBiped.Bip01_R_Finger41',
		'ValveBiped.Bip01_R_Finger42',
		'ValveBiped.Bip01_R_Finger3',
		'ValveBiped.Bip01_R_Finger31',
		'ValveBiped.Bip01_R_Finger32',
		'ValveBiped.Bip01_R_Finger2',
		'ValveBiped.Bip01_R_Finger21',
		'ValveBiped.Bip01_R_Finger22',
		'ValveBiped.Bip01_R_Finger1',
		'ValveBiped.Bip01_R_Finger11',
		'ValveBiped.Bip01_R_Finger12',
		'ValveBiped.Bip01_R_Finger0',
		'ValveBiped.Bip01_R_Finger01',
		'ValveBiped.Bip01_R_Finger02'
	},
	vehicle =
	{
		'ValveBiped.Bip01_Head1',
		'ValveBiped.Bip01_Neck1',
		'ValveBiped.Bip01_Spine4',
		'ValveBiped.Bip01_Spine2',
	}
}

function GM:Legs_UpdateBones( mdl, tbl )
	for i = 0, mdl:GetBoneCount() do
		mdl:ManipulateBoneScale( i, Vector( 1, 1, 1 ) )
		mdl:ManipulateBonePosition( i, Vector() )
	end
	
	for _, v in pairs( tbl ) do
		local i = mdl:LookupBone( v )
		if i then
			mdl:ManipulateBoneScale( i, Vector() )
			mdl:ManipulateBonePosition( i, Vector( -10, -10, 0 ) )
		end
	end
end

local FORWARD_OFFSET = -15
function GM:Legs_Render( ply )
	if not IsValid( ply ) then return end
	if not ply:IsPlayer() then return end
	if not f2s_legs:GetBool() then return end
	
	if IsValid( ply.Legs ) then
		if ply:Alive() and not IsValid( ply:GetObserverTarget() ) and ply.Legs:GetModel() == ply:GetModel() then
			local pos = ply:GetPos()
			local ang = Angle( 0, ply:EyeAngles().y, 0 )
			if ply:InVehicle() then
				local veh = ply:GetVehicle()
				
				ang = veh:GetAngles()
				ang:RotateAroundAxis( ang:Up(), 90 )
				
				if veh:GetModel() == 'models/vehicle.mdl' then
					pos = pos + ang:Up() * 5 - ang:Forward() * 6
				end
			else
				local rad = math.rad( ang.y )
					pos.x = pos.x + math.cos( rad ) * FORWARD_OFFSET
					pos.y = pos.y + math.sin( rad ) * FORWARD_OFFSET
				
				if ply:GetGroundEntity() == NULL then
					if ply:KeyDown( IN_DUCK ) then
						pos.z = pos.z - 36
					end
				end
			end
			
			local dest = ply:GetNWBool( 'sliding' ) and 1 or 0
			ply.Legs.Sliding = ply.Legs.Sliding or 0
			ply.Legs.Sliding = math.Approach( ply.Legs.Sliding, dest, ( ply.Legs.Sliding - dest ) * FrameTime() * 10 )
			
			if ply.Legs.Sliding > 0 then
				ang:RotateAroundAxis( ang:Right(), ply.Legs.Sliding * 80 )
				pos = pos - ang:Up() * 68 * ply.Legs.Sliding + ang:Forward() * 20 * ply.Legs.Sliding
			end
			
			cam.Start3D( EyePos(), EyeAngles() )
				ply.Legs:SetRenderOrigin( pos )
				ply.Legs:SetRenderAngles( ang )
				ply.Legs:SetupBones()
				ply.Legs:DrawModel()
			cam.End3D()
		elseif IsValid( ply.Legs ) then
			ply.Legs:Remove()
		end
	elseif IsValid( ply ) and ply:Alive() then
		ply.Legs = ClientsideModel( ply:GetModel(), RENDERGROUP_OPAQUE )
		ply.Legs:SetNoDraw( true )
		ply.Legs.NextBreath = 0
		ply.Legs.LastTick = 0
		
		self:Legs_UpdateBones( ply.Legs, bones.default )
	end
end

function GM:LegsAnimation( ply, vel, seq )
	if IsValid( ply ) and ply:IsPlayer() and IsValid( ply.Legs ) then
		local vel = ply:GetVelocity():Length2D()
		local pbr = 1
	 	if vel > 0.5 then
			if seq < 0.001 then
				pbr = 0.01
			else
				pbr = vel / seq
				pbr = math.Clamp( pbr, 0.01, 10 )
			end
		end
		
		ply.Legs:SetPlaybackRate( pbr )
		
		local plyseq = ply:GetNWBool( 'sliding' ) and ply:LookupSequence( 'idle_passive' ) or ply:GetSequence()
		if ply.Legs:GetSequence() ~= plyseq then
			ply.Legs:ResetSequence( plyseq )
		end
		
		ply.Legs:FrameAdvance( CurTime() - ply.Legs.LastTick )
		ply.Legs.LastTick = CurTime()
		
		if ply.Legs.NextBreath < CurTime() then
			ply.Legs.NextBreath = CurTime() + 1.95 / 0.5
			ply.Legs:SetPoseParameter( 'breathing', 0.5 )
		end
		
		ply.Legs:SetPoseParameter( 'move_x', ply:GetPoseParameter( 'move_x' ) * 2 - 1 )
		ply.Legs:SetPoseParameter( 'move_y', ply:GetPoseParameter( 'move_y' ) * 2 - 1 )
		ply.Legs:SetPoseParameter( 'move_yaw', ply:GetPoseParameter( 'move_yaw' ) * 360 - 180 )
		ply.Legs:SetPoseParameter( 'body_yaw', ply:GetPoseParameter( 'body_yaw' ) * 180 - 90 )
		ply.Legs:SetPoseParameter( 'spine_yaw', ply:GetPoseParameter( 'spine_yaw' ) * 180 - 90 )
		
		if ply:InVehicle() then
			ply.Legs:SetPoseParameter( 'vehicle_steer', ply:GetVehicle():GetPoseParameter( 'vehicle_steer' ) * 2 - 1 )
			
			if not ply.Legs.BonesUpdate_Veh then
				ply.Legs.BonesUpdate_Veh = true
				self:Legs_UpdateBones( ply.Legs, bones.vehicle )
			end
		elseif ply.Legs.BonesUpdate_Veh then
			ply.Legs.BonesUpdate_Veh = false
			self:Legs_UpdateBones( ply.Legs, bones.default )
		end
	end
end

concommand.Add( 'f2s_forcelegsreset', function( ply ) ply.Legs = nil end )