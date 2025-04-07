type Module = {
	Variables: table,
	Banner: string
}

local Module: Module = {}
Module.__index = Module

function GetDictSize(Dict: table): number
	local Count = 0
	for Key, Value in Dict do
		Count += 1
	end
	return Count
end

function Module.new(Values): Module
	local Class = {}
	return setmetatable(Class, Module)
end

function Module:FormatTableKey(Index): string?
	local Formatter = self.Formatter
	local NeedsBrackets = Formatter:NeedsBrackets(Index)

	if NeedsBrackets then return end
	if typeof(Index) ~= "string" then return end

	return `{Index} = `
end

type ParseTableIntoStringData = {
	Table: table,
	Indent: number?,
	NoBrackets: boolean?
}
function Module:ParseTableIntoString(Data: ParseTableIntoStringData): (string, number)
	local Formatter = self.Formatter

	--// Unpack configuration
	local Indent = Data.Indent or 0
	local NoBrackets = Data.NoBrackets
	local Table = Data.Table

	local IsArray = Table[1]
	local ItemsCount = IsArray and #Table or GetDictSize(Table)

	--// Empty table
	if ItemsCount == 0 then
		return NoBrackets and "" or "{}", ItemsCount
	end

	local IndentString = string.rep("	", Indent)
	local TableString = `{not NoBrackets and "{" or ""}\n`

	--// Generate string
	local Position = 0
	for Index, Value in next, Table do
		local Ending = ""
		local KeyString = ""
		local ValueString = Formatter:Format(Value, Data)

		--// Format the index value
		if typeof(Index) ~= "number" then
			KeyString = self:FormatTableKey(Index)
			if not KeyString then
				local IndexString = Formatter:Format(Value, Data)
				KeyString = `[{IndexString}] = `
			end
		end

		--// Check if , should be added to the line
		Position += 1
		if Position < ItemsCount then
			Ending = ","
		end

		TableString ..= `{IndentString}	{KeyString}{ValueString}{Ending}\n`
	end

	--// Close the table
	TableString ..= `{IndentString}{not NoBrackets and "}" or ""}`

	return TableString, ItemsCount
end

function Module:MakeVariableCodeLine(Data: table): string
	local Name = Data.Name
	local Value = Data.Value
	local Comment = Data.Comment

	--print("Variable-data:", Data)

	local Line = `local {Name} = {Value}`
	local End = Comment and ` -- {Comment}` or ""

	return `{Line}{End}`
end

function Module:MakeVariableCodeLines(Variables: table): string
	local Lines = ""

	for Index, Data in Variables do
		local Line = self:MakeVariableCodeLine(Data)
		Lines ..= `{Line}\n`
	end

	return Lines
end

function Module:MakeVariableCode(Order: table): string
	local Variables = self.Variables
	local ClassedVariables = Variables.VariablesDict

	local Code = ""

	local Index = 0
	for _, Class in next, Order do
		local Variables = ClassedVariables[Class]
		if not Variables then continue end

		Index += 1

		local NewLine = Index > 1 and "\n" or ""
		Code ..= `{NewLine}-- {Class}\n`
		Code ..= self:MakeVariableCodeLines(Variables)
	end

	return Code
end

type MakePathStringData = {
	Object: Instance,
	Parents: table?,
	NoVariables: boolean?
}
function Module:MakePathString(Data: table): (string, number)
	local Variables = self.Variables
	local Formatter = self.Formatter

	local Base = Data.Object
	local Parents = Data.Parents
	local NoVariables = Data.NoVariables

	local PathString = ""
	local ParentsCount = 0

	--// Get object parents
	Parents = Parents or Variables:MakeParentsTable(Base)

	local function ServiceCheck(Object: Instance, String: string)
		local ServiceName = Variables:IsService(Object)
		if not ServiceName then return end

		local ServiceString = `game:GetService("{ServiceName}")`

		--// NoVariables flag
		if NoVariables then
			PathString = ServiceString
			return true
		end

		--// Make service into a variable
		local Name = Variables:MakeVariable({
			Name = ServiceName,
			Class = "Services",
			Value = ServiceString
		})

		PathString = Name
		return true
	end

	--// Make the path string
	for Index, Object in next, Parents do
		local String = Formatter:ObjectToString(Object)

		--// Check for an existing variable
		local Variable = Variables:GetVariable(Object)
		if Variable and not NoVariables then
			String = Variable.Name
		end

		--// Check if the object is a service
		if Index == 2 and Parents[1] == game then
			if ServiceCheck(Object, String) then continue end
		end

		local Brackets = Formatter:NeedsBrackets(String)
		local Separator = Index > 1 and "." or ""
		
		ParentsCount += 1
		PathString ..= Brackets and `["{String}"]` or `{Separator}{String}`
	end

	--// Cache path
	-- PathCache[Object] = {
	-- 	Variables = Variables,
	-- 	Args = {PathString, #Parents}
	-- }

	return PathString, ParentsCount
end

return Module