# EE-14 — Explosion du véhicule d'escape au démarrage moteur

## Contexte

Le véhicule d'escape spawn au parking sans essence (réservoir vide, pas de clé).
Les joueurs doivent trouver le bidon, faire le plein, puis démarrer le moteur pour s'enfuir.

Twist: **2 à 3 secondes après le premier démarrage moteur réussi du véhicule d'escape**, le véhicule explose.
C'est un **one-shot**: si le véhicule survit et est réparé, aucune nouvelle explosion.
Le but dramatique: la première tentative d'évasion échoue spectaculairement.

---

## Validation technique (Context7)

Infos récupérées via Context7 avant d'ajuster cette spec:

- **`Events.OnTick` existe** et *fire every game tick*.
- **`BaseVehicle.getSquare()` existe**.
- **`IsoGameCharacter/IsoPlayer.getVehicle()` existe**.
- `IsoFireManager.explode(getCell(), square, power)` est déjà documenté dans la doc technique du projet et reste l'API cible pour l'explosion.

Conséquence: on peut faire un **timer serveur précis** sans dépendre d'un second aller-retour client pour déclencher l'explosion.

---

## État actuel du code

### Serveur (`EscapadeExpressServer.lua`)
- `spawnEscapeVehicle()` (ligne ~1013): spawn `Base.Van` au parking, `car:repair()`, réservoir vide (`setContainerContentAmount(0)`)
- `Server.escapeVehicle`: référence au véhicule spawné
- `resetScenarioState()` (ligne ~1060): remet `Server.escapeVehicle = nil`
- `broadcastAlert(text, alertType)` (ligne ~746): helper existant pour envoyer des alerts HUD
- Aucun state/timer d'explosion véhicule n'existe encore

### Client (`EscapadeExpress.lua`)
- Aucun code véhicule actuel
- `Events.OnPlayerUpdate` n'est pas hooké actuellement
- `onServerCommand` reçoit déjà les messages serveur standards

---

## Décision d'implémentation

### Approche retenue

**Détection côté client + timer d'explosion côté serveur.**

Pourquoi:
- le client est bien placé pour détecter rapidement que **son** moteur vient de démarrer
- le **serveur** garde l'autorité sur:
  - la validation du véhicule concerné
  - le guard one-shot
  - le délai réel avant explosion
  - l'appel final à `IsoFireManager.explode`
- `Events.OnTick` étant documenté via Context7, il n'y a pas besoin d'un `DetonateVehicle` renvoyé par le client

### Pourquoi on écarte l'ancienne option “timer client puis DetonateVehicle”

Elle marche en LAN, mais elle laisse le client contrôler le moment exact de l'explosion.
Comme le projet veut rester **serveur-authoritaire** sur les mécaniques sensibles, cette variante n'est plus la recommandation.

---

## Spécification

### 1. Détection du démarrage moteur (client)

**Côté client**, ajouter un polling léger dans `Events.OnPlayerUpdate`:

