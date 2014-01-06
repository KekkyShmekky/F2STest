AddCSLuaFile 'shared.lua'
AddCSLuaFile 'cl_hud.lua'
AddCSLuaFile 'cl_lens.lua'
AddCSLuaFile 'cl_menu.lua'
AddCSLuaFile 'cl_deathnotice.lua'
AddCSLuaFile 'cl_spawnmenu.lua'
AddCSLuaFile 'cl_legs.lua'
AddCSLuaFile 'cl_scoreboard.lua'

include 'clientdownload.lua'
include 'glon.lua'
include 'shared.lua'
include 'playerinfo.lua'

local defadv =
[[Press G on your keyboard to deploy special item:1:0:0
Press V on your keyboard to do melee attack:0:1:1
Use 3 at top of QWERTY keyboard to switch firemode:1:1:0
Think before you buy an attachment or weapon!:0:0:1
It's good to spawn more than one spawn beacon:0:1:1
Upper part of the sentry is invulnerable against damage:1:1:0
Sentry's ammo can be replenished by pressing E twice on the body:0:1:0
Buzzsaw can be picked up after it has finished cutting:0:1:0
Buzzsaw stops cutting if it recieves any damage:1:0:0
Tripmines can be toggled on and off by pressing E on it:0:1:0
It's a good idea to put tripmines in dark places:0.8:0:0
The laser of tripmine can only be seen by it's owner and teammates:0:0.5:1
You can switch betwen team and public voice chats by pressing C:0:1:0
Defibrillators can destroy sentries in a single discharge!!:1:0:0
Sentries are good for defending a base when you are away, but be careful! They have vulnerabilities!:0:0:1]]

--[[ TODO:
	add maniac role
	add acog backup sights
	add pickupable weapons
	
]]

f2s_deathtime = CreateConVar( 'f2s_deathtime', 5 )

local oldNetReceive = net.Receive
net.Receive = function( name, func, ... )
		util.AddNetworkString( name )
	return oldNetReceive( name, func, ... )
end

util.AddNetworkString 'buyammo_callback'
util.AddNetworkString 'buypart_callback'
util.AddNetworkString 'team_leave'
util.AddNetworkString 'teams_update'
util.AddNetworkString 'menu_open'
util.AddNetworkString 'connecting'
util.AddNetworkString 'disconnected'
util.AddNetworkString 'ping'

TEAMS = TEAMS or {}
freeindex = freeindex or {}
teamindex = teamindex or 1

net.Receive( 'ping', function( _, pl )
	local ctime = CurTime()
	if not pl.received_pong then
		pl.received_pong = true
		pl.SendPing = ctime + 0.5
		
		if pl:GetNWBool( 'timeout' ) then pl:SetNWBool( 'timeout', false ) end
	end
end )

net.Receive( 'switch_chan', function( _, pl ) pl:SetNWBool( 'pubchan', not pl:GetNWBool( 'pubchan' ) ) end )
net.Receive( 'team_leave', function( _, pl )
	local team = pl:Team()
	if team == 0 then return end
	
	for k, v in pairs( TEAMS ) do
		if v[1] == team then
			for _, p in pairs( player.GetAll() ) do
				p:ChatPrint( pl:Nick() .. ' has left "' .. k .. '"' )
			end
			
			break
		end
	end
	
	pl:SetTeam( 0 )
	
	net.Start( 'teams_update' )
		net.WriteTable( TEAMS )
	net.Send( player.GetAll() )
end )

net.Receive( 'transfer_money', function( _, pl )
	local targ = net.ReadEntity()
	local amount = net.ReadFloat()
	
	if IsValid( targ ) and targ:IsPlayer() and targ ~= pl then
		local from = GAMEMODE:GetItems( pl )
		local to = GAMEMODE:GetItems( targ )
		
		if ( from.money - amount ) < 0 then
			return pl:ChatPrint( 'You don\'t have enough money' )
		end
		
		pl:ChatPrint( 'You have sent $' .. amount .. ' to ' .. targ:Nick() )
		targ:ChatPrint( 'You have received $' .. amount .. ' from ' .. pl:Nick() )
		
		from.money = from.money - amount
		to.money = to.money + amount
	end
end )

net.Receive( 'team_invite', function( _, pl )
	local targ = net.ReadEntity()
	if IsValid( targ ) and targ:IsPlayer() and targ:GetNWInt( 'invite' ) == 0 and pl:Team() ~= 0 then
		targ:SetNWInt( 'invite', pl:Team() )
		targ:ChatPrint( 'You have been invited to "' .. team.GetName( pl:Team() ) .. '" by ' .. pl:Nick() )
		pl:ChatPrint( 'You have invited ' .. targ:Nick() .. ' to "' .. team.GetName( pl:Team() ) .. '"' )
		
		timer.Simple( 20, function() if IsValid( targ ) then targ:SetNWInt( 'invite', 0 ) end end )
	end
end )

net.Receive( 'team_kick', function( _, pl )
	local targ = net.ReadEntity()
	if IsValid( targ ) and targ ~= pl and targ:IsPlayer() and targ:Team() ~= 0 and pl:Team() ~= 0 and targ:Team() == pl:Team() and TEAMS[ team.GetName( pl:Team() ) ][2] == pl then
		for _, pl in pairs( player.GetAll() ) do
			pl:ChatPrint( targ:Nick() .. ' has been kicked out of "' .. team.GetName( pl:Team() ) .. '"' )
		end
		
		targ:SetTeam( 0 )
		
		net.Start( 'teams_update' )
			net.WriteTable( TEAMS )
		net.Send( player.GetAll() )
	end
end )

