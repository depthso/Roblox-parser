type VariableData = {
	Name: string?,
	Value: any,
	Comment: string?
}

type Module = {
	VariablesDict: table,
	VariableLookup: table,
	InstanceQueue: table,
	VariableCount: number
}

local Globals = getfenv(1)

--// Variable pre-render functions 
local RenderFuncs = {
	["Instance"] = function(self, Items: table)
		local Parser = self.Parser

		local AllParents, ObjectParents = self:BulkCollectParents(Items)
		local Duplicates = self:FindDuplicates(AllParents)

		--// Make duplicates into variables
		for _, Object: Instance in Duplicates do
			local Parents = ObjectParents[Object]
			if not Parents then continue end

			local Path = Parser:MakePathString({
				Object = Object,
				Parents = Parents
			})

			--// Make variable
			self:MakeVariable({
				Lookup = Object,
				Comment = "Compressed duplicate",
				Value = Path
			})
		end
	end,
}

local Module: Module = {
	VariableBase = "Jit"
}
Module.__index = Module

local function MultiInsert(Table: table, ToInsert: table)
	for _, Value in next, ToInsert do
		table.insert(Table, Value)
	end
end

function Module.new(Values): Module
	local Class = {
		VariablesDict = {},
		VariableLookup = {},
		InstanceQueue = {},
		VariableCount = 0,
	}
	return setmetatable(Class, Module)
end

function Module:GetVariableCount(): number
	return self.VariableCount
end

function Module:IsGlobal(Value): boolean
	local IndexFunc = self.IndexFunc
	
	--// Check based on instance name
	if typeof(Value) == "Instance" then
		local Name = IndexFunc(Value, "Name")
		return Globals[Name] == Value
	end

	return Globals[Value] and Value
end

function Module:IsService(Object: Instance): boolean
	local IndexFunc = self.IndexFunc
	local ClassName = IndexFunc(Object, "ClassName")
	
	--// Check if object is a service based on the ClassName
	return pcall(function()
		return game:FindService(ClassName)
	end)
end


function Module:MakeName(Data): string
	--// Check if the variable already has defined name
	local Name = Data.Name
	if Name then 
		return Name 
	end
	
	self.VariableCount += 1
	
	local VariableCount = self.VariableCount
	local Base = self.VariableBase
	
	return Base:format(VariableCount)
end

function Module:GetVariable(Value): VariableData?
	local VariableLookup = self.VariableLookup
	return VariableLookup[Value]
end

function Module:MakeVariable(Data: VariableData): string
	local Variables = self.VariablesDict
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
	local Name = self:MakeName(Data)
	Data.Name = Name
	
	local ClassDict = Variables[Class]
	if not ClassDict then
		ClassDict = {}
		Variables[Class] = ClassDict
	end
	
	ClassDict[Lookup] = Data
	VariableLookup[Lookup] = Data
	
	return Name
end

function Module:CollectTableItems(Table, Callback: (Value: any)->nil)
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

function Module:FindDuplicates(Table: table): table
	local Duplicates = {}
	local IndexStates = {}

	for Index, Value in next, Table do
		local State = IndexStates[Value]
		
		--// Check if the value has already been indexed
		if State == 1 then
			table.insert(Duplicates, Value)
			IndexStates[Value] = 2
			continue
		end

		IndexStates[Value] = 1
	end
	
	--// Clear index states in memory
	table.clear(IndexStates)

	return Duplicates
end

function Module:CollectTableTypes(Table: table, Types: table): table
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

function Module:MakeParentsTable(Object): table
	local IndexFunc = self.IndexFunc
	local Swaps = self.Swaps
	local Variables = self.Variables
	
	local Parents = {}
	local NextParent = Object

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
		if Variable and NextParent then
			NextParent = nil
		end

		table.insert(Parents, 1, Current)

		--// Break if no parent
		if not NextParent then break end
	end

	return Parents
end

function Module:BulkCollectParents(Table): (table, table)
	local AllParents = {}
	local ObjectParents = {}

	--// Collect all parents
	for _, Object in next, Table do
		if typeof(Object) ~= "Instance" then continue end

		local Parents = self:MakeParentsTable(Object)
		
		MultiInsert(AllParents, Parents)

		ObjectParents[Object] = Parents
	end
	
	return AllParents, ObjectParents
end

function Module:PrerenderVariables(Table: table, Types: table)	
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