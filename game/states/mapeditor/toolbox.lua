local Toolbox = {}

function Toolbox:init( tools )

    self.panel = loveframes.Create( "frame" )
    self.panel:SetWidth( 88 )
    self.panel:SetHeight( love.graphics.getHeight() )
    self.panel:SetPos( 0, 0 )
    self.panel:SetName( "Toolbox" )
    self.panel:SetDraggable( false )
    self.panel:ShowCloseButton( false )

    local grid = loveframes.Create( "grid", self.panel )
    grid:SetPos( 4, 28 )
    grid:SetRows( 4 )
    grid:SetColumns( 2 )
    grid:SetCellWidth( 36 )
    grid:SetCellHeight( 36 )
    grid:SetCellPadding( 2 )
    grid:SetItemAutoSize( true )

    local i = 1
    for y=1, 4 do
        for x=1, 2 do
            if i <= table.getn( tools ) then
                local button = loveframes.Create( "button" )
                button:SetText( tools[i].__name )
                button:SetSize( 34, 34 )
                button.id = i
                button.OnClick = function( obj, x, y )
                    gamestates.mapeditor:setTool( gamestates.mapeditor.tools[ obj.id ] )
                end
                local tooltip = loveframes.Create( "tooltip" )
                tooltip:SetObject( button )
                tooltip:SetPadding( 10 )
                tooltip:SetText( tools[i].__desc )
                tooltip:SetOffsetY( 24 )
                grid:AddItem( button, x, y )
                i = i + 1
            else
                break
            end
        end
    end

end

function Toolbox:resize( w, h )
    self.panel:SetHeight( h )
end

return Toolbox
