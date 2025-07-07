--!nolint DeprecatedApi

type VariableData = {
	Name: string,
	Value: any,
	Order: number,
	Lookup: any?,
	Class: string?,
	Comment: string?
}

type Table = {
	[any]: any
}

type VariablesDict = {
	[any]: VariableData
}

export type ClassDict = {
	VariableCount: number,
	Variables: VariablesDict
}

type Module = {
	VariablesDict: Table,
	VariableLookup: Table,
	InstanceQueue: Table,
	NoNameCount: number,
	VariableBase: string
}

--// Module
local Module = {
	VariableBase = "Jit"
}
Module.__index = Module

local Globals = getfenv(1)

--// Variable pre-render functions 
local RenderFuncs = {
	["Instance"] = function(self, Items: Table)
		local Parser = self.Parser
		local Formatter = self.Formatter

		local AllParents = self:BulkCollectParents(Items)
		local Duplicates = self:FindDuplicates(AllParents)

		--// Make duplicates into variables
		for _, Object: Instance in next, Duplicates do
			local Path, ParentsCount = Parser:MakePathString({
				Object = Object
			})

			--// Check the parent count to prevent single paths
			if ParentsCount < 3 then continue end

			local Name = Formatter:MakeName(Object)

			--// Make variable
			self:MakeVariable({
				Lookup = Object,
				Name = Name,
				--Comment = "Compressed duplicate",
				Value = Path
			})
		end
	end,
}

local function MultiInsert(Table: Table, ToInsert: Table)
	for _, Value in next, ToInsert do
		table.insert(Table, Value)
	end
end

function Module.new(Values)
	local Class = {
		VariablesDict = {},
		VariableLookup = {},
		InstanceQueue = {},
		VariableNames = {},
		NoNameCount = 0
	}
	return setmetatable(Class, Module)
end

function Module:GetNoNameCount(): number
	return self.NoNameCount
end

function Module:AddVariableToClass(ClassDict: ClassDict, Data: VariableData)
	--// Variable data
	local Value = Data.Value
	local Lookup = Data.Lookup or Value

	ClassDict.VariableCount += 1

	--// Class data
	local Position = ClassDict.VariableCount
	local Variables = ClassDict.Variables

	Data.Order = Position
	Variables[Lookup] = Data
end

function Module:GetClassDict(Class: string): ClassDict
	local Variables = self.VariablesDict
	local ClassDict = Variables[Class]

	--// Return existing
	if ClassDict then return ClassDict end

	--// Create class dict
	ClassDict = {
		VariableCount = 0,
		Variables = {}
	}

	Variables[Class] = ClassDict
	return ClassDict
end

function Module:IsGlobal(Value: (string|Instance)): (string|boolean)
	local IndexFunc = self.IndexFunc

	--// Check based on instance name
	if typeof(Value) == "Instance" then
		local Name = IndexFunc(Value, "Name")
		return Globals[Name] == Value
	end

	return Globals[Value] and Value or false
end

function Module:IsService(Object: Instance): (string|boolean)
	local IndexFunc = self.IndexFunc
	local ClassName = IndexFunc(Object, "ClassName")

	--// Check if object is a service based on the ClassName
	local Success = pcall(function()
		return game:GetService(ClassName)
	end)

	return Success and ClassName or false
end

function Module:IncreaseNameUseCount(Name: string): number
	if not Name then return 0 end

	local VariableNames = self.VariableNames	
	local NameUseCount = VariableNames[Name]

	--// Create missing dict
	if not NameUseCount then
		NameUseCount = 0
		VariableNames[Name] = NameUseCount
	end

	VariableNames[Name] += 1

	return NameUseCount
end

function Module:IncreaseNoNameCount(): number
	self.NoNameCount += 1
	return self.NoNameCount
end

function Module:CheckName(Data): string
	local Name = Data.Name
	local NameUseCount = self:IncreaseNameUseCount(Name)

	--// Check if the variable already has defined name
	if Name then
		if NameUseCount <= 0 then 
			return Name 
		else
			return `{Name}{NameUseCount}`
		end
	end

	--// Create a default variable name
	local NoNameCount = self:IncreaseNoNameCount()

	--// Format VariableBase string
	local Base = self.VariableBase
	return Base:format(NoNameCount)
end

function Module:GetVariable(Value): VariableData?
	local VariableLookup = self.VariableLookup
	return VariableLookup[Value]
