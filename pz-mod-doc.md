# DOC TECHNIQUE - Mod Project Zomboid "Escapade Express"

## Scenario 1: Sortie du Mall
- 4 joueurs coop, debutants, Build 41
- Map: Xonic's Mega Mall (cell 37x28, 3-cell size, entre Muldraugh et West Point)
- Duree: 3h avec chronometre visible
- Objectif: sortir du mall, trouver un vehicule dans le parking, s'enfuir
- Evenements: coupure electricite (~45min), incendie (~2h)
- Mort: joueur ranimable par le medic (30 sec) ou autre joueur (1 min)

---

## 1. COORDONNEES DU MALL (Xonic's Mega Mall)

Source: Steam Workshop page
- Cellule de reference: cell 37x28 (xcell=37, ycell=28)
- 3-cell size map, situe entre Muldraugh et West Point
- 2 malls: West Point Plaza (73 boutiques), Muldraugh Plaza (47 boutiques)
- 1 outlet mall, 1 strip mall, 2 stations essence, restaurants, etc.
- 3 points de spawn possibles: exterieur, interieur, toit

### Conversion coordonnees
Le systeme de coordonnees PZ utilise:
- xcell/ycell = numero de cellule (chaque cellule = 300x300 tiles)
- x/y = position dans la cellule (0-299)
- Coordonnee monde = xcell*300 + x, ycell*300 + y
- Cell 37x28 = debut a 11100, 8400 dans le monde

### IMPORTANT: coordonnees exactes a determiner
Les coordonnees de spawn precis (interieur du mall, parking) doivent etre
determinees en jeu avec le mode debug:
1. Lancer le jeu avec Xonic's Mega Mall active
2. Mode debug, aller a la position souhaitee
3. Lire les coordonnees avec getCell():getGridSquare() ou les coords affichees
4. Convertir en xcell/ycell/x/y pour le code

Pour l'instant, utiliser des placeholders bases sur cell 37x28:
- Spawn arriere-boutique: ~xcell=37, ycell=28, x=100-200, y=100-200, z=0 ou 1
- Parking: ~xcell=37, ycell=28, x=200-250, y=200-250, z=0
- Ces valeurs doivent etre ajustees apres test en jeu

---

## 2. STRUCTURE DU MOD

```
EscapadeExpress/
  mod.info
  poster.png
  media/
    lua/
      client/
        LastStand/
          EscapadeExpress.lua        -- scenario principal
          EscapadeExpress.png        -- image du challenge
        EscapadeExpressUI.lua        -- chronometre UI + messages
      server/
        EscapadeExpressServer.lua   -- logique serveur (revive, spawn vehicule)
```

### mod.info
```
name=Escapade Express
id=EscapadeExpress
description=Scenario coop 4 joueurs: echappez du mall en 3h!
poster=poster.png
require=PillowsRandomScenarios
author=TonNom
```

---

## 3. PATTERN D'UN SCENARIO PILLOW'S

Base sur le code source de Pillow's Random Scenarios (GitHub: crispiboi).

```lua
MonScenario = {}

MonScenario.Add = function()
    addChallenge(MonScenario)
end

MonScenario.OnGameStart = function()
    Events.OnGameStart.Add(MonScenario.OnNewGame)
end

MonScenario.OnNewGame = function()
    -- donner items, set skills, etc.
end

MonScenario.OnInitWorld = function()
    Events.OnGameStart.Add(MonScenario.OnGameStart)
end

MonScenario.setSandBoxVars = function() end
MonScenario.RemovePlayer = function(p) end
MonScenario.AddPlayer = function(p) end
MonScenario.Render = function() end

-- Positions de spawn
MonScenario.spawns = {
    {xcell = 37, ycell = 28, x = 100, y = 100, z = 0},
}

local spawn = MonScenario.spawns[1]
MonScenario.id = "EscapadeExpress"
MonScenario.image = "media/lua/client/LastStand/EscapadeExpress.png"
MonScenario.gameMode = "Escapade Express"
MonScenario.world = "Muldraugh, KY"
MonScenario.xcell = spawn.xcell
MonScenario.ycell = spawn.ycell
MonScenario.x = spawn.x
MonScenario.y = spawn.y
MonScenario.z = spawn.z
MonScenario.enableSandbox = true

Events.OnChallengeQuery.Add(MonScenario.Add)
```

