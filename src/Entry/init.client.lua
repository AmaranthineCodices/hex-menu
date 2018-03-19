local Roact = require(game.ReplicatedStorage.Roact)
local e = Roact.createElement
local RoactAnimate = require(game.ReplicatedStorage.RoactAnimate)
local Hex = require(game.ReplicatedStorage.Hex)

Roact.setGlobalConfig({
    elementTracing = true,
})

local HexButton = require(game.ReplicatedStorage.Menu.HexButton)

local function Label(props)
    return e("TextLabel", {
        Font = Enum.Font.SourceSans,
        TextColor3 = Color3.new(1, 1, 1),
        Text = props.Text,
        TextSize = props.TextSize,
        BackgroundTransparency = 1,
        TextXAlignment = "Left",
        TextYAlignment = "Top",
        Position = props.Position,
    })
end

local layout = {
    {
        Position = Hex.Coordinate.new(0, 0),
        ColorSet = { Color3.fromRGB(108, 92, 231), Color3.fromRGB(162, 155, 254) },
        Text = "Test",
        Icon = "rbxassetid://1520828103",
        Content = {
            e(Label, {
                Position = UDim2.new(0, 30, 0, 30),
                Text = "Hello world!",
                TextSize = 48,
            }),
            e(Label, {
                Position = UDim2.new(0, 30, 0, 80),
                Text = "This is an example screen.",
                TextSize = 20,
            })
        }
    },
    {
        Position = Hex.Coordinate.new(1, 0),
        ColorSet = { Color3.fromRGB(9, 132, 227), Color3.fromRGB(116, 185, 255) },
        Text = "Another test",
        Icon = "rbxassetid://1520828103",
        Content = {
            e(Label, {
                Position = UDim2.new(0, 30, 0, 30),
                Text = "Test",
                TextSize = 48,
            }),
            e(Label, {
                Position = UDim2.new(0, 30, 0, 80),
                Text = "This is another example.",
                TextSize = 20,
            })
        }
    },
    {
        Position = Hex.Coordinate.new(1, -1),
        ColorSet = { Color3.fromRGB(0, 206, 201), Color3.fromRGB(129, 236, 236) },
        Text = "Example",
        Icon = "rbxassetid://1520828103",
        Content = {
            e(Label, {
                Position = UDim2.new(0, 30, 0, 30),
                Text = "Test #2",
                TextSize = 48,
            }),
            e(Label, {
                Position = UDim2.new(0, 30, 0, 80),
                Text = "This is a third example.",
                TextSize = 20,
            })
        }
    }
}

local App = Roact.Component:extend("App")

function App:init()
    self.state = {
        OpenPane = nil,
    }
end

function App:render()
    local children = {
        Background = e("Frame", {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 1,
        }),
    }

    for index, info in ipairs(layout) do
        local hexCoordinate = info.Position
        local relativeX, relativeY = hexCoordinate:ToWorldPosition(Hex.Coordinate.Orientation.FlatTop)
        relativeX = relativeX * 96 + (10 * math.sign(relativeX))
        relativeY = relativeY * 96 + (10 * math.sign(relativeY))

        table.insert(children, e(HexButton, {
            Position = UDim2.new(0.5, relativeX, 0.5, relativeY),
            Size = UDim2.new(0, 192, 1, 0),
            Text = info.Text,
            Icon = info.Icon,
            BackgroundColor3 = info.ColorSet[1],
            HoverColor3 = info.ColorSet[2],
            ZIndex = self.state.OpenPane == index and 3 or 2,
            OnClick = function()
                self:setState({
                    OpenPane = index
                })
            end,
            OnClose = function()
                self:setState({
                    OpenPane = Roact.None,
                })
            end,
            Open = self.state.OpenPane == index,
        }, info.Content))
    end

    return e("ScreenGui", {
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, children)
end

Roact.reify(e(App), game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)