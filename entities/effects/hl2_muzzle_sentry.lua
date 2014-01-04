function EFFECT:Init( fx )
	if not IsValid( fx:GetEntity() ) or not fx:GetAttachment() or not fx:GetEntity():GetAttachment( fx:GetAttachment() ) then return end
	
	self.WeaponEnt = fx:GetEntity()
	self.Attachment = fx:GetAttachment()
	self.Normal = self.WeaponEnt:GetAttachment( self.Attachment ).Ang:Forward()
	self.Position = self:GetTracerShootPos( self.WeaponEnt:GetAttachment( self.Attachment ).Pos, self.WeaponEnt, self.Attachment )
	
	local PE = ParticleEmitter( self.Position )
		for i = 1, 2 do
			local ptcl = PE:Add( 'particle/particle_smokegrenade', self.Position )
				ptcl:SetVelocity( 120 * i * self.Normal + 8 * VectorRand() )
				ptcl:SetAirResistance( 400 )
				ptcl:SetGravity( Vector( 0, 0, math.Rand( 100, 200 ) ) )
				ptcl:SetDieTime( math.Rand( 0.5, 0.8 ) )
				ptcl:SetStartAlpha( math.Rand( 30, 90 ) )
				ptcl:SetEndAlpha( 0 )
				ptcl:SetStartSize( math.Rand( 3, 7 ) )
				ptcl:SetEndSize( math.Rand( 20, 50 ) )
				ptcl:SetRoll( math.Rand( -25, 25 ) )
				ptcl:SetRollDelta( math.Rand( -0.05, 0.05 ) )
				ptcl:SetColor( 120, 120, 120 )
		end
		
		for i = 1, 3 do
			local ptcl = PE:Add( 'effects/muzzleflash' .. math.Rand( 1, 4 ), self.Position )
				ptcl:SetVelocity( 250 * self.Normal )
				ptcl:SetAirResistance( 160 )
				ptcl:SetDieTime( 0.3 )
				ptcl:SetStartAlpha( 200 )
				ptcl:SetEndAlpha( 0 )
				ptcl:SetStartSize( 18 )
				ptcl:SetEndSize( 6 )
				ptcl:SetRoll( math.Rand( 180, 480 ) )
				ptcl:SetRollDelta( math.Rand( -1, 1 ) )
		end
	PE:Finish()
end

function EFFECT:Think()
end

function EFFECT:Render()
end