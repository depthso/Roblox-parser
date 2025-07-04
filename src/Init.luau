--!strict

type Table = {
	[any]: any
}

local Module = {
	--// Package data
	Version = "1.0.8",
	Author = "Depso",
	License = "GNU-GPLv3",
	Repository = "https://github.com/depthso/Roblox-parser",
	ImportUrl = "https://raw.githubusercontent.com/depthso/Roblox-parser/refs/heads/main",

	Modules = {
		Formatter = require("@src/Formatter"),
		Parser = require("@src/Parser"),
		Variables = require("@src/Variables"),
	}
}

local function MergeDict(Base: Table, New: Table)
	for Key, Value in next, New do
		Base[Key] = Value
	end
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