end

function Module:OrderVariables(Variables: VariablesDict): Table
	local Ordered = {}

	for Lookup, Data in next, Variables do
		local Order = Data.Order
		table.insert(Ordered, Order, Data)
	end

	return Ordered
end

function Module:MakeVariable(Data: VariableData): string
	local VariableLookup = self.VariableLookup
	local InstanceQueue = self.InstanceQueue

	local Value = Data.Value
	local Lookup = Data.Lookup or Value
	local Class = Data.Class or "Variables"

	--// Return existing variable
	local Existing = self:GetVariable(Lookup)
	if Existing then
		return Existing.Name
	end

	--// Check if the value is a global
	local Global = self:IsGlobal(Value)
	if Global then
		return Global
	end

	--// Check if value is an instance
	if not Data.Name and typeof(Value) == "Instance" then
		InstanceQueue[Value] = Data
	end

	--// Generate variable name
	local Name = self:CheckName(Data)
	Data.Name = Name

	--// Check variable class dict
	local ClassDict = self:GetClassDict(Class)
	self:AddVariableToClass(ClassDict, Data)

	VariableLookup[Lookup] = Data
	return Name
end

function Module:CollectTableItems(Table: Table, Callback: (Value: any)->nil)
	local function Process(Value)
		local Type = typeof(Value)

		--// Recursive search
		if Type == "table" then
			self:CollectTableItems(Value, Callback)
			return
		end

		Callback(Value)
	end

	--// Process each item in table
	for A, B in next, Table do
		Process(A)
		Process(B)
	end
end

function Module:FindDuplicates(Table: Table): Table
	local Duplicates = {}
	local IndexStates = {}

	for Index, Value in next, Table do
		local State = IndexStates[Value]

		--// Check if the value has already been indexed
		if State == 1 then
			IndexStates[Value] = 2
			table.insert(Duplicates, Value)
			continue
		end

		IndexStates[Value] = 1
	end

	--// Clear index states in memory
	table.clear(IndexStates)

	return Duplicates
end

function Module:CollectTableTypes(Table: Table, Types: Table): Table
	local Collections = {}

	local function Process(Value)
		local Type = typeof(Value)

		--// Check if type should be collected
		if not table.find(Types, Type) then return end

		local Collected = Collections[Type]
		if not Collected then
			Collected = {}
			Collections[Type] = Collected
		end

		table.insert(Collected, Value)
	end

	--// Collect all table items
	self:CollectTableItems(Table, Process)

	return Collections
end

function Module:MakeParentsTable(Object: Instance, NoVariables: boolean?): Table
	local IndexFunc = self.IndexFunc
	local Swaps = self.Swaps
	local Variables = self.Variables
	NoVariables = self.NoVariables or NoVariables

	local Parents = {}
	local NextParent = Object :: Instance?

	while true do
		local Current = NextParent
		NextParent = IndexFunc(NextParent, "Parent")

		--// Global check
		if NextParent == game and self:IsGlobal(Current) then
			NextParent = nil
		end

		--// Check for swaps
		if Swaps then
			local Swap = Swaps[Current]
			if Swap and Swap.NextParent then
				NextParent = Swap.NextParent
			end
		end

		--// Check for a variable with the path
		local Variable = Variables:GetVariable(Current)
		if not NoVariables and Variable and NextParent then
			NextParent = nil
		end

		table.insert(Parents, 1, Current)

		--// Break if no parent
		if not NextParent then break end
	end

	return Parents
end

function Module:BulkCollectParents(Objects: Table): (Table, Table)
	local AllParents = {}
	local ObjectParents = {}

	--// Collect all parents
	for _, Object in next, Objects do
		if typeof(Object) ~= "Instance" then continue end

		local Parents = self:MakeParentsTable(Object)
		MultiInsert(AllParents, Parents)
		ObjectParents[Object] = Parents
	end

	return AllParents, ObjectParents
end

function Module:PrerenderVariables(Table: Table, Types: Table)	
	--// Disable compression if NoVariables is enabled
	if self.NoVariables then return end

	--// Collect keys and values in table
	local Collections = self:CollectTableTypes(Table, Types)

	--// Instances
	for Type, Items in next, Collections do
		local Render = RenderFuncs[Type]
		if Render then
			Render(self, Items)
		end
	end
end

return Module