net.Receive( 'menu_mkteam', function( _, pl )
	local name = net.ReadString()
	if #name < 3 then return pl:ChatPrint( 'Team title is too short' ) end
	if pl:Team() ~= 0 then return pl:ChatPrint( 'You are already staying in a team' ) end	
	if TEAMS[ name ] then return pl:ChatPrint( 'Team with same title already exists' ) end
	local index = teamindex
	local torem
	if #freeindex > 0 then
		index, torem = table.Random( freeindex )
		table.remove( freeindex, torem )
	end
	
	local args = { index, name, Color( math.random( 1, 255 ), math.random( 1, 255 ), math.random( 1, 255 ) ), true }
		team.SetUp( unpack( args ) )
	
	TEAMS[ name ] = { index, pl, args }
	pl:SetTeam( index )
	
	for _, pl in pairs( player.GetAll() ) do
		pl:ChatPrint( 'Team "' .. name .. '" has been made' )
	end
	
	net.Start( 'menu_mkteam' )
		net.WriteTable( args )
	net.Send( player.GetAll() )
	
	if index == teamindex then teamindex = teamindex + 1 end
end )

net.Receive( 'menu_closed', function( _, pl )
	if pl.MenuCallback then
		pl:MenuCallback()
		pl.MenuCallback = nil
	end
end )

net.Receive( 'attachments', function( _, pl )
	local group = net.ReadFloat()
	local weapon = net.ReadFloat()
	local attachment = net.ReadString()
	
	local g = weapon == 2 and 's' or 'p'
	local items = GAMEMODE:GetItems( pl )
	
	if attachment == 'none' then
		items.groups[ g .. 'group' .. group ] = 'none'
	elseif table.HasValue( items.attachments, attachment ) then
		items.groups[ g .. 'group' .. group ] = attachment
	end
end )

net.Receive( 'menu_selectwep', function( _, pl )
	local items = GAMEMODE:GetItems( pl )
	local slot = net.ReadFloat()
	local wep = net.ReadString()
	local w = weapons.Get( wep )
	
	if not table.HasValue( items.avaliable, wep ) and w.Slot ~= -1 then return end
	
	if not w then return end
	if w.Slot ~= slot then return end
	
	if slot == 0 then items.primary = wep end
	if slot == 1 then items.secondary = wep end
	if slot == -1 then items.special = wep end
end )

net.Receive( 'menu_buyweapon', function( _, pl )
	local items = GAMEMODE:GetItems( pl )
	local item = net.ReadString()
	local wep = weapons.Get( item )
	
	if not wep then return end
	if not wep.Price then return end
	if wep.Slot ~= 0 and wep.Slot ~= 1 then return end
	
	if table.HasValue( items.avaliable, item ) then
		pl:ChatPrint( 'You have this weapon already!' )
	elseif wep.Level and items.lvl < wep.Level then
		pl:ChatPrint( 'This weapon is not avaliable on your XP level' )
	elseif items.money < wep.Price then
		pl:ChatPrint( 'You don\'t have enough money!' )
	else
		items.money = items.money - wep.Price
		table.insert( items.avaliable, item )
	end
end )

net.Receive( 'menu_buypart', function( _, pl )
	local part = net.ReadString()
	local item = GAMEMODE.Parts[ part ]
	local items = GAMEMODE:GetItems( pl )
	
	if not GAMEMODE.Parts[ part ] then return end
	if table.HasValue( items.attachments, part ) then
		pl:ChatPrint( 'You have this weapon part already' )
	elseif items.money < item[2] then
		pl:ChatPrint( 'You don\'t have enough money!' )
	else
		table.insert( items.attachments, part )
			items.money = items.money - item[2]
		
		net.Start( 'buypart_callback' )
			net.WriteString( part )
		net.Send( pl )
	end
end )

net.Receive( 'menu_buyammo', function( _, pl )
	local items = GAMEMODE:GetItems( pl )
	local clips = net.ReadString()
	local money = items.money
	
	if GAMEMODE.Ammo[ clips ] then
		if money - GAMEMODE.Ammo[ clips ][3] >= 0 then
			if ( items.ammocount[ clips ] + items.ammobuy[ clips ] ) < ( GAMEMODE.Ammo[ clips ][4] or 3000 ) then
				items.money = items.money - GAMEMODE.Ammo[ clips ][3]
				items.ammobuy[ clips ] = ( items.ammobuy[ clips ] or 0 ) + GAMEMODE.Ammo[ clips ][2]
				
				net.Start( 'buyammo_callback' )
					net.WriteString( clips )
					net.WriteFloat( pl:GetAmmoCount( clips ) + items.ammobuy[ clips ] )
				net.Send( pl )
			else
				pl:ChatPrint( 'You have these items overstocked' )
			end 
		else
			pl:ChatPrint( 'You don\'t have enough money!' )
		end
	end
end )

net.Receive( 'menu', function( _, pl )
	if pl.SpawnProtection == -1 then
		pl:Spawn()
	end
end )

net.Receive( 'firemode', function( _, pl )
	local w = pl:GetActiveWeapon()
	if IsValid( w ) and w.FireMode then w:FireMode() end
end )

net.Receive = oldNetReceive

