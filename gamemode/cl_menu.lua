local menu = {}
local callbacks = {}

local cx, cy = ScrW() / 2, ScrH() / 2

list.Set( "PlayerOptionsModel", "combine", 		"models/player/combine_soldier.mdl" )
list.Set( "PlayerOptionsModel", "combineprison", "models/player/combine_soldier_prisonguard.mdl" )
list.Set( "PlayerOptionsModel", "combineelite", "models/player/combine_super_soldier.mdl" )
list.Set( "PlayerOptionsModel", "police", 		"models/player/police.mdl" )
list.Set( "PlayerOptionsModel", "policefem", 	"models/player/police_fem.mdl" )
list.Set( "PlayerOptionsModel", "stripped", 	"models/player/soldier_stripped.mdl" )

list.Set( "PlayerOptionsModel", "alyx", 		"models/player/alyx.mdl" )
list.Set( "PlayerOptionsModel", "barney", 		"models/player/barney.mdl" )
list.Set( "PlayerOptionsModel", "breen", 		"models/player/breen.mdl" )
list.Set( "PlayerOptionsModel", "eli", 		    "models/player/eli.mdl" )
list.Set( "PlayerOptionsModel", "gman", 		"models/player/gman_high.mdl" )
list.Set( "PlayerOptionsModel", "kleiner", 		"models/player/kleiner.mdl" )
list.Set( "PlayerOptionsModel", "magnusson", 	"models/player/magnusson.mdl" )
list.Set( "PlayerOptionsModel", "monk", 		"models/player/monk.mdl" )
list.Set( "PlayerOptionsModel", "mossman", 		"models/player/mossman.mdl" )
list.Set( "PlayerOptionsModel", "mossmanarctic", "models/player/mossman_arctic.mdl" )
list.Set( "PlayerOptionsModel", "odessa", 		"models/player/odessa.mdl" )

list.Set( "PlayerOptionsModel", "charple", 		"models/player/charple.mdl" )
list.Set( "PlayerOptionsModel", "corpse", 		"models/player/corpse1.mdl" )
list.Set( "PlayerOptionsModel", "zombie", 		"models/player/zombie_classic.mdl" )
list.Set( "PlayerOptionsModel", "zombiefast", 	"models/player/zombie_fast.mdl" )
list.Set( "PlayerOptionsModel", "zombine", 		"models/player/zombie_soldier.mdl" )
list.Set( "PlayerOptionsModel", "zombine",      "models/player/zombie_soldier.mdl" )

list.Set( "PlayerOptionsModel", "female01",		"models/player/Group01/female_01.mdl" )
list.Set( "PlayerOptionsModel", "female02",		"models/player/Group01/female_02.mdl" )
list.Set( "PlayerOptionsModel", "female03",		"models/player/Group01/female_03.mdl" )
list.Set( "PlayerOptionsModel", "female04",		"models/player/Group01/female_04.mdl" )
list.Set( "PlayerOptionsModel", "female05",		"models/player/Group01/female_05.mdl" )
list.Set( "PlayerOptionsModel", "female06",		"models/player/Group01/female_06.mdl" )
list.Set( "PlayerOptionsModel", "female07",		"models/player/Group03/female_01.mdl" )
list.Set( "PlayerOptionsModel", "female08",		"models/player/Group03/female_02.mdl" )
list.Set( "PlayerOptionsModel", "female09",		"models/player/Group03/female_03.mdl" )
list.Set( "PlayerOptionsModel", "female10",		"models/player/Group03/female_04.mdl" )
list.Set( "PlayerOptionsModel", "female11",		"models/player/Group03/female_05.mdl" )
list.Set( "PlayerOptionsModel", "female12",		"models/player/Group03/female_06.mdl" )

list.Set( "PlayerOptionsModel", "male01",		"models/player/Group01/male_01.mdl" )
list.Set( "PlayerOptionsModel", "male02",		"models/player/Group01/male_02.mdl" )
list.Set( "PlayerOptionsModel", "male03",		"models/player/Group01/male_03.mdl" )
list.Set( "PlayerOptionsModel", "male04",		"models/player/Group01/male_04.mdl" )
list.Set( "PlayerOptionsModel", "male05",		"models/player/Group01/male_05.mdl" )
list.Set( "PlayerOptionsModel", "male06",		"models/player/Group01/male_06.mdl" )
list.Set( "PlayerOptionsModel", "male07",		"models/player/Group01/male_07.mdl" )
list.Set( "PlayerOptionsModel", "male08",		"models/player/Group01/male_08.mdl" )
list.Set( "PlayerOptionsModel", "male09",		"models/player/Group01/male_09.mdl" )

list.Set( "PlayerOptionsModel", "male10",		"models/player/Group03/male_01.mdl" )
list.Set( "PlayerOptionsModel", "male11",		"models/player/Group03/male_02.mdl" )
list.Set( "PlayerOptionsModel", "male12",		"models/player/Group03/male_03.mdl" )
list.Set( "PlayerOptionsModel", "male13",		"models/player/Group03/male_04.mdl" )
list.Set( "PlayerOptionsModel", "male14",		"models/player/Group03/male_05.mdl" )
list.Set( "PlayerOptionsModel", "male15",		"models/player/Group03/male_06.mdl" )
list.Set( "PlayerOptionsModel", "male16",		"models/player/Group03/male_07.mdl" )
list.Set( "PlayerOptionsModel", "male17",		"models/player/Group03/male_08.mdl" )
list.Set( "PlayerOptionsModel", "male18",		"models/player/Group03/male_09.mdl" )

