require "ISUI/ISPanel"
require "ISUI/ISButton"

EscapadeExpressRolePicker = EscapadeExpressRolePicker or {}

local RolePickerPanel = ISPanel:derive("EscapadeExpressRolePickerPanel")

local ROLE_ORDER = {
    "soldat", "voleur", "local_", "medic",
    "rambo", "sniper", "samourai", "geek",
    "survivaliste", "pompier", "mecanicien", "athlete",
    "eclaireur", "demolisseur", "invincible", "mule",
    "civil",
}

local ROLE_INFO = {
    soldat = {
        name = "Soldat",
        summary = "Combat / assaut",
        strengths = "Pistolet, couteau, sac de soin",
    },
    voleur = {
        name = "Voleur",
        summary = "Furtivite / melee",
        strengths = "Crowbar, discretion, sac léger",
    },
    local_ = {
        name = "Local",
        summary = "Survie / ressources",
        strengths = "Outils, vivres, carte du mall",
    },
    medic = {
        name = "Medic",
        summary = "Soin / support",
        strengths = "Soins lourds, couteau, duffel",
    },
    rambo = {
        name = "Rambo",
        summary = "Assaut / melee",
        strengths = "Hache, lance machette, tank",
    },
    sniper = {
        name = "Sniper",
        summary = "Tir longue distance",
        strengths = ".308 x50, lunette x4, discretion",
    },
    samourai = {
        name = "Samourai",
        summary = "Katana / precision",
        strengths = "Katana, lames, mobilite",
    },
    geek = {
        name = "Geek",
        summary = "Electronique / support",
        strengths = "Pieces, livres, bidouille",
    },
    survivaliste = {
        name = "Survivaliste",
        summary = "Nature / precision",
        strengths = "Sniper, ALICE pack, camping",
    },
    pompier = {
        name = "Pompier",
        summary = "Sauvetage / anti-feu",
        strengths = "Extincteur, hache, secours",
    },
    mecanicien = {
        name = "Mecanicien",
        summary = "Vehicule / reparations",
        strengths = "Crowbar, outils, reparations",
    },
    athlete = {
        name = "Athlete",
        summary = "Vitesse / mobilite",
        strengths = "Course, esquive, endurance",
    },
    eclaireur = {
        name = "Eclaireur",
        summary = "Exploration / guide",
        strengths = "Machete, carte, discretion",
    },
    demolisseur = {
        name = "Demolisseur",
        summary = "Explosions / chaos",
        strengths = "Bombes, molotovs, masse",
    },
    invincible = {
        name = "Invincible",
        summary = "Tout au max",
        strengths = "Assault rifle, katana, max stats",
    },
    mule = {
        name = "Mule",
        summary = "Transport / stockage",
        strengths = "Gros sac, bidon, vivres",
    },
    civil = {
        name = "Civil",
        summary = "Mode difficile / lambda",
        strengths = "Aucune specialite, survie pure",
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
    self.cardLayouts = {}
    self.rowTop = 82
    self.rowHeight = 74
    self.cardHeight = 68
    self.columns = 3
    self.rowsPerColumn = 6
    self.columnGap = 16
    self.buttonWidth = 118
    self.buttonHeight = 24

    local contentWidth = self.width - 32
    self.cardWidth = math.floor((contentWidth - self.columnGap) / self.columns)

    for index, roleKey in ipairs(ROLE_ORDER) do
        local column = math.floor((index - 1) / self.rowsPerColumn)
        local row = (index - 1) % self.rowsPerColumn
        local x = 16 + (column * (self.cardWidth + self.columnGap))
        local y = self.rowTop + (row * self.rowHeight)

        self.cardLayouts[roleKey] = {
            x = x,
            y = y,
            width = self.cardWidth,
            height = self.cardHeight,
        }

        local buttonX = x + self.cardWidth - self.buttonWidth - 10
        local buttonY = y + self.cardHeight - self.buttonHeight - 8
        local button = ISButton:new(buttonX, buttonY, self.buttonWidth, self.buttonHeight, "Choisir", self, RolePickerPanel.onChooseRole)
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
        local title = "Choisir"
        local enabled = true

        if EscapadeExpressRolePicker.mode == "solo" then
            if EscapadeExpressRolePicker.pendingRole == roleKey then
                title = "Validation..."
                enabled = false
            end
        elseif state.taken then
            title = "Pris"
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
    self:drawText("16 roles uniques + Civil selectionnable. Si tout est pris, Civil devient le fallback automatique.", 16, 40, 0.9, 0.9, 0.9, 1, UIFont.Small)
    self:drawText("Le chrono commencera quand la selection initiale sera terminee.", 16, 58, 0.9, 0.9, 0.9, 1, UIFont.Small)
end

function RolePickerPanel:render()
    ISPanel.render(self)

    for _, roleKey in ipairs(ROLE_ORDER) do
        local info = ROLE_INFO[roleKey]
        local state = EscapadeExpressRolePicker.roleStates[roleKey] or {taken = false, takenBy = nil}
        local layout = self.cardLayouts[roleKey]
        local rowX = layout.x
        local rowY = layout.y
        local rowWidth = layout.width
        local rowHeight = layout.height

        self:drawRect(rowX, rowY, rowWidth, rowHeight, COLOR_ROW.a, COLOR_ROW.r, COLOR_ROW.g, COLOR_ROW.b)
        self:drawRectBorder(rowX, rowY, rowWidth, rowHeight, 0.8, 0.35, 0.35, 0.35)

        self:drawText(info.name, rowX + 10, rowY + 8, 1, 1, 1, 1, UIFont.Medium)
        self:drawText(info.summary, rowX + 10, rowY + 28, 0.86, 0.86, 0.86, 1, UIFont.Small)
        self:drawText(info.strengths, rowX + 10, rowY + 44, 0.72, 0.72, 0.72, 1, UIFont.Small)

        local statusText = "Disponible"
        local statusColor = COLOR_AVAILABLE
        if state.taken then
            statusText = "Pris par " .. tostring(state.takenBy or "un autre joueur")
            statusColor = COLOR_TAKEN
        elseif EscapadeExpressRolePicker.pendingRole == roleKey then
            statusText = "Validation en cours..."
            statusColor = COLOR_PENDING
        end

        self:drawText(statusText, rowX + 10, rowY + 58, statusColor.r, statusColor.g, statusColor.b, statusColor.a, UIFont.Small)
    end

    if EscapadeExpressRolePicker.statusText ~= nil then
        local c = EscapadeExpressRolePicker.statusColor or COLOR_WHITE
        self:drawTextCentre(EscapadeExpressRolePicker.statusText, self.width / 2, self.height - 24, c.r, c.g, c.b, c.a, UIFont.Small)
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

    local width = math.min(1040, getCore():getScreenWidth() - 20)
    local height = math.min(620, getCore():getScreenHeight() - 20)
    local x = math.max(10, math.floor((getCore():getScreenWidth() - width) / 2))
    local y = math.max(10, math.floor((getCore():getScreenHeight() - height) / 2))

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
