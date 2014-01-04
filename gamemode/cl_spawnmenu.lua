f2s_constructor = 'models/props_phx/construct/metal_plate1.mdl'

function GM:OnSpawnMenuOpen()
	if IsValid( self.Spawnmenu ) then self.Spawnmenu:Remove() end
	
	self.Spawnmenu = vgui.Create( 'DFrame' )
	self.Spawnmenu:SetSize( 640, 480 )
	self.Spawnmenu:Center()
	self.Spawnmenu:SetTitle( 'Constructor menu' )
	self.Spawnmenu:SetDraggable( false )
	self.Spawnmenu:ShowCloseButton( false )
	self.Spawnmenu:MakePopup()
	
	local x, y = 0, 0
	for k, v in pairs( self.Props ) do
		local prop = vgui.Create( 'SpawnIcon', self.Spawnmenu )
			prop:SetPos( x * 70 + 5, 25 + y * 70 )
			prop:SetSize( 64, 64 )
			prop:SetModel( v )
			prop.DoClick = function()
				RunConsoleCommand( 'f2s_constructor', v )
				f2s_constructor = v
			end
		
		x = x + 1
		
		if x > 8 then
			x = 0
			y = y + 1
		end
	end
end

function GM:OnSpawnMenuClose()
	if IsValid( self.Spawnmenu ) then self.Spawnmenu:Remove() end
end