---

## 4. API LUA - MECANIQUES CLES (Build 41)

### 4.1. RECUPERER LE JOUEUR
```lua
local pl = getPlayer()             -- joueur local (client)
local pl = getSpecificPlayer(0)    -- joueur specifique par index
-- Multi: getOnlinePlayers() retourne tous les joueurs
```

### 4.2. DONNER DES ITEMS
```lua
local inv = pl:getInventory()
inv:AddItem("Base.Axe")
inv:AddItem("Base.Pistol")
inv:AddItem("Base.Bullets9mm")  -- x1, pour plusieurs: inv:AddItems(item, count)
-- Items vanilla courants:
--   Base.Axe, Base.Pistol, Base.PistolMagazine, Base.Bullets9mm
--   Base.Bandage, Base.DisinfectantAlcohol, Base.Painkillers
--   Base.Hammer, Base.Nails, Base.Plank, Base.Saw
--   Base.Bag_NormalHikingBag, Base.Belt2
--   Base.KeyRing, Base.Torch, Base.Battery
--   Base.PetrolCan, Base.TirePump, Base.LugWrench
--   Base.WaterBottleFull, Base.CannedBeans, Base.TinOpener
```

### 4.3. SET LES SKILLS (PerkFactory.Perks)
```lua
-- Niveau de skill (0-10)
pl:getXp():setXPToLevel(Perks.Fitness, 5)        -- Fitness
pl:getXp():setXPToLevel(Perks.Strength, 5)       -- Force
pl:getXp():setXPToLevel(Perks.Aiming, 3)         -- Visee (armes a feu)
pl:getXp():setXPToLevel(Perks.Reloading, 3)      -- Rechargement
pl:getXp():setXPToLevel(Perks.Sneak, 5)           -- Discretion
pl:getXp():setXPToLevel(Perks.Lightfoot, 5)      -- Pas leger
pl:getXp():setXPToLevel(Perks.Nimble, 5)         -- Agilite
pl:getXp():setXPToLevel(Perks.Carpentry, 3)      -- Menuiserie
pl:getXp():setXPToLevel(Perks.Mechanics, 3)      -- Mecanique
pl:getXp():setXPToLevel(Perks.Doctor, 4)         -- Premier secours
pl:getXp():setXPToLevel(Perks.Cooking, 3)        -- Cuisine

-- Alternative: setLevel directement
pl:getLevel(Perks.Aiming)  -- lire
-- Pour set: utiliser pl:setPerkLevel et/ou getXp():setXPToLevel
```

### 4.4. EQUIPER LE JOUEUR (vetements + items portes)
```lua
-- Porter un vetement
local clothes = inv:AddItem("Base.HoodieDOWN_WhiteTINT")
pl:setWornItem(clothes:getBodyLocation(), clothes)

-- Equiper un sac
local bag = inv:AddItem("Base.Bag_NormalHikingBag")
pl:setClothingItem_Back(bag)

-- Ceinture + arme
local belt = inv:AddItem("Base.Belt2")
pl:setWornItem(belt:getBodyLocation(), belt)
```

### 4.5. SET LES STATS
```lua
pl:getStats():setPanic(50)        -- 0-100
pl:getStats():setStress(50)       -- 0-100
pl:getStats():setEndurance(0)     -- 0-1 (0 = fatigue max)
pl:getStats():setFatigue(0)       -- 0-1 (0 = repose)
pl:getStats():setHunger(0)        -- 0-1 (0 = plein)
pl:getStats():setThirst(0)        -- 0-1 (0 = hydrate)
```

