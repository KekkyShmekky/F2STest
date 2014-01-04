function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	
	local PE = ParticleEmitter( pos + norm * 24 )
		PE:SetNearClip( 0, 128 )
		
		for i = 1, 2 do
			local ptcl = PE:Add( 'particle/particle_smokegrenade', pos + norm * 1 )	
				ptcl:SetVelocity( norm * math.Rand( 1, 3 ) + VectorRand() * 10 )
				ptcl:SetDieTime( math.Rand( 1, 3 ) )
				ptcl:SetStartAlpha( math.random ( 100, 200 ) )
				ptcl:SetStartSize( 0 )
				ptcl:SetEndSize( math.random( 5, 10 ) )
				ptcl:SetRoll( math.random( -180, 180 ) )
				ptcl:SetRollDelta( math.random( -2, 2 ) )
				ptcl:SetColor( 125, 125, 125 )
				ptcl:SetGravity( Vector( 0, 0, math.random( 50, 5 ) ) )
				ptcl:SetAirResistance( math.random( 10, 20 ) )
				ptcl:SetCollide( false )
				ptcl:SetBounce( 0.1 )
		end
		
		for i = 1, 3 do
			local ptcl = PE:Add( 'effects/stunstick', pos + norm * 1 )	
				ptcl:SetVelocity( Vector() )
				ptcl:SetDieTime( FrameTime() * 10 )
				ptcl:SetStartAlpha( 255 )
				ptcl:SetStartSize( 3 )
				ptcl:SetEndSize( math.random( 6, 8 ) )
				ptcl:SetRoll( math.random( -180, 180 ) )
				ptcl:SetColor( 255, 255, 255 )
				ptcl:SetGravity( Vector() )
				ptcl:SetAirResistance( math.random( 10,20 ) )
				ptcl:SetCollide( true )
				ptcl:SetBounce( 0.1 )
		end	
	PE:Finish()		
end

function EFFECT:Think() end
function EFFECT:Render() end