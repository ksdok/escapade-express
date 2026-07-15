-- ============================================================
-- ESCAPADE EXPRESS - Logique serveur (autorite MP)
-- Role assignment, items/skills, revive, vehicule, power, fire
-- ============================================================

local Server = {}

-- ============================================================
-- CONSTANTES (synchro avec client)
-- ============================================================

local PARKING_X = 11250
local PARKING_Y = 8550
local PARKING_Z = 0

local GAS_CAN_LOCATION = {x = 11170, y = 8490, z = 0}

-- Roles: ordre de join
local ROLE_ORDER = {"soldat", "voleur", "local_", "medic"}
local ROLE_NAMES = {
    soldat = "Soldat",
    voleur = "Voleur",
    local_ = "Local",
    medic = "Medic",
}

-- State serveur
Server.roleCounter = 0
Server.escapeVehicle = nil
Server.gameStarted = false
Server.gasCanSpawned = false

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
            {"Base.PistolMagazine", 2},
            {"Base.Bullets9mm", 30},
            {"Base.Bandage", 3},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.HoodieDOWNBlackTINT", 1},
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
            {"Base.HoodieDOWNWhiteTINT", 1},
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
            {"Base.CannedBeans", 2},
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
            {"Base.DisinfectantAlcohol", 2},
            {"Base.Painkillers", 2},
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
-- APPLIQUER UN ROLE A UN JOUEUR
-- ============================================================