### 4.6. VEHICULE - SPAWN ET CONFIGURATION
```lua
-- Recuperer une position dans le monde
local sq = getCell():getGridSquare(worldX, worldY, 0)
-- worldX = xcell*300 + x, worldY = ycell*300 + y

-- Spawner un vehicule (depuis le code de Pillow's EnterAreaChallenge)
local car = addVehicleDebug(
    "Base.Van",              -- type de vehicule
    IsoDirections.E,         -- direction (N/S/E/W)
    nil,                     -- skin (nil = random)
    sq                       -- IsoGridSquare ou le placer
)

-- Configurer l'essence (0 a capacity)
local gasTank = car:getPartById("GasTank")
local maxGas = gasTank:getContainerCapacity()
gasTank:setContainerContentAmount(0)  -- 0 = vide (faut trouver de l'essence)

-- Reparer le vehicule
car:repair()

-- Creer une cle et la donner a un joueur
local key = car:createVehicleKey()
pl:getInventory():AddItem(key)

-- Acces au coffre
car:getPartById("TruckBed"):getItemContainer():AddItem("Base.PetrolCan")

-- Faire monter le joueur dans le vehicule
ISTimedActionQueue.add(ISEnterVehicle:new(pl, car, 0))  -- seat 0 = conducteur
ISTimedActionQueue.add(ISStartVehicleEngine:new(pl))
```

### 4.7. INCENDIE - DECLANCHER UN FEU
Source: JavaDoc IsoFireManager (B41)

```lua
-- Methode 1: IsoFireManager.StartFire
local sq = getCell():getGridSquare(fireX, fireY, 0)
IsoFireManager.StartFire(
    getCell(),    -- IsoCell
    sq,           -- IsoGridSquare ou demarrer le feu
    true,         -- IgniteOnAny (ignorer la combustibilite du sol)
    100           -- FireStartingEnergy (plus = plus puissant)
)

-- Methode 2: avec duree de vie limitee
IsoFireManager.StartFire(getCell(), sq, true, 100, 5000)  -- Life=5000

-- Methode 3: explosion (plus spectaculaire)
IsoFireManager.explode(getCell(), sq, 50)  -- power=50

-- Attirer les zombies vers le feu (bruit)
addSound(pl, sq:getX(), sq:getY(), sq:getZ(), 100, 100)

-- Supprimer le feu
IsoFireManager.RemoveAllOn(sq)
```

### 4.8. COUPURE ELECTRIQUE
Source: JavaDoc IsoGridSquare B41 - haveElectricity / setHaveElectricity

```lua
-- Couper l'electricite sur une zone (parcourir les squares du batiment)
-- Pas d'API globale simple pour couper l'electricite de tout le batiment
-- Option A: setHaveElectricity sur chaque square
-- Option B: utiliser GameServer ou les sandbox vars
-- Option C: set le batiment en alarme (effet similaire de chaos)

-- Approche pratique: iterer sur les squares proches
local pl = getPlayer()
local px = pl:getX()
local py = pl:getY()
for dx = -50, 50 do
    for dy = -50, 50 do
        local sq = getCell():getGridSquare(px+dx, py+dy, 0)
        if sq then
            sq:setHaveElectricity(false)
        end
    end
end

-- NOTE: En B41, l'electricite est geree globalement (shutoff apres X jours)
-- Pour forcer une coupure immediate, il faut soit:
-- 1. setHaveElectricity(false) sur les squares (peut etre lourd)
-- 2. Utiliser l'event OnTick pour desactiver les lights
-- 3. Plus simple: jouer un son + message + desactiver les lampes proches

-- Alternative: utiliser le sandbox var pour forcer le shutoff
-- getSandboxVars():setElecShutoffModifier(0)  -- force coupure immediate
-- (a verifier si cette fonction existe en B41)
```

