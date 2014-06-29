-- Majority of the work is already done with my demoing system :)

local Network = {
    updaterate = 15,
    currenttime = 0,
    players = {}
}

function Network:addPlayer( ip, ent )
    local player = {}
    player.ip = ip
    player.ent = ent
    self.players[ ip ] = player
end

function Network:removePlayer( ip )
    self.players[ ip ] = nil
end

function Network:updateClient( ip, controls, lastsnapshot )
    players[ ip ].controls = controls
    players[ ip ].lastsnapshot = lastsnapshot
end

function Network:sendUpdates( dt )
    while self.currenttime > dt do
        self.currrenttime = self.currenttime - dt
    end
end