list.Set( "PlayerOptionsModel", "refugee01",	"models/player/Group02/male_02.mdl" )
list.Set( "PlayerOptionsModel", "refugee02",	"models/player/Group02/male_04.mdl" )
list.Set( "PlayerOptionsModel", "refugee03",	"models/player/Group02/male_06.mdl" )
list.Set( "PlayerOptionsModel", "refugee04",	"models/player/Group02/male_08.mdl" )

list.Set( "PlayerOptionsModel", "css_arctic",		"models/player/arctic.mdl" )
list.Set( "PlayerOptionsModel", "css_gasmask",		"models/player/gasmask.mdl" )
list.Set( "PlayerOptionsModel", "css_guerilla",		"models/player/guerilla.mdl" )
list.Set( "PlayerOptionsModel", "css_leet",			"models/player/leet.mdl" )
list.Set( "PlayerOptionsModel", "css_phoenix",		"models/player/phoenix.mdl" )
list.Set( "PlayerOptionsModel", "css_riot",			"models/player/riot.mdl" )
list.Set( "PlayerOptionsModel", "css_swat",			"models/player/swat.mdl" )
list.Set( "PlayerOptionsModel", "css_urban",		"models/player/urban.mdl" )

list.Set( "PlayerOptionsModel", "dod_american", "models/player/dod_american.mdl" )
list.Set( "PlayerOptionsModel", "dod_german", "models/player/dod_german.mdl" )