local rep_timeout = {}
concommand.Add( 'f2s_rep', function( ply, _, arg )
	if not IsValid( ply ) then return end
	
	local act = arg[1]
	local tar = Player( arg[2] )
	local uid1 = ply:UniqueID()
	if tar == ply then return end
	if not IsValid( tar ) then return end
	if not rep_timeout[ uid1 ] then rep_timeout[ uid1 ] = {} end
	
	local uid2 = tar:UniqueID()
	
	if ( rep_timeout[ uid1 ][ uid2 ] or 0 ) > CurTime() then
			rep_timeout[ uid1 ][ uid2 ] = rep_timeout[ uid ][ uid2 ] + 1
		return ply:ChatPrint( 'Reputation actions are blocked (' .. math.ceil( rep_timeout[ uid1 ][ uid2 ] - CurTime() ) .. 's left)' )
	end
	
	local rep = math.max( math.ceil( ply:GetNWInt( 'rep' ) / 50 ), 1 )
	if act == 'add' then
		tar:SetNWInt( 'rep', tar:GetNWInt( 'rep' ) + rep )
		
		ply:ChatPrint( 'You\'ve given ' .. rep .. ' REP point(s) to ' .. tar:Nick() )
		tar:ChatPrint( 'You\'ve received ' .. rep .. ' REP point(s) from ' .. ply:Nick() )
	end
	
	if act == 'sub' then
		tar:SetNWInt( 'rep', tar:GetNWInt( 'rep' ) - rep )
		
		ply:ChatPrint( 'You\'ve token ' .. rep .. ' REP point(s) from ' .. tar:Nick() )
		tar:ChatPrint( 'You\'ve lost ' .. rep .. ' REP point(s) to ' .. ply:Nick() )
	end
	
	rep_timeout[ uid1 ][ uid2 ] = CurTime() + 60
end )

function GM:GetFallDamage( ply, vel )
	ply:EmitSound( 'npc/metropolice/gear' .. math.random( 1, 6 ) .. '.wav' )
	
	local dmg = ( vel - 340 ) * 0.227
	local ent = ply:GetGroundEntity()
	if IsValid( ent ) then
		local di = DamageInfo()
			di:SetDamageType( DMG_BLAST )
			di:SetDamage( dmg * 2.3 )
			di:SetAttacker( ply )
			di:SetInflictor( ply:GetActiveWeapon() )
		ent:TakeDamageInfo( di )
	end
	
	if ply:GetNWBool( 'maniac' ) then return 0 end
	return dmg
end

function GM:PlayerCanHearPlayersVoice( pl1, pl2 )
	if not pl2:GetNWBool( 'pubchan' ) and pl2:Team() ~= 0 then return self:IsFriendOf( pl1, pl2 ) end
	return true
end

GM.Items = {}
local precache = {}
function GM:GetItems( ply )
	if not precache[ ply ] then precache[ ply ] = ply:UniqueID() end
	if type( ply ) == 'Player' then ply = precache[ ply ] end
	local items = self.Items[ ply ] or {}
	
	items.xp = items.xp or 0
	items.lvl = items.lvl or 1
	items.rep = items.rep or 0
	items.money = items.money or 300
	items.avaliable = items.avaliable or { 'weapon_match' }
	items.attachments = items.attachments or {}
	items.groups = items.groups or {}
	
	items.primary = items.primary or ''
	items.secondary = items.secondary or 'weapon_match'
	items.special = items.special or 'special_frag'
	
	if not items.ammocount then items.ammocount = {} end
	for k, v in pairs( self.Ammo ) do
		items.ammocount[ k ] = items.ammocount[ k ] or v[2] * ( v[2] > 1 and 3 or 0 )
	end
	
	if not items.ammobuy then items.ammobuy = {} end
	for k, v in pairs( self.Ammo ) do
		items.ammobuy[ k ] = items.ammobuy[ k ] or 0
	end
	
		self.Items[ ply ] = items
	return items
end

function GM:OpenMenu( ply, tab )
	local inv = self:GetItems( ply )
	
	net.Start( 'menu_open' )
		net.WriteFloat( tab )
		net.WriteTable( inv )
	net.Send( ply )
end

local tailcall = false
function GM:PlayerLoadout( ply )
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply.AllowWeaponPickup = true
	
	local inv = self:GetItems( ply )
	for k, v in pairs( inv.groups ) do
		ply:SetNWString( k, v )
	end
	
	for k in pairs( inv.ammocount ) do
		inv.ammocount[ k ] = inv.ammocount[ k ] + inv.ammobuy[ k ]
		inv.ammobuy[ k ] = 0
		
		ply:SetAmmo( inv.ammocount[ k ], k )
	end
	
	if ply:GetNWBool( 'maniac' ) then
		ply:Give( 'chainsaw' )
	else
		if inv.primary then ply:Give( inv.primary ) end
		ply:Give( inv.secondary )
		ply:Give( inv.special )
		ply:Give( 'toolgun' )
		ply:SetNWString( 'special', inv.special )
		
		local w = ply:GetWeapon( inv.secondary )
		if not IsValid( w ) and not tailcall then
			tailcall = true
			inv.secondary = 'weapon_match'
			
			return self:PlayerLoadout( ply )
		elseif not IsValid( w ) then
			ErrorNoHalt( '[F2S:Classic] WARNING #1 (PLAYER HAS NO SECONDARY WEAPON! ' .. ply:Nick() .. ')\n' )
		end
	end
	
	ply.AllowWeaponPickup = false
end

function GM:PlayerSwitchWeapon( ply, old, new )
	if IsValid( new ) and IsValid( old ) then new.OldWeapon = old:GetClass() end
end

function GM:ShowHelp( ply )
	local inv = ply:GetNWInt( 'invite' )
	if inv ~= 0 then
		for k, v in pairs( TEAMS ) do
			if v[1] == inv then
				ply:SetTeam( inv )
				ply:SetNWInt( 'invite', 0 )
				
				for _, pl in pairs( player.GetAll() ) do
					pl:ChatPrint( ply:Nick() .. ' has joined "' .. k .. '"' )
				end
				
				return
			end
		end
	end
	
	self:OpenMenu( ply, 1 )
end

