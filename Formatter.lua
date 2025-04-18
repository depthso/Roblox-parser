local Module = {}
Module.__index = Module

--// Defaults
local DefaultTween = TweenInfo.new()

Module.ClassNameStrings = {
	["DataModel"] = "game",
	["Workspace"] = "workspace"
}

--// Format type functions
Module.Formats = {
	["CFrame"] = function(self, Value)
		local X, Y, Z = self:UnpackVector(Value)
		return `CFrame.new({X},{Y},{Z})`
	end,
	["Vector3"] = function(self, Value)
		local X, Y, Z = self:UnpackVector(Value)
		return `Vector3.new({X},{Y},{Z})`
	end,
	["Vector2"] = function(self, Value)
		local X, Y = self:UnpackVector(Value, true)
		return `Vector2.new({X},{Y})`
	end,
	["Vector2int16"] = function(self, Value)
		local X, Y = self:UnpackVector(Value, true)
		return `Vector2int16.new({X},{Y})`
	end,
	["Vector3int16"] = function(self, Value)
		local X, Y, Z = self:UnpackVector(Value)
		return `Vector3int16.new({X},{Y},{Z})`
	end,
	["Color3"] = function(self, Value)
		return `Color3.fromRGB({Value.R*255},{Value.G*255},{Value.B*255})`
	end,
	["NumberRange"] = function(self, Value)
		local Min = self:Format(Value.Min)
		local Max = self:Format(Value.Max)
		return `NumberRange.new({Min}, {Max})`
	end,
	["NumberSequenceKeypoint"] = function(self, Value)
		return `NumberSequenceKeypoint.new({Value.Time}, {Value.Value}, {Value.Envelope})`
	end,
	["ColorSequenceKeypoint"] = function(self, Value)
		return `ColorSequenceKeypoint.new({Value.Time}, {Value.Value})`
	end,
	["PathWaypoint"] = function(self, Value)
		local Position = self:Format(Value.Position)
		local Action = `Enum.PathWaypointAction.{Value.Action.Name}`
		return `PathWaypoint.new({Position}, {Action}, "{Value.Label}")`
	end,
	["PhysicalProperties"] = function(self, Value)
		return `PhysicalProperties.new("{Value.Density}, {Value.Friction}, {Value.Elasticity}, {Value.FrictionWeight}, {Value.ElasticityWeight}`
	end,
	["Ray"] = function(self, Value)
		local Origin = self:Format(Value.Origin)
		local Direction = self:Format(Value.Direction)
		return `Ray.new({Origin}, {Direction})`
	end,
	["UDim2"] = function(self, Value)
		return `UDim2.new({Value.X.Scale},{Value.X.Offset},{Value.Y.Scale},{Value.Y.Offset})`
	end,
	["UDim"] = function(self, Value)
		return `UDim2.new({Value.Scale},{Value.Offset})`
	end,
	["BrickColor"] = function(self, Value)
		return `BrickColor.new("{Value.Name}")`
	end,
	["buffer"] = function(self, Value)
		return `buffer.fromstring("{buffer.tostring(Value)}")`
	end,
	["DateTime"] = function(self, Value)
		return `DateTime.fromUnixTimestampMillis({Value.UnixTimestampMillis})`
	end,
	["Enum"] = `%*`,
	["string"] = `"%*"`,
	["number"] = `%*`,
	["TweenInfo"] = function(self, Value)
		local Style = `Enum.EasingStyle.{Value.EasingStyle.Name}`
		local Direction = `Enum.EasingDirection.{Value.EasingDirection.Name}`
		
		local IsDefaultStyle = Value.EasingStyle == DefaultTween.EasingStyle 
		local IsDefaultDirection = Value.EasingDirection == DefaultTween.EasingDirection
		
		if IsDefaultStyle and IsDefaultDirection then
			return `TweenInfo.new({Value.Time})`
		end
		
		return `TweenInfo.new({Value.Time}, {Style}, {Direction})`
	end,
	["boolean"] = `%*`,
	["Instance"] = function(self, Object: Instance)
		local Path, Length = self.Parser:MakePathString({
			Object = Object
		})
		return Path, Length > 2
	end,
	["function"] = function(self, Value)
		local Name = debug.info(Value, "n")
		local String = ""

		if #Name <= 0 then
			String = `{Value}`
		else
			String = `function {Name}`
		end

		return `nil --[[{String}]]`
	end,
	["table"] = function(self, Value, Data)
		local Indent = Data.Indent or 0
		local Parsed = self.Parser:ParseTableIntoString({
			NoBrackets = false,
			Indent = Indent + 1,
			Table = Value
		})
		return Parsed
	end,
	["RBXScriptSignal"] = function(self, Value, Data)
		local Name = tostring(Value):match(" (%a+)")
		return `nil --[[Signal: {Name}]]`
	end,
}