local function applyRole(player, roleKey)
    local def = ROLE_DEFS[roleKey]
    if not def then return end

    local inv = player:getInventory()

    -- Donner les items
    for _, itemDef in ipairs(def.items) do
        local itemId, count = itemDef[1], itemDef[2]
        if count > 1 then
            inv:AddItems(itemId, count)
        else
            inv:AddItem(itemId)
        end
    end

    -- Equiper quelques vetements (le premier item de type clothing)
    -- Le joueur peut s'equiper manuellement le reste
    local hoodie = inv:FindAndType("Base.HoodieDOWNBlackTINT")
    if not hoodie then
        hoodie = inv:FindAndType("Base.HoodieDOWNWhiteTINT")
    end
    -- Note: l'equipement auto est optionnel, les joueurs peuvent s'equiper eux-memes

    -- Set les skills
    for _, skillDef in ipairs(def.skills) do
        local perk, level = skillDef[1], skillDef[2]
        player:getXp():setXPToLevel(perk, level)
    end

    -- Set les stats de base
    player:getStats():setPanic(30)
    player:getStats():setHunger(0.2)
    player:getStats():setThirst(0.2)
    player:getStats():setFatigue(0)

    -- Marquer le joueur
    local modData = player:getModData()
    modData.EE_role = roleKey
    modData.EE_reviveEnabled = true
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

    -- Spawner le vehicule
    local car = addVehicleDebug("Base.Van", IsoDirections.E, nil, sq)
    if car == nil then
        print("[EE] ERREUR: Impossible de spawner le vehicule")
        return
    end

    -- Reparer le vehicule
    car:repair()

    -- Vider le reservoir (faut trouver de l'essence)
    local gasTank = car:getPartById("GasTank")
    if gasTank then
        gasTank:setContainerContentAmount(0)
    end

    -- Pas de cle (faut la trouver ou hotwire)
    -- Alternative: donner la cle a un joueur
    -- local key = car:createVehicleKey()
    -- Server.escapeVehicleKey = key

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

    -- Poser un bidon d'essence vide au sol
    sq:SpawnWorldInventoryItem("Base.PetrolCan", 0.5, 0.5, 0.0)
    Server.gasCanSpawned = true
    print("[EE] Bidon d'essence spawn (" .. GAS_CAN_LOCATION.x .. "," .. GAS_CAN_LOCATION.y .. ")")
end

-- ============================================================
-- COUPURE ELECTRIQUE (serveur = autorite)
-- ============================================================

local function cutPower()
    print("[EE] Coupure electrique!")
    -- Iterer sur une zone autour du mall
    local centerX = 11200
    local centerY = 8450
    local radius = 100  -- tiles

    for dx = -radius, radius do
        for dy = -radius, radius do
            local sq = getCell():getGridSquare(centerX + dx, centerY + dy, 0)
            if sq then
                sq:setHaveElectricity(false)
            end
        end
        -- Aussi couper l'etage 1
        for dy2 = -radius, radius do
            local sq1 = getCell():getGridSquare(centerX + dx, centerY + dy2, 1)
            if sq1 then
                sq1:setHaveElectricity(false)
            end
        end
    end

    -- Notifier tous les clients
    sendServerCommand("EscapadeExpress", "AlertMessage", {
        text = "COUPURE DE COURANT! Les lumieres sont eteintes.",
        type = "warning"
    })
end

-- ============================================================
-- INCENDIE (serveur = autorite)
-- ============================================================

local function startFire(data)
    local sq = getCell():getGridSquare(data.x, data.y, data.z)
    if sq == nil then return end

    print("[EE] Incendie demarre a (" .. data.x .. "," .. data.y .. ")")
    IsoFireManager.StartFire(getCell(), sq, true, 100)

    -- Attirer les zombies avec le bruit du feu
    addSound(nil, data.x, data.y, data.z, 100, 200)

    -- Notifier les clients
    sendServerCommand("EscapadeExpress", "AlertMessage", {
        text = "INCENDIE! Le feu se propage dans le mall!",
        type = "danger"
    })
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
    print("[EE] GAME OVER - horde massive!")

    -- Spawn massif de zombies aux entrees
    local entrances = {
        {x = 11200, y = 8400, z = 0},
        {x = 11100, y = 8500, z = 0},
        {x = 11300, y = 8450, z = 0},
    }
    for _, ent in ipairs(entrances) do
        local sq = getCell():getGridSquare(ent.x, ent.y, ent.z)
        if sq then
            addZombiesInOutfit(ent.x, ent.y, ent.z, 50, nil, 0)
        end
    end

    sendServerCommand("EscapadeExpress", "GameOver", {})
    sendServerCommand("EscapadeExpress", "AlertMessage", {
        text = "TEMPS ECOULE! Les zombies envahissent tout!",
        type = "danger"
    })
end

-- ============================================================
-- REVIVE - MONITORING DES JOUEURS A TERRE
-- ============================================================

local REVIVE_TIME_MEDIC = 0.0833   -- 5 min (en heures de jeu)
local REVIVE_TIME_OTHER = 0.1667   -- 10 min (en heures de jeu)
local REVIVE_HEALTH = 0.5          -- HP au revive

local function isMedicNearby(downedPlayer, radius)
    radius = radius or 10  -- tiles
    local players = getOnlinePlayers()
    if players == nil then return false end

    for i = 0, players:size() - 1 do
        local p = players:get(i)
        if p:getUsername() ~= downedPlayer:getUsername() then
            local dx = math.abs(p:getX() - downedPlayer:getX())
            local dy = math.abs(p:getY() - downedPlayer:getY())
            if dx <= radius and dy <= radius then
                local role = p:getModData().EE_role
                if role == "medic" then
                    return true
                end
            end
        end
    end
    return false
end

local function checkDownedPlayers()
    local players = getOnlinePlayers()
    if players == nil then return end

    for i = 0, players:size() - 1 do
        local p = players:get(i)
        local modData = p:getModData()

        -- Detecter un joueur qui tombe a terre (sante critique)
        if not modData.EE_downed and p:getHealth() < 0.15 and modData.EE_reviveEnabled then
            -- Prevenir la mort
            p:setKnockedDown(true)
            p:setHealth(0.01)
            modData.EE_downed = true
            modData.EE_downTime = getGameTime():getWorldAgeHours()

            print("[EE] " .. p:getUsername() .. " est a terre!")
            sendServerCommand("EscapadeExpress", "PlayerDown", {
                username = p:getUsername()
            })
        end

        -- Verifier les joueurs a terre pour le revive
        if modData.EE_downed then
            local elapsed = getGameTime():getWorldAgeHours() - modData.EE_downTime
            local reviveTime = REVIVE_TIME_OTHER
            if isMedicNearby(p) then
                reviveTime = REVIVE_TIME_MEDIC
            end

            if elapsed >= reviveTime then
                -- Ranimer le joueur
                p:setHealth(REVIVE_HEALTH)
                p:setKnockedDown(false)
                modData.EE_downed = false
                modData.EE_downTime = nil

                print("[EE] " .. p:getUsername() .. " est ranime!")
                sendServerCommand("EscapadeExpress", "PlayerRevived", {
                    username = p:getUsername()
                })
            end
        end
    end
end

-- ============================================================
-- GAME START - spawn vehicule + bidon
-- ============================================================

local function onGameStart()
    if Server.gameStarted then return end

    Server.gameStarted = true
    -- Delai pour s'assurer que le monde est charge
    -- Le spawn du vehicule et du bidon se fait ici
    spawnEscapeVehicle()
    spawnGasCan()
end
Events.OnGameStart.Add(onGameStart)

-- ============================================================
-- MONITORING PERIODIQUE (revive)
-- ============================================================

Events.EveryMinutes.Add(checkDownedPlayers)

-- ============================================================
-- RECEPTION COMMANDES CLIENT
-- ============================================================

local function onClientCommand(module, command, player, data)
    if module ~= "EscapadeExpress" then return end

    if command == "PlayerReady" then
        local modData = player:getModData()
        local roleKey = modData.EE_role

        if not roleKey then
            -- Assigner un role au joueur
            local roleIndex = (Server.roleCounter % #ROLE_ORDER) + 1
            roleKey = ROLE_ORDER[roleIndex]
            Server.roleCounter = Server.roleCounter + 1

            -- Appliquer le role (items + skills)
            applyRole(player, roleKey)
            print("[EE] Role assigne: " .. player:getUsername() .. " = " .. (ROLE_NAMES[roleKey] or roleKey))
        end

        -- Notifier le client
        sendServerCommand("EscapadeExpress", "RoleAssigned", {
            username = player:getUsername(),
            role = roleKey,
            roleName = ROLE_NAMES[roleKey] or roleKey
        })

    elseif command == "PlayerDown" then
        -- Le client signale un joueur a terre
        -- Le monitoring serveur (checkDownedPlayers) s'en occupe aussi
        -- mais on enregistre ici aussi pour redundancy
        local modData = player:getModData()
        if not modData.EE_downed then
            modData.EE_downed = true
            modData.EE_downTime = getGameTime():getWorldAgeHours()
        end
        sendServerCommand("EscapadeExpress", "PlayerDown", {
            username = player:getUsername()
        })

    elseif command == "PowerOutage" then
        cutPower()

    elseif command == "StartFire" then
        startFire(data)

    elseif command == "SpawnZombies" then
        spawnZombies(data)

    elseif command == "GameOver" then
        triggerGameOver()
    end
end
Events.OnClientCommand.Add(onClientCommand)