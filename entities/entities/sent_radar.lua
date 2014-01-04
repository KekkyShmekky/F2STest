AddCSLuaFile()

ENT.MaxHealth		= 30
ENT.Spawnable		= true
ENT.PrintName		= 'Spawn beacon'
ENT.Base			= 'base_destructable'

function ENT:Initialize()
	if CLIENT then
		self.NextBeep = CurTime() + 1
		return
	end
	
	self:SetModel( 'models/props_combine/combine_mine01.mdl' )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetNWInt( 'hp', self.MaxHealth )
	
	self.BaseClass.Initialize( self )
end

local tex = CLIENT and surface.GetTextureID( 'vgui/white' )
local step = 2 * math.pi / 6
local polygon = {}
for i = 0, 5 do
	local x, y = math.cos( step * i ), math.sin( step * i )
	local tbl =
	{
		x = x * 20,
		y = y * 20,
		u = x,
		v = y
	}
	
	table.insert( polygon, tbl )
end

function ENT:Draw()
	self:DrawModel()
	
	if not IsValid( self.Owner ) then return end
	
	local color = table.Copy( team.GetColor( IsValid( self.Owner ) and self.Owner.Team and self.Owner:Team() or 0 ) )
		color.r = color.r * ( self.NextBeep - CurTime() ) / 5
		color.g = color.g * ( self.NextBeep - CurTime() ) / 5
		color.b = color.b * ( self.NextBeep - CurTime() ) / 5
	
	cam.Start3D2D( self:GetPos() + 10 * self:GetAngles():Up(), self:GetAngles(), 0.25 )
		surface.SetTexture( tex )
		surface.SetDrawColor( color )
		surface.DrawPoly( polygon )
	cam.End3D2D()
end

function ENT:Think()
	self.Owner = self:GetNWEntity( 'owner' )
	
	if CLIENT and self.NextBeep and self.NextBeep < CurTime() then
		self.NextBeep = CurTime() + 5
		self:EmitSound( 'buttons/button16.wav', 60 )
		
		local dlight = DynamicLight( 0 )
		if dlight then
			local color = team.GetColor( IsValid( self.Owner ) and self.Owner.Team and self.Owner:Team() or 0 )
			
			dlight.Pos = self:GetPos() + 10 * self:GetAngles():Up()
			dlight.r = color.r
			dlight.g = color.g
			dlight.b = color.b
			dlight.Brightness = 1
			dlight.Size = 64
			dlight.Decay = 10.6
			dlight.DieTime = CurTime() + 5
			dlight.Style = 0
		end
	end
	
	self.BaseClass.Think( self )
end