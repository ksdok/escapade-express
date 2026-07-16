-- ============================================================
-- ESCAPADE EXPRESS - Logique serveur (autorite MP)
-- Role assignment, items/skills, revive, vehicule, power, fire
-- ============================================================

local Server = {
    playerSlots = {},
    roleLoadouts = {},
    selectionRoster = {},
    selectionConfirmed = {},
    selectionDenied = {},
    scenarioPrepared = false,
    escapeVehicle = nil,
    gameStarted = false,
    gasCanSpawned = false,
    startTime = nil,
    powerOutageDone = false,
    fireDone = false,
    fireWarningDone = false,
    gameOver = false,
}

-- ============================================================
-- CONSTANTES
-- ============================================================

local PARKING_X = 11250
local PARKING_Y = 8550
local PARKING_Z = 0

local GAS_CAN_LOCATION = {x = 11170, y = 8490, z = 0}
local RESPAWN_X = 11220  -- placeholder arriere-boutique, doit rester distinct du parking
local RESPAWN_Y = 8520
local RESPAWN_Z = 0

local DURATION_HOURS = 3
local POWER_OUTAGE_TIME = 0.75
local FIRE_TIME = 2.0
local FIRE_WARNING_TIME = 1.9

local MALL_ENTRANCES = {
    {x = 11200, y = 8400, z = 0},
    {x = 11100, y = 8500, z = 0},
    {x = 11300, y = 8450, z = 0},
}

local SHOPS = {
    {x = 11180, y = 8430, z = 0},
    {x = 11220, y = 8470, z = 0},
    {x = 11150, y = 8460, z = 0},
    {x = 11200, y = 8420, z = 0},
}

-- Roles: slots fixes par ordre de priorite
local ROLE_ORDER = {"soldat", "voleur", "local_", "medic"}
local ROLE_NAMES = {
    soldat = "Soldat",
    voleur = "Voleur",
    local_ = "Local",
    medic = "Medic",
}

-- ============================================================
-- DEFINITION DES ROLES (items + skills)
-- ============================================================

