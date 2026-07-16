-- ============================================================
-- ESCAPADE EXPRESS - Scenario principal (client/LastStand)
-- Sortie du Xonic's Mega Mall en 3h, 4 joueurs coop, B41
-- Base sur le pattern Pillow's Random Scenarios
-- ============================================================

require "EscapadeExpressShared"

EscapadeExpress = {}

-- ============================================================
-- COORDONNEES (PLACEHOLDERS - a ajuster en jeu avec debug)
-- Cell 37x28 = world coords debut 11100, 8400
-- Procedure: mode debug, teleporter a la position, lire coords
-- ============================================================

local SPAWN = {xcell = 37, ycell = 28, x = 120, y = 120, z = 0}  -- placeholder arriere-boutique

-- Parking du mall (placeholder)
local PARKING_X = 11250
local PARKING_Y = 8550
local PARKING_Z = 0

-- Emplacement du bidon d'essence (placeholder, different du parking)
local GAS_CAN_LOCATION = {x = 11170, y = 8490, z = 0}

-- ============================================================
-- CONSTANTES DU SCENARIO
-- ============================================================

local DURATION_HOURS = 3         -- duree totale

local ROLE_NAMES = {
    soldat = "Soldat",
    voleur = "Voleur",
    local_ = "Local",
    medic = "Medic",
}

