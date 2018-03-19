local Roact = require(game.ReplicatedStorage.Roact)
local RoactAnimate = require(game.ReplicatedStorage.RoactAnimate)
local Hex = require(game.ReplicatedStorage.Hex)

local CloseButton = require(script.Parent.CloseButton)
local ScreenFrame = require(script.Parent.ScreenFrame)

local e = Roact.createElement

local HEX_IMAGE = "rbxassetid://1520392730"
local HEX_AR = 1.158

local HexButton = Roact.Component:extend("HexMenuButton")

function HexButton:init()
    self.state = {
        _bgColor = RoactAnimate.Value.new(self.props.BackgroundColor3),
        _size = RoactAnimate.Value.new(self.props.Size),
        _contentSize = RoactAnimate.Value.new(UDim2.new(0, 0, 0, 0)),
        _labelTransparency = RoactAnimate.Value.new(0),
        _position = RoactAnimate.Value.new(self.props.Position),
        _hovered = false,
    }
end

function HexButton:willUpdate(nextProps, nextState)
    local screenWidth = workspace.CurrentCamera.ViewportSize.X
    local screenHeight = workspace.CurrentCamera.ViewportSize.Y
    local necessaryWidth = screenHeight * HEX_AR

    if nextProps.Open then
        if not self.props.Open then
            RoactAnimate.Sequence({
                RoactAnimate(self.state._labelTransparency, TweenInfo.new(0.1), 1),
                RoactAnimate.Parallel({
                    RoactAnimate(self.state._bgColor, TweenInfo.new(0.125), nextProps.BackgroundColor3),
                    RoactAnimate(self.state._size, TweenInfo.new(0.3), UDim2.new(0, necessaryWidth, 1, 0)),
                    RoactAnimate.Sequence({
                        RoactAnimate(self.state._position, TweenInfo.new(0.125), UDim2.new(0.5, 0, 0.5, 0)),
                        RoactAnimate.Sequence({
                            RoactAnimate(self.state._contentSize, TweenInfo.new(0), UDim2.new(0, 0, 0, screenHeight)),
                            RoactAnimate(self.state._contentSize, TweenInfo.new(0.4), UDim2.new(0, screenWidth, 0, screenHeight)),
                        }),
                    })
                })
            }):Start()
        end
    else
        local newBgColor = nextState._hovered and nextProps.HoverColor3 or nextProps.BackgroundColor3
        local sizeModifier = nextState._hovered and UDim2.new(0, 6, 0, 6) or UDim2.new(0, 0, 0, 0)
        local sizeDirection = nextState._hovered and Enum.EasingDirection.In or Enum.EasingDirection.Out

        if self.props.Open then
            RoactAnimate.Sequence({
                RoactAnimate(self.state._contentSize, TweenInfo.new(0.15), UDim2.new(0, 0, 1, 0)),
                RoactAnimate.Parallel({
                    RoactAnimate(self.state._position, TweenInfo.new(0.125), self.props.Position),
                    RoactAnimate(self.state._size, TweenInfo.new(0.125, Enum.EasingStyle.Sine, sizeDirection), nextProps.Size + sizeModifier),
                    RoactAnimate(self.state._bgColor, TweenInfo.new(0.125), newBgColor),
                    RoactAnimate(self.state._labelTransparency, TweenInfo.new(0.1), 0),
                }),
            }):Start()
        else
            RoactAnimate.Parallel({
                RoactAnimate(self.state._size, TweenInfo.new(0.0625, Enum.EasingStyle.Sine, sizeDirection), nextProps.Size + sizeModifier),
                RoactAnimate(self.state._bgColor, TweenInfo.new(0.125), newBgColor),
            }):Start()
        end
    end
end

function HexButton:didMount()
    game:GetService("UserInputService").InputChanged:Connect(function(input, gp)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        local rbx = self._ref
        local x = input.Position.X
        local y = input.Position.Y

        local relativeX = x - rbx.AbsolutePosition.X - rbx.AbsoluteSize.X / 2
        local relativeY = y - rbx.AbsolutePosition.Y - rbx.AbsoluteSize.Y / 2

        -- Flat-top hexes.
        local hexSize = rbx.AbsoluteSize.X / 2
        local coordinate = Hex.Coordinate.fromWorldPosition(relativeX, relativeY, Hex.Coordinate.Orientation.FlatTop, hexSize)

        self:setState({
            _hovered = coordinate.Q == 0 and coordinate.R == 0,
        })
    end)
end

function HexButton:render()
    local children = {}

    for key, child in pairs(self.props[Roact.Children] or {}) do
        children[key] = child
    end

    table.insert(children, e(CloseButton, {
        Position = UDim2.new(1, -64, 0, 32),
        OnClick = self.props.OnClose
    }))

    return e(RoactAnimate.ImageButton, {
        ImageColor3 = self.state._bgColor,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = self.state._size,
        BackgroundTransparency = 1,
        Image = HEX_IMAGE,
        Position = self.state._position,
        ZIndex = self.props.ZIndex,
        [Roact.Ref] = function(rbx) self._ref = rbx end,
        [Roact.Event.MouseButton1Down] = function(rbx, x, y)
            local relativeX = x - rbx.AbsolutePosition.X - rbx.AbsoluteSize.X / 2
            local relativeY = y - rbx.AbsolutePosition.Y - rbx.AbsoluteSize.Y / 2

            -- Flat-top hexes.
            local hexSize = rbx.AbsoluteSize.X / 2
            local coordinate = Hex.Coordinate.fromWorldPosition(relativeX, relativeY, Hex.Coordinate.Orientation.FlatTop, hexSize)

            if coordinate.Q == 0 and coordinate.R == 0 then
                self.props.OnClick()
            end
        end,
    }, {
        e("UIAspectRatioConstraint", {
            AspectRatio = HEX_AR,
            AspectType = Enum.AspectType.FitWithinMaxSize,
            DominantAxis = Enum.DominantAxis.Width,
        }),

        Icon = self.props.Icon and e(RoactAnimate.ImageLabel, {
            Image = self.props.Icon,
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.new(1, 1, 1),
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0.5, 0, 1, -10),
            AnchorPoint = Vector2.new(0.5, 1),
            ImageTransparency = self.state._labelTransparency,
        }),

        Title = e(RoactAnimate.TextLabel, {
            Text = self.props.Text,
            TextScaled = true,
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSansSemibold,
            TextColor3 = Color3.new(1, 1, 1),
            TextTransparency = self.state._labelTransparency,
            Size = UDim2.new(0.667, 0, 1, -96),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
        }, {
            e("UITextSizeConstraint", {
                MaxTextSize = 24,
                MinTextSize = 8,
            })
        }),

        ContentContainer = e(RoactAnimate.Frame, {
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            BackgroundColor3 = self.props.BackgroundColor3,
            ClipsDescendants = true,
            Size = self.state._contentSize,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ZIndex = 3,
        }, {
            e(ScreenFrame, {}, children)
        })
    })
end

return HexButton
