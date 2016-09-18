local MAJOR, MINOR = "kLib-1.0", 1

local kLib = LibStub:NewLibrary(MAJOR, MINOR)

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
    if not IsAddOnLoaded('Blizzard_DebugTools') then
        LoadAddOn('Blizzard_DebugTools')
    end
    local prefix = self:Color_String(tostring(self), 1, 0.5, 0.5, 1)
    local args = {...}
    local threshold = args[#args] or 3
    if type(threshold) ~= 'number' then threshold = 3 end
    if self.db.profile.debug.enabled then
        if (threshold >= self.db.profile.debug.threshold) then
            -- Check if contains enough values for threshold.
            if #args >= 2 then
                local last = args[#args]
                -- Is last value numeric.
                if type(last) == 'number' then
                    -- If within valid thresholds.
                    if last >= 0 and last <= 3 then
                        -- Remove final value from list.
                        tremove(args, #args)
                    end
                end
            end
            print(prefix)
            -- Output
            DevTools_Dump(args)
        end
    end
end

--[[ Output basic error messages
]]
function kLib:Error(...)
    if not ... then return end
    self:Print(ChatFrame1, ('Error: %s'):format(strjoin(' - ', ...)))
end

--[[ Format realm name
]]
function kLib:FormatRealm(realm)
    realm = realm and realm or self.realm
    return string.lower(string.gsub(realm, " ", "-"))
end

--[[ Retrieve the region based on locale string
]]
function kLib:GetRegion()
    local locales = {
        deDE = 'eu',
        enGB = 'eu',
        enUS = 'us',
        esES = 'us',
        esMX = 'us',
        frFR = 'eu',
        itIT = 'eu',
        koKR = 'kr',
        ptBR = 'us',
        ruRU = 'eu',
        zhCN = 'tw',
        zhTW = 'tw',
    }

    return locales[GetLocale()]
end

--[[ Check if debug mode active
]]
function kLib:InDebug()
    return self.db.profile.debug.enabled
end

--[[ Determine if object is of custom type
]]
function kLib:IsType(object, type)
    return (self:Type(object) == type)
end

-- [[ Determine the type of passed object (custom or standard) ]]
function kLib:Type(object)
    -- check if type is table, possibly containing custom type
    if type(object) == 'table' then
        if object.type then
            return object.type
        elseif object.objectType then
            return object.objectType
        elseif object.object_type then
            return object.object_type
        else
            return type(object)
        end
    else
        return type(object)
    end
end

--- embedding and embed handling
local mixins = {
    'Debug',
    'Error',
    'InDebug',
    'FormatRealm',
    'GetRegion',
    'IsType',
    'Type',
}

-- Embeds kLib into the target object making the functions from the mixins list available on target:..
-- @param target target object to embed AceBucket in
function kLib:Embed(target)
    for k, v in pairs(mixins) do
        target[v] = self[v]
    end
    self.embeds[target] = true
    return target
end

function kLib:OnEmbedEnable(target)
    if kLib.weakcommands[target] then
        for command, func in pairs(kLib.weakcommands[target]) do
            target:RegisterChatCommand(command, func, false, true) -- nonpersisting and silent registry
        end
    end
end

function kLib:OnEmbedDisable(target)
    if kLib.weakcommands[target] then
        for command, func in pairs(kLib.weakcommands[target]) do
            target:UnregisterChatCommand(command)
        end
    end
end

for addon in pairs(kLib.embeds) do
    kLib:Embed(addon)
end
