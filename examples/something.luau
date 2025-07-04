-- just copy and paste this i dont care anymore

local Parser = require(script.Parser)

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

--------/// WRAP IN A FUNCTION DONT COMPLAIN
local function ParseRemote(Data: table): string
	local Args = Data.Args
	local Remote = Data.Remote
	local Method = Data.Method
	
	--// Swaps
	local Swaps = {
		[Character] = {
			String = "Character",
			NextParent = LocalPlayer
		},
		[LocalPlayer] = {
			String = "LocalPlayer",
		}
	}
	
	--// Make parser
	local Module = Parser:New({
		VariableBase = "Jitalang_%.d",
		Swaps = Swaps,
		IndexFunc = function(Object, Key)
			return Object[Key]
		end,
	})
	
	local Variables = Module.Variables
	local Formatter = Module.Formatter
	local Parser = Module.Parser
	
	--// Pre-render replacements example
	local Replacements = Formatter:MakeReplacements()
	Formatter:SetValueSwaps(Replacements)
	
	--// Pre-render variables
	Variables:PrerenderVariables(Args, {"Instance"})
	
	--// Parse arguments
	local ParsedTable = Parser:ParseTableIntoString({
		NoBrackets = true,
		Table = Args
	})
	
	--// Create remote variable
	local RemoteVariable = Variables:MakeVariable({
		Value = Formatter:Format(Remote, {
			NoVariableCreate = true
		}),
		Lookup = Remote,
		Name = "Remote",
		Class = "Remote"
	})
	
	--// Make code
	local Code = "-- Generated with sigma spy BOIIIIIIIII (+9999999 AURA)\n"
	
	--// Generate variables code
	Code ..= Parser:MakeVariableCode({
		"Services", "Variables", "Remote"
	})
	
	--// Remote invoke code
	Code ..= `\n{RemoteVariable}:{Method}({ParsedTable})`

	return Code
end

local Code = ParseRemote({
	Remote = Instance.new("RemoteFunction", workspace),
	Method = "InvokeServer",
	Args =  {
		[["Hello world!"]],
		math.huge,
		Vector2.new(1,1),
		Vector3.new(1,1,4),
		Vector2.one,
		Vector3.zero,
		workspace:GetServerTimeNow(),
		workspace.DistributedGameTime,
		workspace.AirDensity,
		buffer.create(1),
		-math.huge,
		AnimationTweenInfo = TweenInfo.new(0.08),
		TextFont = Font.fromEnum(Enum.Font.RobotoMono),
		game.ChildAdded,
		game.ChildAdded:Connect(function() end),
		[10] = "sus dog",
		[500] = "ts pmo",
		"ghost busters",
		workspace.CurrentCamera:GetRenderCFrame(),
		workspace.CurrentCamera.CFrame,
		[[Hello world,
Steven here
Bozo]]
	}
})

print(Code)

-- :d