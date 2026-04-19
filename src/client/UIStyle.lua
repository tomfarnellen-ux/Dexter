local UIStyle = {}

UIStyle.Primary = Color3.fromRGB(110, 80, 255)
UIStyle.PrimaryDark = Color3.fromRGB(70, 50, 200)
UIStyle.Accent = Color3.fromRGB(255, 200, 50)
UIStyle.Panel = Color3.fromRGB(32, 28, 58)
UIStyle.PanelLight = Color3.fromRGB(60, 50, 110)
UIStyle.Success = Color3.fromRGB(120, 230, 150)
UIStyle.Danger = Color3.fromRGB(255, 110, 110)
UIStyle.TextPrimary = Color3.fromRGB(255, 255, 255)
UIStyle.TextMuted = Color3.fromRGB(210, 210, 230)

function UIStyle.Corner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = parent
	return corner
end

function UIStyle.Stroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(0, 0, 0)
	stroke.Thickness = thickness or 2
	stroke.Transparency = 0.2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

function UIStyle.Padding(parent, amount)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, amount)
	pad.PaddingBottom = UDim.new(0, amount)
	pad.PaddingLeft = UDim.new(0, amount)
	pad.PaddingRight = UDim.new(0, amount)
	pad.Parent = parent
	return pad
end

function UIStyle.FormatCoins(n)
	n = math.floor(n or 0)
	if n >= 1e9 then return string.format("%.2fB", n / 1e9) end
	if n >= 1e6 then return string.format("%.2fM", n / 1e6) end
	if n >= 1e3 then return string.format("%.1fK", n / 1e3) end
	return tostring(n)
end

return UIStyle
