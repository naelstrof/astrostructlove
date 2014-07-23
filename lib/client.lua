local Client = {
    active = false,
    host = nil,
    server = nil,
    callbacks = {}
}

function Client:init( ip, port )
    self.host = enet.host_create()
    if not self.host then
        error( "Enet failed to create a generic host! I had no idea this was possible to be honest." )
    end
    self.server = self.host:connect( ip .. ":" .. tostring( port ) )
    if not self.server then
        error( "Enet failed to create a peer, this shouldn't ever happen either..." )
    end
    self.active = true
end

function Client:setCallbacks( receive, disconnect, connect )
    self.callbacks.receive = receive
    self.callbacks.disconnect = disconnect
    self.callbacks.connect = connect
end

function Client:update()
    if not self.active then
        return
    end
    local event = self.host:service()
    while event do
        if event.type == "receive" then
            local msg = event.data
            if self.callbacks.receive then
                self.callbacks.receive( event.data )
            end
        elseif event.type == "connect" then
            if self.callbacks.connect then
                self.callbacks.connect()
            end
        elseif event.type == "disconnect" then
            if self.callbacks.disconnect then
                self.callbacks.disconnect()
            end
            self.host = nil
            self.server = nil
        end
        event = self.host:service()
    end
end

function Client:send( message, channel, flag )
    if not self.active then
        return
    end
    flag = flag or "unreliable"
    channel = channel or 0
    if self.server then
        self.server:send( message, channel, flag )
    end
end

function Client:disconnect()
    if not self.active then
        return
    end
    self.server:disconnect()
    self.host:flush()
    self.active = false
    self.server = nil
    self.host = nil
    -- We need self.host to be garbage collected to make enet relieve the
    -- address it's bound to
    collectgarbage()
end

return Client
