--[[
    A Frame that has an AbsoluteSize equal to the screen size, regardless of
    the size of its parent. The size of this frame cannot be changed in any
    way. This will error if used on the server.

    This may be used the same as any ScreenGui.
]]

local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local Roact = require(game.ReplicatedStorage.Roact)
local e = Roact.createElement

local ScreenFrame = Roact.Component:extend("ScreenFrame")

function ScreenFrame:init()
    self.state = {
        _screenSize = Vector2.new(0, 0),
        _parentAbsolutePosition = Vector2.new(0, 0),
    }
end

function ScreenFrame:render()
    return e("Frame", {
        Size = UDim2.new(0, self.state._screenSize.X, 0, self.state._screenSize.Y),
        Position = UDim2.new(0, -self.state._parentAbsolutePosition.X, 0, -self.state._parentAbsolutePosition.Y),
        BackgroundTransparency = 1,
        [Roact.Ref] = function(rbx)
            self._ref = rbx
        end,
    }, self.props[Roact.Children])
end

function ScreenFrame:_parentDidChange()
    self:setState({
        _parentAbsolutePosition = self._ref.Parent.AbsolutePosition,
    })
end

function ScreenFrame:_viewportSizeDidChange()
    local topLeftInset, bottomLeftInset = GuiService:GetGuiInset()
    local viewportSize = Workspace.CurrentCamera.ViewportSize
    local screenSize = viewportSize - topLeftInset - bottomLeftInset

    self:setState({
        _screenSize = screenSize,
    })
end

function ScreenFrame:didMount()
    self:_parentDidChange()
    self:_viewportSizeDidChange()

    -- Parent will cause this frame to be unmounted, so we can assume that parent is constant.
    self._parentConnection = self._ref.Parent:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        self:_parentDidChange()
    end)

    -- Assume the current camera does not change.
    self._cameraConnection = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        self:_viewportSizeDidChange()
    end)
end

function ScreenFrame:willUnmount()
    self._parentConnection:Disconnect()
    self._cameraConnection:Disconnect()
end

return ScreenFrame
