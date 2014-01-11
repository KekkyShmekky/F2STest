local color_yellow = Color( 255, 255, 0 )
local color_black = Color( 0, 0, 0, 200 )

surface.CreateFont( 'HUD', {
	font		= 'arial',
	size		= 17,
	weight		= 1000,
	bold		= true
} )

surface.CreateFont( 'HL2', {
	font		= 'halflife2',
	size		= 40
} )

surface.CreateFont( 'HL2_ICO', {
	font		= 'halflife2',
	size		= 52
} )

surface.CreateFont( 'CSS', {
	font		= 'csd',
	size		= 52
} )

surface.CreateFont( 'HL2MP', {
	font		= 'hl2mp',
	size		= 52
} )

surface.CreateFont( 'HL2_AMMO', {
	font		= 'halflife2',
	size		= 46
} )

local ammo =
{
	[ '357' ] = '\x71',
	[ '308' ] = '\x71',
	[ '.45 ACP' ] = '\x70',
	[ '40x60 grenade' ] = '\x74',
	machinegun = '\x72',
	buckshot = '\x73',
	ar2 = '\x75',
	ar2altfire = '\x7A',
	medkit = '\x2B',
	frag_grenade = '\x5F'
}

GM.Health = 0
GM.Armor = 0
GM.Ammo = 0
GM.WeaponSelectionAlpha = 0
GM.WeaponSelectionOpen = 0

GM.HUD_L_Height = 102

GM.BlockHUD =
{
	'CHudHealth',
	'CHudBattery',
	'CHudAmmo',
	'CHudWeaponSelection',
	'CHudCrosshair'
}

local grad = surface.GetTextureID( 'gui/center_gradient' )
local gradup = surface.GetTextureID( 'gui/gradient_up' )
local graddown = surface.GetTextureID( 'gui/gradient_down' )
local warning = Color( 255, 0, 0, 255 )
local reloadstat =
{
	ACT_VM_FIDGET,
	ACT_VM_RELOAD,
	ACT_VM_RELOAD_SILENCED,
	ACT_SHOTGUN_RELOAD_START,
	ACT_SHOTGUN_RELOAD_FINISH
}

function GM:VMSequenceUpdated( _, vm, _, new )
	if not IsValid( vm ) then return end
	
	if self.ShotgunReloading and vm:GetSequenceActivity( new ) ~= ACT_VM_RELOAD then self.ShotgunReloading = false end
	if vm:GetSequenceActivity( new ) == ACT_SHOTGUN_RELOAD_START then self.ShotgunReloading = true end
	
	if table.HasValue( reloadstat, vm:GetSequenceActivity( new ) ) then
		self.ReloadingInit = CurTime()
		self.ReloadingSequenceLen = vm:SequenceDuration() / vm:GetPlaybackRate()
		self.ReloadingSequence = self.ReloadingInit + self.ReloadingSequenceLen
	else
		self.ReloadingInit = CurTime()
		self.ReloadingSequenceLen = 0
		self.ReloadingSequence = self.ReloadingInit + self.ReloadingSequenceLen
	end
end