function UpdateTeamList()
	if not menu then return end
	if not IsValid( menu.players ) or not IsValid( menu.teamlist ) then return end
	
	menu.players:Clear()
	menu.teamlist:Clear()
	
	local lpt = LocalPlayer():Team()
	local line = menu.teamlist:AddLine( 0, 'Unassigned', #team.GetPlayers( 0 ), team.TotalFrags( 0 ), team.TotalDeaths( 0 ) )
		line.Columns[ 2 ]:SetTextColor( team.GetColor( 0 ) )
		line.OnSelect = function()
			menu.players:Clear()
			
			for _, pl in pairs( player.GetAll() ) do
				if pl:Team() == 0 then
					local line = menu.players:AddLine( pl:Nick() )
					if lpt ~= 0 and pl ~= LocalPlayer() then
						local invite = vgui.Create( 'DButton', line )
							invite:SetPos( 710, 0 )
							invite:SetSize( 59, 18 )
							invite:SetText( 'INVITE' )
							invite.DoClick = function()
								if not IsValid( pl ) then return end
								
								net.Start( 'team_invite' )
									net.WriteEntity( pl )
								net.SendToServer()
							end
					end
				end
			end
		end
	
	local teams = {}
	for _, pl in pairs( player.GetAll() ) do
		if pl:Team() ~= 0 and not table.HasValue( teams, pl:Team() ) then
			local index = pl:Team()
			table.insert( teams, index )
			
			local line = menu.teamlist:AddLine( index, team.GetName( index ), #team.GetPlayers( index ), team.TotalFrags( index ), team.TotalDeaths( index ) )
				line.Columns[ 2 ]:SetTextColor( team.GetColor( index ) )
				line.OnSelect = function()
					menu.players:Clear()
					
					for _, pl in pairs( player.GetAll() ) do
						if pl:Team() == index then
							local line = menu.players:AddLine( pl:Nick() )
							
							if lpt ~= 0 and index ~= lpt then
								local invite = vgui.Create( 'DButton', line )
									invite:SetPos( 710, 0 )
									invite:SetSize( 59, 18 )
									invite:SetText( 'INVITE' )
									invite.DoClick = function()
										if not IsValid( pl ) then return end
										
										net.Start( 'team_invite' )
											net.WriteEntity( pl )
										net.SendToServer()
									end
							elseif lpt ~= 0 and index == lpt and LocalPlayer() ~= pl then
								local kick = vgui.Create( 'DButton', line )
									kick:SetPos( 710, 0 )
									kick:SetSize( 59, 18 )
									kick:SetText( 'KICK' )
									kick.DoClick = function()
										if not IsValid( pl ) then return end
										
										net.Start( 'team_kick' )
											net.WriteEntity( pl )
										net.SendToServer()
									end
							end
						end
					end
				end
				
			if index == lpt then
				local leave = vgui.Create( 'DButton', line )
					leave:SetPos( 505, 0 )
					leave:SetSize( 59, 18 )
					leave:SetText( 'LEAVE' )
					leave.DoClick = function()
						net.Start( 'team_leave' )
						net.SendToServer()
					end
			end
		end
	end
	
	menu.teamlist:SelectItem( line )
	line:OnSelect()
end

local function UpdateWeaponLists( inventory )
	-- heavily structed magic, do not look or/and interact with it!!!
	
	menu.wpri_l:Clear()
	menu.wsec_l:Clear()
	
	for _, c in pairs( inventory.avaliable ) do		
		for _, w in pairs( weapons.GetList() ) do
			if w.ThisClass == c or w.ClassName == c then
				local model = ( w.Slot == 0 and menu.wpri_i or menu.wsec_i )
				local list = ( w.Slot == 0 and menu.wpri_l or menu.wsec_l )
				local cell = ( w.Slot == 0 and 'primary' or 'secondary' )
				local ammo = ( w.Slot == 0 and '1' or '2' )
				
				local line = list:AddLine( w.PrintName )
					line.OnSelect = function()
						net.Start( 'menu_selectwep' )
							net.WriteFloat( ammo - 1 )
							net.WriteString( c )
						net.SendToServer()
						
						model:SetModel( w.WorldModel )
						menu[ 'buypri' .. ammo ]:SetVisible( w.Primary.Ammo )
						menu[ 'buysec' .. ammo ]:SetVisible( w.Secondary.Ammo )
						
						menu[ 'agroup' .. ammo ]:Clear()
						menu[ 'aselect' .. ammo ]:Clear()
						
						local a = w.Attachments
						if a then
							for k, v in pairs( a ) do
								local line = menu[ 'agroup' .. ammo ]:AddLine( 'Group ' .. k )
									line.OnSelect = function()
										menu[ 'aselect' .. ammo ]:Clear()
										
										local none = menu[ 'aselect' .. ammo ]:AddLine( 'None' )
											none.OnSelect = function()
												net.Start( 'attachments' )
													net.WriteFloat( k )
													net.WriteFloat( ammo )
													net.WriteString( 'none' )
												net.SendToServer()
												surface.PlaySound( 'suit/detach.wav' )
											end
										
										for i in pairs( v ) do
											local line = menu[ 'aselect' .. ammo ]:AddLine( GAMEMODE.Parts[ i ][1] )
												line.OnSelect = function()
													net.Start( 'attachments' )
														net.WriteFloat( k )
														net.WriteFloat( ammo )
														net.WriteString( i )
													net.SendToServer()
													surface.PlaySound( 'suit/attach.wav' )
													
													inventory.groups[ ( ammo == '2' and 's' or 'p' ) .. 'group' .. k ] = i
												end
												
											if inventory.groups[ ( ammo == '2' and 's' or 'p' ) .. 'group' .. k ] == i then
												menu[ 'aselect' .. ammo ]:SelectItem( line )
											end
												
											if not table.HasValue( inventory.attachments, i ) then
												local buy = vgui.Create( 'DButton', line )
													buy:SetPos( 105, 0 )
													buy:SetSize( 16, 16 )
													buy:SetText( '$' )
													buy.DoClick = function()
														net.Start( 'menu_buypart' )
															net.WriteString( i )
														net.SendToServer()
														
														buy.OnCursorExited()
													end
													
													buy.OnCursorExited = function() line:SetColumnText( 1, GAMEMODE.Parts[ i ][1] ) end
													buy.OnCursorEntered = function() line:SetColumnText( 1, '$' .. GAMEMODE.Parts[ i ][2] ) end
												
												callbacks[ i ] = function()
													if IsValid( buy ) then buy:Remove() end
														table.insert( inventory.attachments, i )
													end
												end
											end
											
										if #menu[ 'aselect' .. ammo ]:GetSelected() == 0 then
											menu[ 'aselect' .. ammo ]:SelectItem( none )
										end
									end
								end
							end
						
						menu[ 'buypri' .. ammo ].DoClick = function()
							net.Start( 'menu_buyammo' )
								net.WriteString( w.Primary.Ammo )
							net.SendToServer()
						end
						
						menu[ 'buysec' .. ammo ].DoClick = function()
							net.Start( 'menu_buyammo' )
								net.WriteString( w.Secondary.Ammo )
							net.SendToServer()
						end
						
						local dec1 = GAMEMODE.Ammo[ w.Primary.Ammo ] or w.Primary.Ammo
						local dec2 = GAMEMODE.Ammo[ w.Secondary.Ammo ] or w.Secondary.Ammo
						
						if dec1 then menu[ 'ammopri' .. ammo ]:SetText( dec1[1] .. ' [' .. ( inventory.ammocount[ w.Primary.Ammo ] or 0 ) .. ']' ) else menu[ 'ammopri' .. ammo ]:SetText( ' ' ) end
						if dec2 then menu[ 'ammosec' .. ammo ]:SetText( dec2[1] .. ' [' .. ( inventory.ammocount[ w.Secondary.Ammo ] or 0 ) .. ']' ) else menu[ 'ammosec' .. ammo ]:SetText( ' ' ) end
						
						callbacks[ w.Primary.Ammo or 'none' ] = function( num ) if dec1 then menu[ 'ammopri' .. ammo ]:SetText( dec1[1] .. ' [' .. num .. ']' ) else menu[ 'ammopri' .. ammo ]:SetText( ' ' ) end end
						callbacks[ w.Secondary.Ammo or 'none' ] = function( num ) if dec2 then menu[ 'ammosec' .. ammo ]:SetText( dec2[1] .. ' [' .. num .. ']' ) else menu[ 'ammosec' .. ammo ]:SetText( ' ' ) end end
						
						inventory[ cell ] = w.ThisClass or w.ClassName
					end
					
				if inventory[ cell ] == c then
					line:OnSelect()
					list:SelectItem( line )
				end
			end
		end
	end
end

local function UpdateSpecialWeaponryList( inv )
	menu.wspec_l:Clear()
	
	for _, w in pairs( weapons.GetList() ) do
		if w.Slot == -1 then
			local line = menu.wspec_l:AddLine( w.PrintName )
				line.OnSelect = function()
					net.Start( 'menu_selectwep' )
						net.WriteFloat( -1 )
						net.WriteString( w.ThisClass or w.ClassName )
					net.SendToServer()
					
					menu.wspec_i:SetModel( w.WorldModel )
					menu.buyspec:SetVisible( w.Primary.Ammo )
					menu.buyspec.DoClick = function()
						net.Start( 'menu_buyammo' )
							net.WriteString( w.Primary.Ammo )
						net.SendToServer()
					end
					
					local dec1 = GAMEMODE.Ammo[ w.Primary.Ammo ] or w.Primary.Ammo
					if dec1 then menu.ammospec:SetText( dec1[1] .. ' [' .. ( ( inv.ammocount[ w.Primary.Ammo ] or 0 ) + ( inv.ammobuy[ w.Primary.Ammo ] or 0 ) ) .. ']' ) else menu.ammospec:SetText( ' ' ) end
					
					callbacks[ w.Primary.Ammo or 'none' ] = function( num ) if dec1 then menu.ammospec:SetText( dec1[1] .. ' [' .. num .. ']' ) else menu.ammospec:SetText( ' ' ) end end
					inv.special = w.ThisClass or w.ClassName
				end
				
				if inv.special == ( w.ThisClass or w.ClassName ) then
					line:OnSelect()
					menu.wspec_l:SelectItem( line )
				end
		end
	end
end

net.Receive( 'buyammo_callback', function()
	local f = callbacks[ net.ReadString() ]
	if f then
		f( net.ReadFloat() )
		surface.PlaySound( 'items/ammo_pickup.wav' )
	end
end )

net.Receive( 'buypart_callback', function()
	local f = callbacks[ net.ReadString() ]
	if f then
		f( net.ReadFloat() )
		surface.PlaySound( 'ambient/levels/labs/coinslot1.wav' )
	end
end )

net.Receive( 'menu_open', function()
	local tab = net.ReadFloat() or 0
	local inventory = net.ReadTable()
	
	table.Empty( callbacks )
	
	if menu.frame then menu.frame:Remove() end
	
	menu.frame = vgui.Create( 'DFrame' )
	menu.frame:SetSize( 800, 600 )
	menu.frame:SetPos( cx - 400, cy - 300 )
	menu.frame:SetDraggable( false )
	menu.frame:SetTitle( 'F2S: Classic - Menu' )
	menu.frame:MakePopup()
	menu.frame.Close = function( self )
		net.Start( 'menu' )
			net.WriteString( inventory.primary )
			net.WriteString( inventory.secondary )
		net.SendToServer()
		
		net.Start( 'menu_closed' )
		net.SendToServer()
		
		self:Remove()
	end
	
	menu.tabs = vgui.Create( 'DPropertySheet', menu.frame )
	menu.tabs:SetPos( 5, 25 )
	menu.tabs:SetSize( 790, 570 )
	
	menu.teams = vgui.Create( 'DPanel' )
	menu.teams:SetSize( 780, 505 )
	
	
	menu.teamlist = vgui.Create( 'DListView', menu.teams )
	menu.teamlist:SetPos( 5, 5 )
	menu.teamlist:SetSize( 770, 260 )
	menu.teamlist:SetMultiSelect( false )
	menu.teamlist:AddColumn( 'INDEX' ):SetFixedWidth( 52 )
	menu.teamlist:AddColumn( 'TITLE' ):SetFixedWidth( 512 )
	menu.teamlist:AddColumn( 'MEMBERS' ):SetFixedWidth( 72 )
	menu.teamlist:AddColumn( 'FRAGS' ):SetFixedWidth( 72 )
	menu.teamlist:AddColumn( 'DEATHS' ):SetFixedWidth( 72 )
	
	menu.players = vgui.Create( 'DListView', menu.teams )
	menu.players:SetPos( 5, 270 )
	menu.players:SetSize( 770, 210 )
	menu.players:SetMultiSelect( false )
	menu.players:AddColumn( 'PLAYERS' )
	
	menu.label1 = vgui.Create( 'DLabel', menu.teams )
	menu.label1:SetPos( 5, 488 )
	menu.label1:SetText( 'Title:' )
	menu.label1:SizeToContents()
	
	menu.name = vgui.Create( 'DTextEntry', menu.teams )
	menu.name:SetPos( 58, 485 )
	menu.name:SetSize( 250, 20 )
	
	menu.mkteam = vgui.Create( 'DButton', menu.teams )
	menu.mkteam:SetPos( 655, 485 )
	menu.mkteam:SetSize( 120, 20 )
	menu.mkteam:SetText( 'Create team' )
	menu.mkteam.DoClick = function()
		net.Start( 'menu_mkteam' )
			net.WriteString( menu.name:GetValue() )
		net.SendToServer()
		
		timer.Simple( 0.5, function() UpdateTeamList() end )
	end
	
	menu.misc = vgui.Create( 'DPanel' )
	menu.misc:SetSize( 780, 505 )
	
	local mdl = menu.misc:Add( 'DModelPanel' )
		mdl:Dock( FILL )
		mdl:SetFOV( 45 )
		mdl:SetCamPos( Vector( 90, 0, 60 ) )
		
		local sheet = menu.misc:Add( 'DPropertySheet' )
			sheet:Dock( FILL )
			
		local pan = sheet:Add( 'DPanelSelect' )
		for k, v in pairs( list.Get( 'PlayerOptionsModel' ) ) do
			local icon = vgui.Create( 'SpawnIcon' )
				icon:SetModel( v )
				icon:SetSize( 64, 64 )
				icon:SetTooltip( k )
				
				pan:AddPanel( icon, { cl_playermodel = k } )
		end
		
		sheet:AddSheet( 'Model', pan )
			
		local pan = sheet:Add( 'DPanel' )
		
		local blur = vgui.Create( 'DCheckBoxLabel', pan )
			blur:SetPos( 5, 10 )
			blur:SetText( 'Disable blur' )
			blur:SetConVar( 'f2s_disableblur' )
			blur:SizeToContents()
			
		local muz = vgui.Create( 'DCheckBoxLabel', pan )
			muz:SetPos( 5, 30 )
			muz:SetText( 'Disable muzzleflash' )
			muz:SetConVar( 'f2s_disablemuzzle' )
			muz:SizeToContents()
			
		local sounds = vgui.Create( 'DCheckBoxLabel', pan )
			sounds:SetPos( 5, 50 )
			sounds:SetText( 'Disable distant sounds' )
			sounds:SetConVar( 'f2s_disabledistantsounds' )
			sounds:SizeToContents()
			
		local rain = vgui.Create( 'DCheckBoxLabel', pan )
			rain:SetPos( 5, 70 )
			rain:SetText( 'Lower rain quality' )
			rain:SetConVar( 'f2s_lowerrain' )
			rain:SizeToContents()
		
		local legs = vgui.Create( 'DCheckBoxLabel', pan )
			legs:SetPos( 5, 90 )
			legs:SetText( 'Draw legs' )
			legs:SetConVar( 'f2s_legs' )
			legs:SizeToContents()
			
		local hud = vgui.Create( 'DCheckBoxLabel', pan )
			hud:SetPos( 5, 110 )
			hud:SetText( 'Static HUD' )
			hud:SetConVar( 'f2s_statichud' )
			hud:SizeToContents()
			
		local headbob = vgui.Create( 'DCheckBoxLabel', pan )
			headbob:SetPos( 5, 130 )
			headbob:SetText( 'Reduce head bob' )
			headbob:SetConVar( 'f2s_reduceheadbob' )
			headbob:SizeToContents()
		
		sheet:AddSheet( 'Optimization', pan )
		
		local pan = sheet:Add( 'DPanel' )
		
		local amount = vgui.Create( 'DTextEntry', pan )
			amount:SetPos( 5, 300 )
			amount:SetWide( 250 )
			amount.Think = function( self )
				local s = self:GetValue()
				for i = 1, #s do
					if not tonumber( s[i] ) then
						self:SetValue( string.gsub( s, s[i], '' ) )
						break
					end
				end
			end
		
		local translator = {}
		local plys = vgui.Create( 'DListView', pan )
			plys:SetPos( 5, 10 )
			plys:SetSize( 250, 285 )
			plys:AddColumn( 'PLAYERS' )
			
		for _, pl in pairs( player.GetAll() ) do
			if pl == LocalPlayer() then continue end
			
			translator[ plys:AddLine( pl:Nick() ) ] = pl
		end
			
		local give = vgui.Create( 'DButton', pan )
			give:SetPos( 5, 325 )
			give:SetWide( 250 )
			give:SetText( 'Give out' )
			give.DoClick = function()
				local s = amount:GetValue()
				for i = 1, #s do
					if not tonumber( s[i] ) then
						return
					end
				end
				
				local v = plys:GetSelectedLine()
				if v then v = plys:GetLine( v ) end
				
				if v and translator[ v ] then
					net.Start( 'transfer_money' )
						net.WriteEntity( translator[ v ] )
						net.WriteFloat( tonumber( s ) )
					net.SendToServer()
				end
			end
			
		sheet:AddSheet( 'Money transfer', pan )
	
		menu.guide = vgui.Create( 'HTML' )
		menu.guide:OpenURL( 'http://google.com' )
		menu.guide:SetSize( 780, 505 )
		
		menu.shop = vgui.Create( 'DPanel' )
		menu.shop:SetSize( 780, 505 )
		
		menu.gabe = vgui.Create( 'DImage', menu.shop )
		menu.gabe:SetPos( 5, 5 )
		menu.gabe:SetSize( 128, 128 )
		menu.gabe:SetImage( 'gaben.png' )
		menu.gabe.PaintOver = function( self )
			surface.SetDrawColor( color_black )
			surface.DrawOutlinedRect( 0, 0, self:GetSize() )
		end
		
		menu.title = vgui.Create( 'DLabel', menu.shop )
		menu.title:SetPos( 148, 10 )
		menu.title:SetFont( 'ScoreboardDefaultTitle' )
		menu.title:SetText( 'Welcome to the Gaben\'s hardware store!' )
		menu.title:SizeToContents()
		
		menu.tip = vgui.Create( 'DLabel', menu.shop )
		menu.tip:SetPos( 148, 40 )
		menu.tip:SetFont( 'ChatFont' )
		menu.tip:SetText( '' )
		
		menu.preview = vgui.Create( 'DModelPanel', menu.shop )
		menu.preview:SetPos( 520, 138 )
		menu.preview:SetSize( 256, 192 )
		menu.preview:SetCamPos( Vector( -48, 0, 5 ) )
		menu.preview:SetLookAt( Vector( 0, 0, 3 ) )
		menu.preview.OldPaint = menu.preview.Paint
		menu.preview.MoreText = 'NO WEAPON'
		menu.preview.Paint = function( self, ... )
			self.OldPaint( self, ... )
			
			surface.SetDrawColor( color_black )
			surface.DrawOutlinedRect( 0, 0, self:GetSize() )
			
			if #self.MoreText > 1 then
				surface.SetDrawColor( 0, 0, 0, 127 )
				surface.DrawRect( 0, 0, self:GetSize() )
			end
			
			surface.SetFont( 'ScoreboardDefaultTitle' )
			surface.SetTextPos( ( self:GetWide() - surface.GetTextSize( self.MoreText ) ) / 2, 82 )
			surface.SetTextColor( 255, 255, 0, 255 )
			surface.DrawText( self.MoreText )
		end
		
		menu.sinfo = vgui.Create( 'DLabel', menu.shop )
		menu.sinfo:SetPos( 522, 332 )
		menu.sinfo:SetText( 'Price:\nFinal balance:\nClip size:\nBullet spread:\nJamming chance:\nRate of fire:\nSupported attachments:' )
		menu.sinfo:SizeToContents()
		
		menu.dinfo = vgui.Create( 'DLabel', menu.shop )
		menu.dinfo:SetPos( 650, 332 )
		menu.dinfo:SetText( '' )
		
		menu.btnbuy = vgui.Create( 'DButton', menu.shop )
		menu.btnbuy:SetPos( 521, 475 )
		menu.btnbuy:SetSize( 256, 30 )
		menu.btnbuy:SetFont( 'ChatFont' )
		menu.btnbuy:SetText( 'BUY' )
		menu.btnbuy:SetEnabled( false )
		menu.btnbuy.DoClick = function( self )
			if self.Weapon and not table.HasValue( inventory.avaliable, self.Weapon ) then
				net.Start( 'menu_buyweapon' )
					net.WriteString( self.Weapon )
				net.SendToServer()
				
				table.insert( inventory.avaliable, self.Weapon )
				surface.PlaySound( 'items/ammo_pickup.wav' )
				
				for i = 0.3, 2.5, 0.5 do timer.Simple( i, function() surface.PlaySound( 'ambient/levels/labs/coinslot1.wav' ) end ) end
				
				UpdateWeaponLists( inventory )
				self.Row:OnSelect()
			end
		end
		
		menu.weplist = vgui.Create( 'DListView', menu.shop )
		menu.weplist:SetPos( 5, 138 )
		menu.weplist:SetSize( 510, 512 )
		menu.weplist:AddColumn( 'Name' ):SetFixedWidth( 250 )
		menu.weplist:AddColumn( 'Type' ):SetFixedWidth( 80 )
		menu.weplist:AddColumn( 'Jamming chance' ):SetFixedWidth( 100 )
		menu.weplist:AddColumn( 'Price' )
		
		for _, w in pairs( weapons.GetList() ) do
			if ( w.Slot == 0 or w.Slot == 1 ) and w.Price and not table.HasValue( inventory.avaliable, w.ThisClass or w.ClassName ) then
				local line = menu.weplist:AddLine( w.PrintName, w.Slot == 0 and 'Primary' or 'Secondary', ( w.JamChance > 1 and '1 of ' .. w.JamChance or '0%' ), '$' .. w.Price - 1 .. '.99' )
					line.OnSelect = function()
						menu.preview:SetModel( w.WorldModel )
						
						if w.Gaben then
							menu.tip:SetText( w.Gaben )
							menu.tip:SizeToContents()
							
							timer.Simple( 0.01, function()
								menu.tip:SetText( w.Gaben )
								menu.tip:SizeToContents()
							end )
						else
							menu.tip:SetText( '' )
						end
						
						local info = {}
						
						table.insert( info, w.Price )
						table.insert( info, inventory.money - w.Price )
						table.insert( info, w.Primary.ClipSize )
						
						if w.Primary.Cone then
							table.insert( info, w.Primary.Cone < 0.03 and 'thin' or ( w.Primary.Cone < 0.06 and 'moderate' or ( w.Primary.Cone < 0.1 and 'wide' or 'very wide' ) ) )
						else
							table.insert( info, 'unknown' )
						end
						
						table.insert( info, ( w.JamChance > 1 and '1 of ' .. w.JamChance or '0%' ) )
						table.insert( info, math.floor( 60 / w.Primary.Delay ) )
						
						if w.Attachments then
							local att = {}
							for _, v in pairs( w.Attachments ) do
								for k in pairs( v ) do
									if GAMEMODE.Parts[ k ] then table.insert( att, '\t' .. string.lower( GAMEMODE.Parts[ k ][1] ) ) end
								end
							end
							
							table.insert( info, table.concat( att, '\n' ) )
						else
							table.insert( info, 'none' )
						end
						
						menu.dinfo:SetText( string.format( '$%s\n$%s\n%s round(s)\n%s\n%s\n%s rpm\n%s\n', unpack( info ) ) )
						menu.dinfo:SizeToContents()
						
						timer.Simple( 0.01, function()
							menu.dinfo:SetText( string.format( '$%s\n$%s\n%s round(s)\n%s\n%s\n%s rpm\n%s\n', unpack( info ) ) )
							menu.dinfo:SizeToContents()
						end )
						
						if table.HasValue( inventory.avaliable, w.ThisClass or w.ClassName ) then
							menu.btnbuy.Weapon = nil
							menu.btnbuy:SetEnabled( false )
							menu.preview.MoreText = 'SOLD'
						elseif w.Level and inventory.lvl < w.Level then
							menu.btnbuy.Weapon = nil
							menu.btnbuy:SetEnabled( false )
							menu.preview.MoreText = 'LOW XP LEVEL'
						elseif inventory.money < w.Price then
							menu.btnbuy.Weapon = nil
							menu.btnbuy:SetEnabled( false )
							menu.preview.MoreText = 'LOW MONEY'
						else
							menu.btnbuy.Weapon = w.ThisClass or w.ClassName
							menu.btnbuy.Row = line
							menu.btnbuy:SetEnabled( true )
							menu.preview.MoreText = ''
						end
					end
			end
		end
		
		menu.lout = vgui.Create( 'DPanel' )
		menu.lout:SetSize( 780, 505 )
		
		menu.buypri1 = vgui.Create( 'DButton', menu.lout )
		menu.buypri1:SetPos( 5, 140 )
		menu.buypri1:SetSize( 40, 25 )
		menu.buypri1:SetText( 'BUY' )
		
		menu.agroup1 = vgui.Create( 'DListView', menu.lout )
		menu.agroup1:SetPos( 5, 5 )
		menu.agroup1:SetSize( 123, 128 )
		menu.agroup1:AddColumn( 'ATTACHMENT GROUPS' )
		menu.agroup1:SetMultiSelect( false )
		
		menu.aselect1 = vgui.Create( 'DListView', menu.lout )
		menu.aselect1:SetPos( 136, 5 )
		menu.aselect1:SetSize( 123, 128 )
		menu.aselect1:AddColumn( 'ATTACHMENTS' )
		menu.aselect1:SetMultiSelect( false )
		
		menu.agroup2 = vgui.Create( 'DListView', menu.lout )
		menu.agroup2:SetPos( 266, 5 )
		menu.agroup2:SetSize( 123, 128 )
		menu.agroup2:AddColumn( 'ATTACHMENT GROUPS' )
		menu.agroup2:SetMultiSelect( false )
		
		menu.aselect2 = vgui.Create( 'DListView', menu.lout )
		menu.aselect2:SetPos( 397, 5 )
		menu.aselect2:SetSize( 123, 128 )
		menu.aselect2:AddColumn( 'ATTACHMENTS' )
		menu.aselect2:SetMultiSelect( false )
		
		menu.ammopri1 = vgui.Create( 'DLabel', menu.lout )
		menu.ammopri1:SetPos( 50, 145 )
		menu.ammopri1:SetText( '' )
		menu.ammopri1.OldSetText = menu.ammopri1.SetText
		menu.ammopri1.SetText = function( self, text )
			self:OldSetText( text )
			self:SizeToContents()
		end
		
		menu.buypri2 = vgui.Create( 'DButton', menu.lout )
		menu.buypri2:SetPos( 266, 140 )
		menu.buypri2:SetSize( 40, 25 )
		menu.buypri2:SetText( 'BUY' )
		
		menu.ammopri2 = vgui.Create( 'DLabel', menu.lout )
		menu.ammopri2:SetPos( 311, 145 )
		menu.ammopri2.OldSetText = menu.ammopri2.SetText
		menu.ammopri2.SetText = function( self, text )
			self:OldSetText( text )
			self:SizeToContents()
		end
		
		menu.buysec1 = vgui.Create( 'DButton', menu.lout )
		menu.buysec1:SetPos( 5, 170 )
		menu.buysec1:SetSize( 40, 25 )
		menu.buysec1:SetText( 'BUY' )
		
		menu.ammosec1 = vgui.Create( 'DLabel', menu.lout )
		menu.ammosec1:SetPos( 50, 175 )
		menu.ammosec1:SetText( '' )
		menu.ammosec1.OldSetText = menu.ammosec1.SetText
		menu.ammosec1.SetText = function( self, text )
			self:OldSetText( text )
			self:SizeToContents()
		end
		
		menu.buysec2 = vgui.Create( 'DButton', menu.lout )
		menu.buysec2:SetPos( 266, 170 )
		menu.buysec2:SetSize( 40, 25 )
		menu.buysec2:SetText( 'BUY' )
		
		menu.ammosec2 = vgui.Create( 'DLabel', menu.lout )
		menu.ammosec2:SetPos( 311, 175 )
		menu.ammosec2.OldSetText = menu.ammosec2.SetText
		menu.ammosec2.SetText = function( self, text )
			self:OldSetText( text )
			self:SizeToContents()
		end
		
		menu.wpri_i = vgui.Create( 'DModelPanel', menu.lout )
		menu.wpri_i:SetPos( 5, 200 )
		menu.wpri_i:SetSize( 256, 128 )
		menu.wpri_i:SetCamPos( Vector( -32, 0, 3 ) )
		menu.wpri_i:SetLookAt( Vector() )
		menu.wpri_i.OldPaint = menu.wpri_i.Paint
		menu.wpri_i.Paint = function( self, ... )
			self.OldPaint( self, ... )
			
			surface.SetDrawColor( color_black )
			surface.DrawOutlinedRect( 0, 0, self:GetSize() )
		end
		
		menu.wpri_l = vgui.Create( 'DListView', menu.lout )
		menu.wpri_l:SetPos( 5, 332 )
		menu.wpri_l:SetSize( 256, 128 )
		menu.wpri_l:SetMultiSelect( false )
		menu.wpri_l:AddColumn( 'PRIMARY' )
		
		menu.wsec_i = vgui.Create( 'DModelPanel', menu.lout )
		menu.wsec_i:SetPos( 266, 200 )
		menu.wsec_i:SetSize( 256, 128 )
		menu.wsec_i:SetCamPos( Vector( -24, 0, 3 ) )
		menu.wsec_i:SetLookAt( Vector() )
		menu.wsec_i.OldPaint = menu.wsec_i.Paint
		menu.wsec_i.Paint = function( self, ... )
			self.OldPaint( self, ... )
			
			surface.SetDrawColor( color_black )
			surface.DrawOutlinedRect( 0, 0, self:GetSize() )
		end
		
		menu.wsec_l = vgui.Create( 'DListView', menu.lout )
		menu.wsec_l:SetPos( 266, 332 )
		menu.wsec_l:SetSize( 256, 128 )
		menu.wsec_l:SetMultiSelect( false )
		menu.wsec_l:AddColumn( 'SECONDARY' )
		
		menu.buyspec = vgui.Create( 'DButton', menu.lout )
		menu.buyspec:SetPos( 527, 303 )
		menu.buyspec:SetSize( 40, 25 )
		menu.buyspec:SetText( 'BUY' )
		
		menu.ammospec = vgui.Create( 'DLabel', menu.lout )
		menu.ammospec:SetPos( 573, 308 )
		menu.ammospec.OldSetText = menu.ammospec.SetText
		menu.ammospec.SetText = function( self, text )
			self:OldSetText( text )
			self:SizeToContents()
		end
		
		menu.wspec_i = vgui.Create( 'DModelPanel', menu.lout )
		menu.wspec_i:SetPos( 527, 5 )
		menu.wspec_i:SetSize( 250, 295 )
		menu.wspec_i:SetCamPos( Vector( -18, 0, 5 ) )
		menu.wspec_i:SetLookAt( Vector( 0, 0, 5 ) )
		menu.wspec_i.OldPaint = menu.wspec_i.Paint
		menu.wspec_i.Paint = function( self, ... )
			self.OldPaint( self, ... )
			
			surface.SetDrawColor( color_black )
			surface.DrawOutlinedRect( 0, 0, self:GetSize() )
		end
		
		menu.wspec_l = vgui.Create( 'DListView', menu.lout )
		menu.wspec_l:SetPos( 527, 332 )
		menu.wspec_l:SetSize( 250, 128 )
		menu.wspec_l:SetMultiSelect( false )
		menu.wspec_l:AddColumn( 'SPECIAL' )
		
		UpdateSpecialWeaponryList( inventory )
		UpdateWeaponLists( inventory )
		
	if tab == 2 then
		menu.tabs:AddSheet( 'Teams', menu.teams, 'icon16/chart_organisation.png', true, true, 'Teams' )
		menu.tabs:AddSheet( 'Guide', menu.guide, 'icon16/help.png', true, true, 'How2play' )
		menu.tabs:AddSheet( 'Loadout', menu.lout, 'icon16/gun.png', true, true, 'Your guns' )
		menu.tabs:AddSheet( 'Gaben\'s shop', menu.shop, 'icon16/coins.png', true, true, 'Gaben\'s hardware store' )
		menu.tabs:AddSheet( 'Misc', menu.misc, 'icon16/application_view_tile.png', true, true, 'Misc' )
	elseif tab == 3 then
		menu.tabs:AddSheet( 'Loadout', menu.lout, 'icon16/gun.png', true, true, 'Your guns' )
		menu.tabs:AddSheet( 'Guide', menu.guide, 'icon16/help.png', true, true, 'How2play' )
		menu.tabs:AddSheet( 'Teams', menu.teams, 'icon16/chart_organisation.png', true, true, 'Teams' )
		menu.tabs:AddSheet( 'Gaben\'s shop', menu.shop, 'icon16/coins.png', true, true, 'Gaben\'s hardware store' )
		menu.tabs:AddSheet( 'Misc', menu.misc, 'icon16/application_view_tile.png', true, true, 'Misc' )
	elseif tab == 4 then
		menu.tabs:AddSheet( 'Gaben\'s shop', menu.shop, 'icon16/coins.png', true, true, 'Gaben\'s hardware store' )
		menu.tabs:AddSheet( 'Guide', menu.guide, 'icon16/help.png', true, true, 'How2play' )
		menu.tabs:AddSheet( 'Teams', menu.teams, 'icon16/chart_organisation.png', true, true, 'Teams' )
		menu.tabs:AddSheet( 'Loadout', menu.lout, 'icon16/gun.png', true, true, 'Your guns' )
		menu.tabs:AddSheet( 'Misc', menu.misc, 'icon16/application_view_tile.png', true, true, 'Misc' )
	else
		menu.tabs:AddSheet( 'Guide', menu.guide, 'icon16/help.png', true, true, 'How2play' )
		menu.tabs:AddSheet( 'Teams', menu.teams, 'icon16/chart_organisation.png', true, true, 'Teams' )
		menu.tabs:AddSheet( 'Loadout', menu.lout, 'icon16/gun.png', true, true, 'Your guns' )
		menu.tabs:AddSheet( 'Gaben\'s shop', menu.shop, 'icon16/coins.png', true, true, 'Gaben\'s hardware store' )
		menu.tabs:AddSheet( 'Misc', menu.misc, 'icon16/application_view_tile.png', true, true, 'Misc' )
	end
	
	WAIT_FOR_LOCALPLAYER = true
end )