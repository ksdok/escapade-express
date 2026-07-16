require "ISUI/ISPanel"
require "ISUI/ISButton"

EscapadeExpressRolePicker = EscapadeExpressRolePicker or {}

local RolePickerPanel = ISPanel:derive("EscapadeExpressRolePickerPanel")

local ROLE_ORDER = {"soldat", "voleur", "local_", "medic"}
local ROLE_INFO = {
    soldat = {
        name = "Soldat",
        summary = "Combat / protection",
        strengths = "Pistolet, robustesse, couverture",
    },
    voleur = {
        name = "Voleur",
        summary = "Furtivite / utilitaire",
        strengths = "Discretion, crowbar, mobilite",
    },
    local_ = {
        name = "Local",
        summary = "Survie / ressources",
        strengths = "Outils, vivres, sac a dos",
    },
    medic = {
        name = "Medic",
        summary = "Soin / support",
        strengths = "Bandages, soins, secours",
    },
}

local COLOR_BG = {r = 0.05, g = 0.05, b = 0.05, a = 0.92}
local COLOR_BORDER = {r = 0.7, g = 0.7, b = 0.7, a = 1}
local COLOR_ROW = {r = 0.14, g = 0.14, b = 0.14, a = 0.85}
local COLOR_AVAILABLE = {r = 0.2, g = 0.85, b = 0.3, a = 1}
local COLOR_TAKEN = {r = 0.9, g = 0.35, b = 0.35, a = 1}
local COLOR_PENDING = {r = 1, g = 0.85, b = 0.2, a = 1}
local COLOR_WHITE = {r = 1, g = 1, b = 1, a = 1}

EscapadeExpressRolePicker.panel = nil
EscapadeExpressRolePicker.mode = nil
EscapadeExpressRolePicker.roleStates = {}
EscapadeExpressRolePicker.statusText = nil
EscapadeExpressRolePicker.statusColor = COLOR_WHITE
EscapadeExpressRolePicker.pendingRole = nil

local function cloneRoleStates(roleStates)
    local result = {}
    for _, roleKey in ipairs(ROLE_ORDER) do
        local state = roleStates and roleStates[roleKey] or nil
        result[roleKey] = {
            taken = state ~= nil and state.taken == true or false,
            takenBy = state and state.takenBy or nil,
        }
    end
    return result
end

local function buildAllAvailableStates()
    local result = {}
    for _, roleKey in ipairs(ROLE_ORDER) do
        result[roleKey] = {
            taken = false,
            takenBy = nil,
        }
    end
    return result
end

local function getLocalUsername()
    local pl = getPlayer()
    return pl and pl:getUsername() or nil
end

local function setButtonEnabled(button, enabled)
    if button == nil then return end
    if button.setEnable ~= nil then
        button:setEnable(enabled)
    else
        button.enable = enabled
    end
end

local function setButtonTitle(button, title)
    if button == nil then return end
    if button.setTitle ~= nil then
        button:setTitle(title)
    else
        button.title = title
    end
end

function RolePickerPanel:initialise()
    ISPanel.initialise(self)
end

function RolePickerPanel:createChildren()
    ISPanel.createChildren(self)

    if self.roleButtons ~= nil then return end

    self.roleButtons = {}
    self.rowTop = 70
    self.rowHeight = 92
    self.buttonWidth = 150

    for index, roleKey in ipairs(ROLE_ORDER) do
        local y = self.rowTop + ((index - 1) * self.rowHeight) + 44
        local button = ISButton:new(self.width - self.buttonWidth - 24, y, self.buttonWidth, 28, "Choisir ce role", self, RolePickerPanel.onChooseRole)
        button.internal = roleKey
        button:initialise()
        button:instantiate()
        self:addChild(button)
        self.roleButtons[roleKey] = button
    end

    self:updateButtons()
end

