# EE-17 — Spawn différé / retry du véhicule et des objets d'évasion

## Contexte

Un test solo du 2026-07-18 a montré que les objets EE-15 peuvent être absents en jeu alors que les coordonnées sont correctes.

Symptôme observé:
- le joueur va aux coordonnées de la clé, mais ne trouve rien

Logs `[EE]` relevés dans `DebugLog.txt`:
- `ERREUR: Impossible de trouver le square du parking.`
- `ERREUR: Impossible de trouver le square du bidon d'essence.`
- `ERREUR: Cle de vehicule indisponible pour le spawn.`
- `ERREUR: Impossible de trouver le square de la batterie de voiture.`

Conclusion: `prepareScenario()` tente de spawner le van, le bidon, la clé et la batterie trop tôt, avant que les squares visés du mall soient disponibles côté serveur.

## État actuel du code

### Serveur (`EscapadeExpressServer.lua`)
- `onGameStart()` appelle `resetScenarioState()` puis `prepareScenario()`
- `prepareScenario()` pose `Server.scenarioPrepared = true`, puis appelle immédiatement:
  - `spawnEscapeVehicle()`
  - `spawnGasCan()`
  - `spawnCarKey()`
  - `spawnCarBattery()`
- chaque fonction de spawn fait un `getCell():getGridSquare(...)`
- si le square est `nil`, la fonction log une erreur puis `return`
- il n'existe pas de mécanisme de retry robuste après cet échec initial
- la clé dépend du véhicule: si le van ne spawn pas, `car:createVehicleKey()` n'est jamais appelé, donc `Server.escapeVehicleKey` reste `nil`

### Configuration (`EscapadeExpressConfig.lua`)
Les coordonnées réelles sont déjà renseignées pour:
- `parking`
- `gasCan`
- `carKey`
- `carBattery`

Le problème n'est donc pas prioritairement un problème de coordonnées, mais de timing de chargement des squares.

## Objectif

Rendre le spawn du van, du bidon, de la clé et de la batterie fiable même si les squares ciblés ne sont pas encore disponibles au tout début du scénario.

## Spécification

### 1. Séparer la préparation d'état et la préparation des objets monde

`prepareScenario()` ne doit plus considérer le scénario comme "prêt" uniquement parce qu'il a tenté un spawn une fois.

Ajouter une notion distincte côté serveur:
- `Server.worldObjectsPrepared` — vrai seulement quand les 4 éléments sont bien prêts:
  - van spawn
  - bidon spawn
  - clé spawn
  - batterie spawn

`Server.scenarioPrepared` peut continuer à signifier que l'état global du scénario a été initialisé, mais il ne doit plus empêcher les retries des objets monde.

### 2. Ajouter une fonction de retry centralisée

Créer une fonction serveur du style `tryPrepareWorldObjects()` qui:
1. tente `spawnEscapeVehicle()` si le van n'existe pas
2. tente `spawnGasCan()` si le bidon n'est pas spawn
3. tente `spawnCarKey()` si la clé n'est pas spawn
4. tente `spawnCarBattery()` si la batterie n'est pas spawn
5. pose `Server.worldObjectsPrepared = true` seulement quand tout est effectivement prêt

Important:
- `spawnCarKey()` ne doit être tentée que si `Server.escapeVehicleKey` existe déjà, donc après succès du spawn du van
- la fonction doit être idempotente et sûre si appelée plusieurs fois

### 3. Ajouter des retries après `OnGameStart`

Ne pas dépendre d'un unique essai au `OnGameStart`.

Retries recommandés:
- appel initial dans `prepareScenario()`
- nouvel appel quand un joueur envoie `RolePickerReady`
- filet de sécurité périodique via `EveryOneMinute` tant que `Server.worldObjectsPrepared == false`

But:
- si les chunks/squares du mall ne sont pas prêts au démarrage, ils pourront l'être quelques secondes plus tard sans relancer la partie

### 4. Logging plus utile

Remplacer les logs d'échec bruts par des logs plus actionnables.

Exemples:
- `Spawn vehicule differe: square parking indisponible, retry plus tard`
- `Spawn cle differe: vehicule ou cle non prete, retry plus tard`
- `Objets d'evasion prets: van + bidon + cle + batterie`

Le but est de distinguer:
- un échec temporaire normal de chargement
- un vrai problème durable de coordonnées/config

### 5. Ne pas démarrer les dépendances critiques sans objets monde

Le timer peut rester découplé du choix de rôle comme aujourd'hui, mais l'implémentation finale doit éviter un état où:
- le scénario a commencé
- les rôles sont distribués
- mais les objets critiques d'évasion n'ont jamais existé

Minimum attendu:
- les retries continuent même après le choix de rôle tant que `worldObjectsPrepared` est faux

### 6. Solo et multi

Le correctif doit fonctionner:
- en solo
- en LAN multi

Le serveur reste l'autorité pour les spawns monde.

## Fichiers à modifier

### `media/lua/server/EscapadeExpressServer.lua`
- ajouter `Server.worldObjectsPrepared`
- ajouter `tryPrepareWorldObjects()`
- adapter `prepareScenario()` pour initialiser l'état puis tenter sans bloquer les retries
- appeler `tryPrepareWorldObjects()` depuis:
  - `prepareScenario()`
  - `RolePickerReady`
  - un hook périodique serveur (`EveryOneMinute`) tant que nécessaire
- améliorer les logs de spawn différé / succès final

### `project-state.md`
- ajouter le ticket EE-17
- historiser le constat de test/log

## Hors scope

- Ne pas changer les coordonnées réelles de la clé, de la batterie, du bidon ou du parking
- Ne pas modifier la logique des hordes EE-15
- Ne pas modifier la logique d'explosion EE-14
- Ne pas ajouter de nouvelle UI de quête

## Critères d'acceptation

1. Si les squares du mall sont indisponibles au `OnGameStart`, le serveur réessaie automatiquement plus tard
2. Le van finit par spawn sans relancer la partie
3. Le bidon finit par spawn sans relancer la partie
4. La clé finit par spawn sans relancer la partie
5. La batterie finit par spawn sans relancer la partie
6. Les logs `[EE]` montrent explicitement les retries puis le succès final
7. Le correctif fonctionne en solo
8. Le correctif reste compatible LAN
9. Après chargement réussi, le joueur peut réellement trouver la clé aux coordonnées configurées

## Taille estimée

Medium (M) — refactor léger du flux de préparation serveur + état explicite + retries idempotents
