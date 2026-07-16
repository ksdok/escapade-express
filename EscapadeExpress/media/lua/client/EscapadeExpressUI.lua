-- ============================================================
-- ESCAPADE EXPRESS - UI (chronometre + messages)
-- Affiche le timer 3h, le role, et les alertes a l'ecran
-- ============================================================

require "EscapadeExpressShared"

local UI = {}

-- Couleurs (R, G, B, A) 0-1
local COLOR_WHITE = {1, 1, 1, 1}
local COLOR_GREEN = {0.2, 0.8, 0.2, 1}
local COLOR_YELLOW = {1, 1, 0.2, 1}
local COLOR_RED = {1, 0.2, 0.2, 1}
local COLOR_BG = {0, 0, 0, 0.6}

local DURATION_HOURS = 3
local HUD_MARGIN_X = 20
local HUD_MARGIN_Y = 20
local HUD_LINE_GAP = 24

-- Messages temporaires (fondu)
UI.messages = {}
UI.messageDuration = 5  -- secondes d'affichage


-- ============================================================
-- OUTILS DE POSITIONNEMENT HUD
-- ============================================================

local function getRightAlignedX(font, text)
    local screenWidth = getCore():getScreenWidth()
    local textWidth = getTextManager():MeasureStringX(font, text)
    return screenWidth - textWidth - HUD_MARGIN_X
end

-- ============================================================
-- AFFICHAGE DU CHRONOMETRE
-- ============================================================

local function drawTimer()
    if EE_startTime == nil then return end
    if EE_gameOver then
        local gameOverText = "TEMPS ECOULE - GAME OVER"
        getTextManager():DrawString(UIFont.NewMedium, getRightAlignedX(UIFont.NewMedium, gameOverText), HUD_MARGIN_Y,
            gameOverText, 1, 0.2, 0.2, 1)
        return
    end

    local elapsed = getGameTime():getWorldAgeHours() - EE_startTime
    local remaining = DURATION_HOURS - elapsed
    if remaining <= 0 then return end

    local totalMin = math.floor(remaining * 60)
    local hours = math.floor(totalMin / 60)
    local mins = totalMin % 60

    local text = string.format("Temps restant: %dh%02d", hours, mins)

    -- Couleur selon le temps restant
    local color
    if remaining > 1.5 then
        color = COLOR_GREEN
    elseif remaining > 0.5 then
        color = COLOR_YELLOW
    else
        color = COLOR_RED
    end

    getTextManager():DrawString(UIFont.NewMedium, getRightAlignedX(UIFont.NewMedium, text), HUD_MARGIN_Y, text,
        color[1], color[2], color[3], color[4])
end

-- ============================================================
-- AFFICHAGE DU ROLE
-- ============================================================

local function drawRole()
    local pl = getPlayer()
    if pl == nil then return end
    local role = pl:getModData().EE_role
    if role == nil then return end

    local roleNames = {
        soldat = "Soldat",
        voleur = "Voleur",
        local_ = "Local",
        medic = "Medic",
        rambo = "Rambo",
        sniper = "Sniper",
        samourai = "Samourai",
        geek = "Geek",
        survivaliste = "Survivaliste",
        pompier = "Pompier",
        mecanicien = "Mecanicien",
        athlete = "Athlete",
        eclaireur = "Eclaireur",
        demolisseur = "Demolisseur",
        invincible = "Invincible",
        mule = "Mule",
        civil = "Civil",
    }
    local name = roleNames[role] or role
    local text = "Role: " .. name

    getTextManager():DrawString(UIFont.NewSmall, getRightAlignedX(UIFont.NewSmall, text), HUD_MARGIN_Y + HUD_LINE_GAP, text,
        COLOR_WHITE[1], COLOR_WHITE[2], COLOR_WHITE[3], COLOR_WHITE[4])
end

-- ============================================================
-- AFFICHAGE DES MESSAGES TEMPORAIRES
-- ============================================================

local function drawMessages()
    local nowSeconds = EE_getNowSeconds()
    local y = HUD_MARGIN_Y + (HUD_LINE_GAP * 2) + 10
    for i = #UI.messages, 1, -1 do
        local msg = UI.messages[i]
        local age = nowSeconds - msg.time
        if age >= UI.messageDuration then
            table.remove(UI.messages, i)
        else
            local alpha = 1
            if age > UI.messageDuration - 1 then
                alpha = UI.messageDuration - age  -- fondu
            end
            getTextManager():DrawString(UIFont.NewMedium, getRightAlignedX(UIFont.NewMedium, msg.text), y, msg.text,
                msg.color[1], msg.color[2], msg.color[3], alpha)
            y = y + 25
        end
    end
end

-- ============================================================
-- FONCTION POUR AJOUTER UN MESSAGE (depuis autres fichiers)
-- ============================================================

function UI.addMessage(text, color)
    table.insert(UI.messages, {
        text = text,
        color = color or COLOR_WHITE,
        time = EE_getNowSeconds()
    })
end

-- ============================================================
-- HOOK DE RENDU
-- ============================================================

local function onPostUIDraw()
    drawTimer()
    drawRole()
    drawMessages()
end
Events.OnPostUIDraw.Add(onPostUIDraw)

-- ============================================================
-- MESSAGES VIA COMMANDES SERVEUR
-- ============================================================

local function onServerCommand(module, command, data)
    if module ~= "EscapadeExpress" then return end

    if command == "AlertMessage" then
        local color = COLOR_WHITE
        if data.type == "warning" then color = COLOR_YELLOW
        elseif data.type == "danger" then color = COLOR_RED
        elseif data.type == "success" then color = COLOR_GREEN
        end
        UI.addMessage(data.text, color)
    elseif command == "RoleAssigned" then
        local pl = getPlayer()
        if pl and data.username == pl:getUsername() then
            UI.addMessage("Role: " .. data.roleName, COLOR_GREEN)
        end
    elseif command == "RoleDenied" then
        local pl = getPlayer()
        if pl and data.username == pl:getUsername() then
            UI.addMessage(data.text or "Trop de joueurs pour ce scenario!", COLOR_RED)
        end
    end
end
Events.OnServerCommand.Add(onServerCommand)