function GM:ShowTeam( ply )
	if ply:GetNWInt( 'invite' ) ~= 0 then return ply:SetNWInt( 'invite', 0 ) end
	
	self:OpenMenu( ply, 2 )
end

function GM:ShowSpare1( ply )
	self:OpenMenu( ply, 3 )
end

function GM:ShowSpare2( ply )
	self:OpenMenu( ply, 4 )
end

function GM:Think()
	self:BulletsThink()
	
	local ctime = CurTime()
	if ( self.NextWeatherUpdate or 0 ) < ctime then
		self.NextWeatherUpdate = ctime + math.random( 90, 710 )
		self.Weather = math.random( 0, 1 )
		
		local sun = ents.FindByClass( 'env_sun' )[1]
		if IsValid( sun ) then
			if self.Weather == WEATHER_RAIN then
				sun:Fire( 'TurnOff' )
			else
				sun:Fire( 'TurnOn' )
			end
		end
		
		umsg.Start( 'weather' )
			umsg.Short( self.Weather )
		umsg.End()
	end
	
	if self.Weather == WEATHER_RAIN then
		if ( self.NextThunder or 0 ) < ctime then
			self.NextThunder = ctime + math.random( 10, 40 )
			
			umsg.Start( 'thunder' )
			umsg.End()
		end
		
		if ( self.NextWind or 0 ) < ctime then
			self.NextWind = ctime + math.random( 7, 71 )
			self.WindDir = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 )
			
			umsg.Start( 'winddir' )
				umsg.Vector( self.WindDir )
			umsg.End()
		end
	elseif self.WindDir:Length() > 0 then
		self.WindDir = Vector()
		
		umsg.Start( 'winddir' )
			umsg.Vector( self.WindDir )
		umsg.End()
	end
	
	if ( self.NextTeamUpdate or 0 ) < ctime then
		self.NextTeamUpdate = ctime + 1
		
		for k, v in pairs( TEAMS ) do
			if #team.GetPlayers( v[1] ) == 0 then
				for _, pl in pairs( player.GetAll() ) do
					pl:ChatPrint( 'Team "' .. k .. '" is empty, removing...' )
				end
				
				table.insert( freeindex, v[1] )
				TEAMS[ k ] = nil
				
				break
			end
			
			if not IsValid( v[2] ) or v[2]:Team() ~= v[1] then
				local leaders = {}
				for _, pl in pairs( player.GetAll() ) do
					if pl:Team() == v[1] then table.insert( leaders, pl ) end
				end
				
				if #leaders > 0 then
					v[2] = table.Random( leaders )
					
					for _, pl in pairs( player.GetAll() ) do
						pl:ChatPrint( v[2]:Nick() .. ' has become the leader of "' .. k .. '"' )
					end
					
					break
				end
			end
		end
	end
	
	if not self.ItemsLoaded then
		self.ItemsLoaded = true
		
		local info = file.Read( 'f2s_classic.txt', 'DATA' )
		if type( info ) ~= 'string' then
			ErrorNoHalt( '[F2S: Classic] WARNING LEVEL #1 (f2s_classic.txt contents are not a string)\n' )
		else
			local ok, ret = pcall( glon.decode, info )
			if ok and type( ret ) == 'table' then
				self.Items = ret
			elseif not ok then
				ErrorNoHalt( '[F2S: Classic] FATAL ERROR LEVEL #1 (glon.decode failed)\n' )
			else
				ErrorNoHalt( '[F2S: Classic] FATAL ERROR LEVEL #1 (glon.decode returned NOT A TABLE)\n' )
			end
		end
	end
	
	if ( self.NextAdvert or 0 ) < ctime then
		self.NextAdvert = ctime + 10
		
		local line = table.Random( ( file.Read( 'adverts.txt', 'DATA' ) or defadv ):Split( '\n' ) ):Split( ':' )
		
		umsg.Start( 'advert' )
			umsg.String( line[1] )
			umsg.Short( tonumber( line[2] ) * 255 )
			umsg.Short( tonumber( line[3] ) * 255 )
			umsg.Short( tonumber( line[4] ) * 255 )
		umsg.End()
	end
	
	for _, pl in pairs( player.GetAll() ) do
		if pl.SendPing and not pl.received_pong and not pl:GetNWBool( 'timeout' ) and ( ctime - pl.SendPing ) >= 0 then pl:SetNWBool( 'timeout', true ) end
		if not pl:IsBot() and ( pl.SendPing or 0 ) < ctime then
			pl.SendPing = ctime + 1
			pl.received_pong = false
			
			net.Start( 'ping' )
			net.Send( pl )
		end
		
		if not pl:Alive() then continue end
		
		local check = -math.random( 3000, 3500 )
		local inv = self:GetItems( pl )
		if pl:GetNWInt( 'xp', check ) == check then pl:SetNWInt( 'xp', inv.xp ) end
		if pl:GetNWInt( 'lvl', check ) == check then pl:SetNWInt( 'lvl', inv.lvl ) end
		if pl:GetNWInt( 'rep', check ) == check then pl:SetNWInt( 'rep', inv.rep ) end
		if pl:GetNWInt( 'money' ) ~= inv.money then pl:SetNWInt( 'money', inv.money ) end
		
		if pl:Armor() > 100 and ( pl.ArmorOverflow or 0 ) < ctime then
			pl:SetArmor( pl:Armor() - 1 )
			pl.ArmorOverflow = ctime + 0.2
		end
		
		local w = pl:GetActiveWeapon()
		if IsValid( w ) then pl.LastWeapon = w:GetClass() end
		
		if pl.StreaksTime and pl.StreaksTime < ctime and pl.StreaksTime > ctime - 1 and pl:GetNWInt( 'livexp' ) > 0 then
			inv.money = inv.money + pl:GetNWInt( 'livexp' ) * 0.1
			
			pl:SetNWInt( 'xp', pl:GetNWInt( 'xp' ) + pl:GetNWInt( 'livexp' ) )
			pl:SetNWInt( 'livexp', 0 )
			pl:SendLua( 'surface.PlaySound("effects/exp.mp3")' )
		end
		
		local nextlvl = pl:GetNWInt( 'lvl' ) ^ 2 * 500
		if pl:GetNWInt( 'xp' ) > nextlvl then
			pl:SetNWInt( 'xp', pl:GetNWInt( 'xp' ) - nextlvl )
			pl:SetNWInt( 'lvl', pl:GetNWInt( 'lvl' ) + 1 )
			pl:SendLua( 'surface.PlaySound("effects/lvl.mp3")' )
			pl:SetHealth( 100 )
			pl:SetArmor( 250 )
			
			inv.lvl = pl:GetNWInt( 'lvl' )
			inv.money = inv.money + pl:GetNWInt( 'lvl' ) * 250
			
			local contents = {}
			for _, e in pairs( weapons.GetList() ) do
				if e.Level == pl:GetNWInt( 'lvl' ) then
					table.insert( contents, e.PrintName )
				end
			end
			
			umsg.Start( 'feed', pl )
				umsg.String( 'LEVEL UP! ' .. pl:GetNWInt( 'lvl' ) )
				if #contents > 0 then umsg.String( table.concat( contents, ', ' ) .. ( #contents > 1 and ' are' or ' is' ) .. ' now avaliable!' ) end
			umsg.End()
			
			self:ShutDown()
		end
		
		local hp, arm = pl:Health(), pl:Armor()
		if pl.LastHealth ~= hp then
			if ( pl.LastHealth or 0 ) > hp then
				pl.NextHeal = ctime + 5
				pl.HealRate = 1
				pl.MaxHealth = math.random( 81, 96 )
			end
			
			pl.LastHealth = hp
		end
		
		if pl:GetNWBool( 'maniac' ) then
			if ( pl.Loss or 0 ) < CurTime() then
				pl.Loss = CurTime() + 1
				pl.LossRate = math.min( ( pl.LossRate or 0 ) + 0.2, 10 )
				
				if pl:Health() <= 1 then
					local dmg = DamageInfo()
						dmg:SetDamage( 10 )
						dmg:SetAttacker( pl )
						dmg:SetInflictor( pl:GetActiveWeapon() )
					pl:TakeDamageInfo( dmg )
				else
					pl:SetHealth( pl:Health() - pl.LossRate )
				end
			end
		else
			if pl.HealRate and pl.NextHeal and pl.NextHeal < ctime and pl:Health() < ( pl.MaxHealth or 80 ) then
				pl.HealRate = math.max( pl.HealRate * 0.9, 0.5 )
				pl.NextHeal = ctime + pl.HealRate * 5
				pl:SetHealth( pl:Health() + 1 )
			end
		end
		
		
		if pl.LastArmor ~= arm then
			if ( pl.LastArmor or 0 ) > arm then
				pl.NextCharge = ctime + 2
				pl.ChargeRate = 1
			end
			
			pl.LastArmor = arm
		end
		
		if not pl:GetNWBool( 'maniac' ) and pl.ChargeRate and pl.NextCharge and pl.NextCharge < ctime and pl:Armor() < 100 then
			pl.ChargeRate = pl.ChargeRate * 0.9
			pl.NextCharge = ctime + pl.ChargeRate * 1
			pl:SetArmor( pl:Armor() + 1 )
		end
	end
