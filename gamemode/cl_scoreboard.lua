local board
local connecting = {}
local disconnected = {}
local avatars = {}
local null = function() end

net.Receive( 'connecting', function()
	connecting = net.ReadTable()
	
	for _, c in pairs( connecting ) do
		GAMEMODE:GetAvatar( c.sid, null )
	end
end )

net.Receive( 'disconnected', function()
	local c = net.ReadTable()
		GAMEMODE:GetAvatar( c.sid, null )
	local index = table.insert( disconnected, c )
	
	timer.Simple( 30, function() table.remove( disconnected, index ) end )
end )

net.Receive( 'ping', function()
	net.Start( 'ping' )
	net.SendToServer()
end )

local grad = surface.GetTextureID( 'gui/gradient' )
local base_paint = function( self, w, h )
	surface.SetDrawColor( self.Color )
	surface.DrawRect( 0, 1, w, h - 2 )
	
	surface.SetTexture( grad )
	surface.SetDrawColor( color_white )
	surface.DrawTexturedRect( 41, 20, 512, 2 )
	
	surface.SetDrawColor( color_black )
	surface.DrawLine( 753, 1, 753, h - 2 )
	surface.DrawLine( 753, 1, 753, h - 2 )
	surface.DrawLine( 719, 1, 719, h - 2 )
	surface.DrawLine( 678, 1, 678, h - 2 )
	
	if not self.SplitInfo then surface.DrawLine( 606, 1, 606, h - 2 ) end
end

function GM:GetSID64( sid )
	if sid == 'BOT' or sid == 'NULL' or sid == 'STEAM_ID_PENDING' or sid == 'UNKNOWN' then return 0 end
	
	local p = sid:Split( ':' )
	local a, b = p[2], p[3]
	
	return tostring( '7656119' .. 7960265728 + a + b * 2 )
end

function GM:GetAvatar( sid, func )
	if avatars[ sid ] then
		func( unpack( avatars[ sid ] ) )
	else
		http.Post( 'http://steamcommunity.com/profiles/' .. self:GetSID64( sid ) .. '?xml=1', '', function( text )
			local icon = string.match( text, '<avatarIcon><!%[CDATA%[(.-)%]%]></avatarIcon>' )
			local med = string.match( text, '<avatarMedium><!%[CDATA%[(.-)%]%]></avatarMedium>' )
			local full = string.match( text, '<avatarFull><!%[CDATA%[(.-)%]%]></avatarFull>' )
			
			if icon and med and full then
				func( icon, med, full )
				avatars[ sid ] = { icon, med, full }
			end
		end )
	end
end

