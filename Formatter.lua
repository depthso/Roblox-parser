local Module = {}
Module.__index = Module

Module.ClassNameStrings = {
	["DataModel"] = "game",
	["Workspace"] = "workspace"
}

--// Format type functions
Module.Formats = {
	["CFrame"] = function(self, Value)
		return `CFrame.new({Value.X},{Value.Y},{Value.Z})`
	end,
	["Vector3"] = function(self, Value)
		return `Vector3.new({Value.X},{Value.Y},{Value.Z})`
	end,
	["Color3"] = function(self, Value)
		return `Color3.fromRGB({Value.R*255},{Value.G*255},{Value.B*255})`
	end,
	["UDim2"] = function(self, Value)
		return `UDim2.new({Value.X.Scale},{Value.X.Offset},{Value.Y.Scale},{Value.Y.Offset})`
	end,
	["UDim"] = function(self, Value)
		return `UDim2.new({Value.Scale},{Value.Offset})`
	end,
	["Enum"] = function(self, Value)
		return `UDim2.new({Value.Scale},{Value.Offset})`
	end,
	["BrickColor"] = function(self, Value)
		return `BrickColor.new("{Value.Name}")`
	end,
	["string"] = `"%*"`,
	["number"] = `%*`,
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

		return self:Format(String) 
	end,
	["table"] = function(self, Value, Data)
		local Indent = Data.Indent or 0
		return self.Parser:ParseTableIntoString({
			NoBrackets = false,
			Indent = Indent + 1,
			Table = Value
		})
	end,
}

function Module:NeedsBrackets(String: string)
	if not String then return end
	return not String:match("^[%a_][%w_]*$")
end

function Module.new(Values: table): Module
	local Class = {}
	return setmetatable(Class, Module)
end

function Module:Format(Value, Extra)
	local Formats = self.Formats
	local Variables = self.Variables
	
	Extra = Extra or {}

	local Type = typeof(Value)
	local Format = Formats[Type]

	--// Invoke compile function
	if typeof(Format) == "function" then
		local Formatted, IsVariable = Format(self, Value, Extra)
		
		--// Make variable
		if IsVariable and not Extra.NoVariableCreate then
			Formatted = Variables:MakeVariable({
				Lookup = Value,
				Value = Formatted
			})
		end
		
		return Formatted
	end

	--// Check if the data-type is supported
	if not Format then
		warn("No format for type", Type)
		return Value
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
