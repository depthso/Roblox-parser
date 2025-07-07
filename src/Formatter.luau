type table = {
	[any]: any
}

local Module = {}
Module.__index = Module

--// Defaults
local DefaultTween = TweenInfo.new()
local GetServerTimeNow = workspace.GetServerTimeNow

Module.ClassNameStrings = {
	["DataModel"] = "game",
	["Workspace"] = "workspace",
	["Stats"] = "stats()",
	["GlobalSettings"] = "settings()",
	["PluginManagerInterface"] = "PluginManager()",
	["UserSettings"] = "UserSettings()",
	["DebuggerManager"] = "DebuggerManager()"
}

--// Format type functions
Module.Formats = {
	["CFrame"] = function(self, Value)
		local Arguments = self:FormatVectorValues(Value, false, true)
		return `CFrame.new({Arguments})`
	end,
	["Vector3"] = function(self, Value)
		local Arguments = self:FormatVectorValues(Value)
		return `Vector3.new({Arguments})`
	end,
	["Vector2"] = function(self, Value)
		local Arguments = self:FormatVectorValues(Value, true)
		return `Vector2.new({Arguments})`
	end,
	["Vector2int16"] = function(self, Value)
		local Arguments = self:FormatVectorValues(Value, true)
		return `Vector2int16.new({Arguments})`
	end,
	["Vector3int16"] = function(self, Value)
		local Arguments = self:FormatVectorValues(Value)
		return `Vector3int16.new({Arguments})`
	end,
	["Color3"] = function(self, Value)
		return `Color3.fromRGB({Value.R*255}, {Value.G*255}, {Value.B*255})`
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
		local String = buffer.tostring(Value)
		String = self:Format(String)
		return `buffer.fromstring({String}) --[[{Value}]]`
	end,
	["DateTime"] = function(self, Value)
		return `DateTime.fromUnixTimestampMillis({Value.UnixTimestampMillis})`
	end,
	["Font"] = function(self, Value)
		local Family = self:Format(Value.Family)
		return `Font.new({Family}, {Value.Weight}, {Value.Style.Name})`
	end,
	["Enum"] = `%*`,
	["string"] = function(self, Value)
		local Filtered = self:MakePrintable(Value)
		local FormatBase = `"%*"`

		local HasBrackets = Filtered:find("%[%[=*[[]")
		local HasNewLine = Filtered:find("[\n\r]")

		if not HasBrackets and HasNewLine then
			FormatBase = "[[%*]]"
		end

		return FormatBase:format(Filtered)
	end,
	["number"] = `%*`,
	["TweenInfo"] = function(self, Value)
		local Style = `Enum.EasingStyle.{Value.EasingStyle.Name}`
		local Direction = `Enum.EasingDirection.{Value.EasingDirection.Name}`

		local IsDefaultStyle = Value.EasingStyle == DefaultTween.EasingStyle 
		local IsDefaultDirection = Value.EasingDirection == DefaultTween.EasingDirection
		local Time = math.round(Value.Time * 100) / 100

		if IsDefaultStyle and IsDefaultDirection then
			return `TweenInfo.new({Time})`
		end

		return `TweenInfo.new({Time}, {Style}, {Direction})`
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

		return `function() end --[[{String}]]`
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

function Module:IsPrintable(Character: string, NoNewlines: boolean)
	--// Disallow \n and \r (return)
	if NoNewlines then
		return Character:match("[%g ]")
	end

	return Character:match("[\n\r%g ]")
end

function Module:MakePrintable(String: string, NoNewlines: boolean): string
	local Filtered = String:gsub("\"", [[\"]])

	return Filtered:gsub(".", function(Character: string)
		if NoNewlines then
			Character = Character:gsub("\n", "\\n")
			Character = Character:gsub("\r", "\\r")
		end

		--// Printable character
		if self:IsPrintable(Character, NoNewlines) then
			return Character
		end

		--// Format non-printable characters by /hex
		return `\\{Character:byte()}`
	end)
end

function Module:FormatVectorValues(Vector, ...): string
	local Values = {self:RoundVector(Vector, ...)}
	return table.concat(Values, ", ")
end

function Module:RoundValues(Table: table): table
	local RoundedTable = {}
	
	for _, Value in next, Table do
		local Rounded = math.round(Value)
		table.insert(RoundedTable, Rounded)
	end
	
	return RoundedTable
end

function Module:RoundVector(Vector, IsVector2: boolean?, IsCFrame: boolean?): (number, number, number?)
	local X, Y, Z = Vector.X, Vector.Y, not IsVector2 and Vector.Z or 0

	if IsCFrame then
		local Components = {Vector:GetComponents()}
		return unpack(self:RoundValues(Components))
	end

	return math.round(X), math.round(Y), not IsVector2 and math.round(Z) or nil
end

function Module:GetServerTimeNow(): number
	return GetServerTimeNow(workspace)
end

function Module:MakeReplacements(Timestamp: number): table
	local Delay = tick() - (Timestamp or tick())

	--// Time specific
	local ServerTime = math.round(self:GetServerTimeNow() - Delay)
	local GameTime = math.round(workspace.DistributedGameTime - Delay)

	--// Replacement wrapper
	local Replacements = {}
	local function AddReplacement(Key, Replacement)
		--// Negitive version
		if typeof(Key) == "number" then
			Replacements[-Key] = `-{Replacement}`
		end
		
		Replacements[Key] = Replacement
	end

	--// Replacements
	AddReplacement(Vector2.one, "Vector2.one")
	AddReplacement(Vector2.zero, "Vector2.zero")
	AddReplacement(Vector3.one, "Vector3.one")
	AddReplacement(Vector3.zero, "Vector3.zero")
	AddReplacement(math.huge, "math.huge")
	AddReplacement(math.pi, "math.pi")
	AddReplacement(workspace.Gravity, "workspace.Gravity")
	AddReplacement(workspace.AirDensity, "workspace.AirDensity")
	AddReplacement(workspace.CurrentCamera.CFrame, "workspace.CurrentCamera.CFrame")
	AddReplacement(GameTime, "workspace.DistributedGameTime")
	AddReplacement(ServerTime, "workspace:GetServerTimeNow()")

	return Replacements
end

function Module:SetValueSwaps(ValueSwaps: table)
	self.ValueSwaps = ValueSwaps
end

function Module:FindStringIntSwap(Value: string)
	--// Check if string is a int
	local Int = tonumber(Value)
	if not Int then return end

	--// Find a swap for the int value
	local Swap = self:FindValueSwap(Int)
	return Swap
end

function Module:FindValueSwap(Value)
	local ValueSwaps = self.ValueSwaps

	--// Lookup replacement in ValueSwaps
	local Replacement = ValueSwaps[Value]
	if Replacement then return Replacement end

	--// String formatting
	if typeof(Value) == "string" then
		local Swap = self:FindStringIntSwap(Value)
		if Swap then
			return `tostring({Swap})`
		end
	end

	--// Check if the value is a number
	local IsNumber = typeof(Value) == "number"
	if not IsNumber then return end

	--// Round the number up
	local Rounded = math.round(Value)
	return ValueSwaps[Rounded]
end

function Module:NeedsBrackets(String: string)
	if not String then return end

	--// Only allow strings for bracket checking
	if typeof(String) ~= "string" then 
		return true
	end

	return not String:match("^[%a_][%w_]*$")
end

function Module:MakeName(Value): string?
	local Name = self:ObjectToString(Value)
	Name = Name:gsub("[./ #%@$%£+-()\n\r]", "")
	Name = self:MakePrintable(Name, true)

	--// Check if the name can be used for a variable
	if self:NeedsBrackets(Name) then return end

	--// Prevent long and short variable names
	if #Name < 1 or #Name > 30 then return end

	return Name
end

function Module.new(Values: table): table
	local Base = {}
	local Class = setmetatable(Base, Module)
	Class.ValueSwaps = Class:MakeReplacements()

	return Class
end

type FormatExtra = {
	NoVariables: boolean?,
	Indent: number?
}
function Module:Format(Value, Extra)
	local Formats = self.Formats
	local Variables = self.Variables

	Extra = Extra or {}
	local NoVariables = self.NoVariables or Extra.NoVariables
	
	--// Check for a value swap
	local Swap = self:FindValueSwap(Value)
	if Swap then return Swap end

	local Type = typeof(Value)
	local Format = Formats[Type]
	local Name = nil

	--// Variable name based on Instance name
	if typeof(Value) == "Instance" then
		Name = self:MakeName(Value)
	end

	--// Invoke compile function
	if typeof(Format) == "function" then
		local Formatted, IsVariable = Format(self, Value, Extra)

		--// Make variable
		if IsVariable and not NoVariables then
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
		return `{Value} --[[{Type} not supported]]`
	end

	return Format:format(Value)
end

function Module:ObjectToString(Object: Instance): string
	local Swaps = self.Swaps
	local IndexFunc = self.IndexFunc
	local Replacements = self.ClassNameStrings

	local Name = IndexFunc(Object, "Name")
	local ClassName = IndexFunc(Object, "ClassName")

	local Replacement = Replacements[ClassName]
	local String = Replacement or Name
	String = self:MakePrintable(String, true)

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