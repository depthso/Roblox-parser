--!strict

--[[
    Written by depso
    GNU GPLv3 License
    
    https://github.com/depthso
]]

type Table = {
	[any]: any 
}

local Module = {
	--// Package data
	Version = "1.1.1",
	Author = "Depso",
	License = "GNU-GPLv3",
	Repository = "https://github.com/depthso/Roblox-parser",
	ImportUrl = "https://raw.githubusercontent.com/depthso/Roblox-parser/refs/heads/main",

	Modules = {}
}

--// Import modules
local ImportModules = {
	"Parser",
	"Formatter",
	"Variables"
}

local function MergeDict(Base: Table, New: Table)
	for Key, Value in next, New do
		Base[Key] = Value
	end
end

--// This can be replaced
function Module:Import(Name: string)
	local Script = script:FindFirstChild(Name)
	return require(Script)
end

function Module:Load()
	local Modules = self.Modules

	for _, Name in next, ImportModules do
		Modules[Name] = self:Import(Name)
	end

	return self
end

function Module:New(Data: Table): Table
	local Modules = self.Modules

	local Class = {
		Variables = Modules.Variables.new(),
		Formatter = Modules.Formatter.new(),
		Parser = Modules.Parser.new()
	}

	--// Merge passed data with the shared class data
	if Data then
		MergeDict(Class, Data)
	end

	--// Merge class modules
	for Name, Value in next, Class do
		if typeof(Value) ~= "table" then continue end

		if Value.new then
			MergeDict(Value, Class)
		end
	end

	return Class
end

return Module