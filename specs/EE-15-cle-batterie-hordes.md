# EE-15 — Clé de véhicule, batterie et hordes déclenchées

## Contexte

Le scénario actuel a deux étapes d'évasion: trouver le bidon d'essence → faire le plein → démarrer. C'est trop simple et linéaire. Ce ticket enrichit le parcours:

- Le véhicule spawn maintenant **sans clé** ET avec une **batterie déchargée**
- Les joueurs doivent trouver 3 objets pour s'enfuir: bidon, clé, batterie
- Chaque fois qu'un objet important est récupéré, une **horde de zombies** apparaît aux entrées du mall

## État actuel du code

### Serveur (`EscapadeExpressServer.lua`)
- `spawnEscapeVehicle()` (ligne 1042): spawn `Base.Van`, `car:repair()`, réservoir vide
- `spawnGasCan()` (ligne 1274): spawn `Base.PetrolCan` au sol via `sq:AddWorldInventoryItem()`
- `spawnZombies(data)` (ligne 1390): wrapper autour de `addZombiesInOutfit(x, y, z, count, nil, 0)`
- `MALL_ENTRANCES` (config): 3 entrées du mall
- `Server` table: guards one-shot (`gasCanSpawned`, etc.)
- `onClientCommand` (ligne 1632): handler commandes client

### Config (`EscapadeExpressConfig.lua`)
- `EE_Config.parking` = {x=11345, y=8957, z=0}
- `EE_Config.gasCan` = {x=11174, y=8432, z=4}
- `EE_Config.entrances` = 3 entrées du mall

### Client (`EscapadeExpress.lua`)
- `OnPlayerUpdate` déjà hooké pour EE-14 (détection démarrage moteur)

## Spécification

### 1. Spawn de la clé de véhicule

Le véhicule spawn sans clé. La clé est cachée à un endroit distinct dans le mall.

Côté serveur, dans `spawnEscapeVehicle()`:
```lua
-- Ne pas donner la clé au véhicule. La créer séparément et la cacher.
local key = car:createVehicleKey()
-- La clé est un InventoryItem. La stocker pour la spawner au sol.
```

Nouvelle fonction `spawnCarKey()`:
- Guard `Server.carKeySpawned`
- Spawn la clé au sol à `EE_Config.carKey` (nouveau placeholder dans la config)
- Utilise `sq:AddWorldInventoryItem(key, 0.5, 0.5, 0.0)` (item object, pas string — la clé est liée au véhicule)

Note: `AddWorldInventoryItem` accepte un `InventoryItem` directement, pas seulement un string. La clé créée par `createVehicleKey()` est liée au véhicule spécifique, donc il faut la créer pendant `spawnEscapeVehicle()` et la stocker pour `spawnCarKey()`.

### 2. Batterie déchargée

Le véhicule spawn avec une batterie déchargée (0%). Les joueurs doivent trouver une batterie chargée dans le mall et l'installer.

Côté serveur, dans `spawnEscapeVehicle()`:
```lua
local battery = car:getPartById("GasTank") -- non, la batterie:
local battery = car:getPartById("Battery")
if battery then
    battery:setContainerContentAmount(0)  -- déchargée
end
```

Nouvelle fonction `spawnCarBattery()`:
- Guard `Server.carBatterySpawned`
- Spawn `Base.CarBattery1` (batterie standard B41; pas `Base.CarBattery`) au sol à `EE_Config.carBattery` (nouveau placeholder)

### 3. Détection de ramassage d'objet important

Quand un joueur ramasse le bidon, la clé ou la batterie, le serveur déclenche une horde.

**Approche**: le client détecte le ramassage via `OnPlayerUpdate` (polling inventaire), et signale au serveur. Le serveur valide et déclenche la horde.

Pourquoi polling et pas un event de pickup: PZ B41 n'a pas d'event `OnItemPickup` fiable. Le polling dans `OnPlayerUpdate` est l'approche éprouvée (déjà utilisée pour EE-14).