- récupérer le joueur local
- vérifier si le joueur est dans un véhicule
- vérifier si le moteur du véhicule est réellement démarré (`isEngineStarted()` si disponible dans le runtime B41; sinon fallback vers l'état moteur équivalent déjà exposé par `BaseVehicle`)
- garder un flag local pour ne reporter qu'une seule fois
- envoyer:

```lua
sendClientCommand("EscapadeExpress", "VehicleStarted", {})
```

Notes:
- le client ne décide **pas** de l'explosion
- un passager peut théoriquement détecter aussi l'état moteur; ce n'est pas grave car le **serveur filtre**
- le flag local doit être reset au redémarrage du scénario / nouvelle partie

### 2. Validation serveur du bon véhicule

Quand le serveur reçoit `VehicleStarted`, il doit vérifier:

1. `Server.escapeVehicle ~= nil`
2. `not Server.vehicleStartDetected`
3. `not Server.vehicleExploded`
4. `player:getVehicle() ~= nil`
5. `player:getVehicle() == Server.escapeVehicle`

But: éviter qu'un autre véhicule de la map déclenche EE-14.

### 3. Guard one-shot (serveur)

Nouveaux champs dans `Server`:

```lua
vehicleStartDetected = false,
vehicleExploded = false,
vehicleExplodeTickDelay = nil,
vehicleExplodeTickCounter = 0,
vehicleExplosionTickActive = false,
```

Dans `resetScenarioState()`, remettre:

```lua
Server.vehicleStartDetected = false
Server.vehicleExploded = false
Server.vehicleExplodeTickDelay = nil
Server.vehicleExplodeTickCounter = 0
Server.vehicleExplosionTickActive = false
```

### 4. Délai d'explosion (serveur, recommandé)

Le délai doit être géré **côté serveur** avec `Events.OnTick`, via un **compteur de ticks**, pas via `getWorldAgeHours()`.

Au premier `VehicleStarted` valide:

```lua
local delayTicks = ZombRand(120, 181) -- ~2 a 3 secondes a 60 fps
Server.vehicleStartDetected = true
Server.vehicleExplodeTickDelay = delayTicks
Server.vehicleExplodeTickCounter = 0
```

Important:
- **ne pas utiliser `EveryOneMinute`**: trop coarse
- pour un délai aussi court, **préférer un compteur de ticks** à un delta en heures

### 5. Tick serveur pendant l'attente

Ajouter une fonction dédiée, par exemple:

```lua
local function vehicleExplosionTick()
    if Server.vehicleExploded or not Server.vehicleStartDetected or Server.vehicleExplodeTickDelay == nil then
        return
    end

    Server.vehicleExplodeTickCounter = Server.vehicleExplodeTickCounter + 1
    if Server.vehicleExplodeTickCounter >= Server.vehicleExplodeTickDelay then
        explodeEscapeVehicle()
    end
end
```

Comportement attendu:
- enregistrer `Events.OnTick.Add(vehicleExplosionTick)` seulement quand une explosion est en attente
- désenregistrer le hook après explosion
- désenregistrer aussi dans `resetScenarioState()` par sécurité si le hook était encore actif

### 6. Warning joueur

Au moment où le serveur programme l'explosion, il broadcast immédiatement:

```lua
broadcastAlert("Le moteur s'etouffe...", "warning")
```

Puis au moment de l'explosion:

```lua
broadcastAlert("LE VEHICULE EXPLOSE!", "danger")
```

Le HUD existant côté client gère déjà `AlertMessage`, donc **pas besoin de modifier `EscapadeExpressUI.lua`**.

### 7. Explosion serveur

Créer une fonction dédiée:

```lua
local function explodeEscapeVehicle()
    if Server.vehicleExploded then return end
    if Server.escapeVehicle == nil then return end

    local sq = Server.escapeVehicle:getSquare()
    if sq == nil then return end

    Server.vehicleExploded = true
    Server.vehicleExplodeTickDelay = nil
    Server.vehicleExplodeTickCounter = 0

    IsoFireManager.explode(getCell(), sq, 50)
    broadcastAlert("LE VEHICULE EXPLOSE!", "danger")
end
```

Notes:
- `power = 50`: explosion moyenne, cohérente avec la doc technique existante
- les dégâts joueurs / dégâts véhicule restent gérés par le moteur PZ
- aucun traitement manuel de dégâts n'est requis

### 8. Nettoyage client + fallback solo

Le client doit:
- reporter le premier démarrage moteur observé en multi
- garder un flag local du type `EE_engineStartReported`
- reset ce flag au lancement du scénario / nouvelle partie
- fournir un **fallback solo local** si aucun vrai serveur ne traite `VehicleStarted`

Fallback solo attendu:
- détecter que le runtime est solo
- valider localement qu'il s'agit bien du véhicule d'escape (heuristique basée sur le parking/config)
- démarrer un petit compteur `OnTick` client (~2-3 secondes)
- déclencher `IsoFireManager.explode()` localement à la fin du délai
- réutiliser l'UI existante via un `AlertMessage` local simulé ou un équivalent

Il ne faut **pas** ajouter:
- de commande `DetonateVehicle`
- de logique multi où le client décide du moment exact de l'explosion

---

## Flux réseau retenu

```text
Client                              Serveur
  │                                   │
  │ (OnPlayerUpdate: moteur detecte)  │
  ├── VehicleStarted ───────────────► │
  │                                   │ valide:
  │                                   │ - escapeVehicle existe
  │                                   │ - pas deja declenche
  │                                   │ - player:getVehicle() == escapeVehicle
  │                                   │
  │ ◄── AlertMessage (warning) ────── │ "Le moteur s'etouffe..."
  │                                   │
  │                                   │ OnTick: tickCounter >= tickDelay ?
  │                                   │
  │ ◄── AlertMessage (danger) ─────── │ "LE VEHICULE EXPLOSE!"
  │                                   │ └── IsoFireManager.explode(...)
```

---

## Fichiers à modifier

### `media/lua/server/EscapadeExpressServer.lua`
- ajouter les champs `vehicleStartDetected`, `vehicleExploded`, `vehicleExplodeTickDelay`, `vehicleExplodeTickCounter`, `vehicleExplosionTickActive`
- reset de ces champs dans `resetScenarioState()`
- ajouter `explodeEscapeVehicle()`
- ajouter `vehicleExplosionTick()`
- ajouter gestion `VehicleStarted` dans `onClientCommand`
- enregistrer/désenregistrer dynamiquement `Events.OnTick`
- envoyer les `broadcastAlert` warning/danger

### `media/lua/client/LastStand/EscapadeExpress.lua`
- hook `Events.OnPlayerUpdate`
- polling de l'état moteur du véhicule courant
- guard local `EE_engineStartReported`
- envoi `VehicleStarted` en multi
- fallback solo local (tick + explosion + alertes)
- reset du flag et de l'état solo lors d'une nouvelle partie / reset scénario

### `media/lua/client/EscapadeExpressUI.lua`
- **aucune modification requise**

---

## Hors scope

- ne pas modifier le spawn du véhicule
- ne pas modifier la logique de bidon d'essence
- ne pas gérer manuellement les dégâts du blast
- ne pas ajouter un second véhicule de secours
- ne pas ajouter un système client de compte à rebours local pour l'explosion

---

## Critères d'acceptation

1. Le véhicule d'escape explose **2 à 3 secondes** après le **premier démarrage moteur réussi**
2. L'explosion ne se produit qu'**une seule fois** par scénario
3. Le serveur valide que le démarrage concerne bien **le véhicule d'escape**
4. Le **serveur** programme et déclenche l'explosion
5. Un message HUD **warning** précède l'explosion
6. Un message HUD **danger** accompagne l'explosion
7. `resetScenarioState()` remet tous les guards/timers EE-14 à zéro et nettoie le hook `OnTick`
8. Le comportement fonctionne en **solo** et en **LAN multi** via le même flux serveur
9. Pas de régression sur le revive/respawn si un joueur est blessé par l'explosion

---

## Taille estimée

Medium (M) — nouveau polling client léger + scheduling serveur `OnTick` + guard one-shot + validation du bon véhicule + alerts
