gameevent.Listen( 'player_spawn' )
gameevent.Listen( 'player_connect' )
gameevent.Listen( 'player_disconnect' )

local EV_interact = evolve and true
local connecting = {}

function GM:player_connect( data )
	local struct = { name = data.name, sid = data.networkid }
	local uid = util.CRC( 'gm_' .. data.networkid .. '_gm' )
	local items = self.Items[ uid ]
	if items then
		struct.lvl = items.lvl
		struct.rep = items.rep
	end
	
	if EV_interact and evolve.PlayerInfo[ uid ] then
		struct.lastnick = evolve.PlayerInfo[ uid ].Nick
	end
	
	connecting[ data.userid ] = struct
	self:SendJoiners()
end

function GM:player_spawn( data )
	connecting[ data.userid ] = nil
	self:SendJoiners()
end

function GM:player_disconnect( data )
	local waffle = { name = data.name, sid = data.networkid, reason = data.reason }
	local items = self.Items[ util.CRC( 'gm_' .. data.networkid .. '_gm' ) ]
	if items then
		waffle.lvl = items.lvl
		waffle.rep = items.rep
	end
	
	if connecting[ data.userid ] then
		for _, pl in pairs( player.GetAll() ) do
			pl:ChatPrint( data.name .. ' [ ' .. data.networkid .. ' ] gave up connecting' )
		end
		
		waffle.reason = 'gave up connecting'
	else
		local reason = 'disconneted from server'
		if data.reason == ( data.name .. ' timed out' ) then
			reason = 'crashed / network problem'
		end
		
		for _, pl in pairs( player.GetAll() ) do
			pl:ChatPrint( data.name .. ' [ ' .. data.networkid .. ' ] ' .. reason )
		end
	end
	
	net.Start( 'disconnected' )
		net.WriteTable( waffle )
	net.Send( player.GetAll() )
	
	connecting[ data.userid ] = nil
	self:SendJoiners()
end

function GM:SendJoiners()
	net.Start( 'connecting' )
		net.WriteTable( connecting )
	net.Broadcast()
end