Côté client, extension de `OnPlayerUpdate`:
```lua
-- Vérifier si le joueur a un des objets-clés dans son inventaire
local inv = player:getInventory()
if not keyItemsReported.bidon and inv:contains("Base.PetrolCan") then
    keyItemsReported.bidon = true
    sendClientCommand("EscapadeExpress", "KeyItemFound", {item = "bidon"})
end
if not keyItemsReported.key and inv:contains(...) then
    -- La clé n'a pas un item ID fixe; c'est un VehicleKey lié au véhicule
    -- Alternatives:
    --   a) Vérifier le type: inv:FindAndReturn("Base.CarKey") (si l'item type est Base.CarKey)
    --   b) Le serveur peut vérifier lui-même si la clé a été ramassée
end
```

**Problème de la clé**: `createVehicleKey()` crée un item de type clé de véhicule, mais l'item ID exact peut varier. Deux options:

#### Option A: Vérification côté serveur (recommandé)

Le serveur sait où la clé a été spawnée. Au lieu de faire confiance au client, le serveur vérifie lui-même si la clé a été ramassée en scannant l'inventaire des joueurs via `EveryOneMinute` ou `OnTick`:

```lua
local function checkKeyItemsPickedUp()
    if Server.carKeyFound then
        -- déjà détecté
    else
        -- vérifier si un joueur a la clé dans son inventaire
        for _, player in ipairs(getScenarioPlayers()) do
            local inv = player:getInventory()
            -- La clé est stockée dans Server.escapeVehicleKey (référence)
            -- On peut vérifier par type ou par référence
            if Server.escapeVehicleKey and inv:contains(Server.escapeVehicleKey) then
                Server.carKeyFound = true
                triggerItemHorde("cle")
            end
        end
    end
    -- même logique pour batterie
end
```

Avantage: le serveur est l'autorité. Pas de spoofing possible. La clé peut être vérifiée par référence d'objet (`inv:contains(item)` compare les références Java).

Inconvénient: polling serveur (léger, 1 fois par minute via `EveryOneMinute` suffit — pas besoin de OnTick).

#### Option B: Détection côté client

Le client envoie `KeyItemFound` quand il détecte l'objet. Le serveur valide.

Avantage: détection immédiate (pas de délai de 1 minute).

Inconvénient: le client doit savoir quoi chercher. Pour le bidon et la batterie, c'est facile (item ID fixe). Pour la clé, il faut un moyen de l'identifier (type `Base.CarKey`?).

**Recommandation**: Hybride — le client signale immédiatement bidon/batterie, puis le serveur valide par référence d'objet pour bidon/clé/batterie. Un scan serveur `EveryOneMinute` reste en filet de sécurité.

### 4. Horde déclenchée par objet trouvé

Quand un objet important est trouvé, le serveur:
1. Guard one-shot par objet (`Server.bidonHordeTriggered`, `Server.keyHordeTriggered`, `Server.batteryHordeTriggered`)
2. Spawn une horde aux entrées du mall
3. Broadcast `AlertMessage` (warning ou danger)
4. Joue un son via `addSound` au centre du mall pour attirer les zombies existants

Intensité progressive:
- Bidon trouvé: 30 zombies par entrée (warning)
- Clé trouvée: 40 zombies par entrée (danger)
- Batterie trouvée: 50 zombies par entrée (danger)

Ces valeurs sont des placeholders — à ajuster en test.

### 5. Config

Nouveaux placeholders dans `EscapadeExpressConfig.lua`:
```lua
EE_Config.carKey = {x = <placeholder>, y = <placeholder>, z = <placeholder>}
EE_Config.carBattery = {x = <placeholder>, y = <placeholder>, z = <placeholder>}
```

### 6. Reset

Dans `resetScenarioState()`:
```lua
Server.carKeySpawned = false
Server.carBatterySpawned = false
Server.escapeVehicleKey = nil
Server.bidonHordeTriggered = false
Server.keyHordeTriggered = false
Server.batteryHordeTriggered = false
```

### 7. Solo