function Module:UnpackVector(Vector, IsVector2: boolean?): (number, number, number)
	local X, Y, Z = Vector.X, Vector.Y, not IsVector2 and Vector.Z or 0
	return math.round(X), math.round(Y), math.round(Z)
end

function Module:CacheSpecialFormats() --TODO
	return {
		math.round(workspace:GetServerTimeNow())
	}
end

function Module:MakeValueSwaps()
	local ServerTime = math.round(workspace:GetServerTimeNow())
	
	return {
		[Vector2.one] = "Vector2.one",
		[Vector2.zero] = "Vector2.zero",
		[Vector3.one] = "Vector3.one",
		[Vector3.zero] = "Vector3.zero",
		[math.huge] = "math.huge",
		[math.pi] = "math.pi",
		[ServerTime] = "workspace:GetServerTimeNow()"
	}
end

function Module:FindValueSwap(Value)
	local ValueSwaps = self:MakeValueSwaps()
	local IsNumber = typeof(Value) == "number"
	
	local Original = ValueSwaps[Value]
	if Original then return Original end
	if not IsNumber then return end
	
	local Rounded = math.round(Value)
	return ValueSwaps[Rounded]
end

function Module:NeedsBrackets(String: string)
	if not String then return end
	return not String:match("^[%a_][%w_]*$")
end

function Module:MakeName(Value): string?
	local Name = self:ObjectToString(Value)
	Name = Name:gsub(" ", "")
	
	--// Check if the name can be used for a variable
	if self:NeedsBrackets(Name) then return end
	
	--// Prevent long and short variable names
	if #Name < 3 or #Name > 15 then return end
	
	return Name
end

function Module.new(Values: table): Module
	local Class = {}
	return setmetatable(Class, Module)
end

function Module:Format(Value, Extra)
	local Formats = self.Formats
	local Variables = self.Variables

	Extra = Extra or {}
	
	--// Check for a value swap
	local Swap = self:FindValueSwap(Value)
	if Swap then return Swap end

	local Type = typeof(Value)
	local Format = Formats[Type]
	local Name = nil
	
	if typeof(Value) == "Instance" then
		Name = self:MakeName(Value)
	end

	--// Invoke compile function
	if typeof(Format) == "function" then
		local Formatted, IsVariable = Format(self, Value, Extra)

		--// Make variable
		if IsVariable and not Extra.NoVariableCreate then
			Formatted = Variables:MakeVariable({
				Name = Name,
				Lookup = Value,
				Value = Formatted
			})
		end

		return Formatted
	end

	--// Check if the data-type is supported
	if not Format then
		warn("No format for type", Type)
		return `{Value} --[[{Type} not supported]]`
	end

	return Format:format(Value)
end

function Module:ObjectToString(Object): string
	local Swaps = self.Swaps
	local IndexFunc = self.IndexFunc
	local Replacements = self.ClassNameStrings

	local Name = IndexFunc(Object, "Name")
	local ClassName = IndexFunc(Object, "ClassName")

	local Replacement = Replacements[ClassName]
	local String = Replacement or Name

	--// Check for swaps
	if Swaps then
		local Swap = Swaps[Object]
		if Swap then
			String = Swap.String
		end
	end

	return String
end

return Module