end

function GM:PlayerDeathThink( ply )
	if ply.DeathTime and ply.DeathTime + f2s_deathtime:GetFloat() < CurTime() and ply:KeyDown( IN_JUMP ) then ply:Spawn() end
end

local function GetStreaksUMSGName( num )
	if num == 2 then return 'DOUBLE KILL 200'
	elseif num == 3 then return 'TRIPPLE KILL 300'
	elseif num == 4 then return 'QUADRO KILL 400'
	elseif num == 5 then return 'PENTA KILL 500'
	elseif num == 6 then return 'HEXA KILL 600'
	else return 'RAMPAGE 1000' end
end

function GM:DispatchKill( ent, ply )
	ply.Streaks = ( ply.StreaksTime or 0 ) > CurTime() and ply.Streaks + 1 or 0
	ply.StreaksTime = CurTime() + 6
	
	if ent:IsPlayer() then ent:AddDeaths( 1 ) end
	if ply:IsPlayer() then ply:AddFrags( 1 ) end
	
	if ply.Streaks > 6 and not ply:GetNWBool( 'highvalue' ) then
		ply:SetNWBool( 'highvalue', true )
		
		umsg.Start( 'feed' )
			umsg.String( string.upper( ply:Nick() ) .. ' BECAME A NEW HIGH VALUE TARGET' )
		umsg.End()
	end
	
	local helper
	if IsValid( ent.SubAttacker ) and ent.SubAttacker:IsPlayer() then
		--helper = ent.SubAttacker
		--helper:SetNWInt( 'livexp', helper:GetNWInt( 'livexp' ) + 70 )
	end
	
	ply:SetNWInt( 'livexp', ply:GetNWInt( 'livexp' ) + 100 )
	
	if ent.LastHeadshot then ply:SetNWInt( 'livexp', ply:GetNWInt( 'livexp' ) + 50 ) end
	if ply.Streaks > 0 then ply:SetNWInt( 'livexp', ply:GetNWInt( 'livexp' ) + ( ( ply.Streaks > 6 and 10 or ply.Streaks ) * 100 ) ) end
	
	if ent:GetClass() == 'npc_antlionguard' or ent:GetNWBool( 'highvalue' ) then		
		umsg.Start( 'feed', ply )
			umsg.String( 'HIGH VALUE TARGET KILLED 5000' )
			if ent.LastHeadshot then umsg.String( 'HEADSHOT 50' )
			elseif ply.Streaks > 0 then umsg.String( GetStreaksUMSGName( ply:GetNWBool( 'highvalue' ) and 10 or ply.Streaks ) ) end
		umsg.End()
		
		if IsValid( helper ) and helper:IsPlayer() then
			umsg.Start( 'feed', ply )
				umsg.String( 'HIGH VALUE TARGET KILL ASSIST 3500' )
			umsg.End()
			
			ply:SetNWInt( 'livexp', ply:GetNWInt( 'livexp' ) + 3400 )
		end
		
		ply:SetNWInt( 'livexp', ply:GetNWInt( 'livexp' ) + 4900 )
		
		self:GetItems( ply ).money = self:GetItems( ply ).money + 1000
	else
		umsg.Start( 'feed', ply )
			umsg.String( 'ENEMY KILLED 100' )
			if ent.LastHeadshot then umsg.String( 'HEADSHOT 50' )
			elseif ply.Streaks > 0 then umsg.String( GetStreaksUMSGName( ply:GetNWBool( 'highvalue' ) and 10 or ply.Streaks ) ) end
		umsg.End()
		
		if IsValid( helper ) and helper:IsPlayer() then
			umsg.Start( 'feed', ply )
				umsg.String( 'KILL ASSIST 70' )
			umsg.End()
			
			ply:SetNWInt( 'livexp', ply:GetNWInt( 'livexp' ) + 70 )
		end
		
		self:GetItems( ply ).money = self:GetItems( ply ).money + 70 * math.max( ply.Streaks, 1 )
	end
	
	local inv = self:GetItems( ply )
	if not inv.firstprey and not table.HasValue( inv.avaliable, 'weapon_mp7' ) then
		inv.firstprey = true
		
		umsg.Start( 'feed', ply )
			umsg.String( 'FIRST PREY KILL' )
			umsg.String( 'MP7 was added to your inventory' )
		umsg.End()
		
		table.insert( inv.avaliable, 'weapon_mp7' )
	end
