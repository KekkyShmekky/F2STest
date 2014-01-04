local bar = surface.GetTextureID( 'effects/lensflare/bar' )
local iris = surface.GetTextureID( 'effects/lensflare/iris' )
local flare = surface.GetTextureID( 'effects/lensflare/flare' )
local color_ring = surface.GetTextureID( 'effects/lensflare/color_ring' )

local pow = math.pow
local info = util.GetSunInfo

local SetTexture = surface.SetTexture
local SetDrawColor = surface.SetDrawColor
local DrawTexturedRect = surface.DrawTexturedRect

local w, h = ScrW(), ScrH()
local function mulW( x, f ) return ( x - w / 2 ) * f + w / 2 end
local function mulH( y, f ) return ( y - h / 2 ) * f + h / 2 end

function GM:DrawCenteredRect( tex, x, y, sz )
	SetTexture( tex )
	DrawTexturedRect( x - sz / 2, y - sz / 2, sz, sz )
end

GM.LensContrast = 0
function GM:RenderFlares( w, h )
	if self.LensContrast > 0 then return end
	
	SetTexture( flare )
	SetDrawColor( 255, 0, 0 )
	
	local ad = math.max( w, h ) * 24
	local d = 0
	local thiscont = 0
	for k, v in pairs( FLARES ) do
		if k % 2 == 1 then
			thiscont = math.Clamp( 1 - FLARES[ k + 1 ] / 52, 0.01, 1 )
			
			v = v:ToScreen()
			d = ad * thiscont
			if thiscont > 0.01 then
				self.LensContrast = math.max( self.LensContrast, thiscont / 15 )
				DrawTexturedRect( v.x - d / 2, v.y - d / 2, d, d )
			end
		end
	end
	
	table.Empty( FLARES )
end

function GM:RenderLens()
	w, h = ScrW(), ScrH()
	
	self:RenderFlares( w, h )
	
	local sun = info()
	if not sun or sun.obstruction == 0 or self.Weather ~= WEATHER_NORMAL then return end
	
	local pos = ( EyePos() + sun.direction * 4096 ):ToScreen()
	local dot = ( sun.direction:Dot( EyeVector() ) - 0.8 ) * 5
	local sz = w * 0.15
	local mul = math.Clamp( ( sun.direction:Dot( EyeVector() ) - 0.4 ) * ( 1 - pow( 1 - sun.obstruction, 2 ) ), 0, 1 ) * 2
	if mul == 0 then return end
	
	SetDrawColor( 255, 230, 180, 350 * mul )
	self:DrawCenteredRect( flare, pos.x, pos.y, sz * 25 )
	
	SetDrawColor( 255, 255, 255, 800 * pow( mul, 3 ) )
	self:DrawCenteredRect( color_ring, mulW( pos.x, 0.5 ), mulH( pos.y, 0.5 ), sz * 1.5 )

	SetDrawColor( 255, 230, 180, 255 * mul )
	self:DrawCenteredRect( bar, mulW( pos.x, -0.5 ), mulH( pos.y, -0.5 ), sz * 10 )
	
	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, 1.8 ), mulH( pos.y, 1.8 ), sz * 0.15 )

	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, 1.82 ), mulH( pos.y, 1.82 ), sz * 0.1 )

	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, 1.5 ), mulH( pos.y, 1.5 ), sz * 0.05 )

	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, 0.6 ), mulH( pos.y, 0.6 ), sz * 0.05 )

	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, 0.59 ), mulH( pos.y, 0.59 ), sz * 0.15 )

	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, 0.3 ), mulH( pos.y, 0.3 ), sz * 0.1 )

	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, -0.7 ), mulH( pos.y, -0.7 ), sz * 0.1 )

	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, -0.72 ), mulH( pos.y, -0.72 ), sz * 0.15 )

	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, -0.73 ), mulH( pos.y, -0.73 ), sz * 0.05 )

	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, -0.9 ), mulH( pos.y, -0.9 ), sz * 0.1 )

	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, -0.92 ), mulH( pos.y, -0.92 ), sz * 0.05 )

	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, -1.3 ), mulH( pos.y, -1.3 ), sz * 0.15 )
	
	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, -1.5 ), mulH( pos.y, -1.5 ), sz )
	
	SetDrawColor( 255, 230, 180, 255 * pow( mul, 3 ) )
	self:DrawCenteredRect( iris, mulW( pos.x, -1.7 ), mulH( pos.y, -1.7 ), sz * 0.1 )
end