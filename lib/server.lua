local Server = {
    active = false,
    host = nil,
    peers = {},
    callbacks = {}
}

function Server:init( port )
    if not self.host then
        self.host = enet.host_create( "*:" .. tostring( port ) )
    end
    if not self.host then
        error( "Failed to bind to address *:" .. tostring( port ) .. "! It's probably in use" )
    end
    self.active = true
    self.peers = {}
    print( "Created a listen server on " .. self.host:socket_get_address() )
end

function Server:setCallbacks( receive, disconnect, connect )
    self.callbacks.receive = receive
    self.callbacks.disconnect = disconnect
    self.callbacks.connect = connect
end

function Server:update()
    if not self.active then
        return
    end
    local event = self.host:service()
    while event do
        if event.type == "receive" then
            local msg = event.data
            if self.callbacks.receive then
                self.callbacks.receive( event.data, event.peer:index() )
            end
        elseif event.type == "connect" then
            self.peers[ event.peer:index() ] = event.peer
            if self.callbacks.connect then
                self.callbacks.connect( event.peer:index() )
            end
        elseif event.type == "disconnect" then
            self.peers[ event.peer:index() ] = nil
            if self.callbacks.disconnect then
                self.callbacks.disconnect( event.peer:index() )
            end
        end
        event = self.host:service()
    end
end

function Server:send( message, peerindex, channel, flag )
    if not self.active then
        return
    end
    flag = flag or "unreliable"
    channel = channel or 0
    if not peerindex then
        self.host:broadcast( message, channel, flag )
    else
        self.peers[ peerindex ]:send( message, channel, flag )
    end
end

function Server:disconnect()
    if not self.active then
        return
    end
    for i,v in pairs( self.peers ) do
        v:disconnect_now()
    end
    self.peers = {}
    self.active = false
    self.host = nil
    -- We need self.host to be garbage collected to make enet relieve the
    -- address it's bound to
    collectgarbage()
end

return Server