En solo, le serveur est local. Les mêmes fonctions s'exécutent. La détection côté serveur fonctionne en solo car `getScenarioPlayers()` retourne le joueur local. Les hordes spawnent aux entrées du mall. Pas de problème particulier.

## Flux réseau

```
Client                              Serveur
  │                                   │
  │ (OnPlayerUpdate: polling inv)    │
  ├── KeyItemFound (bidon) ────────► │ (guard, spawn horde, broadcast AlertMessage)
  ├── KeyItemFound (batterie) ──────► │ (guard, spawn horde, broadcast AlertMessage)
  │                                   │
  │ (EveryOneMinute: checkKeyItems)  │
  │                                   │ ← scan inventaire joueurs pour la clé
  │                                   │ (si trouvé: spawn horde, broadcast)
  │ ◄── AlertMessage (horde) ─────── │
  │                                   │
```

## Fichiers à modifier

### `media/lua/shared/EscapadeExpressConfig.lua`
- Ajouter `EE_Config.carKey` et `EE_Config.carBattery` (placeholders)

### `media/lua/server/EscapadeExpressServer.lua`
- `spawnEscapeVehicle()`: créer la clé via `createVehicleKey()`, la stocker dans `Server.escapeVehicleKey`, décharger la batterie
- Nouvelle fonction `spawnCarKey()`: spawn la clé au sol à `EE_Config.carKey`
- Nouvelle fonction `spawnCarBattery()`: spawn `Base.CarBattery1` au sol à `EE_Config.carBattery`
- Nouvelle fonction `triggerItemHorde(itemType)`: guard one-shot, spawn zombies aux entrées, broadcast AlertMessage
- Nouvelle fonction `checkKeyItemsPickedUp()`: dans `EveryOneMinute`, scan inventaire joueurs pour la clé (par référence)
- `onClientCommand`: handler `KeyItemFound` (bidon + batterie)
- `prepareScenario()`: appeler `spawnCarKey()` et `spawnCarBattery()`
- `resetScenarioState()`: reset des nouveaux guards
- `Server` table: ajouter `carKeySpawned`, `carBatterySpawned`, `escapeVehicleKey`, `bidonHordeTriggered`, `keyHordeTriggered`, `batteryHordeTriggered`

### `media/lua/client/LastStand/EscapadeExpress.lua`
- Extension de `OnPlayerUpdate`: polling inventaire pour `Base.PetrolCan` et les batteries voiture (`Base.CarBattery1/2/3`)
- Flags locaux `keyItemsReported` (table avec `.bidon` et `.batterie`)
- Envoi `sendClientCommand("EscapadeExpress", "KeyItemFound", {item = "bidon"})` ou `"batterie"`
- Reset de `keyItemsReported` dans `OnNewGame`

## Hors scope

- Ne pas modifier la logique de démarrage moteur (EE-14 gère l'explosion)
- Ne pas modifier la logique de bidon existante (le bidon est toujours requis pour l'essence)
- Ne pas gérer l'installation de la batterie dans le véhicule (le moteur PZ gère ça via l'UI mécanique)
- Ne pas ajouter de système de quête/tracker UI (les joueurs savent ce qu'ils cherchent via les alerts)
- Ne pas modifier les rôles existants

## Critères d'acceptation

1. Le véhicule spawn sans clé, avec batterie déchargée (0%) et réservoir vide
2. La clé est cachée à un endroit distinct dans le mall (placeholder)
3. La batterie est cachée à un autre endroit distinct (placeholder)
4. Quand le bidon est ramassé: 30 zombies par entrée + message warning
5. Quand la clé est ramassée: 40 zombies par entrée + message danger
6. Quand la batterie est ramassée: 50 zombies par entrée + message danger
7. Chaque horde ne se déclenche qu'une seule fois par scénario
8. Le reset remet tous les guards à zéro
9. Fonctionne en solo et en multi LAN
10. Les joueurs doivent trouver les 3 objets (bidon + clé + batterie) pour s'enfuir

## Taille estimée

Medium (M) — spawn clé/batterie, polling inventaire client, détection serveur, hordes déclenchées, guards, config, reset