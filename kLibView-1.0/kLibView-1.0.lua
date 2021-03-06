local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error

local MAJOR, MINOR = "kLibView-1.0", 1

local kLibView, oldminor = LibStub:GetLibrary(MAJOR, true) and LibStub:GetLibrary(MAJOR, true) or LibStub:NewLibrary(MAJOR, MINOR)

_G.kLibView = kLibView

if not kLibView then return end -- No upgrade needed

kLibView.embeds = kLibView.embeds or {} -- table containing objects kLibView is embedded in.
kLibView.commands = kLibView.commands or {} -- table containing commands registered
kLibView.weakcommands = kLibView.weakcommands or {} -- table containing self, command => func references for weak commands that don't persist through enable/disable

-- Lua APIs
local tconcat, tostring, select = table.concat, tostring, select
local type, pairs, error = type, pairs, error
local format, strfind, strsub = string.format, string.find, string.sub
local max = math.max

--[[ Disable an object (alpha & mouse)
]]
function kLibView:View_DisableObject(object)
    if not object then return end
    object:EnableMouse(false)
    object:SetAlpha(self.alpha.disabled)
end

--[[ Enable an object (alpha & mouse)
]]
function kLibView:View_EnableObject(object)
    if not object then return end
    object:EnableMouse(true)
    object:SetAlpha(self.alpha.enabled)
end

--[[ Find an object by name and optional type
]]
function kLibView:View_FindObject(parent, name, objectType)
    if not name or not type(name) == 'string' or not parent then return end
    if parent.name and parent.name == name then
        if objectType then
            if parent.objectType and parent.objectType == objectType then return parent end
        else
            return parent
        end
    end
    for i, v in ipairs({ parent:GetChildren() }) do
        if v.name and v.name == name then
            if objectType then
                if v.objectType and v.objectType == objectType then return v end
            else
                return v
            end
        end
        local recursiveObject = self:View_FindObject(v, name, objectType)
        if recursiveObject then return recursiveObject end
    end
end

--[[ Get the color option for a view object
]]
function kLibView:View_GetColor(object, colorType)
    if not object or not object.objectType then return end
    colorType = colorType or 'default'
    if object.color then return object.color[colorType] end
end

--[[ Get object value
]]
function kLibView:View_GetFlag(object, flag)
    if not object then return end
    return object[flag]
end

--[[ Generate the view object name
]]
function kLibView:View_Name(object, parent)
    if not object then return end
    -- Assign actual object name
    if type(object) == 'table' then
        if object:GetName() then
            object = object:GetName()
        end
    end
    -- Check if object contains base addon name already, indicating full path
    if string.find(object, tostring(self)) then return object end

    if parent then
        if type(parent) == 'string' and string.find(parent, tostring(self)) then
            return ('%s%s'):format(parent, object)
        elseif type(parent) == 'table' and string.find(parent:GetName(), tostring(self)) then
            return ('%s%s'):format(parent:GetName(), object)
        end
    end
    return ('%s%s'):format(tostring(self), object)
end

--[[ Set the color option for a view object
]]
function kLibView:View_SetColor(object, colorType, color)
    if not object or not object.objectType then return end
    colorType = colorType or 'default'
    color = self:Color_Get(color)
    object.color = object.color or {}
    if color then
        object.color[colorType] = color
    else
        -- Check if objectType is found in defaults
        object.color[colorType] = self:Color_Default(object.objectType, colorType)
    end
end

--[[ Set object value
]]
function kLibView:View_SetFlag(object, flag, value)
    if not object then return end
    object[flag] = value
end

--[[ Update color for SquareButton
]]
function kLibView:View_UpdateColor(object, event)
    if not object or not object.objectType then return end
    local colorType = 'default'
    if event == 'OnMouseDown' or event == 'OnLeave' then
        if object.selected then
            colorType = 'selected'
        end
    elseif event == 'OnEnter' then
        colorType = 'hover'
    end
    self:View_Texture_Update(object, self:View_GetColor(object, colorType))
end

function kLibView:AddMixins(mixins)
    self.mixins = self.mixins or {}
    for i, v in pairs(mixins) do
        tinsert(self.mixins, v)
    end
end

-- Embeds kLibView into the target object making the functions from the mixins list available on target:..
-- @param target target object to embed AceBucket in
function kLibView:Embed(target)
    for k, v in pairs(self.mixins) do
        target[v] = self[v]
    end
    self.embeds[target] = true
    return target
end

function kLibView:OnEmbedEnable(target)
    if kLibView.weakcommands[target] then
        for command, func in pairs(kLibView.weakcommands[target]) do
            target:RegisterChatCommand(command, func, false, true) -- nonpersisting and silent registry
        end
    end
end

function kLibView:OnEmbedDisable(target)
    if kLibView.weakcommands[target] then
        for command, func in pairs(kLibView.weakcommands[target]) do
            target:UnregisterChatCommand(command) -- TODO: this could potentially unregister a command from another application in case of command conflicts. Do we care?
        end
    end
end

--- embedding and embed handling
local mixins = {
    'View_DisableObject',
    'View_EnableObject',
    'View_FindObject',
    'View_GetColor',
    'View_GetFlag',
    'View_Name',
    'View_SetColor',
    'View_SetFlag',
    'View_UpdateColor',
}

-- Add Mixins
kLibView:AddMixins(mixins)