function RolePickerPanel:onChooseRole(button)
    local roleKey = button and button.internal or nil
    if roleKey == nil then return end

    EscapadeExpressRolePicker.statusText = nil
    EscapadeExpressRolePicker.statusColor = COLOR_WHITE

    if EscapadeExpressRolePicker.mode == "solo" then
        local pl = getPlayer()
        if pl == nil then return end
        if EscapadeExpress == nil or EscapadeExpress.ApplyRoleLocally == nil then return end

        local applied = EscapadeExpress.ApplyRoleLocally(pl, roleKey)
        if applied ~= nil then
            if EscapadeExpress.StartLocalScenarioTimer ~= nil then
                EscapadeExpress.StartLocalScenarioTimer()
            end
            EscapadeExpressRolePicker.close()
        end
        return
    end

    EscapadeExpressRolePicker.pendingRole = roleKey
    self:updateButtons()
    sendClientCommand("EscapadeExpress", "ChooseRole", {
        roleKey = roleKey,
    })
end

function RolePickerPanel:updateButtons()
    for _, roleKey in ipairs(ROLE_ORDER) do
        local button = self.roleButtons[roleKey]
        local state = EscapadeExpressRolePicker.roleStates[roleKey] or {taken = false, takenBy = nil}
        local title = "Choisir ce role"
        local enabled = true

        if EscapadeExpressRolePicker.mode == "solo" then
            if EscapadeExpressRolePicker.pendingRole == roleKey then
                title = "Validation..."
                enabled = false
            end
        elseif state.taken then
            title = "Role pris"
            enabled = false
        elseif EscapadeExpressRolePicker.pendingRole == roleKey then
            title = "Validation..."
            enabled = false
        end

        setButtonTitle(button, title)
        setButtonEnabled(button, enabled)
    end
end

function RolePickerPanel:prerender()
    ISPanel.prerender(self)

    self:drawTextCentre("Choisis ton role", self.width / 2, 12, 1, 1, 1, 1, UIFont.Medium)
    self:drawText("Le chrono commencera quand la selection initiale sera terminee.", 16, 40, 0.9, 0.9, 0.9, 1, UIFont.Small)
end

function RolePickerPanel:render()
    ISPanel.render(self)

    for index, roleKey in ipairs(ROLE_ORDER) do
        local info = ROLE_INFO[roleKey]
        local state = EscapadeExpressRolePicker.roleStates[roleKey] or {taken = false, takenBy = nil}
        local top = self.rowTop + ((index - 1) * self.rowHeight)
        local rowX = 16
        local rowY = top
        local rowWidth = self.width - 32
        local rowHeight = self.rowHeight - 10

        self:drawRect(rowX, rowY, rowWidth, rowHeight, COLOR_ROW.a, COLOR_ROW.r, COLOR_ROW.g, COLOR_ROW.b)
        self:drawRectBorder(rowX, rowY, rowWidth, rowHeight, 0.8, 0.35, 0.35, 0.35)

        self:drawText(info.name, rowX + 12, rowY + 10, 1, 1, 1, 1, UIFont.Medium)
        self:drawText(info.summary, rowX + 12, rowY + 34, 0.85, 0.85, 0.85, 1, UIFont.Small)
        self:drawText("Forces: " .. info.strengths, rowX + 12, rowY + 54, 0.72, 0.72, 0.72, 1, UIFont.Small)

        local statusText = "Disponible"
        local statusColor = COLOR_AVAILABLE
        if state.taken then
            statusText = "Pris par " .. tostring(state.takenBy or "un autre joueur")
            statusColor = COLOR_TAKEN
        elseif EscapadeExpressRolePicker.pendingRole == roleKey then
            statusText = "Validation en cours..."
            statusColor = COLOR_PENDING
        end

        self:drawText(statusText, rowX + 12, rowY + 72, statusColor.r, statusColor.g, statusColor.b, statusColor.a, UIFont.Small)
    end

    if EscapadeExpressRolePicker.statusText ~= nil then
        local c = EscapadeExpressRolePicker.statusColor or COLOR_WHITE
        self:drawTextCentre(EscapadeExpressRolePicker.statusText, self.width / 2, self.height - 28, c.r, c.g, c.b, c.a, UIFont.Small)
    end
