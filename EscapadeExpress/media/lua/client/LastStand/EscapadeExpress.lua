-- ============================================================
-- ESCAPADE EXPRESS - Scenario principal (client/LastStand)
-- Sortie du Xonic's Mega Mall en 3h, 4 joueurs coop, B41
-- Base sur le pattern Pillow's Random Scenarios
-- ============================================================

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

-- State global (partage entre fichiers client)
EE_startTime = nil
EE_gameOver = false

local timeWarningsShown = {}
local runtimeHooksRegistered = false

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
    Events.EveryMinutes.Add(EscapadeExpress.EveryMinutes)
    Events.OnPlayerDeath.Add(EscapadeExpress.OnPlayerDeath)
    Events.OnCreatePlayer.Add(EscapadeExpress.OnCreatePlayer)
end

EscapadeExpress.OnGameStart = function()
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
    if scenarioInitialized then return end

    local pl = getPlayer()
    if pl == nil then return end
    if pl:getHoursSurvived() > 1 then return end

    scenarioInitialized = true

    -- Le timer est synchronise par le serveur
    EE_startTime = nil
    EE_gameOver = false
    timeWarningsShown = {}

    -- Marquer le joueur pour le revive
    pl:getModData().EE_reviveEnabled = true
    pl:getModData().EE_role = nil  -- sera assigne par le serveur

    -- Demander au serveur d'assigner un role et de synchroniser le timer
    sendClientCommand("EscapadeExpress", "PlayerReady", {
        username = pl:getUsername()
    })

    -- Message d'intro
    pl:Say("On est pieges dans le mall! Trouvez un vehicule et un bidon d'essence!")
end

EscapadeExpress.OnCreatePlayer = function()
    EscapadeExpress.OnNewGame()
end

-- ============================================================
-- 4. STUBS REQUIS (pattern Pillow's)
-- ============================================================

EscapadeExpress.setSandBoxVars = function() end
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
            username = player:getUsername(),
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
            pl:Say("Mon role: " .. data.roleName)
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