local ROLE_DEFS = {
    soldat = {
        skills = {
            {Perks.Aiming, 4},
            {Perks.Reloading, 3},
            {Perks.Fitness, 4},
            {Perks.Strength, 4},
            {Perks.Sneak, 2},
        },
        items = {
            {"Base.Pistol", 1},
            {"Base.9mmClip", 2},
            {"Base.Bullets9mm", 30},
            {"Base.Bandage", 3},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.HoodieDOWN_WhiteTINT", 1},
            {"Base.Trousers", 1},
        },
    },
    voleur = {
        skills = {
            {Perks.Sneak, 5},
            {Perks.Lightfoot, 5},
            {Perks.Nimble, 5},
            {Perks.Electrical, 2},
            {Perks.Fitness, 3},
        },
        items = {
            {"Base.Crowbar", 1},
            {"Base.Screwdriver", 1},
            {"Base.Bandage", 2},
            {"Base.Torch", 1},
            {"Base.Battery", 1},
            {"Base.HoodieDOWN_WhiteTINT", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
        },
    },
    local_ = {
        skills = {
            {Perks.Cooking, 4},
            {Perks.Carpentry, 4},
            {Perks.PlantScavenging, 3},
            {Perks.Fitness, 3},
            {Perks.Strength, 3},
        },
        items = {
            {"Base.Hammer", 1},
            {"Base.Nails", 20},
            {"Base.Saw", 1},
            {"Base.WaterBottleFull", 2},
            {"Base.TinnedBeans", 2},
            {"Base.TinOpener", 1},
            {"Base.Bandage", 2},
            {"Base.Bag_NormalHikingBag", 1},
            {"Base.Map", 1},
        },
    },
    medic = {
        skills = {
            {Perks.Doctor, 6},
            {Perks.Fitness, 3},
            {Perks.Strength, 3},
            {Perks.Aiming, 2},
        },
        items = {
            {"Base.Bandage", 5},
            {"Base.Disinfectant", 2},
            {"Base.Pills", 2},
            {"Base.Antibiotics", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.Bag_DuffelBag", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
        },
    },
}

-- State global (partage entre fichiers client)
EE_startTime = nil
EE_gameOver = false

local timeWarningsShown = {}
local runtimeHooksRegistered = false
local soloPickerFallbackAt = nil
local soloFallbackTickRegistered = false

local function isSinglePlayerRuntime()
    if isClient ~= nil then
        return not isClient()
    end

    if getOnlinePlayers ~= nil then
        local onlinePlayers = getOnlinePlayers()
        return onlinePlayers == nil or onlinePlayers:size() == 0
    end

    return true
end

local function applyRoleLocally(player, roleKey)
    if player == nil or roleKey == nil then return false end

    local def = ROLE_DEFS[roleKey]
    if def == nil then return false end

    local modData = player:getModData()
    if modData.EE_localRoleApplied == roleKey then
        modData.EE_role = roleKey
        modData.EE_reviveEnabled = true
        return false
    end

    local inv = player:getInventory()
    for _, itemDef in ipairs(def.items) do
        local itemId, count = itemDef[1], itemDef[2]
        if count > 1 then
            inv:AddItems(itemId, count)
        else
            inv:AddItem(itemId)
        end
    end

    for _, skillDef in ipairs(def.skills) do
        local perk, level = skillDef[1], skillDef[2]
        player:getXp():setXPToLevel(perk, level)
    end

    player:getStats():setPanic(30)
    player:getStats():setHunger(0.2)
    player:getStats():setThirst(0.2)
    player:getStats():setFatigue(0)

    modData.EE_role = roleKey
    modData.EE_reviveEnabled = true
    modData.EE_localRoleApplied = roleKey

    return true
end

local function syncWarningStateFromTimer()
    timeWarningsShown = {}

    if EE_startTime == nil then return end

    local elapsed = getGameTime():getWorldAgeHours() - EE_startTime
    local remainingMin = math.floor((DURATION_HOURS - elapsed) * 60)

    if remainingMin < 120 then timeWarningsShown[120] = true end
    if remainingMin < 60 then timeWarningsShown[60] = true end
    if remainingMin < 30 then timeWarningsShown[30] = true end
    if remainingMin < 10 then timeWarningsShown[10] = true end
end

EscapadeExpress.ApplyRoleLocally = function(player, roleKey)
    return applyRoleLocally(player, roleKey)
end

EscapadeExpress.StartLocalScenarioTimer = function()
    if EE_startTime == nil then
        EE_startTime = getGameTime():getWorldAgeHours()
        syncWarningStateFromTimer()
    end
end

local function enforceRealTimeDayLength()
    if SandboxVars ~= nil then
        SandboxVars.DayLength = 26
    end

    if getGameTime ~= nil then
        local gameTime = getGameTime()
        if gameTime ~= nil and gameTime.setMinutesPerDay ~= nil then
            gameTime:setMinutesPerDay(60 * 24)
        end
    end
end

local function ensureSoloFallbackTickRegistered()
    if soloFallbackTickRegistered then return end
    Events.OnTick.Add(EscapadeExpress.TickRolePickerFallback)
    soloFallbackTickRegistered = true
end

local function unregisterSoloFallbackTick()
    if not soloFallbackTickRegistered then return end
    Events.OnTick.Remove(EscapadeExpress.TickRolePickerFallback)
    soloFallbackTickRegistered = false
end

local gameStartEventRegistered = false
local scenarioInitialized = false

-- ============================================================
-- 1. REGISTRATION (pattern Pillow's)
-- ============================================================

EscapadeExpress.Add = function()
    addChallenge(EscapadeExpress)
end

-- ============================================================
-- 2. HOOKS D'EVENEMENTS
-- ============================================================

local function registerRuntimeHooks()
    if runtimeHooksRegistered then return end

    runtimeHooksRegistered = true
    Events.EveryOneMinute.Add(EscapadeExpress.EveryMinutes)
    Events.OnPlayerDeath.Add(EscapadeExpress.OnPlayerDeath)
    Events.OnCreatePlayer.Add(EscapadeExpress.OnCreatePlayer)
end

EscapadeExpress.OnGameStart = function()
    enforceRealTimeDayLength()
    registerRuntimeHooks()
    EscapadeExpress.OnNewGame()
end

EscapadeExpress.OnInitWorld = function()
    scenarioInitialized = false

    if not gameStartEventRegistered then
        Events.OnGameStart.Add(EscapadeExpress.OnGameStart)
        gameStartEventRegistered = true
    end
end

-- ============================================================
-- 3. NOUVELLE PARTIE - initialisation
-- ============================================================

EscapadeExpress.OnNewGame = function()
    local pl = getPlayer()
    if pl == nil then return end
    if pl:getHoursSurvived() > 1 then return end

    if not scenarioInitialized then
        scenarioInitialized = true

        -- Le timer est synchronise par le serveur
        EE_startTime = nil
        EE_gameOver = false
        timeWarningsShown = {}
        soloPickerFallbackAt = nil

        -- Initialisation locale une seule fois
        pl:getModData().EE_reviveEnabled = true
        pl:getModData().EE_role = nil  -- sera assigne par le serveur
        pl:getModData().EE_localRoleApplied = nil
        pl:getModData().EE_roleSelectionDenied = false

        -- Message d'intro
        pl:Say("On est pieges dans le mall! Trouvez un vehicule et un bidon d'essence!")
    else
        -- Rejoin / create-player tardif: garder le revive actif
        pl:getModData().EE_reviveEnabled = true
    end

    if pl:getModData().EE_role ~= nil or pl:getModData().EE_roleSelectionDenied then
        return
    end

    if sendClientCommand ~= nil then
        if isSinglePlayerRuntime() and soloPickerFallbackAt == nil then
            soloPickerFallbackAt = EE_getNowSeconds() + 3
            ensureSoloFallbackTickRegistered()
        end

        -- Multiplayer: demander l'ouverture du picker tant que le role n'est pas confirme.
        sendClientCommand("EscapadeExpress", "RolePickerReady", {
            username = pl:getUsername()
        })
        return
    end

    -- Dernier recours: solo sans reseau local disponible.
    if isSinglePlayerRuntime() and not EscapadeExpressRolePicker.isVisible() then
        EscapadeExpressRolePicker.openLocal()
    end
end

EscapadeExpress.OnCreatePlayer = function()
    EscapadeExpress.OnNewGame()
end

EscapadeExpress.TickRolePickerFallback = function()
    if soloPickerFallbackAt == nil then
        unregisterSoloFallbackTick()
        return
    end

    if not isSinglePlayerRuntime() then
        soloPickerFallbackAt = nil
        unregisterSoloFallbackTick()
        return
    end

    local pl = getPlayer()
    if pl == nil then return end
    if pl:getModData().EE_role ~= nil then
        soloPickerFallbackAt = nil
        unregisterSoloFallbackTick()
        return
    end

    if EscapadeExpressRolePicker.isVisible() then
        soloPickerFallbackAt = nil
        unregisterSoloFallbackTick()
        return
    end

    if EE_getNowSeconds() >= soloPickerFallbackAt then
        soloPickerFallbackAt = nil
        unregisterSoloFallbackTick()
        EscapadeExpressRolePicker.openLocal()
    end
end

-- ============================================================
-- 4. STUBS REQUIS (pattern Pillow's)
-- ============================================================

EscapadeExpress.setSandBoxVars = function()
    if SandboxVars ~= nil then
        SandboxVars.DayLength = 26
    end
end
EscapadeExpress.RemovePlayer = function(p) end
EscapadeExpress.AddPlayer = function(p) end
EscapadeExpress.Render = function() end

-- ============================================================
-- 5. SPAWN
-- ============================================================

EscapadeExpress.spawns = {SPAWN}
local spawn = EscapadeExpress.spawns[1]

-- ============================================================
-- 6. METADATA
-- ============================================================

EscapadeExpress.id = "EscapadeExpress"
EscapadeExpress.image = "media/lua/client/LastStand/EscapadeExpress.png"
EscapadeExpress.gameMode = "Escapade Express"
EscapadeExpress.world = "Muldraugh, KY"
EscapadeExpress.xcell = spawn.xcell
EscapadeExpress.ycell = spawn.ycell
EscapadeExpress.x = spawn.x
EscapadeExpress.y = spawn.y
EscapadeExpress.z = spawn.z
EscapadeExpress.enableSandbox = true

-- ============================================================
-- 7. ENREGISTREMENT FINAL
-- ============================================================

Events.OnChallengeQuery.Add(EscapadeExpress.Add)

-- ============================================================
-- 8. LOGIQUE PERIODIQUE (cote client)
-- ============================================================

EscapadeExpress.EveryMinutes = function()
    if EE_startTime == nil or EE_gameOver then return end

    local pl = getPlayer()
    if pl == nil then return end

    local elapsed = getGameTime():getWorldAgeHours() - EE_startTime
    local remaining = DURATION_HOURS - elapsed

    if remaining <= 0 then
        return
    end

    local remainingMin = math.floor(remaining * 60)

    if remainingMin <= 120 and not timeWarningsShown[120] then
        timeWarningsShown[120] = true
        pl:Say("Plus que 2 heures!")
    elseif remainingMin <= 60 and not timeWarningsShown[60] then
        timeWarningsShown[60] = true
        pl:Say("Plus que 1 heure!")
    elseif remainingMin <= 30 and not timeWarningsShown[30] then
        timeWarningsShown[30] = true
        pl:Say("Plus que 30 minutes! Depechez-vous!")
    elseif remainingMin <= 10 and not timeWarningsShown[10] then
        timeWarningsShown[10] = true
        pl:Say("Plus que 10 minutes!")
    end
end

-- ============================================================
-- 9. MORT DU JOUEUR (prevention cote client)
-- ============================================================

EscapadeExpress.OnPlayerDeath = function(player)
    if player == nil then return end

    local modData = player:getModData()
    if modData.EE_reviveEnabled and not EE_gameOver then
        if modData.EE_downed then return end

        -- Empecher la mort: le serveur gerera le revive
        player:setHealth(0.01)
        player:setKnockedDown(true)
        player:setDoDeathSound(false)
        modData.EE_downed = true
        modData.EE_downTime = getGameTime():getWorldAgeHours()
        modData.EE_downX = player:getX()
        modData.EE_downY = player:getY()
        modData.EE_downZ = player:getZ()

        -- Informer le serveur
        sendClientCommand("EscapadeExpress", "PlayerDown", {
            x = modData.EE_downX,
            y = modData.EE_downY,
            z = modData.EE_downZ
        })

        player:Say("Je suis a terre! Quelqu'un peut me ranimer!")
    end
end

-- ============================================================
-- 10. RECEPTION COMMANDES SERVEUR
-- ============================================================

local function onServerCommand(module, command, data)
    if module ~= "EscapadeExpress" then return end

    if command == "RoleAssigned" then
        local pl = getPlayer()
        if pl and data.username == pl:getUsername() then
            pl:getModData().EE_role = data.role
            pl:getModData().EE_localRoleApplied = data.role
            pl:getModData().EE_roleSelectionDenied = false
            soloPickerFallbackAt = nil
            unregisterSoloFallbackTick()
        end
    elseif command == "RoleDenied" then
        local pl = getPlayer()
        if pl and data.username == pl:getUsername() then
            pl:getModData().EE_role = nil
            pl:getModData().EE_reviveEnabled = false
            pl:getModData().EE_roleSelectionDenied = true
            soloPickerFallbackAt = nil
            unregisterSoloFallbackTick()
        end
    elseif command == "PlayerDown" then
        local pl = getPlayer()
        if pl then
            pl:Say(data.username .. " est a terre! Allez le ranimer!")
        end
    elseif command == "PlayerRevived" then
        local pl = getPlayer()
        if pl and data.username == pl:getUsername() then
            local modData = pl:getModData()
            modData.EE_downed = false
            modData.EE_downTime = nil
            modData.EE_downX = nil
            modData.EE_downY = nil
            modData.EE_downZ = nil
            if data.reviverType == "medic" then
                pl:Say("Le medic m'a ranime!")
            else
                pl:Say("Je suis ranime!")
            end
        elseif pl then
            pl:Say(data.username .. " est de retour!")
        end
    elseif command == "PlayerRespawned" then
        local pl = getPlayer()
        if pl and data.username == pl:getUsername() then
            local modData = pl:getModData()
            modData.EE_downed = false
            modData.EE_downTime = nil
            modData.EE_downX = nil
            modData.EE_downY = nil
            modData.EE_downZ = nil
            pl:Say("Je me reveille au point de depart...")
        elseif pl then
            pl:Say(data.username .. " a ete renvoye au point de depart.")
        end
    elseif command == "SyncTimer" then
        EE_startTime = data and data.startTime or nil
        syncWarningStateFromTimer()
    elseif command == "GameOver" then
        EE_gameOver = true
    elseif command == "Message" then
        local pl = getPlayer()
        if pl and data and data.text then
            pl:Say(data.text)
        end
    end
end
Events.OnServerCommand.Add(onServerCommand)