end

function EscapadeExpressRolePicker.isVisible()
    return EscapadeExpressRolePicker.panel ~= nil
end

function EscapadeExpressRolePicker.setStatus(text, color)
    EscapadeExpressRolePicker.statusText = text
    EscapadeExpressRolePicker.statusColor = color or COLOR_WHITE
end

function EscapadeExpressRolePicker.setRoleStates(roleStates)
    if roleStates == nil then return end
    EscapadeExpressRolePicker.roleStates = cloneRoleStates(roleStates)
    if EscapadeExpressRolePicker.panel ~= nil then
        EscapadeExpressRolePicker.panel:updateButtons()
    end
end

function EscapadeExpressRolePicker.open(mode, roleStates)
    EscapadeExpressRolePicker.mode = mode or "network"
    EscapadeExpressRolePicker.pendingRole = nil
    EscapadeExpressRolePicker.statusText = nil
    EscapadeExpressRolePicker.statusColor = COLOR_WHITE
    EscapadeExpressRolePicker.roleStates = cloneRoleStates(roleStates or buildAllAvailableStates())

    if EscapadeExpressRolePicker.panel ~= nil then
        EscapadeExpressRolePicker.panel:updateButtons()
        return EscapadeExpressRolePicker.panel
    end

    local width = 620
    local height = 460
    local x = math.floor((getCore():getScreenWidth() - width) / 2)
    local y = math.floor((getCore():getScreenHeight() - height) / 2)

    local panel = RolePickerPanel:new(x, y, width, height)
    panel:initialise()
    panel:instantiate()
    panel.backgroundColor = COLOR_BG
    panel.borderColor = COLOR_BORDER
    panel.moveWithMouse = false
    panel:createChildren()
    panel:addToUIManager()

    EscapadeExpressRolePicker.panel = panel
    return panel
end

function EscapadeExpressRolePicker.openLocal()
    return EscapadeExpressRolePicker.open("solo", buildAllAvailableStates())
end

function EscapadeExpressRolePicker.close()
    EscapadeExpressRolePicker.pendingRole = nil
    if EscapadeExpressRolePicker.panel ~= nil then
        EscapadeExpressRolePicker.panel:removeFromUIManager()
        EscapadeExpressRolePicker.panel = nil
    end
end

local function handleTargetedCommand(data)
    local username = getLocalUsername()
    return username ~= nil and data ~= nil and data.username == username
end

local function onServerCommand(module, command, data)
    if module ~= "EscapadeExpress" then return end

    if command == "OpenRolePicker" then
        if handleTargetedCommand(data) then
            local pl = getPlayer()
            if pl ~= nil and pl:getModData().EE_role == nil then
                EscapadeExpressRolePicker.open("network", data.roleStates)
            end
        end
    elseif command == "SyncRolePickerState" then
        EscapadeExpressRolePicker.setRoleStates(data and data.roleStates or nil)
    elseif command == "RoleUnavailable" then
        if handleTargetedCommand(data) then
            EscapadeExpressRolePicker.pendingRole = nil
            EscapadeExpressRolePicker.setRoleStates(data.roleStates or buildAllAvailableStates())
            EscapadeExpressRolePicker.setStatus(data.text or "Ce role vient d'etre pris.", COLOR_TAKEN)
            if EscapadeExpressRolePicker.panel ~= nil then
                EscapadeExpressRolePicker.panel:updateButtons()
            end
        end
    elseif command == "RoleAssigned" then
        if handleTargetedCommand(data) then
            EscapadeExpressRolePicker.close()
        end
    elseif command == "RoleDenied" then
        if handleTargetedCommand(data) then
            EscapadeExpressRolePicker.close()
        end
    end
end
Events.OnServerCommand.Add(onServerCommand)