### 4.9. MORT / REVIVE D'UN JOUEUR
Source: JavaDoc IsoGameCharacter B41 + event OnPlayerDeath

```lua
-- Timings du scenario (temps de jeu)
local REVIVE_TIME_MEDIC = 30 / 3600  -- 30 sec
local REVIVE_TIME_OTHER = 1 / 60     -- 1 min

-- Intercepter la mort cote client puis prevenir le serveur
local function onPlayerDeath(player)
    local modData = player:getModData()
    if modData.EE_reviveEnabled then
        player:setHealth(0.01)
        player:setKnockedDown(true)
        player:setDoDeathSound(false)

        modData.EE_downed = true
        modData.EE_downTime = getGameTime():getWorldAgeHours()
        modData.EE_downX = player:getX()
        modData.EE_downY = player:getY()
        modData.EE_downZ = player:getZ()

        sendClientCommand("EscapadeExpress", "PlayerDown", {
            x = modData.EE_downX,
            y = modData.EE_downY,
            z = modData.EE_downZ,
        })
    end
end
Events.OnPlayerDeath.Add(onPlayerDeath)

-- Verification cote serveur (autorite)
local function checkDownedPlayers(players)
    for i = 0, players:size() - 1 do
        local p = players:get(i)
        local modData = p:getModData()
        if modData.EE_downed and modData.EE_downTime then
            local elapsed = getGameTime():getWorldAgeHours() - modData.EE_downTime
            local reviverType = getNearbyReviverType(p)

            if reviverType == "medic" and elapsed >= REVIVE_TIME_MEDIC then
                revivePlayer(p, reviverType)
            elseif elapsed >= REVIVE_TIME_OTHER then
                if reviverType == "other" or reviverType == "medic" then
                    revivePlayer(p, reviverType)
                else
                    respawnPlayerAtStart(p)
                end
            end
        end
    end
end
Events.EveryMinutes.Add(checkDownedPlayers)

-- IMPORTANT: le revive en multi est delicat.
-- - OnPlayerDeath est un event CLIENT (se declenche sur la machine du joueur qui meurt)
-- - En multi, il faut synchroniser via getModData() ou des commandes custom
-- - setHealth() peut ne pas etre autorise cote client sur d'autres joueurs
-- - Peut necessiter du code SERVER pour autorite
--
-- APPROCHE RECOMMANDEE POUR LE MULTI:
-- 1. Code client: intercepter OnPlayerDeath, envoyer un signal au serveur
-- 2. Code serveur: gerer le revive (setHealth, setKnockedDown) avec autorite
-- 3. Utiliser sendClientCommand / addServerCommand pour la communication client-serveur
```

### 4.10. CHRONOMETRE (TIMER 3H)
```lua
-- Stocker le temps de debut dans getModData() ou variable globale
local startTime = nil

local function onGameStart()
    startTime = getGameTime():getWorldAgeHours()  -- heures ecoulees dans le monde
end
Events.OnGameStart.Add(onGameStart)

-- Verifier le temps (a appeler dans OnTick ou EveryMinutes)
local function checkTimer()
    if startTime == nil then return end
    local currentHours = getGameTime():getWorldAgeHours()
    local elapsedHours = currentHours - startTime
    local remainingHours = 3 - elapsedHours

    if remainingHours <= 0 then
        -- TEMPS ECOULE: horde massive ou game over
        getPlayer():Say("Temps ecoule! Les zombies envahissent le mall!")
        -- spawn horde massive
    elseif remainingHours <= 0.5 then
        -- 30 min restantes: warning
        getPlayer():Say("Plus que 30 minutes!")
    end
end
Events.EveryMinutes.Add(checkTimer)

-- AFFICHAGE DU CHRONO (cote client, dans l'UI)
-- Utiliser Events.OnPostUIDraw pour dessiner du texte a l'ecran
local function drawTimer()
    if startTime == nil then return end
    local elapsed = getGameTime():getWorldAgeHours() - startTime
    local remaining = 3 - elapsed
    if remaining <= 0 then return end

    local mins = math.floor(remaining * 60)
    local text = "Temps restant: " .. mins .. " min"

    -- Dessiner avec getTextManager()
    getTextManager():DrawString(UIFont.NewSmall, 10, 10, text, 1, 1, 1, 1)
    -- ou utiliser ISTimeStamp / ISUIElement pour un affichage plus propre
end
Events.OnPostUIDraw.Add(drawTimer)
```