local lastheadercolor
function GM:CreatePlayerRowByInfo( entity, networkid, nick, lastnick, level, r, reason )
	local base = vgui.Create( 'DPanel' )
		base:SetSize( 785, 42 )
		base.Paint = base_paint
		base.Color = table.Copy( lastheadercolor )
		base.Color.r = base.Color.r * 0.8
		base.Color.g = base.Color.g * 0.8
		base.Color.b = base.Color.b * 0.8
		base.Color.a = 200
		base.SplitInfo = not IsValid( entity )
	
	local copy = vgui.Create( 'DButton', base )
		copy:Dock( FILL )
		copy:SetText( ' ' )
		copy.Paint = nil
		copy.DoRightClick = function()
			local dm = DermaMenu( base )
				dm:AddOption( 'Open profile', function() gui.OpenURL( 'http://steamcommunity.com/profiles/' .. self:GetSID64( networkid ) ) end )
				dm:AddOption( 'Copy profile URL', function()
					SetClipboardText( 'http://steamcommunity.com/profiles/' .. self:GetSID64( networkid ) )
					LocalPlayer():ChatPrint( 'Profile URL copied to clipboard' )
				end )
				
				dm:AddOption( 'Copy SteamID', function()
					SetClipboardText( networkid )
					LocalPlayer():ChatPrint( 'SteamID copied to clipboard' )
				end )
				
				if IsValid( entity ) and entity ~= LocalPlayer() then
					local userid = entity:UserID()
					local nick = entity:Nick()
					
					dm:AddSpacer()
					dm:AddOption( '+ rep', function() RunConsoleCommand( 'f2s_rep', 'add', userid ) end )
					dm:AddOption( '- rep', function() RunConsoleCommand( 'f2s_rep', 'sub', userid ) end )
					
					dm:AddSpacer()
					dm:AddOption( entity:IsMuted() and 'Unmute' or 'Mute', function() entity:SetMuted( not entity:IsMuted() ) end )
					
					if LocalPlayer():IsAdmin() then
						dm:AddOption( 'Kick', function()
							LocalPlayer():ConCommand( 'say !kick ' .. nick )
						end )
					end
				end
				
				dm:Open()
		end
		
	local name = vgui.Create( 'DLabel', base )
		name:SetPos( 42, 4 )
		name:SetText( nick .. ( lastnick and lastnick ~= nick and ' (' .. lastnick .. ')' or '' ) )
		name:SetTextColor( color_white )
		name:SizeToContents()
	
	local lvl = vgui.Create( 'DLabel', base )
		lvl:SetText( level or 1 )
		lvl:SizeToContents()
		lvl:SetTextColor( color_white )
		lvl:SetPos( 737 - lvl:GetWide() / 2, 13 )
		
	local rep = vgui.Create( 'DLabel', base )
		rep:SetText( r or 0 )
		rep:SizeToContents()
		rep:SetTextColor( color_white )
		rep:SetPos( 699 - rep:GetWide() / 2, 13 )
	
	if IsValid( entity ) and entity:IsPlayer() then
		rep.Think = function( self )
			if ( self.NextUpdate or 0 ) > CurTime() then return end
				self.NextUpdate = CurTime() + 0.5
			
			rep:SetText( entity:GetNWInt( 'rep' ) )
			rep:SizeToContents()
			rep:SetPos( 699 - rep:GetWide() / 2, 13 )
		end
		
		local ava = vgui.Create( 'AvatarImage', base )
			ava:SetPos( 6, 5 )
			ava:SetSize( 32, 32 )
			ava:SetPlayer( entity, 32 )
			
		local squad = vgui.Create( 'DLabel', base )
			squad:SetPos( 42, 24 )
			squad:SetText( entity:Team() == 0 and 'Unassigned' or team.GetName( entity:Team() ) )
			squad:SetTextColor( entity:Team() == 0 and color_white or team.GetColor( entity:Team() ) )
			squad:SizeToContents()
			
		local killsdeaths = vgui.Create( 'DLabel', base )
			killsdeaths:SetTextColor( color_white )
			killsdeaths.Think = function( self )
				if ( self.NextUpdate or 0 ) > CurTime() then return end
				
				self.NextUpdate = CurTime() + 0.3
				self:SetText( entity:Frags() .. ' : ' .. entity:Deaths() )
				self:SizeToContents()
				self:SetPos( 643 - self:GetWide() / 2, 13 )
			end
		
		if entity ~= LocalPlayer() then
			local mute = vgui.Create( 'DImageButton', base )
				mute:SetSize( 16, 16 )
				mute:SetPos( 585, 3 )
				mute.Think = function( self )
					local mute = entity:IsMuted()
					if mute ~= self.Muted then
						self.Muted = mute
						self:SetImage( mute and 'icon16/sound_mute.png' or 'icon16/sound.png' )
					end
				end
				
				mute.DoClick = function()
					entity:SetMuted( not entity:IsMuted() )
				end
				
			local add = vgui.Create( 'DButton', base )
				add:SetPos( 681, 29 )
				add:SetSize( 10, 10 )
				add:SetText( '+' )
				add.DoClick = function()
					RunConsoleCommand( 'f2s_rep', 'add', entity:UserID() )
				end
				
			local sub = vgui.Create( 'DButton', base )
				sub:SetPos( 707, 29 )
				sub:SetSize( 10, 10 )
				sub:SetText( '-' )
				sub.DoClick = function()
					RunConsoleCommand( 'f2s_rep', 'sub', entity:UserID() )
				end
		end
		
		if entity:IsBot() then
			local ping = vgui.Create( 'DLabel', base )
				ping:SetTextColor( color_white )
				ping:SetText( 'BOT' )
				ping:SizeToContents()
				ping:SetPos( 770 - ping:GetWide() / 2, 13 )
		else
			local state
			local ping = vgui.Create( 'DLabel', base )
				ping:SetTextColor( color_white )
				ping.Think = function( self )
					if ( self.NextPing or 0 ) < CurTime() then
						self.NextPing = CurTime() + 0.2
						
						local timeout = entity:GetNWBool( 'timeout' )
						
						state.ShouldDraw = timeout
						state:SetVisible( state.ShouldDraw )
						
						self:SetText( entity:Ping() )
						self:SizeToContents()
						self:SetPos( 769 - self:GetWide() / 2, timeout and 5 or 13 )
					end
				end
				
			state = vgui.Create( 'DImage', base )
			state:SetSize( 16, 16 )
			state:SetPos( 768 - state:GetWide() / 2, 21 )
			state.Think = function( self )
				if ( self.NextAnim or 0 ) < CurTime() and self.ShouldDraw then
					self.NextAnim = CurTime() + 0.5
					self.Connect = not self.Connect
					
					self:SetImage( self.Connect and 'icon16/connect.png' or 'icon16/disconnect.png' )
				end
			end
		end
	else
		local ava = vgui.Create( 'DHTML', base )
			ava:SetPos( 6, 5 )
			ava:SetSize( 32, 32 )
		self:GetAvatar( networkid, function( icon ) if IsValid( ava ) then ava:OpenURL( icon ) end end )
		
		local status = vgui.Create( 'DLabel', base )
			status:SetPos( 42, 24 )
			status:SetTextColor( color_white )
			
			if entity == nil then
				status:SetText( string.upper( reason[1] ) .. string.sub( reason, 2, #reason ) )
			else
				status:SetText( 'Connecting' )
				status.Think = function( self )
					if ( self.NextDot or 0 ) < CurTime() then
						self.NextDot = CurTime() + 0.5
						self.Dots = ( self.Dots or 0 ) + 1
						
						if self.Dots > 3 then self.Dots = 0 end
						
						self:SetText( 'Connecting' .. string.rep( '.', self.Dots ) )
						self:SizeToContents()
					end
				end
			end
			
			status:SizeToContents()
			
		local ping = vgui.Create( 'DImage', base )
			ping:SetSize( 16, 16 )
			ping:SetPos( 768 - ping:GetWide() / 2, 13 )
			
		if entity == nil then
			ping:SetImage( 'icon16/disconnect.png' )
		else
			ping.Think = function( self )
				if ( self.NextAnim or 0 ) < CurTime() then
					self.NextAnim = CurTime() + 0.5
					self.Connect = not self.Connect
					
					self:SetImage( self.Connect and 'icon16/connect.png' or 'icon16/disconnect.png' )
				end
			end
		end
	end
	
	return base
end

function GM:CreatePlayerRow( ply )
	return self:CreatePlayerRowByInfo( ply, ply:SteamID(), ply:Nick(), nil, ply:GetNWInt( 'lvl', 1 ), ply:GetNWInt( 'rep' ) )
end

function GM:CreateHeader( text, split, color )
	lastheadercolor = color
	
	local header = vgui.Create( 'DPanel' )
		header:SetSize( 785, 18 )
		header.Color = color
		header.Paint = function( self, w, h )
			surface.SetDrawColor( self.Color )
			surface.DrawRect( 0, 0, w, h )
			
			surface.SetFont( 'DermaDefault' )
			surface.SetTextColor( color_white )
			surface.SetTextPos( 5, 2 )
			surface.DrawText( text )
			
			surface.SetTextPos( 760, 2 )
			surface.DrawText( 'ping' )
			surface.SetTextPos( 726, 2 )
			surface.DrawText( 'level' )
			surface.SetTextPos( 690, 2 )
			surface.DrawText( 'REP' )
			
			surface.SetDrawColor( color_black )
			surface.DrawLine( 753, 0, 753, 18 )
			surface.DrawLine( 719, 0, 719, 18 )
			surface.DrawLine( 678, 0, 678, 18 )
			
			if not split then
				surface.SetTextPos( 613, 2 )
				surface.DrawText( 'kills : deaths' )
				surface.DrawLine( 606, 0, 606, 18 )
			end
		end
	return header
end

local w, h = ScrW(), ScrH()
function GM:ScoreboardShow()
	if board then return end
	
	board = vgui.Create( 'DFrame' )
	board:SetSize( 800, 600 )
	board:SetPos( ( w - 800 ) / 2, ( h - 600 ) / 2 )
	board:ShowCloseButton( false )
	board:SetDraggable( false )
	board.lblTitle:SetText( ' ' )
	board.Paint = function( self, w, h )
		draw.RoundedBox( 10, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
		
		surface.SetDrawColor( 255, 255, 255 )
		surface.DrawLine( 10, 18, w - 12, 18 )
		surface.DrawLine( 10, h - 18, w - 12, h - 18 )
		
		surface.SetFont( 'DermaDefault' )
		surface.SetTextColor( 255, 255, 255 )
		
		surface.SetTextPos( 4, 3 )
		surface.DrawText( #player.GetAll() .. '/' .. game.MaxPlayers() )
		
		surface.SetTextPos( 400 - surface.GetTextSize( GetHostName() ) / 2, 3 )
		surface.DrawText( GetHostName() )
		
		local time = os.date( '*t' )
		if time.hour <= 9 then time.hour = '0' .. time.hour end
		if time.min <= 9 then time.min = '0' .. time.min end
		
		time = time.hour .. ( ( CurTime() % 1 >= 0.5 ) and ':' or ' ' ) .. time.min
		
		surface.SetTextPos( 796 - surface.GetTextSize( time ), 3 )
		surface.DrawText( time )
		
		if self.CursorEnabled then
			surface.SetTextPos( 400 - surface.GetTextSize( 'Right click on player to see its options' ) / 2, h - 16 )
			surface.DrawText( 'Right click on player to see its options' )
		else
			surface.SetTextPos( 400 - surface.GetTextSize( 'Right click to enable cursor' ) / 2, h - 16 )
			surface.DrawText( 'Right click to enable cursor' )
		end
	end
	
	board.Think = function( self )
		if input.IsMouseDown( MOUSE_RIGHT ) and not self.CursorEnabled then
			self:MakePopup()
			self.CursorEnabled = true
			
			RunConsoleCommand( '-attack2' )
		end
	end
	
	board.players = vgui.Create( 'DPanelList', board )
	board.players:SetSize( 785, 550 )
	board.players:Center()
	board.players.Paint = nil
	board.players.Think = function( self )
		if self.PlayersCount ~= #player.GetAll() or self.ConnectingCount ~= #connecting or self.DisconnectedCount ~= #disconnected then
			self.PlayersCount = #player.GetAll()
			self.ConnectingCount = #connecting
			self.DisconnectedCount = #disconnected
			board:Update()
		end
	end
	
	board.Update = function()
		board.players:Clear()
		
		local admins, others = {}, {}
		for _, pl in pairs( player.GetAll() ) do
			if pl:IsAdmin() then table.insert( admins, pl )
			else table.insert( others, pl ) end
		end
		
		if #admins > 0 then
			board.players:AddItem( self:CreateHeader( 'Mingebags', false, Color( 255, 0, 0 ) ) )
			
			for _, a in pairs( admins ) do
				board.players:AddItem( self:CreatePlayerRow( a ) )
			end
		end
		
		if #others > 0 then
			board.players:AddItem( self:CreateHeader( 'Players', false, Color( 30, 205, 30 ) ) )
			
			for _, p in pairs( others ) do
				board.players:AddItem( self:CreatePlayerRow( p ) )
			end
		end
		
		if table.Count( connecting ) > 0 then
			board.players:AddItem( self:CreateHeader( 'Connecting', true, Color( 0, 100, 205 ) ) )
			
			for _, c in pairs( connecting ) do
				board.players:AddItem( self:CreatePlayerRowByInfo( NULL, c.sid, c.name, c.lastnick, c.lvl, c.rep ) )
			end
		end
		
		if table.Count( disconnected ) > 0 then
			board.players:AddItem( self:CreateHeader( 'Recently disconnected', true, Color( 0, 0, 0 ) ) )
			
			for _, c in pairs( disconnected ) do
				board.players:AddItem( self:CreatePlayerRowByInfo( nil, c.sid, c.name, nil, c.lvl, c.rep, c.reason ) )
			end
		end
		
		local e = vgui.Create( 'DPanel' )
			e:SetSize( 785, 8 )
			e.Paint = function( self, w, h )
				surface.SetDrawColor( lastheadercolor )
				surface.DrawRect( 0, 0, w, h )
			end
		board.players:AddItem( e )
	end
end

function GM:ScoreboardHide()
	if not board then return end
	
	board = board:Remove()
end