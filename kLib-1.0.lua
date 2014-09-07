local MAJOR,MINOR = "kLib-1.0", 1

local kLib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not kLib then return end -- No upgrade needed

kLib.embeds = kLib.embeds or {} -- table containing objects kLib is embedded in.
kLib.commands = kLib.commands or {} -- table containing commands registered
kLib.weakcommands = kLib.weakcommands or {} -- table containing self, command => func references for weak commands that don't persist through enable/disable

-- Lua APIs
local tconcat, tostring, select = table.concat, tostring, select
local type, pairs, error = type, pairs, error
local format, strfind, strsub = string.format, string.find, string.sub
local max = math.max

-- WoW APIs
local _G = _G

--[[ Create debug messages
]]
function kLib:Debug(...)
  local isDevLoaded = IsAddOnLoaded('_Dev')
  local isSpewLoaded = IsAddOnLoaded('Spew')
  local prefix = "|cff33ff99"..tostring( self ).."|r: "
  local threshold = select(select('#', ...), ...) or 3
  if type(threshold) ~= 'number' then threshold = 3 end
  if self.db.profile.debug.enabled then
    if (threshold >= self.db.profile.debug.threshold) then
      if isSpewLoaded then
        Spew(...)
      elseif isDevLoaded then
        dump(prefix, ...)
      else
        self:Print(ChatFrame1, ('%s%s'):format(prefix,...))     
      end
    end
  end
end

--[[ Output basic error messages
]]
function kLib:Error(...)
  if not ... then return end
  self:Print(ChatFrame1, ('Error: %s'):format(strjoin(' - ', ...)))
end

--[[ Check if debug mode active
]]
function kLib:InDebug()
  return self.db.profile.debug.enabled
end

--- embedding and embed handling
local mixins = {
  'Debug',
  'Error',
  'InDebug',
} 

-- Embeds kLib into the target object making the functions from the mixins list available on target:..
-- @param target target object to embed AceBucket in
function kLib:Embed( target )
  for k, v in pairs( mixins ) do
    target[v] = self[v]
  end
  self.embeds[target] = true
  return target
end

function kLib:OnEmbedEnable( target )
  if kLib.weakcommands[target] then
    for command, func in pairs( kLib.weakcommands[target] ) do
      target:RegisterChatCommand( command, func, false, true ) -- nonpersisting and silent registry
    end
  end
end

function kLib:OnEmbedDisable( target )
  if kLib.weakcommands[target] then
    for command, func in pairs( kLib.weakcommands[target] ) do
      target:UnregisterChatCommand( command ) -- TODO: this could potentially unregister a command from another application in case of command conflicts. Do we care?
    end
  end
end

for addon in pairs(kLib.embeds) do
  kLib:Embed(addon)
end
