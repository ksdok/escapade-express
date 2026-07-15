# EE-07 (M) - Fiabiliser la synchro multi des evenements scripts cote serveur

## Contexte

Les evenements scripts (coupure elec, incendie, zombies, game over) sont
declenches cote client dans `EscapadeExpress.EveryMinutes` et `EveryHours`.
Le client envoie un `sendClientCommand` au serveur, qui execute l'action.

## Probleme actuel

1. **Chaque client declenche l'event independamment**: Si 4 joueurs sont
   connectes, `EveryMinutes` tourne sur chaque client. Le premier qui atteint
   `elapsed >= 0.75` envoie `PowerOutage`. Mais les autres clients peuvent
   envoyer la meme commande dans la meme minute -- le serveur execute `cutPower()`
   plusieurs fois (boucle 200x200 sur les squares, x4).

2. **Le timer est par client**: `EE_startTime` est set par chaque client dans
   `OnNewGame`. Si un joueur rejoint en retard, son `EE_startTime` est different
   -- il va declencher les events a des moments differents des autres.

3. **Pas de guard serveur sur les events**: Le serveur ne track pas si la coupure
   elec ou l'incendie a deja eu lieu. Il execute betement chaque commande recue.

4. **Game over declenche par n'importe quel client**: Si un client a un timer
   desynchronise, il peut declencher le game over trop tot ou trop tard.

## Spec corrective

### A. Deplacer le declenchement des events cote serveur

Le serveur doit etre l'autorite pour le timer et les events scripts.

```lua
-- Serveur: EscapadeExpressServer.lua

Server.startTime = nil
Server.powerOutageDone = false
Server.fireDone = false
Server.fireWarningDone = false
Server.gameOver = false

local DURATION_HOURS = 3
local POWER_OUTAGE_TIME = 0.75
local FIRE_TIME = 2.0
local FIRE_WARNING_TIME = 1.9

local function onGameStart()
    if Server.gameStarted then return end
    Server.gameStarted = true
    Server.startTime = getGameTime():getWorldAgeHours()
    spawnEscapeVehicle()
    spawnGasCan()
end

-- Remplacer le monitoring client par un monitoring serveur
local function serverEveryMinutes()
    if Server.startTime == nil or Server.gameOver then return end

    local elapsed = getGameTime():getWorldAgeHours() - Server.startTime

    -- Coupure elec
    if not Server.powerOutageDone and elapsed >= POWER_OUTAGE_TIME then
        Server.powerOutageDone = true
        cutPower()
    end

    -- Warning incendie
    if not Server.fireWarningDone and elapsed >= FIRE_WARNING_TIME then
        Server.fireWarningDone = true
        sendServerCommand("EscapadeExpress", "AlertMessage", {
            text = "Je sens de la fumee...",
            type = "warning"
        })
    end

    -- Incendie
    if not Server.fireDone and elapsed >= FIRE_TIME then
        Server.fireDone = true
        local shop = SHOPS[ZombRand(#SHOPS) + 1]
        startFire({x = shop.x, y = shop.y, z = shop.z})
    end

    -- Game over
    if elapsed >= DURATION_HOURS and not Server.gameOver then
        Server.gameOver = true
        triggerGameOver()
    end
end
Events.EveryMinutes.Add(serverEveryMinutes)

-- Spawn zombies cote serveur aussi
local function serverEveryHours()
    if Server.startTime == nil or Server.gameOver then return end
    local elapsed = getGameTime():getWorldAgeHours() - Server.startTime
    local count = 3
    if elapsed >= 1 then count = 10 end
    if elapsed >= 2 then count = 25 end
    for _, entrance in ipairs(MALL_ENTRANCES) do
        spawnZombies({x = entrance.x, y = entrance.y, z = entrance.z, count = count})
    end
end
Events.EveryHours.Add(serverEveryHours)
```

### B. Client ne fait que recevoir et afficher

Le client `EveryMinutes` ne fait plus que:
- Afficher le timer (deja fait dans l'UI)
- Dire les warnings temporels ("Plus que 30 minutes!")

Les events (coupure elec, incendie, zombies, game over) sont retirés du client
et gérés exclusivement par le serveur.

Le client recoit les `sendServerCommand` existants (`AlertMessage`, `GameOver`)
et les affiche.

### C. Synchroniser le timer au client

Le serveur envoie son `startTime` aux clients au debut:

```lua
-- Dans onGameStart serveur, apres set startTime:
sendServerCommand("EscapadeExpress", "SyncTimer", {
    startTime = Server.startTime
})
```

Cote client:
```lua
elseif command == "SyncTimer" then
    EE_startTime = data.startTime
```

Les late joiners recoivent le timer a leur connexion via `PlayerReady`.

### D. SHOPS et MALL_ENTRANCES cote serveur

Deplacer les constantes `SHOPS` et `MALL_ENTRANCES` du client vers le serveur
(puisque c'est le serveur qui declenche les events maintenant).

## Fichiers a modifier

- `media/lua/server/EscapadeExpressServer.lua`:
  - Ajouter `Server.startTime`, `Server.powerOutageDone`, etc.
  - Ajouter `serverEveryMinutes()` et `serverEveryHours()`
  - Deplacer `SHOPS`, `MALL_ENTRANCES` cote serveur
  - Envoyer `SyncTimer` aux clients
- `media/lua/client/LastStand/EscapadeExpress.lua`:
  - Retirer la logique de declenchement de `EveryMinutes` (coupure, incendie, game over)
  - Retirer `EveryHours` (zombies) cote client
  - Garder uniquement les warnings temporels ("Plus que X minutes!")
  - Ajouter handler `SyncTimer`
  - Retirer les `sendClientCommand("EscapadeExpress", "PowerOutage", ...)` etc.

## Critere d'acceptation

1. Les events scripts sont declenches une seule fois, par le serveur
2. Tous les clients voient les events au meme moment
3. Un late joiner a le meme timer que les autres
4. Le game over ne peut pas etre declenche par un client desynchronise
5. La coupure elec n'est executee qu'une fois (pas de boucle 200x200 x4)

## Dependencies

- Aucune (independant)
- Simplifie EE-08 (moins de messages dupliques car moins de declenchements)

## Taille estimee

Medium (M) -- refactoring architecturale du client vers le serveur