local Roact = require(game.ReplicatedStorage.Roact)

local CLOSE_IMAGE = "rbxassetid://1524709933"

return function(props)
    return Roact.createElement("ImageButton", {
        BackgroundTransparency = 1,
        Image = CLOSE_IMAGE,
        Size = UDim2.new(0, 32, 0, 32),
        AnchorPoint = Vector2.new(1, 0),
        ImageColor3 = Color3.new(1, 1, 1),
        Position = props.Position,
        [Roact.Event.MouseButton1Click] = props.OnClick,
    })
end