GM.Clip1 = 0
GM.Money = 0
GM.LiveScore = 0
GM.TotalScore = 0
GM.TargetScore = 0
function GM:RenderHUD()
	surface.SetAlphaMultiplier( 1 - math.max( self.LastDamaged + 0.3 - CurTime(), 0 ) * 2.9 )
	
	local ply = LocalPlayer()
	local w, h = 86, ScrH() - self.HUD_L_Height
	
	warning.a = math.abs( math.sin( CurTime() * 8 ) ) * 255
	
	local dest = ply:Armor() > 0 and 142 or 102
	self.HUD_L_Height = math.Approach( self.HUD_L_Height, dest, ( dest - self.HUD_L_Height ) * FrameTime() * 3 )
	
	dest = math.min( ply:Health(), 100 ) * 2.46
	self.Health = math.Approach( self.Health, dest, math.max( math.abs( dest - self.Health ), 20 ) * FrameTime() )
	
	dest = math.min( ply:Armor(), 100 ) * 2.46
	self.Armor = math.Approach( self.Armor, dest, math.max( math.abs( dest - self.Armor ), 20 ) * FrameTime() )
	
	self.Money = math.Approach( self.Money, ply:GetNWInt( 'money' ), FrameTime() * 10000 )
	self.LiveScore = math.Approach( self.LiveScore, ply:GetNWInt( 'livexp' ), FrameTime() * 10000 )
	self.TotalScore = math.Approach( self.TotalScore, ply:GetNWInt( 'xp' ), FrameTime() * 10000 )
	self.TargetScore = math.Approach( self.TargetScore, ply:GetNWInt( 'lvl' ) ^ 2 * 500, FrameTime() * 10000 )
	
	self:RenderFeed()	
	self:HUD3DY( -15 )
	
	draw.RoundedBoxEx( 10, w, h - 20, 128, 20, color_black, true, true, false, false )
	draw.RoundedBoxEx( 10, w, h, 256, ( self.Armor > 0 and 68 or 38 ), color_black, false, true, true, true )
	draw.RoundedBox( 10, w, 70, 200, 100, color_black )
	
	surface.SetFont( 'HUD' )
	surface.SetTextColor( color_yellow )
	surface.SetTextPos( w + 5, 75 )
	surface.DrawText( 'Money' )
	
	surface.SetTextPos( w + 5, h - 17 )
	surface.DrawText( 'VOICE: ' )
	
	local flick = true
	local text = not ply:GetNWBool( 'pubchan' ) and ply:Team() ~= 0 and 'TEAM' or 'PUBLIC'
	if self.ChanFlick and self.ChanFlick > CurTime() then flick = CurTime() % 0.2 >= 0.1 end
	
	if flick then
		surface.SetTextPos( w + 123 - surface.GetTextSize( text ), h - 17 )
		surface.DrawText( text )
	end
	
	if text ~= self.LastChanText then
		self.LastChanText = text
		self.ChanFlick = CurTime() + 0.8
	end
	
	surface.SetTextPos( w + 100, 75 )
	surface.DrawText( '$' .. math.floor( self.Money ) )
	
	surface.SetTextPos( w + 5, 105 )
	surface.DrawText( 'Hot XP' )
	
	surface.SetTextPos( w + 100, 105 )
	surface.DrawText( math.floor( self.LiveScore ) )
	
	surface.SetTextPos( w + 5, 120 )
	surface.DrawText( 'Total XP' )
	
	surface.SetTextPos( w + 100, 120 )
	surface.DrawText( math.floor( self.TotalScore ) .. ' / ' .. math.floor( self.TargetScore ) )
	
	surface.SetTextPos( w + 5, 150 )
	surface.DrawText( 'Level' )
	
	surface.SetTextPos( w + 100, 150 )
	surface.DrawText( math.floor( ply:GetNWInt( 'lvl' ) ) )
	
	
	surface.SetTextColor( ply:Health() > 30 and color_yellow or warning )
	surface.SetTextPos( w + 5, h + 2 )
	surface.DrawText( 'HEALTH' )
	
	if self.Armor > 0 then
		surface.SetTextColor( color_yellow )
		surface.SetTextPos( w + 5, h + 34 )
		surface.DrawText( 'SUIT' )
	end
	
	surface.SetDrawColor( ply:Health() > 30 and color_yellow or warning )
	surface.DrawRect( w + 5, h + 20, self.Health, 10 )
	
	if self.Armor > 0 then
		surface.SetDrawColor( color_yellow )
		surface.DrawRect( w + 5, h + 52, self.Armor, 10 )
	end
	
	if ply:Armor() > 100 then
		local a = math.Clamp( ply:Armor() - 100, 0, 100 ) * 2.48
		
		surface.SetTexture( grad )
		surface.DrawTexturedRectRotated( w + 3 + a / 2 + math.random( -2, 2 ), h + 57 + math.random( -2, 2 ), 30, a, 90 )
	end

	self:HUD3DY( 15 )
	
	w, h = ScrW() - 298, ScrH() - 78
	
	local wep = ply:GetActiveWeapon()
	local wepsel = false
	if IsValid( wep ) then		
		local pri = ply:GetAmmoCount( wep:GetPrimaryAmmoType() )
		local clip1 = wep:Clip1()
		
		local sec = wep:GetSecondaryAmmoType()
		local ico = ammo[ ( wep.Secondary or {} ).Ammo or '' ]
		if sec > -1 then
			draw.RoundedBox( 10, w + 180, h, 76, 38, color_black )
			
			if ico then
				local ar2 = sec == 2
				local sec = ply:GetAmmoCount( sec )
				
				surface.SetFont( ar2 and 'HL2_ICO' or 'HL2' )
				surface.SetTextColor( color_yellow )
				surface.SetTextPos( w + 184, h - ( ar2 and 5 or 1 ) )
				surface.DrawText( ico )
				
				surface.SetFont( 'HL2' )
				surface.SetTextPos( w + 234 - surface.GetTextSize( sec ) / 2, h - 3 )
				surface.DrawText( sec )
			end
			
			w = w - 86
		end
		
		surface.SetFont( 'HUD' )
		
		if clip1 == -1 then clip1 = pri end
		if wep.Primary and wep.Primary.ClipSize and wep:Clip1() ~= -1 then
			self.Clip1 = math.Approach( self.Clip1, math.min( clip1 / wep.Primary.ClipSize, 1 ), FrameTime() )
		else
			self.Clip1 = math.Approach( self.Clip1, math.min( clip1 / 100, 1 ), FrameTime() )
		end
		
		local problem = clip1 > 0 and not wep:GetNWBool( 'jammed' )
		if self.ReloadingSequence and self.ReloadingSequence > CurTime() then
			wepsel = true
			self.Clip1 = 1
			
			local prog = ( CurTime() - self.ReloadingInit ) / self.ReloadingSequenceLen
			
			draw.RoundedBox( 10, w, h, 256, 38, color_black )
			
			surface.SetTextColor( color_yellow )
			surface.SetTextPos( w + 5, h + 2 )
			surface.DrawText( 'RELOADING' )
			
			surface.SetDrawColor( 255, 255, 0, math.abs( math.sin( CurTime() * 8 ) ) * 255 )
			surface.DrawRect( w + 5, h + 20, 246 * prog, 10 )
			
			local tex = math.min( math.floor( prog * 100 + 3 ), 100 ) .. '%'
			surface.SetTextColor( 255 * ( 1 - prog ), 255 * prog, 0 )
			surface.SetTextPos( w + 252 - surface.GetTextSize( tex ), h + 2 )
			surface.DrawText( tex )
		elseif pri > 0 or clip1 >= 0 then
			wepsel = true
			self.ReloadingSequence = nil
			
			draw.RoundedBox( 10, w, h, 256, 38, color_black )
			
			surface.SetTextColor( problem and color_yellow or warning )
			surface.SetTextPos( w + 5, h + 2 )
			surface.DrawText( ( wep:GetNWBool( 'jammed' ) and 'JAMMED' or ( clip1 > 0 and 'AMMO' or 'EMPTY' ) ) .. ( wep:GetNWBool( 'onebullet' ) and ' +1' or '' ) )
			
			surface.SetDrawColor( problem and color_yellow or warning )
			surface.DrawRect( w + 5, h + 20, self.Clip1 * 236 + 10, 10 )
			
			if wep:Clip1() ~= -1 and pri ~= 0 then
				surface.SetTextColor( pri > wep.Primary.ClipSize / 2 and color_yellow or warning )
				surface.SetTextPos( w + 252 - surface.GetTextSize( pri ), h + 2 )
				surface.DrawText( pri )
			end
		end
		
		local w = ScrW()
		local h = h - 44
		draw.RoundedBoxEx( 10, w - 298, h, 81, 38, color_black, true, false, true, false )
		draw.RoundedBoxEx( 0, w - 210, h, 42, 38, color_black )
		draw.RoundedBoxEx( 0, w - 163, h, 66, 38, color_black )
		draw.RoundedBoxEx( 10, w - 92, h, 50, 38, color_black, false, true, false, true )
		
		surface.SetFont( 'HL2_ICO' )
		surface.SetTextColor( color_yellow )
		
		local nwep = wep
		local spec_ammo
		local x = w
		for _, w in pairs( ply:GetWeapons() ) do
			if w.Slot == math.abs( 1 - wep.Slot ) then nwep = w end
			if w.Slot == -1 then
				if w.FontOverride then surface.SetFont( w.FontOverride ) end
				
				surface.SetTextPos( x - 89 + ( w.PosOffset and w.PosOffset.x or 0 ), h - 14 + ( w.PosOffset and w.PosOffset.y or 0 ) )
				surface.DrawText( w.IconLetter )
				
				if w.Primary.Ammo ~= 'none' then spec_ammo = ply:GetAmmoCount( w.Primary.Ammo ) end
			end
		end
		
		surface.SetFont( nwep.FontOverride or 'HL2_ICO' )
		
		if IsValid( nwep ) and nwep.IconLetter then
			surface.SetTextPos( w - 294 + ( nwep.PosOffset and nwep.PosOffset.x or 0 ), h - ( nwep.FontOverride == 'CSS' and -3 or 18 ) + ( nwep.PosOffset and nwep.PosOffset.y or 0 ) )
			surface.DrawText( nwep.IconLetter )
		end
		
		surface.SetFont( 'HUD' )
		surface.SetTextPos( w - 161, h + 10 )
		surface.DrawText( 'Tool Gun' )
		
		if spec_ammo then
			surface.SetFont( 'Default' )
			surface.SetTextPos( w - 45 - surface.GetTextSize( spec_ammo ), h + 24 )
			surface.DrawText( spec_ammo )
		end
		
		local npri = ply:GetAmmoCount( nwep:GetPrimaryAmmoType() )
		if npri > -1 then
			surface.SetTextPos( w - 220 - surface.GetTextSize( npri ), h + 24 )
			surface.DrawText( npri )
		end
		
		surface.SetFont( 'HL2_AMMO' )
		
		local flick = true
		local ico = ammo[ ( wep.Primary or {} ).Ammo or '' ] or '\x72'
		if self.FireModeFlick and self.FireModeFlick + 0.75 > CurTime() then flick = CurTime() % 0.3 >= 0.15 end
		
		if ico and flick then
			surface.SetTextPos( w - 188 - surface.GetTextSize( ico ) / 2, h - ( ico == '\x73' and 12 or 5 ) )
			surface.DrawText( ico )
			
			local auto = wep.Primary.Automatic or wep:GetNWBool( 'burst' )
			if auto then
				surface.SetTextPos( w - 188 - surface.GetTextSize( ico ) / 2, h - 15 )
				surface.DrawText( ico )
				surface.SetTextPos( w - 188 - surface.GetTextSize( ico ) / 2, h + 5 )
				surface.DrawText( ico )
			end
			
			if self.LastFireModeAutomatic ~= auto then
				self.LastFireModeAutomatic = auto
				self.FireModeFlick = CurTime()
			end
			
			if self.LastFireModeLetter ~= ico then
				self.LastFireModeLetter = ico
				self.FireModeFlick = CurTime()
			end
			
			if ico == '\x73' then
				local text = wep:GetNWBool( 'pump' ) and 'PUMP' or 'SEMI'
				if self.LastFireModeText ~= text then
					self.LastFireModeText = text
					self.FireModeFlick = CurTime()
				end
				
				surface.SetFont( 'HUD' )
				surface.SetTextPos( w - 189 - surface.GetTextSize( text ) / 2, h + 18 )
				surface.DrawText( text )
			end
		end
	end
	
	local x, y = ScrW() / 2, ScrH() / 2
	if self.HitMarker and self.HitMarker > 0 then
		self.HitMarker = math.Approach( self.HitMarker, 0, FrameTime() * 5 )
		
		cam.Start2D()
		
		surface.SetAlphaMultiplier( self.HitMarker or 0 )
		surface.SetTexture( 0 )
		surface.SetDrawColor( 225, 225, 255 )
		surface.DrawTexturedRectRotated( x - 8, y + 8, 12, 2, 45 )
		surface.DrawTexturedRectRotated( x - 8, y - 8, 12, 2, -45 )
		surface.DrawTexturedRectRotated( x + 8, y + 8, 12, 2, -45 )
		surface.DrawTexturedRectRotated( x + 8, y - 8, 12, 2, 45 )
		
		cam.End2D()
	end
	
	surface.SetAlphaMultiplier( self.WeaponSelectionAlpha )
	
	local w = self.SelectedWeapon
	local before, after = {}, {}
	local post
	for _, e in pairs( ply:GetWeapons() ) do
		if post then table.insert( after, e ) end
		if e == w then post = true end
		if not post then table.insert( before, e ) end
	end
	
	self.StatOffset = math.Approach( self.StatOffset or 0, #before * 64 + 64, FrameTime() * 256 )
	self.WeaponSelectionAlpha = math.Approach( self.WeaponSelectionAlpha, ( self.WeaponSelectionOpen > CurTime() ) and 1 or 0, FrameTime() * 3 )
	
	if self.WeaponSelectionAlpha > 0 then
		surface.SetTexture( gradup )
		surface.SetDrawColor( 0, 0, 0, 225 )
		surface.DrawTexturedRect( x, y - 192, 116, 192 )
		surface.SetDrawColor( color_yellow )
		surface.DrawTexturedRect( x, y - 192, 2, 192 )
		surface.DrawTexturedRect( x + 116, y - 192, 2, 192 )
		
		surface.SetTexture( graddown )
		surface.SetDrawColor( 0, 0, 0, 225 )
		surface.DrawTexturedRect( x, y, 116, 192 )
		surface.SetDrawColor( color_yellow )
		surface.DrawTexturedRect( x, y, 2, 192 )
		surface.DrawTexturedRect( x + 116, y, 2, 192 )
		
		surface.DrawRect( x, y - 2, 16, 4 )
		
		local w = self.SelectedWeapon
		
		if IsValid( w ) and ( w.IconLetter or w:GetClass() == 'toolgun' ) then
			self:DrawWeaponIcon( w, x, y, true )
		end
		
		table.Reverse( before )
		
		for i, w in pairs( before ) do
			local ny = i * 64
			surface.SetAlphaMultiplier( math.Clamp( ( ny ) / 300, 0, 1 ) * self.WeaponSelectionAlpha )
			self:DrawWeaponIcon( w, x, y + ny - self.StatOffset )
		end
		
		for i, w in pairs( after ) do
			local ny = i * 42 + 24
			
			surface.SetAlphaMultiplier( math.Clamp( ( 200 - ny ) / 300, 0, 1 ) * self.WeaponSelectionAlpha )
			self:DrawWeaponIcon( w, x, y + ny )
		end
	end
	
	surface.SetAlphaMultiplier( 1 )
end

function GM:DrawWeaponIcon( w, x, y, adv )
	local eo = 0
	if not w.FontOverride and w.IconLetter == '\x26' then eo = -28 end
	
	surface.SetTextColor( ( w:GetNWBool( 'jammed' ) or w:Clip1() <= 0 ) and warning or color_yellow )
	
	if w:GetClass() == 'toolgun' then
		surface.SetFont( 'HUD' )
		
		local px, py = surface.GetTextSize( 'Tool Gun' )
		
		surface.SetTextPos( x + 62 - px * 0.5, y - py * 0.5 )
		surface.DrawText( 'Tool Gun' )
	elseif w.IconLetter then
		surface.SetFont( w.FontOverride or 'HL2_ICO' )
		surface.SetTextPos( x + 62 + ( w.PosOffset and w.PosOffset.x or 0 ) - surface.GetTextSize( w.IconLetter ) / 2 + eo, y - ( w.FontOverride == 'CSS' and 10 or 32 ) + ( w.PosOffset and w.PosOffset.y or 0 ) )
		surface.DrawText( w.IconLetter )
	end
	
	if not adv then return end
	
	local text = w.PrintName
	if #text > 15 then text = string.sub( w.PrintName, 1, 14 ) .. '...' end
	
	surface.SetFont( 'Default' )
	surface.SetTextPos( x + 7, y - 28 )
	surface.DrawText( text )
	
	if w.Primary then
		surface.SetFont( 'HUD' )
		
		if w.Primary.ClipSize > 0 then
			surface.SetTextPos( x + 7, y + 18 )
			surface.DrawText( w:Clip1() .. ( w:GetNWBool( 'onebullet' ) and ' +1' or '' ) )
		end
		
		if w.Primary.Ammo ~= 'none' then
			local text = LocalPlayer():GetAmmoCount( w.Primary.Ammo )
			
			surface.SetTextPos( x + 112 - surface.GetTextSize( text ), y + 18 )
			surface.DrawText( text )
		end
	end
end

function GM:HUDShouldDraw( type )
	if not table.HasValue( self.BlockHUD, type ) then return true end
end

function GM:PlayerBindPress( ply, bind, down )
	local w = ply:GetActiveWeapon()
	
	if down then
		if bind == '+menu_context' then
			net.Start( 'switch_chan' )
			net.SendToServer()
		end
		
		if string.sub( bind, 1, 4 ) == 'slot' then
			local slot = tonumber( string.sub( bind, 5, 5 ) )
			if slot == 3 then
				net.Start( 'firemode' )
				net.SendToServer()
				
				return true
			end
			
			for _, w in pairs( ply:GetWeapons() ) do
				if w.Slot and w.Slot + 1 == slot then
					RunConsoleCommand( 'use', w:GetClass() )
					break
				end
			end
			
			return true
		end
		
		if IsValid( w ) then
			if bind == 'invprev' and w.HandleZoom and w:HandleZoom( -1 ) then return true end
			if bind == 'invnext' and w.HandleZoom and w:HandleZoom( 1 ) then return true end
		end
		
		if bind == 'invprev' or bind == 'invnext' then
			self.WeaponSelectionOpen = CurTime() + 0.75
			self.WeaponSelectionTrigger = CurTime() + 0.75
			
			local stop
			for _, w in pairs( ( bind == 'invprev' ) and table.Reverse( ply:GetWeapons() ) or ply:GetWeapons() ) do
				if stop then
					self.SelectedWeapon = w
					break
				end
				
				if w == self.SelectedWeapon then stop = true end
			end
			
			return true
		end
	end
end

function GM:player_hurt( data )
	local lp = LocalPlayer()
	if Player( data.attacker ) == lp and Player( data.userid ) ~= lp then
		self.HitMarker = 1
		lp:EmitSound( 'effects/marker.wav', 40 )
	end
	
	if Player( data.userid ) == lp then
		self.LastDamaged = CurTime()
		surface.PlaySound( 'effects/hit.wav' )
	end
end

gameevent.Listen( 'player_hurt' )