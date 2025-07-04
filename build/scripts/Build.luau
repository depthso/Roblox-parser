--// Libraries
local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

--// Configuration
local ConfigFile = fs.readFile(process.args[1])
local Config = serde.decode("json", ConfigFile)

local OutputFile = Config.output
local DarkluaConfig = Config.darkluaconfig

local Frame = fs.readFile(Config.frame)

--// Compile file with Darklua
local DarkLuaResponce = process.exec("darklua", {
	"process",
	Config.main,
	OutputFile,
	"-c",
	DarkluaConfig,
})

--// Print error message
if not DarkLuaResponce.ok then
	print(DarkLuaResponce.stderr)
	return
end

local Compiled = Frame
local DarkluaOut = fs.readFile(OutputFile)
Compiled ..= `\n{DarkluaOut}`

fs.writeFile(OutputFile, Compiled)
print(DarkLuaResponce.stdout)