end

function GM:OnNPCKilled( npc, inf, killa )
	self.BaseClass:OnNPCKilled( npc, inf, killa )
	
	if inf:IsPlayer() then
		killa = inf
		inf = killa:GetOwner()
	end
	
	if IsValid( killa ) and killa:IsPlayer() then
		self:DispatchKill( npc, killa )
	end
end

function GM:PlayerHurt( ply )
	local mdl = self:CheckModel( ply:GetModel() )
	local sound
	
	if mdl == 'combine' then
		sound = string.format( 'npc/metropolice/pain%i.wav', math.random( 1, 4 ) )
	elseif mdl == 'female' then
		sound = string.format( 'vo/npc/female01/pain0%i.wav', math.random( 1, 9 ) )
	elseif mdl == 'male' then
		sound = string.format( 'vo/npc/male01/pain0%i.wav', math.random( 2, 6 ) )
	elseif mdl == 'zombie' then
		sound = string.format( 'npc/zombie/zombie_pain%i.wav', math.random( 1, 6 ) )
	end
	
	if sound then ply:EmitSound( sound, SNDLVL_IDLE ) end
end

function GM:DoPlayerDeath( ply )
	if not IsValid( ply.RagdollEntity ) then
		local rent = ents.Create( 'prop_ragdoll' )
			rent:SetPos( ply:GetPos() )
			rent:SetAngles( ply:GetAngles() )
			rent:SetModel( ply:GetModel() )			
			rent:Spawn()
			rent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			rent:Activate()
			
			local v = ply:GetVelocity() * 0.3
			for i = 0, rent:GetPhysicsObjectCount() - 1 do
				local bone = rent:GetPhysicsObjectNum( i )
				if IsValid( bone ) then
					local pos, ang = ply:GetBonePosition( rent:TranslatePhysBoneToBone( i ) )
					if pos and ang then
						bone:SetPos( pos )
						bone:SetAngles( ang )
					end
					
					bone:SetVelocity( v )
				end
			end
			
		ply.RagdollEntity = rent
		ply.Loss = 0
		ply.LossRate = 0
		
		rent:SetNWBool( 'headshot', ply.LastHeadshot )
		rent:SetNWEntity( 'player', ply )
	end
end

