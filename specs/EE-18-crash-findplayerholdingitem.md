# EE-18 — Corriger le crash serveur `findPlayerHoldingItem` / `checkObjectiveItemsPickedUp`

## Contexte

Un test solo recent avec EE-17 actif montre que le vehicule d'escape spawn maintenant correctement quand il est rapproche de la zone de depart, mais qu'une erreur Lua serveur survient juste apres.

Log observe dans `DebugLog.txt`:
- `[EE] Vehicule d'escape spawn au parking (11370,8955).`
- `STACK TRACE`
- `function: findPlayerHoldingItem -- file: EscapadeExpressServer.lua line # 1616`
- `function: checkObjectiveItemsPickedUp -- file: EscapadeExpressServer.lua line # 1678`
- `Object tried to call nil in findPlayerHoldingItem.`
- `Exception thrown java.lang.RuntimeException: Object tried to call nil in findPlayerHoldingItem`

En parallele, les retries EE-17 continuent d'indiquer que le bidon, la cle et la batterie ne sont pas encore spawnes au moment du crash.

## Probleme

La surveillance serveur des objets d'objectif (`checkObjectiveItemsPickedUp`) plante pendant son scan periodique.

Impact:
- spam d'erreurs dans la log
- risque d'interruption de la logique de surveillance des objets
- instabilite de la suite EE-15 / EE-17

## Hypothese principale

`findPlayerHoldingItem()` appelle `getScenarioPlayers()` alors que cette fonction helper est definie plus bas dans le fichier sous forme `local function`, sans declaration prealable exploitable a cet endroit.

En Lua, cela peut laisser la reference a `nil` au moment de l'appel depuis `findPlayerHoldingItem()`.

## Objectif

Rendre `checkObjectiveItemsPickedUp()` robuste et sans crash, meme quand:
- les objets monde ne sont pas encore spawnes
- les references d'objets sont encore `nil`
- le scan serveur tourne avant que tout l'environnement EE-15/EE-17 soit pret

## Specification

### 1. Corriger l'appel helper qui vaut `nil`

Faire en sorte que `findPlayerHoldingItem()` puisse toujours appeler un helper valide pour enumerer les joueurs du scenario.

Approches acceptables:
- deplacer `getScenarioPlayers()` plus haut dans le fichier avant son premier usage
- ou declarer correctement une reference locale avant usage puis l'assigner ensuite

Le correctif doit eliminer l'erreur `Object tried to call nil in findPlayerHoldingItem`.

### 2. Garder la surveillance idempotente quand les objets ne sont pas encore prets

`checkObjectiveItemsPickedUp()` ne doit jamais lever d'erreur si:
- `Server.gasCanItem == nil`
- `Server.escapeVehicleKey == nil`
- `Server.escapeVehicleBattery == nil`

Le comportement attendu est simplement:
- ne rien faire pour l'objet non pret
- attendre le prochain tick de surveillance

### 3. Ne pas casser EE-15

La correction ne doit pas modifier la logique fonctionnelle EE-15:
- les hordes restent one-shot
- la detection par reference d'objet reste en place
- le scan recursif des sacs reste actif

### 4. Logging propre

Ajouter si utile un log defensif discret du style:
- `Surveillance objets differee: references d'objectif non pretes`

Mais:
- pas de spam massif a chaque tick
- priorite a la suppression du stack trace

## Fichiers a modifier

### `EscapadeExpress/media/lua/server/EscapadeExpressServer.lua`
- corriger l'ordre / la declaration des helpers serveur
- fiabiliser `findPlayerHoldingItem()`
- fiabiliser `checkObjectiveItemsPickedUp()` face aux references `nil`

### `project-state.md`
- ajouter le ticket EE-18
- historiser le crash observe en log

## Hors scope

- ne pas changer les coords du bidon, de la cle ou de la batterie dans ce ticket
- ne pas refaire la strategie de spawn EE-17 dans ce ticket
- ne pas modifier la logique des hordes au-dela du strict necessaire pour stopper le crash

## Criteres d'acceptation

1. La log ne contient plus `Object tried to call nil in findPlayerHoldingItem`
2. `checkObjectiveItemsPickedUp()` peut tourner meme si les references d'objets sont encore `nil`
3. Le serveur ne produit plus de stack trace Lua lie a cette surveillance
4. EE-15 reste compatible avec EE-17
5. Quand les objets existent enfin, la detection de ramassage continue de fonctionner

## Taille estimee

Small (S) — correctif local de robustesse sur l'ordre des helpers et les guards nil cote serveur
