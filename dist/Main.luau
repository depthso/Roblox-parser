local a a={cache={},load=function(b)if not a.cache[b]then a.cache[b]={c=a[b]()}
end return a.cache[b].c end}do function a.a()local b={}b.__index=b local c,d=
TweenInfo.new(),workspace.GetServerTimeNow b.ClassNameStrings={DataModel='game',
Workspace='workspace',Stats='stats()',GlobalSettings='settings()',
PluginManagerInterface='PluginManager()',UserSettings='UserSettings()',
DebuggerManager='DebuggerManager()'}b.Formats={CFrame=function(e,f)local g=e:
FormatVectorValues(f,false,true)return`CFrame.new({g})`end,Vector3=function(e,f)
local g=e:FormatVectorValues(f)return`Vector3.new({g})`end,Vector2=function(e,f)
local g=e:FormatVectorValues(f,true)return`Vector2.new({g})`end,Vector2int16=
function(e,f)local g=e:FormatVectorValues(f,true)return`Vector2int16.new({g})`
end,Vector3int16=function(e,f)local g=e:FormatVectorValues(f)return`Vector3int16.new({
g})`end,Color3=function(e,f)return`Color3.fromRGB({f.R*255}, {f.G*255}, {f.B*255
})`end,NumberRange=function(e,f)local g,h=e:Format(f.Min),e:Format(f.Max)return`NumberRange.new({
g}, {h})`end,NumberSequenceKeypoint=function(e,f)return`NumberSequenceKeypoint.new({
f.Time}, {f.Value}, {f.Envelope})`end,ColorSequenceKeypoint=function(e,f)return`ColorSequenceKeypoint.new({
f.Time}, {f.Value})`end,PathWaypoint=function(e,f)local g,h=e:Format(f.Position)
,`Enum.PathWaypointAction.{f.Action.Name}`return`PathWaypoint.new({g}, {h}, "{f.
Label}")`end,PhysicalProperties=function(e,f)return`PhysicalProperties.new("{f.
Density}, {f.Friction}, {f.Elasticity}, {f.FrictionWeight}, {f.ElasticityWeight}`
end,Ray=function(e,f)local g,h=e:Format(f.Origin),e:Format(f.Direction)return`Ray.new({
g}, {h})`end,UDim2=function(e,f)return`UDim2.new({f.X.Scale},{f.X.Offset},{f.Y.
Scale},{f.Y.Offset})`end,UDim=function(e,f)return`UDim2.new({f.Scale},{f.Offset})`
end,BrickColor=function(e,f)return`BrickColor.new("{f.Name}")`end,buffer=
function(e,f)local g=buffer.tostring(f)g=e:Format(g)return`buffer.fromstring({g}) --[[{
f}]]`end,DateTime=function(e,f)return`DateTime.fromUnixTimestampMillis({f.
UnixTimestampMillis})`end,Font=function(e,f)local g=e:Format(f.Family)return`Font.new({
g}, {f.Weight}, {f.Style.Name})`end,Enum=`%*`,string=function(e,f)local g,h=e:
MakePrintable(f),`"%*"`local i,j=g:find'%[%[=*[[]',g:find'[\n\r]'if not i and j
then h='[[%*]]'end return h:format(g)end,number=`%*`,TweenInfo=function(e,f)
local g,h,i,j=`Enum.EasingStyle.{f.EasingStyle.Name}`,`Enum.EasingDirection.{f.
EasingDirection.Name}`,f.EasingStyle==c.EasingStyle,f.EasingDirection==c.
EasingDirection if i and j then return`TweenInfo.new({f.Time})`end return`TweenInfo.new({
f.Time}, {g}, {h})`end,boolean=`%*`,Instance=function(e,f)local g,h=e.Parser:
MakePathString{Object=f}return g,h>2 end,['function']=function(e,f)local g,h=
debug.info(f,'n'),''if#g<=0 then h=`{f}`else h=`function {g}`end return`nil --[[{
h}]]`end,table=function(e,f,g)local h=g.Indent or 0 local i=e.Parser:
ParseTableIntoString{NoBrackets=false,Indent=h+1,Table=f}return i end,
RBXScriptSignal=function(e,f,g)local h=tostring(f):match' (%a+)'return`nil --[[Signal: {
h}]]`end}function b:IsPrintable(e,f)if f then return e:match'[%g ]'end return e:
match'[\n\r%g ]'end function b:MakePrintable(e,f)local g=e:gsub('"','\\"')return
g:gsub('.',function(h)if f then h=h:gsub('\n','\\n')h=h:gsub('\r','\\r')end if
self:IsPrintable(h,f)then return h end return`\\{h:byte()}`end)end function b:
FormatVectorValues(e,...)local f={self:RoundVector(e,...)}return table.concat(f,
', ')end function b:RoundValues(e)local f={}for g,h in next,e do local i=math.
round(h)table.insert(f,i)end return f end function b:RoundVector(e,f,g)local h,i
,j=e.X,e.Y,not f and e.Z or 0 if g then local k={e:GetComponents()}return
unpack(self:RoundValues(k))end return math.round(h),math.round(i),not f and math
.round(j)or nil end function b:GetServerTimeNow()return d(workspace)end function
b:MakeReplacements(e)local f=tick()-(e or tick())local g,h,i=math.round(self:
GetServerTimeNow()-f),math.round(workspace.DistributedGameTime-f),{}local j=
function(j,k)if typeof(j)=='number'then i[-j]=`-{k}`end i[j]=k end j(Vector2.one
,'Vector2.one')j(Vector2.zero,'Vector2.zero')j(Vector3.one,'Vector3.one')j(
Vector3.zero,'Vector3.zero')j(math.huge,'math.huge')j(math.pi,'math.pi')j(
workspace.Gravity,'workspace.Gravity')j(workspace.AirDensity,
'workspace.AirDensity')j(workspace.CurrentCamera.CFrame,
'workspace.CurrentCamera.CFrame')j(h,'workspace.DistributedGameTime')j(g,
'workspace:GetServerTimeNow()')return i end function b:SetValueSwaps(e)self.
ValueSwaps=e end function b:FindStringIntSwap(e)local f=tonumber(e)if not f then
return end return self:FindValueSwap(f)end function b:FindValueSwap(e)local f=
self.ValueSwaps local g=f[e]if g then return g end if typeof(e)=='string'then
local h=self:FindStringIntSwap(e)if h then return`tostring({h})`end end local h=
typeof(e)=='number'if not h then return end local i=math.round(e)return f[i]end
function b:NeedsBrackets(e)if not e then return end if typeof(e)~='string'then
return true end return not e:match'^[%a_][%w_]*$'end function b:MakeName(e)local
f=self:ObjectToString(e)f=f:gsub('[./ #%@$%\u{a3}+-()\n\r]','')f=self:
MakePrintable(f,true)if self:NeedsBrackets(f)then return end if#f<1 or#f>30 then
return end return f end function b.new(e)local f={}local g=setmetatable(f,b)g.
ValueSwaps=g:MakeReplacements()return g end function b:Format(e,f)local g,h=self
.Formats,self.Variables f=f or{}local i,j=self.NoVariables or f.NoVariables,self
:FindValueSwap(e)if j then return j end local k=typeof(e)local l,m=(g[k])if
typeof(e)=='Instance'then m=self:MakeName(e)end if typeof(l)=='function'then
local n,o=l(self,e,f)if o and not i then n=h:MakeVariable{Name=m,Lookup=e,Value=
n}end return n end if not l then return`{e} --[[{k} not supported]]`end return l
:format(e)end function b:ObjectToString(e)local f,g,h=self.Swaps,self.IndexFunc,
self.ClassNameStrings local i,j=g(e,'Name'),g(e,'ClassName')local k=h[j]local l=
k or i l=self:MakePrintable(l,true)if f then local m=f[e]if m then l=m.String
end end return l end return b end function a.b()local b={}b.__index=b function
GetDictSize(c)local d=0 for e in next,c do d+=1 end return d end function b.new(
c)local d={}return setmetatable(d,b)end function b:FormatTableKey(c)local d=self
.Formatter local e=d:NeedsBrackets(c)if e then return end if typeof(c)~='string'
then return end return`{c} = `end function b:ParseTableIntoString(c)local d,e,f,
g=self.Formatter,c.Indent or 0,c.NoBrackets,c.Table local h=GetDictSize(g)if h==
0 then return f and''or'{}',h end local i,j,k=string.rep('\t',e),`{not f and'{'
or''}\n`,0 for l,m in next,g do local n,o,p='','',d:Format(m,c)k+=1 if typeof(l)
~='number'then o=self:FormatTableKey(l)if not o then local q=d:Format(m,c)o=`[{q
}] = `end end if k<h then n=','end j..=`{i}\t{o}{p}{n}\n`end j..=`{i}{not f and
'}'or''}`return j,h end function b:MakeVariableCodeLine(c)local d,e,f=c.Name,c.
Value,c.Comment local g,h=`local {d} = {e}`,f and` -- {f}`or''return`{g}{h}`end
function b:MakeVariableCodeLines(c)local d,e=self.Variables,c.Variables local f,
g=d:OrderVariables(e),''for h,i in f do local j=self:MakeVariableCodeLine(i)g..=
`{j}\n`end return g end function b:MakeVariableCode(c)local d=self.Variables
local e,f,g=d.VariablesDict,'',0 for h,i in next,c do local j=false repeat local
k=e[i]if not k then j=true break end g+=1 local l=g>1 and'\n'or''f..=`{l}-- {i}\n`
f..=self:MakeVariableCodeLines(k)j=true until true if not j then break end end
return f end function b:MakePathString(c)local d,e,f,g,h,i,j=self.Variables,self
.Formatter,c.Object,c.Parents,c.NoVariables,'',0 g=g or d:MakeParentsTable(f,h)
local k=function(k,l)local m=d:IsService(k)if not m then return end local n=`game:GetService("{
m}")`if h then i=n return true end local o=d:MakeVariable{Name=m,Class=
'Services',Value=n}i=o return true end for l,m in next,g do local n=false repeat
local o,p=e:ObjectToString(m),d:GetVariable(m)if p and not h then o=p.Name end
if l==2 and g[1]==game then if k(m,o)then n=true break end end local q,r=e:
NeedsBrackets(o),l>1 and'.'or''j+=1 i..=q and`["{o}"]`or`{r}{o}`n=true until
true if not n then break end end return i,j end return b end function a.c()local
b,c,d={},getfenv(1),{VariableBase='Jit'}d.__index=d local e,f=function(e,f)for g
,h in next,f do table.insert(e,h)end end,function(e,f)b[e]=f end function d.new(
g)local h={VariablesDict={},VariableLookup={},InstanceQueue={},VariableNames={},
NoNameCount=0}return setmetatable(h,d)end function d:GetNoNameCount()return self
.NoNameCount end function d:AddVariableToClass(g,h)local i=h.Value local j=h.
Lookup or i g.VariableCount+=1 local k,l=g.VariableCount,g.Variables h.Order=k l
[j]=h end function d:GetClassDict(g)local h=self.VariablesDict local i=h[g]if i
then return i end i={VariableCount=0,Variables={}}h[g]=i return i end function d
:IsGlobal(g)local h=self.IndexFunc if typeof(g)=='Instance'then local i=h(g,
'Name')return c[i]==g end return c[g]and g or false end function d:IsService(g)
local h=self.IndexFunc local i=h(g,'ClassName')local j=pcall(function()return
game:GetService(i)end)return j and i or false end function d:
IncreaseNameUseCount(g)if not g then return 0 end local h=self.VariableNames
local i=h[g]if not i then i=0 h[g]=i end h[g]+=1 return i end function d:
IncreaseNoNameCount()self.NoNameCount+=1 return self.NoNameCount end function d:
CheckName(g)local h=g.Name local i=self:IncreaseNameUseCount(h)if h then if i<=0
then return h else return`{h}{i}`end end local j,k=self:IncreaseNoNameCount(),
self.VariableBase return k:format(j)end function d:GetVariable(g)local h=self.
VariableLookup return h[g]end function d:OrderVariables(g)local h={}for i,j in
next,g do local k=j.Order table.insert(h,k,j)end return h end function d:
MakeVariable(g)local h,i,j=self.VariableLookup,self.InstanceQueue,g.Value local
k,l=g.Lookup or j,g.Class or'Variables'local m=self:GetVariable(k)if m then
return m.Name end local n=self:IsGlobal(j)if n then return n end if not g.Name
and typeof(j)=='Instance'then i[j]=g end local o=self:CheckName(g)g.Name=o local
p=self:GetClassDict(l)self:AddVariableToClass(p,g)h[k]=g return o end function d
:CollectTableItems(g,h)local i=function(i)local j=typeof(i)if j=='table'then
self:CollectTableItems(i,h)return end h(i)end for j,k in next,g do i(j)i(k)end
end function d:FindDuplicates(g)local h,i={},{}for j,k in next,g do local l=
false repeat local m=i[k]if m==1 then i[k]=2 table.insert(h,k)l=true break end i
[k]=1 l=true until true if not l then break end end table.clear(i)return h end
function d:CollectTableTypes(g,h)local i={}local j=function(j)local k=typeof(j)
if not table.find(h,k)then return end local l=i[k]if not l then l={}i[k]=l end
table.insert(l,j)end self:CollectTableItems(g,j)return i end function d:
MakeParentsTable(g,h)local i,j,k,l,m=self.IndexFunc,self.Swaps,self.Variables,{}
,g while true do local n=m m=i(m,'Parent')if m==game and self:IsGlobal(n)then m=
nil end if j then local o=j[n]if o and o.NextParent then m=o.NextParent end end
local o=k:GetVariable(n)if not h and o and m then m=nil end table.insert(l,1,n)
if not m then break end end return l end function d:BulkCollectParents(g)local h
,i={},{}for j,k in next,g do local l=false repeat if typeof(k)~='Instance'then l
=true break end local m=self:MakeParentsTable(k)e(h,m)i[k]=m l=true until true
if not l then break end end return h,i end function d:PrerenderVariables(g,h)
local i=self:CollectTableTypes(g,h)for j,k in next,i do local l=b[j]if l then l(
self,k)end end end f('Instance',function(g,h)local i,j,k,l=g.Parser,g.Formatter,
g:BulkCollectParents(h)local m=g:FindDuplicates(k)for n,o in next,m do local p=
false repeat local q,r=i:MakePathString{Object=o}if r<3 then p=true break end
local s=j:MakeName(o)g:MakeVariable{Lookup=o,Name=s,Value=q}p=true until true if
not p then break end end end)return d end end local b,c={Version='1.0.8',Author=
'Depso',License='GNU-GPLv3',Repository=
'https://github.com/depthso/Roblox-parser',ImportUrl=
[[https://raw.githubusercontent.com/depthso/Roblox-parser/refs/heads/main]],
Modules={Formatter=a.load'a',Parser=a.load'b',Variables=a.load'c'}},function(b,c
)for d,e in next,c do b[d]=e end end function b:New(d)local e=self.Modules local
f={Variables=e.Variables.new(),Formatter=e.Formatter.new(),Parser=e.Parser.new()
}if d then c(f,d)end for g,h in next,f do local i=false repeat if typeof(h)~=
'table'then i=true break end if h.new then c(h,f)end i=true until true if not i
then break end end return f end return b