function GM:PlayerDeath( ply, inf, killa )
	local wep = weapons.Get( ply.LastWeapon or '' )
	if wep and wep.WorldModel then
		local fake = ents.Create( 'prop_physics' )
			fake:SetPos( ply:GetShootPos() )
			fake:SetAngles( ply:GetAngles() )
			fake:SetModel( wep.WorldModel )
			fake:Spawn()
			fake:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			
		if IsValid( fake:GetPhysicsObject() ) then
			fake:GetPhysicsObject():SetVelocity( ply:GetAimVector() * 64 + ply:GetVelocity() * 3 )
		end
		
		timer.Simple( 5, function() if IsValid( fake ) then
			fake:SetKeyValue( 'targetname', 'fake' )
			
			local dslv = ents.Create( 'env_entity_dissolver' )
				dslv:Spawn()
				dslv:SetKeyValue( 'dissolvetype', 3 )
				dslv:Fire( 'Dissolve', 'fake' )
			fake:DeleteOnRemove( dslv )
		end end )
	end
	
	if inf:IsPlayer() then
		local rinf = killa
		killa = inf
		inf = rinf
	end
	
	local mdl = self:CheckModel( ply:GetModel() )
	
	if mdl == 'combine' then
		ply:EmitSound( string.format( 'npc/metropolice/die%i.wav', math.random( 1, 4 ) ), SNDLVL_IDLE )
	elseif mdl == 'female' then
		ply:EmitSound( string.format( 'vo/npc/female01/moan0%i.wav', math.random( 1, 5 ) ), SNDLVL_IDLE )
	elseif mdl == 'male' then
		ply:EmitSound( string.format( 'vo/npc/male01/moan0%i.wav', math.random( 1, 5 ) ), SNDLVL_IDLE )
	elseif mdl == 'zombie' then
		ply:EmitSound( string.format( 'npc/zombie/zombie_die%i.wav', math.random( 1, 3 ) ), SNDLVL_IDLE )
	end
	
	local items = self:GetItems( ply )	
	for k in pairs( items.groups ) do
		ply:SetNWString( k, 'none' )
	end
	
	self.BaseClass:PlayerDeath( ply, inf, killa )
	
	ply:SpectateEntity( ply.RagdollEntity )
	ply:Spectate( OBS_MODE_CHASE )
	ply:SetNWEntity( 'killer', killa )
	
	if IsValid( killa ) and killa:IsPlayer() and not self:IsFriendOf( ply, killa ) then
		self:DispatchKill( ply, killa )
	end
	
	umsg.Start( 'death', ply )
		umsg.Float( f2s_deathtime:GetFloat() )
	umsg.End()
	
	if ply:GetNWBool( 'highvalue' ) then ply:SetNWBool( 'highvalue', false ) end
	if ply:GetNWBool( 'maniac' ) then ply:SetNWBool( 'maniac', false ) end
	
	ply.Helper = nil
	ply.ActualKiller = nil
	ply.DeathTime = CurTime()
end

function GM:PlayerDisconnected( ply )
	if IsValid( ply.RagdollEntity ) then ply.RagdollEntity:Remove() end
	local items = self:GetItems( ply )
		items.xp = ply:GetNWInt( 'xp' ) + ply:GetNWInt( 'livexp' )
		items.lvl = ply:GetNWInt( 'lvl' )
		items.rep = ply:GetNWInt( 'rep' )
	
	if ply:Alive() then
		for k, v in pairs( items.ammocount ) do
			items.ammocount[ k ] = ply:GetAmmoCount( k ) + items.ammobuy[ k ]
			items.ammobuy[ k ] = 0
		end
	end
	
	for _, e in pairs( ents.GetAll() ) do
		if e:GetNWEntity( 'owner' ) == ply then e:Remove() end
	end
	
	for k in pairs( precache ) do
		if k == ply then precache[ ply ] = nil end
	end
	
	if type( self.Items ) == 'table' then
		local ok, ret = pcall( glon.encode, self.Items )
		if ok and type( ret ) == 'string' then
			file.Write( 'f2s_classic.txt', ret )
		elseif not ok then
			ErrorNoHalt( '[F2S: Classic] FATAL ERROR LEVEL #1 (glon.encode failed)\n' )
		else
			ErrorNoHalt( '[F2S: Classic] FATAL ERROR LEVEL #1 (glon.encode returned NOT A STRING!)\n' )
		end
	else
		ErrorNoHalt( '[F2S: Classic] FATAL ERROR LEVEL #2 (GAMEMODE.Items is not table!)\n' )
	end
end

function GM:ShutDown()
	if type( self.Items ) == 'table' then
		for _, pl in pairs( player.GetAll() ) do
			if pl:Alive() then
				local items = self:GetItems( pl )
					items.xp = pl:GetNWInt( 'xp' ) + pl:GetNWInt( 'livexp' )
					items.lvl = pl:GetNWInt( 'lvl' )
				
				for k, v in pairs( items.ammocount ) do
					items.ammocount[ k ] = pl:GetAmmoCount( k ) + items.ammobuy[ k ]
					items.ammobuy[ k ] = 0
				end
			end
		end
		
		local ok, ret = pcall( glon.encode, self.Items )
		if ok and type( ret ) == 'string' then
			file.Write( 'f2s_classic.txt', ret )
		elseif not ok then
			ErrorNoHalt( '[F2S: Classic] FATAL ERROR LEVEL #1 (glon.encode failed)\n' )
		else
			ErrorNoHalt( '[F2S: Classic] FATAL ERROR LEVEL #1 (glon.encode returned NOT A STRING!)\n' )
		end
	else
		ErrorNoHalt( '[F2S: Classic] FATAL ERROR LEVEL #2 (GAMEMODE.Items is not table!)\n' )
	end
end

function GM:PlayerInitialSpawn( ply )	
	self:OpenMenu( ply, 1 )
	ply:SetTeam( 0 )
	ply.SpawnProtection = -1
	ply.InitialSpawn = true
end

function GM:CanPlayerSuicide( ply )
	return true
end