### 4.11. AUGMENTATION PROGRESSIVE DES ZOMBIES
```lua
-- Spawn de zombies a des positions proches des entrees du mall
local function spawnZombies()
    if startTime == nil then return end
    local elapsed = getGameTime():getWorldAgeHours() - startTime

    -- Densite selon le temps ecoule
    local count
    if elapsed < 1 then
        count = 2   -- heure 0-1: tres peu
    elseif elapsed < 2 then
        count = 8   -- heure 1-2: moyen
    else
        count = 20  -- heure 2-3: intense
    end

    -- Spawn aux entrees du mall (coordonnees a determiner)
    local entrances = {
        {x = 11150, y = 8450, z = 0},  -- entree nord (placeholder)
        {x = 11200, y = 8500, z = 0},  -- entree sud (placeholder)
    }

    for _, pos in ipairs(entrances) do
        local sq = getCell():getGridSquare(pos.x, pos.y, pos.z)
        if sq then
            addZombiesInOutfit(pos.x, pos.y, pos.z, count, nil, 0)
        end
    end
end
Events.EveryHours.Add(spawnZombies)

-- NOTE: addZombiesInOutfit est une fonction globale de debug
-- En mode production, preferer: 
--   getCell():getChunk():SpawnZombie()
-- ou utiliser les migrations de zombies (zombie population management)
```

### 4.12. MESSAGES ET DIALOGUE
```lua
-- Faire parler le joueur (affiche au-dessus du personnage)
pl:Say("On doit sortir d'ici!")

-- Message systeme (chat)
if getSpecificPlayer(0) then
    getSpecificPlayer(0):Say("Attention, je vois des zombies!")
end

-- Message HUD (texte a l'ecran)
-- Utiliser ISChat pour envoyer un message dans le chat
-- ISChat.instance:printMessage("SYSTEME: Coupure de courant!")
```

### 4.13. SONS
```lua
-- Jouer un son sur le joueur
pl:playSound("Thunder")              -- tonnerre
pl:playSound("PlayerDied")           -- mort
pl:playSound("SmallExplosion")       -- explosion
pl:playSound("LightbulbBurnedOut")    -- ampoule grillee
pl:playSound("PutItemInBag")         -- item dans sac

-- Attirer les zombies avec du bruit
addSound(pl, x, y, z, volume, radius)  -- radius en tiles
```

---

## 5. EVENTS LUA UTILES (Build 41)

| Event | Quand | Cote |
|---|---|---|
| OnChallengeQuery | Au demarrage, enregistre les challenges | Client |
| OnGameStart | Debut d'une partie | Client |
| OnNewGame | Nouveau personnage cree | Client |
| OnCreatePlayer | Personnage spawn dans le monde | Client |
| OnPlayerDeath | Un joueur meurt | Client |
| OnPlayerUpdate | Chaque tick, par joueur | Client |
| EveryMinutes | Chaque minute de jeu | Client |
| EveryTenMinutes | Toutes les 10 min de jeu | Client |
| EveryHours | Chaque heure de jeu | Client |
| OnTick | Chaque frame (tres frequent!) | Client |
| OnPostUIDraw | Apres le rendu UI (pour dessiner) | Client |
| OnKeyStartPressed | Touche pressee | Client |

---

## 6. PROBLEMATIQUES ET SOLUTIONS

