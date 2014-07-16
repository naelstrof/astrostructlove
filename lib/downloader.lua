local Downloader = {}

function Downloader.download( link )
    love.filesystem.createDirectory( "downloads/" )
    -- We use md5sums to check if we already have the file
    local md5sum = MD5.sumhexa( link )
    if not love.filesystem.exists( "downloads/" .. md5sum ) then
        local b, c, h = HTTP.request( link )
        if b then
            love.filesystem.write( "downloads/" .. md5sum, b )
            return "downloads/" .. md5sum
        end
    end
    return "downloads/" .. md5sum
end

return Downloader