function GM:PlayerSpawn( ply )
	if ply.InitialSpawn then
		ply.InitialSpawn = false
		
		ply:Spectate( OBS_MODE_CHASE )
		ply:SpectateEntity( table.Random( player.GetAll() ) )
		ply:SetNWInt( 'xp', self:GetItems( ply ).xp )
		ply:SetNWInt( 'lvl', self:GetItems( ply ).lvl )
		ply:SetNWInt( 'money', self:GetItems( ply ).money )
		ply:SetNWInt( 'rep', self:GetItems( ply ).rep )
	else
		self.BaseClass:PlayerSpawn( ply )
		
		ply:UnSpectate()
		ply:SetArmor( 100 )
		
		local points = {}
		for _, e in pairs( ents.FindByClass( 'sent_radar' ) ) do
			if e:GetOwner() == ply then
				local tr = util.TraceLine( {
					start = e:GetPos() + e:GetAngles():Up() * 5,
					endpos = e:GetPos() + e:GetAngles():Up() * 100,
					filter = e
				} )
				
				if not tr.Hit then
					table.insert( points, e )
				end
			end
		end
		
		if #points > 0 then
			local spot = table.Random( points )
			
			ply.SpawnProtection = CurTime() + 1
			ply:SetPos( spot:GetPos() - ( spot:GetAngles():Up().z < 0 and Vector( 0, 0, 95 ) or Vector() ) )
			ply:ChatPrint( 'You are protected just for 1 second after spawning from spawn beacon' )
		else
			ply.SpawnProtection = CurTime() + 4
		end
		
		if IsValid( ply:GetHands() ) then ply:GetHands():Remove() end
		
		local hands = ents.Create( 'gmod_hands' )
		if IsValid( hands ) then
			hands:DoSetup( ply )
			
			local ov = player_manager.TranslatePlayerHands( ply:GetInfo( 'cl_playermodel' ) )
				hands:SetModel( ov.model )
				hands:SetSkin( ov.skin )
				hands:SetBodyGroups( ov.body )
				hands:Spawn()
		end
		
		if ply:GetNWBool( 'maniac' ) then
			ply:SetNWBool( 'highvalue', true )
			ply:SetModel( 'models/player/zombie_soldier.mdl' )
			ply:SetWalkSpeed( 230 )
			ply:SetRunSpeed( 370 )
		else
			ply:SetWalkSpeed( 200 )
			ply:SetRunSpeed( 350 )
		end
		
		ply:SetCrouchedWalkSpeed( 0.4 )
		ply:SetWalkSpeed( 200 )
		ply:SetRunSpeed( 350 )
		ply.LastHeadshot = false
	end
	
	umsg.Start( 'weather', ply )
		umsg.Short( self.Weather )
	umsg.End()
	
	if self.Weather == WEATHER_RAIN then
		umsg.Start( 'winddir', ply )
			umsg.Vector( self.WindDir )
		umsg.End()
	end
	
	net.Start( 'teams_update' )
		net.WriteTable( TEAMS )
	net.Send( ply )
	
	if IsValid( ply.RagdollEntity ) then ply.RagdollEntity:Remove() end
end

function GM:PlayerCanPickupItem( ply )
	if ply.AllowWeaponPickup then return true end
	return false
end

function GM:PlayerCanPickupWeapon( ply )
	if ply.AllowWeaponPickup then return true end
	return false
end

local mask = bit.band( MASK_SHOT, bit.bnot( CONTENTS_WINDOW ) )
function GM:EntityTakeDamage( ent, dmg )
	if ent.SpawnProtection == -1 or ent.SpawnProtection and ent.SpawnProtection > CurTime() then dmg:SetDamage( 0 ) end
	
	local a = dmg:GetAttacker()
	if IsValid( a ) and a:GetClass() == 'npc_grenade_frag' then
		dmg:SetInflictor( a )
		
		local owner = a:GetNWEntity( 'owner', a:GetOwner() )
		if IsValid( owner ) then dmg:SetAttacker( a:GetNWEntity( 'owner', a:GetOwner() ) ) end
		
		dmg:ScaleDamage( 3 )
	end
	
	if IsValid( a ) and a:IsPlayer() and ent:IsPlayer() and not self:IsFriendOf( ent, a ) and dmg:GetDamageType() ~= DMG_BLAST then
		for _, pl in pairs( player.GetAll() ) do
			if self:IsFriendOf( a, pl ) then
				umsg.Start( 'spot', pl )
					umsg.Entity( ent )
				umsg.End()
			end
		end
	end
	
	if IsValid( a ) and ( a.SpawnProtection == -1 or a.SpawnProtection and a.SpawnProtection > CurTime() ) then return dmg:SetDamage( 0 ) end
	if IsValid( ent.MainAttacker ) and ent.MainAttacker ~= a then ent.SubAttacker = ent.MainAttacker end
		ent.MainAttacker = a
end

function GM:ScaleNPCDamage( ent, group, dmg )
	local a = dmg:GetAttacker()
	if a ~= ent.ActualKiller then
		ent.Helper = ent.ActualKiller
		ent.ActualKiller = a
	end
	
	dmg:ScaleDamage( 2 )
	
	local inf = dmg:GetInflictor()
	if IsValid( inf ) then
		if inf:GetClass() == 'crossbow_bolt' then dmg:SetDamage( 250 )
		elseif inf:GetClass() == 'grenade_ar2' and inf.UnderPower then dmg:ScaleDamage( 0.25 ) else dmg:ScaleDamage( 1 ) end
	end
	
	ent.LastHeadshot = group == HITGROUP_HEAD
	
	-- bee eef three
	if group == HITGROUP_HEAD and math.random( 1, 5 ) ~= 3 then dmg:ScaleDamage( 4 )
	elseif group == HITGROUP_LEFTLEG or group == HITGROUP_RIGHTLEG then dmg:ScaleDamage( 0.5 )
	elseif group == HITGROUP_LEFTARM or group == HITGROUP_RIGHTARM then dmg:ScaleDamage( 0.25 )
	end
	
	local att = dmg:GetAttacker()
	if IsValid( att ) and att:IsPlayer() and ent:IsPlayer() and self:IsFriendOf( att, ent ) and ent ~= att then dmg:ScaleDamage( 0.01 ) end
	if att == ent then dmg:ScaleDamage( 2.5 ) end
end

function GM:ScalePlayerDamage( ent, group, dmg )	
		dmg:ScaleDamage( 2 )
	self:ScaleNPCDamage( ent, group, dmg )
end