### 6.1. MULTIPLAYER - AUTORITE CLIENT VS SERVER
- OnPlayerDeath est CLIENT: se declenche sur la machine du joueur qui meurt
- setHealth() sur un AUTRE joueur peut ne pas marcher cote client
- Solution: code serveur pour les actions d'autorite (revive, spawn vehicule)
- Communication: sendClientCommand(mod, command, data) / addServerCommand

### 6.2. COORDONNEES EXACTES DU MALL
- Cell 37x28 connu, mais position exacte dans le mall inconnue
- Doit etre determine en jeu avec le mode debug
- Procedure: lancer le jeu, aller a la position, lire les coords
- Les placeholders (xcell=37, ycell=28, x=100-200) doivent etre ajustes

### 6.3. COUPURE ELECTRIQUE
- Pas d'API simple pour couper l'electricite de tout un batiment
- setHaveElectricity(false) sur les squares (lourd mais fonctionne)
- Alternative: ElecShutoff dans les sandbox vars (a verifier)
- Le feu attire les zombies naturellement (systeme vanilla)

### 6.4. REVIVE EN MULTIPLAYER
- Le plus technique du scenario
- Pas de systeme natif de revive en B41
- Approche: intercepter OnPlayerDeath, empecher Kill(), set health + knockedDown
- Peut necessiter des tests iteratifs pour que ca marche en multi
- Risque: le jeu peut forcer la mort malgre setHealth (test necessaire)

---

## 7. SOURCES CONSULTEES

- PZwiki Modding: https://pzwiki.net/wiki/Modding
- PZwiki Lua API: https://pzwiki.net/wiki/Lua_(API)
- PZwiki OnPlayerDeath: https://pzwiki.net/wiki/OnPlayerDeath
- PZwiki IsoPlayer: https://pzwiki.net/wiki/IsoPlayer
- PZwiki Vehicle scripts: https://pzwiki.net/wiki/Vehicle_(scripts)
- JavaDoc B41 IsoFireManager: https://zomboid-javadoc.com/41.65/zombie/iso/objects/IsoFireManager.html
- JavaDoc B41 IsoGridSquare: https://zomboid-javadoc.com/41.65/zombie/iso/IsoGridSquare.html
- JavaDoc B41 IsoGameCharacter: https://zomboid-javadoc.com/41.65/zombie/characters/IsoGameCharacter.html
- JavaDoc IsoPlayer: https://projectzomboid.com/modding/zombie/characters/IsoPlayer.html
- JavaDoc IsoFireManager: https://projectzomboid.com/modding/zombie/iso/objects/IsoFireManager.html
- GitHub Pillow's Random Scenarios (code source): https://github.com/crispiboi/Pillow-s-Random-Scenarios
- GitHub Custom Vehicle Spawner Template: https://github.com/rouennes/Custom-Vehicule-Spawner-Template
- GitHub FWolfe Modding Guide: https://github.com/FWolfe/Zomboid-Modding-Guide
- GitHub PZ events guide: https://github.com/demiurgeQuantified/PZ-events-guide/blob/main/Events.md
- LuaDocs (events): https://demiurgequantified.github.io/ProjectZomboidLuaDocs/md_Events.html
- Context7 PZ Lua Docs: https://context7.com/websites/demiurgequantified_github_io_projectzomboidluadocs_index
- Context7 PZ JavaDocs: https://context7.com/demiurgequantified/projectzomboidjavadocs
- Steam Workshop Xonic's Mega Mall: https://steamcommunity.com/sharedfiles/filedetails/?id=1713269594
- Steam Workshop Pillow's Random Scenarios: https://steamcommunity.com/sharedfiles/filedetails/?id=2106657533
- Supercraft modding guide: https://supercraft.host/wiki/project-zomboid/build_a_project_zomboid_mod/
- Steam Workshop Death Prevention mod (ref): https://steamcommunity.com/sharedfiles/filedetails/?id=3244802339
- Steam Workshop Knocked Down mod (ref): https://steamcommunity.com/workshop/filedetails/?id=3265507347