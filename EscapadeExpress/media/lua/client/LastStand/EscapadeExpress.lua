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

local SPAWN = {xcell = 37, ycell = 28, x = 150, y = 150, z = 0}

-- Parking du mall (placeholder)
local PARKING_X = 11250
local PARKING_Y = 8550
local PARKING_Z = 0

-- Entrees du mall pour spawn zombies (placeholder)
local MALL_ENTRANCES = {
    {x = 11200, y = 8400, z = 0},  -- entree nord
    {x = 11100, y = 8500, z = 0},  -- entree sud
    {x = 11300, y = 8450, z = 0},  -- entree est
}

-- Boutiques pour incendie (placeholder)
local SHOPS = {
    {x = 11180, y = 8430, z = 0},
    {x = 11220, y = 8470, z = 0},
    {x = 11150, y = 8460, z = 0},
    {x = 11200, y = 8420, z = 0},
}

-- Emplacement du bidon d'essence (placeholder, different du parking)
local GAS_CAN_LOCATION = {x = 11170, y = 8490, z = 0}

-- ============================================================
-- CONSTANTES DU SCENARIO
-- ============================================================

local DURATION_HOURS = 3         -- duree totale
local POWER_OUTAGE_TIME = 0.75   -- ~45 min
local FIRE_TIME = 2.0            -- ~2h
local FIRE_WARNING_TIME = 1.9    -- warning incendie ~1h54

-- State global (partage entre fichiers client)
EE_startTime = nil
EE_powerOutageDone = false
EE_fireDone = false
EE_fireWarningDone = false
EE_gameOver = false
EE_escapeVehicleSpawned = false

local runtimeHooksRegistered = false
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
    Events.EveryHours.Add(EscapadeExpress.EveryHours)
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

    -- Initialiser le timer
    EE_startTime = getGameTime():getWorldAgeHours()
    EE_powerOutageDone = false
    EE_fireDone = false
    EE_fireWarningDone = false
    EE_gameOver = false

    -- Marquer le joueur pour le revive
    pl:getModData().EE_reviveEnabled = true
    pl:getModData().EE_role = nil  -- sera assigne par le serveur

    -- Demander au serveur d'assigner un role et de donner items
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

    local elapsed = getGameTime():getWorldAgeHours() - EE_startTime
    local remaining = DURATION_HOURS - elapsed

    -- === COUPURE ELECTRIQUE (~45 min) ===
    if not EE_powerOutageDone and elapsed >= POWER_OUTAGE_TIME then
        EE_powerOutageDone = true
        local pl = getPlayer()
        if pl then pl:Say("Coupure de courant! Les lumieres sont eteintes.") end
        -- Le serveur gere l'autorite de l'electricite
        sendClientCommand("EscapadeExpress", "PowerOutage", {})
        -- Jouer un son
        if pl then pl:playSound("LightbulbBurnedOut") end
    end

    -- === WARNING INCENDIE (~1h54) ===
    if not EE_fireWarningDone and elapsed >= FIRE_WARNING_TIME then
        EE_fireWarningDone = true
        local pl = getPlayer()
        if pl then pl:Say("Je sens de la fumee... Un incendie pourrait demarrer!") end
    end

    -- === INCENDIE (~2h) ===
    if not EE_fireDone and elapsed >= FIRE_TIME then
        EE_fireDone = true
        -- Choisir une boutique au hasard
        local shop = SHOPS[ZombRand(#SHOPS) + 1]
        local pl = getPlayer()
        if pl then
            pl:Say("Un incendie! Le feu se propage!")
            pl:playSound("SmallExplosion")
        end
        -- Le serveur demarre le feu (autorite)
        sendClientCommand("EscapadeExpress", "StartFire", {
            x = shop.x, y = shop.y, z = shop.z
        })
    end

    -- === FIN DU TIMER (3h) ===
    if remaining <= 0 and not EE_gameOver then
        EE_gameOver = true
        local pl = getPlayer()
        if pl then pl:Say("TEMPS ECOULE! Les zombies envahissent le mall!") end
        -- Horde massive: le serveur spawn beaucoup de zombies
        sendClientCommand("EscapadeExpress", "GameOver", {})
    end

    -- === WARNINGS TEMPS ===
    if remaining > 0 then
        local remainingMin = math.floor(remaining * 60)
        if remainingMin == 120 then
            local pl = getPlayer()
            if pl then pl:Say("Plus que 2 heures!") end
        elseif remainingMin == 60 then
            local pl = getPlayer()
            if pl then pl:Say("Plus que 1 heure!") end
        elseif remainingMin == 30 then
            local pl = getPlayer()
            if pl then pl:Say("Plus que 30 minutes! Depechez-vous!") end
        elseif remainingMin == 10 then
            local pl = getPlayer()
            if pl then pl:Say("Plus que 10 minutes!") end
        end
    end
end

-- ============================================================
-- 9. AUGMENTATION PROGRESSIVE DES ZOMBIES (chaque heure)
-- ============================================================

EscapadeExpress.EveryHours = function()
    if EE_startTime == nil or EE_gameOver then return end

    local pl = getPlayer()
    if pl == nil then return end

    local elapsed = getGameTime():getWorldAgeHours() - EE_startTime

    -- Densite selon le temps ecoule
    local count
    if elapsed < 1 then
        count = 3    -- heure 0-1: tres faible
    elseif elapsed < 2 then
        count = 10   -- heure 1-2: moyen
    else
        count = 25   -- heure 2-3: intense
    end

    -- Le serveur spawn les zombies (autorite en MP)
    for _, entrance in ipairs(MALL_ENTRANCES) do
        sendClientCommand("EscapadeExpress", "SpawnZombies", {
            x = entrance.x, y = entrance.y, z = entrance.z,
            count = count
        })
    end
end

-- ============================================================
-- 10. MORT DU JOUEUR (prevention cote client)
-- ============================================================

EscapadeExpress.OnPlayerDeath = function(player)
    if player == nil then return end

    local modData = player:getModData()
    if modData.EE_reviveEnabled and not EE_gameOver then
        -- Empecher la mort: le serveur gerera le revive
        player:setHealth(0.01)
        player:setKnockedDown(true)
        player:setDoDeathSound(false)
        modData.EE_downed = true

        -- Informer le serveur
        sendClientCommand("EscapadeExpress", "PlayerDown", {
            username = player:getUsername(),
            x = player:getX(),
            y = player:getY(),
            z = player:getZ()
        })

        player:Say("Je suis a terre! Quelqu'un peut me ranimer!")
    end
end

-- ============================================================
-- 11. RECEPTION COMMANDES SERVEUR
-- ============================================================

local function onServerCommand(module, command, data)
    if module ~= "EscapadeExpress" then return end

    if command == "RoleAssigned" then
        -- Le serveur a assigne un role et donne les items
        local pl = getPlayer()
        if pl and data.username == pl:getUsername() then
            pl:getModData().EE_role = data.role
            pl:Say("Mon role: " .. data.roleName)
        end
    elseif command == "PlayerDown" then
        -- Un autre joueur est a terre
        local pl = getPlayer()
        if pl then
            pl:Say(data.username .. " est a terre! Allez le ranimer!")
        end
    elseif command == "PlayerRevived" then
        local pl = getPlayer()
        if pl and data.username == pl:getUsername() then
            pl:Say("Je suis ranime!")
        elseif pl then
            pl:Say(data.username .. " est de retour!")
        end
    elseif command == "GameOver" then
        EE_gameOver = true
    elseif command == "Message" then
        local pl = getPlayer()
        if pl then pl:Say(data.text) end
    end
end
Events.OnServerCommand.Add(onServerCommand)