local ROLE_DEFS = {
    soldat = {
        name = "Soldat",
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
        name = "Voleur",
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
        name = "Local",
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
        name = "Medic",
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

-- ============================================================
-- OUTILS SERVEUR
-- ============================================================

local function syncTimerToClients()
    if Server.startTime == nil then return end

    sendServerCommand("EscapadeExpress", "SyncTimer", {
        startTime = Server.startTime
    })
end

local function broadcastAlert(text, alertType)
    sendServerCommand("EscapadeExpress", "AlertMessage", {
        text = text,
        type = alertType
    })
end

-- ============================================================
-- ASSIGNATION ET APPLICATION DES ROLES
-- ============================================================

local function getAssignedRole(username)
    if username == nil then return nil end
    return Server.playerSlots[username]
end

local function isRoleTaken(roleKey, exceptUsername)
    for username, takenRole in pairs(Server.playerSlots) do
        if username ~= exceptUsername and takenRole == roleKey then
            return true, username
        end
    end

    return false, nil
end

local function hasFreeRole(exceptUsername)
    for _, roleKey in ipairs(ROLE_ORDER) do
        local taken = isRoleTaken(roleKey, exceptUsername)
        if not taken then
            return true
        end
    end

    return false
end

local function buildRolePickerState()
    local result = {}

    for _, roleKey in ipairs(ROLE_ORDER) do
        local taken, username = isRoleTaken(roleKey)
        result[roleKey] = {
            taken = taken,
            takenBy = username,
        }
    end

    return result
end

local function broadcastRolePickerState()
    sendServerCommand("EscapadeExpress", "SyncRolePickerState", {
        roleStates = buildRolePickerState()
    })
end

local function markSelectionDenied(username)
    if username == nil then return end
    Server.selectionDenied[username] = true
    Server.selectionConfirmed[username] = nil
end

local function markSelectionConfirmed(username, roleKey)
    if username == nil then return end
    Server.selectionConfirmed[username] = roleKey
    Server.selectionDenied[username] = nil
end

local function addPlayerToInitialRoster(username)
    if username == nil or Server.gameStarted then return end
    Server.selectionRoster[username] = true
end

local function maybeStartScenarioTimer()
    if not Server.scenarioPrepared or Server.gameStarted then
        return false
    end

    for username, _ in pairs(Server.selectionRoster) do
        if not Server.selectionConfirmed[username] and not Server.selectionDenied[username] then
            return false
        end
    end

    if next(Server.selectionRoster) == nil then
        return false
    end

    Server.gameStarted = true
    Server.gameOver = false
    Server.powerOutageDone = false
    Server.fireDone = false
    Server.fireWarningDone = false
    Server.startTime = getGameTime():getWorldAgeHours()

    print("[EE] Timer du scenario demarre, startTime=" .. tostring(Server.startTime))
    syncTimerToClients()
    return true
end

local function applyRole(player, roleKey)
    local def = ROLE_DEFS[roleKey]
    if not def then return false end

    local username = player:getUsername()
    local modData = player:getModData()
    modData.EE_role = roleKey
    modData.EE_reviveEnabled = true

    if username ~= nil and Server.roleLoadouts[username] == roleKey then
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

    if username ~= nil then
        Server.roleLoadouts[username] = roleKey
    end

    return true
end

-- ============================================================
-- SPAWN DU VEHICULE D'ESCAPE
-- ============================================================

local function spawnEscapeVehicle()
    if Server.escapeVehicle ~= nil then return end

    local sq = getCell():getGridSquare(PARKING_X, PARKING_Y, PARKING_Z)
    if sq == nil then
        print("[EE] ERREUR: Impossible de trouver le square du parking")
        return
    end

    local car = addVehicleDebug("Base.Van", IsoDirections.E, nil, sq)
    if car == nil then
        print("[EE] ERREUR: Impossible de spawner le vehicule")
        return
    end

    car:repair()

    local gasTank = car:getPartById("GasTank")
    if gasTank then
        gasTank:setContainerContentAmount(0)
    end

    Server.escapeVehicle = car
    print("[EE] Vehicule d'escape spawn au parking (" .. PARKING_X .. "," .. PARKING_Y .. ")")
end

-- ============================================================
-- SPAWN DU BIDON D'ESSENCE
-- ============================================================

local function spawnGasCan()
    if Server.gasCanSpawned then return end

    local sq = getCell():getGridSquare(GAS_CAN_LOCATION.x, GAS_CAN_LOCATION.y, GAS_CAN_LOCATION.z)
    if sq == nil then
        print("[EE] ERREUR: Impossible de trouver le square du bidon d'essence")
        return
    end

    sq:AddWorldInventoryItem("Base.PetrolCan", 0.5, 0.5, 0.0)
    Server.gasCanSpawned = true
    print("[EE] Bidon d'essence spawn (" .. GAS_CAN_LOCATION.x .. "," .. GAS_CAN_LOCATION.y .. ")")
end

-- ============================================================
-- INITIALISATION DU SCENARIO
-- ============================================================

local function resetScenarioState()
    Server.playerSlots = {}
    Server.roleLoadouts = {}
    Server.selectionRoster = {}
    Server.selectionConfirmed = {}
    Server.selectionDenied = {}
    Server.scenarioPrepared = false
    Server.escapeVehicle = nil
    Server.gameStarted = false
    Server.gasCanSpawned = false
    Server.startTime = nil
    Server.powerOutageDone = false
    Server.fireDone = false
    Server.fireWarningDone = false
    Server.gameOver = false
end

local function prepareScenario()
    if Server.scenarioPrepared then return false end

    if SandboxVars ~= nil then
        SandboxVars.DayLength = 26
    end

    if getGameTime ~= nil then
        local gameTime = getGameTime()
        if gameTime ~= nil and gameTime.setMinutesPerDay ~= nil then
            gameTime:setMinutesPerDay(60 * 24)
        end
    end

    Server.scenarioPrepared = true
    Server.gameOver = false
    Server.startTime = nil

    spawnEscapeVehicle()
    spawnGasCan()

    print("[EE] Scenario prepare, en attente du choix des roles")
    return true
end

-- ============================================================
-- COUPURE ELECTRIQUE (serveur = autorite)
-- ============================================================

local function cutPower()
    print("[EE] Coupure electrique!")

    local centerX = 11200
    local centerY = 8450
    local radius = 100

    for dx = -radius, radius do
        for dy = -radius, radius do
            local sq = getCell():getGridSquare(centerX + dx, centerY + dy, 0)
            if sq then
                sq:setHaveElectricity(false)
            end
        end

        for dy2 = -radius, radius do
            local sq1 = getCell():getGridSquare(centerX + dx, centerY + dy2, 1)
            if sq1 then
                sq1:setHaveElectricity(false)
            end
        end
    end

    broadcastAlert("COUPURE DE COURANT! Les lumieres sont eteintes.", "warning")
end

-- ============================================================
-- INCENDIE (serveur = autorite)
-- ============================================================

local function startFire(data)
    local sq = getCell():getGridSquare(data.x, data.y, data.z)
    if sq == nil then return end

    print("[EE] Incendie demarre a (" .. data.x .. "," .. data.y .. ")")
    IsoFireManager.StartFire(getCell(), sq, true, 100)

    addSound(nil, data.x, data.y, data.z, 100, 200)
    broadcastAlert("INCENDIE! Le feu se propage dans le mall!", "danger")
end

-- ============================================================
-- SPAWN ZOMBIES (serveur = autorite)
-- ============================================================

local function spawnZombies(data)
    local count = data.count or 5
    local sq = getCell():getGridSquare(data.x, data.y, data.z)
    if sq == nil then return end

    addZombiesInOutfit(data.x, data.y, data.z, count, nil, 0)
    print("[EE] " .. count .. " zombies spawn a (" .. data.x .. "," .. data.y .. ")")
end

-- ============================================================
-- GAME OVER (horde massive)
-- ============================================================

local function triggerGameOver()
    if Server.gameOver then return end

    Server.gameOver = true
    print("[EE] GAME OVER - horde massive!")

    for _, ent in ipairs(MALL_ENTRANCES) do
        local sq = getCell():getGridSquare(ent.x, ent.y, ent.z)
        if sq then
            addZombiesInOutfit(ent.x, ent.y, ent.z, 50, nil, 0)
        end
    end

    sendServerCommand("EscapadeExpress", "GameOver", {})
    broadcastAlert("TEMPS ECOULE! Les zombies envahissent tout!", "danger")
end

-- ============================================================
-- REVIVE - MONITORING DES JOUEURS A TERRE
-- ============================================================

local REVIVE_TIME_MEDIC = 30 / 3600
local REVIVE_TIME_OTHER = 1 / 60
local REVIVE_HEALTH = 0.5
local RESPAWN_HEALTH = 0.3
local REVIVE_RADIUS = 10

local function getScenarioPlayers()
    local result = {}

    if getOnlinePlayers ~= nil then
        local onlinePlayers = getOnlinePlayers()
        if onlinePlayers ~= nil and onlinePlayers:size() > 0 then
            for i = 0, onlinePlayers:size() - 1 do
                result[#result + 1] = onlinePlayers:get(i)
            end
            return result
        end
    end

    if getPlayer ~= nil then
        local singlePlayer = getPlayer()
        if singlePlayer ~= nil then
            result[#result + 1] = singlePlayer
        end
    end

    return result
end

local function markPlayerDowned(player, x, y, z)
    local modData = player:getModData()
    if modData.EE_downed then
        return false
    end

    modData.EE_downed = true
    modData.EE_downTime = getGameTime():getWorldAgeHours()
    modData.EE_downX = x ~= nil and x or player:getX()
    modData.EE_downY = y ~= nil and y or player:getY()
    modData.EE_downZ = z ~= nil and z or player:getZ()

    player:setKnockedDown(true)
    player:setDoDeathSound(false)
    player:setHealth(0.01)

    print("[EE] " .. player:getUsername() .. " est a terre!")
    sendServerCommand("EscapadeExpress", "PlayerDown", {
        username = player:getUsername()
    })

    return true
end

local function getNearbyReviverType(downedPlayer, radius)
    radius = radius or REVIVE_RADIUS
    local hasOtherNearby = false

    for _, p in ipairs(getScenarioPlayers()) do
        if p:getUsername() ~= downedPlayer:getUsername() then
            local otherData = p:getModData()
            if not otherData.EE_downed then
                local dx = math.abs(p:getX() - downedPlayer:getX())
                local dy = math.abs(p:getY() - downedPlayer:getY())
                if dx <= radius and dy <= radius then
                    local role = otherData.EE_role
                    if role == "medic" then
                        return "medic"
                    end
                    hasOtherNearby = true
                end
            end
        end
    end

    if hasOtherNearby then
        return "other"
    end

    return nil
end

local function clearDownedState(player)
    local modData = player:getModData()
    modData.EE_downed = false
    modData.EE_downTime = nil
    modData.EE_downX = nil
    modData.EE_downY = nil
    modData.EE_downZ = nil
end

local function revivePlayer(player, reviverType)
    player:setHealth(REVIVE_HEALTH)
    player:setKnockedDown(false)
    clearDownedState(player)

    print("[EE] " .. player:getUsername() .. " est ranime (" .. reviverType .. ")")
    sendServerCommand("EscapadeExpress", "PlayerRevived", {
        username = player:getUsername(),
        reviverType = reviverType
    })
end

local function respawnPlayerAtStart(player)
    player:setHealth(RESPAWN_HEALTH)
    player:setKnockedDown(false)
    player:setX(RESPAWN_X)
    player:setY(RESPAWN_Y)
    player:setZ(RESPAWN_Z)
    clearDownedState(player)

    print("[EE] " .. player:getUsername() .. " respawn au depart")
    sendServerCommand("EscapadeExpress", "PlayerRespawned", {
        username = player:getUsername()
    })
end

local function checkDownedPlayers()
    for _, p in ipairs(getScenarioPlayers()) do
        local modData = p:getModData()

        if not modData.EE_downed and p:getHealth() < 0.15 and modData.EE_reviveEnabled then
            markPlayerDowned(p)
        end

        if modData.EE_downed and modData.EE_downTime then
            local elapsed = getGameTime():getWorldAgeHours() - modData.EE_downTime
            local reviverType = getNearbyReviverType(p)

            if reviverType == "medic" and elapsed >= REVIVE_TIME_MEDIC then
                revivePlayer(p, reviverType)
            elseif elapsed >= REVIVE_TIME_OTHER then
                if reviverType == "medic" or reviverType == "other" then
                    revivePlayer(p, reviverType)
                else
                    respawnPlayerAtStart(p)
                end
            end
        end
    end
end

-- ============================================================
-- MONITORING PERIODIQUE DES EVENTS
-- ============================================================

local function serverEveryMinutes()
    if Server.startTime == nil or Server.gameOver then return end

    local elapsed = getGameTime():getWorldAgeHours() - Server.startTime

    if not Server.powerOutageDone and elapsed >= POWER_OUTAGE_TIME then
        Server.powerOutageDone = true
        cutPower()
    end

    if not Server.fireWarningDone and elapsed >= FIRE_WARNING_TIME then
        Server.fireWarningDone = true
        broadcastAlert("Je sens de la fumee...", "warning")
    end

    if not Server.fireDone and elapsed >= FIRE_TIME then
        Server.fireDone = true
        local shop = SHOPS[ZombRand(#SHOPS) + 1]
        startFire({x = shop.x, y = shop.y, z = shop.z})
    end

    if elapsed >= DURATION_HOURS then
        triggerGameOver()
    end
end

local function serverEveryHours()
    if Server.startTime == nil or Server.gameOver then return end

    local elapsed = getGameTime():getWorldAgeHours() - Server.startTime
    local count = 3

    if elapsed >= 1 then count = 10 end
    if elapsed >= 2 then count = 25 end

    for _, entrance in ipairs(MALL_ENTRANCES) do
        spawnZombies({
            x = entrance.x,
            y = entrance.y,
            z = entrance.z,
            count = count,
        })
    end
end

-- ============================================================
-- GAME START
-- ============================================================

local function onGameStart()
    resetScenarioState()
    prepareScenario()
end
Events.OnGameStart.Add(onGameStart)

Events.EveryOneMinute.Add(checkDownedPlayers)
Events.EveryOneMinute.Add(serverEveryMinutes)
Events.EveryHours.Add(serverEveryHours)

-- ============================================================
-- RECEPTION COMMANDES CLIENT
-- ============================================================

local function onClientCommand(module, command, player, data)
    if module ~= "EscapadeExpress" then return end

    if command == "RolePickerReady" then
        prepareScenario()

        local username = player:getUsername()
        local assignedRole = getAssignedRole(username)

        if assignedRole ~= nil then
            markSelectionConfirmed(username, assignedRole)
            applyRole(player, assignedRole)

            sendServerCommand("EscapadeExpress", "RoleAssigned", {
                username = username,
                role = assignedRole,
                roleName = ROLE_NAMES[assignedRole] or assignedRole
            })

            if Server.gameStarted then
                syncTimerToClients()
            else
                maybeStartScenarioTimer()
            end
            return
        end

        if not Server.gameStarted then
            addPlayerToInitialRoster(username)
        end

        if not hasFreeRole(username) then
            local modData = player:getModData()
            modData.EE_role = nil
            modData.EE_reviveEnabled = false
            markSelectionDenied(username)

            print("[EE] Aucun role disponible pour " .. tostring(username) .. " (scenario limite a 4 joueurs)")
            sendServerCommand("EscapadeExpress", "RoleDenied", {
                username = username,
                text = "Trop de joueurs pour ce scenario!"
            })

            if Server.gameStarted then
                syncTimerToClients()
            else
                maybeStartScenarioTimer()
            end
            return
        end

        sendServerCommand("EscapadeExpress", "OpenRolePicker", {
            username = username,
            roleStates = buildRolePickerState()
        })
        broadcastRolePickerState()

    elseif command == "ChooseRole" then
        prepareScenario()

        local username = player:getUsername()
        local roleKey = data and data.roleKey or nil

        if roleKey == nil or ROLE_DEFS[roleKey] == nil then
            sendServerCommand("EscapadeExpress", "RoleUnavailable", {
                username = username,
                roleKey = roleKey,
                text = "Role invalide.",
                roleStates = buildRolePickerState()
            })
            return
        end

        local assignedRole = getAssignedRole(username)
        if assignedRole ~= nil then
            applyRole(player, assignedRole)
            sendServerCommand("EscapadeExpress", "RoleAssigned", {
                username = username,
                role = assignedRole,
                roleName = ROLE_NAMES[assignedRole] or assignedRole
            })
            if Server.gameStarted then
                syncTimerToClients()
            else
                maybeStartScenarioTimer()
            end
            return
        end

        if not Server.gameStarted then
            addPlayerToInitialRoster(username)
        end

        local taken, takenBy = isRoleTaken(roleKey, username)
        if taken then
            sendServerCommand("EscapadeExpress", "RoleUnavailable", {
                username = username,
                roleKey = roleKey,
                text = "Ce role vient d'etre pris par " .. tostring(takenBy) .. ".",
                roleStates = buildRolePickerState()
            })
            return
        end

        Server.playerSlots[username] = roleKey
        markSelectionConfirmed(username, roleKey)

        local loadoutGranted = applyRole(player, roleKey)
        if loadoutGranted then
            print("[EE] Role assigne: " .. tostring(username) .. " = " .. (ROLE_NAMES[roleKey] or roleKey))
        else
            print("[EE] Role resynchronise: " .. tostring(username) .. " = " .. (ROLE_NAMES[roleKey] or roleKey))
        end

        sendServerCommand("EscapadeExpress", "RoleAssigned", {
            username = username,
            role = roleKey,
            roleName = ROLE_NAMES[roleKey] or roleKey
        })
        broadcastRolePickerState()

        if Server.gameStarted then
            syncTimerToClients()
        else
            maybeStartScenarioTimer()
        end

    elseif command == "PlayerDown" then
        local downX = data and data.x or nil
        local downY = data and data.y or nil
        local downZ = data and data.z or nil
        markPlayerDowned(player, downX, downY, downZ)
    end
end
Events.OnClientCommand.Add(onClientCommand)
