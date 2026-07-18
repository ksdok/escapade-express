# Escapade Express

Mod Project Zomboid (Build 41) — scénario coop 4 joueurs: échappez du Xonic's Mega Mall en 3h!

Scénario custom qui s'intègre dans Pillow's Random Scenarios (apparaît dans le menu Challenges).

## Concept

- 4 joueurs coop, débutants, LAN
- Spawn dans l'arrière-boutique du Xonic's Mega Mall (cell 37x28)
- 4 rôles: Soldat, Voleur, Local, Medic — skills et items différents
- Objectif: traverser le mall, trouver un véhicule dans le parking, s'enfuir
- Véhicule sans essence — faut trouver un bidon
- Chronomètre 3h (visible à l'écran)
- Densité zombies: faible au début, augmente avec le temps
- Mort: joueur ranimable (medic 30 sec, autre joueur 1 min, sinon respawn départ)

## Événements scriptés

1. **Coupure électrique** (~45 min) — lumières coupées, torches obligatoires
2. **Warning incendie** (~1h54) — message de fumée
3. **Incendie** (~2h) — feu dans une boutique aléatoire, se propage, attire les zombies
4. **Horde finale** (3h) — si le temps est écoulé, 50 zombies par entrée du mall

## Rôles

Les rôles sont maintenant choisis via une fenêtre post-spawn. Le serveur valide qu'un rôle n'est pris qu'une seule fois. Un joueur qui se déconnecte et revient garde son rôle. Un 5e joueur est refusé.

EE-11 verrouille la V1 des 4 rôles historiques ci-dessous. Une partie du roster étendu EE-12 a aussi été rebalancée dans le code, mais ce tableau reste centré sur les rôles débutants LAN.

| Rôle | Compétences | Items clés |
|------|-------------|------------|
| Soldat | Aiming 9, Reloading 10, Lightfoot 5, Nimble 9, Sneak 4, Strength 7, Fitness 7, SmallBlade 8, LongBlade 7, Sprinting 4 | Pistol, HuntingKnife, 9mmClip x2, Bullets9mm x30, Bandages x3, Torche, Batteries x2, Eau x1, Sac Duffel |
| Voleur | Lightfoot 8, Nimble 6, Sneak 9, Strength 3, Fitness 7, SmallBlade 8, SmallBlunt 7, LongBlunt 7, Sprinting 6 | Crowbar, Screwdriver, Bandages x2, Torche, Batterie, Eau x1, Schoolbag, Hoodie blanc, Chaussures |
| Local | Cooking 4, Carpentry 4, PlantScavenging 3, Fitness 3, Strength 3 | Hammer, Clous x20, Scie, Eau x2, Haricots x2, Ouvre-boîte, Bandages x2, Torche, Batterie, Sac à dos, Carte |
| Medic | Doctor 10, Fitness 6, Lightfoot 5, Strength 4, Sneak 3, Nimble 5, Sprinting 3 | KitchenKnife, Bandages x5, Désinfectant x2, Pills x2, Antibiotiques, Torche, Batteries x2, Eau x1, Sac Duffel |

Tous les rôles démarrent avec: Panic 30, Hunger 0.2, Thirst 0.2, Fatigue 0.

## Mods requis

- **Pillow's Random Scenarios** (Workshop ID: 2106657533) — mod hôte
- **Xonic's Mega Mall** (Workshop ID: 1713269594) — map

## Installation

```bash
cp -r EscapadeExpress ~/Zomboid/mods/
```

Activer les 3 mods dans le jeu:
1. Pillow's Random Scenarios
2. Xonic's Mega Mall
3. Escapade Express

Menu principal > Challenges > Escapade Express

## Architecture du projet

```
escapade-express/
├── README.md                                      # ce fichier
├── project-state.md                               # backlog, tickets, historique
├── pz-mod-doc.md                                  # doc technique (API B41, coords, patterns)
├── .gitignore
│
├── specs/                                         # spécifications par ticket
│   ├── EE-06-assignation-roles.md
│   ├── EE-07-synchro-multi-events.md
│   ├── EE-08-messages-dupliques.md
│   ├── EE-09-placeholders-coords.md
│   ├── EE-10-plan-test.md
│   ├── EE-11-objets-roles.md
│   ├── EE-12-nouveaux-roles.md
│   └── EE-13-choix-role.md
│
└── EscapadeExpress/                               # le mod (à installer dans ~/Zomboid/mods/)
    ├── mod.info                                   # manifeste (require=PillowsRandomScenarios)
    ├── poster.png                                 # image du mod (256x256)
    ├── README.md                                  # readme du mod (installation + test)
    └── media/
        └── lua/
            ├── shared/                            # config partagée client/serveur
            │   └── EscapadeExpressConfig.lua      # placeholders coords + helpers world<->cell
            ├── client/                            # code côté client
            │   ├── LastStand/
            │   │   ├── EscapadeExpress.lua        # scénario principal (spawn, registration, timer, death)
            │   │   └── EscapadeExpress.png        # image de preview du challenge (200x200)
            │   ├── EscapadeExpressRolePicker.lua  # picker de rôle post-spawn
            │   ├── EscapadeExpressShared.lua      # helpers partagés client
            │   └── EscapadeExpressUI.lua          # HUD: chronomètre, rôle, messages temporaires
            │
            └── server/                            # code côté serveur (autorité MP)
                └── EscapadeExpressServer.lua      # rôles, items/skills, vehicule, bidon, power, fire, zombies, revive
```

### Détail des fichiers Lua

#### `client/LastStand/EscapadeExpress.lua` — Scénario principal

Registration du challenge via le pattern Pillow's (`OnChallengeQuery > addChallenge`). Gère:

- **Spawn**: cell 37x28, x=120, y=120, z=0 (placeholder arrière-boutique)
- **Initialisation solo/multi**: détection `isSinglePlayerRuntime()`, demande d'ouverture du role picker au serveur, fallback local si le flux réseau solo ne répond pas
- **Day length temps réel**: `SandboxVars.DayLength = 26` + `setMinutesPerDay(60*24)` pour que le chronomètre 3h corresponde à 3h réelles
- **Warnings temporels**: "Plus que 2h/1h/30min/10min!" via `pl:Say()` avec guard `timeWarningsShown` initialisé selon le temps restant au sync timer (late joiner safe)
- **Prévention mort client**: `OnPlayerDeath` → `setHealth(0.01)`, `setKnockedDown(true)`, `setDoDeathSound(false)`, envoie `PlayerDown` au serveur
- **Réception commandes serveur**: `RoleAssigned`, `RoleDenied`, `PlayerDown`, `PlayerRevived`, `PlayerRespawned`, `SyncTimer`, `GameOver`, `Message`

Définit aussi les `ROLE_DEFS` et `ROLE_NAMES` côté client pour le fallback solo.

#### `client/EscapadeExpressRolePicker.lua` — Picker de rôle

UI `ISPanel` custom ouverte post-spawn. Gère:

- affichage des 4 rôles avec résumé, forces et statut (`Disponible`, `Pris par <username>`, validation en cours)
- envoi `ChooseRole` au serveur en multi
- fermeture automatique sur `RoleAssigned` / `RoleDenied`
- variante solo locale qui applique le rôle puis démarre le timer seulement après validation

#### `shared/EscapadeExpressConfig.lua` — Config coords partagée

Source unique des placeholders de coordonnées du mall pour le client et le serveur. Définit:

- `EE_Config.spawn`, `parking`, `respawn`, `entrances`, `shops`, `gasCan`, `powerOutageCenter`, `powerOutageRadius`
- `EE_Config.worldToCell(worldX, worldY)`
- `EE_Config.cellToWorld(xcell, ycell, x, y)`

Tous les ajustements debug du mall doivent maintenant passer par ce fichier.

#### `client/EscapadeExpressShared.lua` — Helpers client

Fonctions partagées entre les fichiers client, notamment `EE_getNowSeconds()` pour les timestamps UI et fallback.

#### `client/EscapadeExpressUI.lua` — HUD (178 lignes)

Affichage via `Events.OnPostUIDraw`. Trois éléments HUD alignés à droite:

- **Chronomètre**: format "Temps restant: 2h45", couleur dynamique (vert >1h30, jaune <1h30, rouge <30min), "TEMPS ECOULE - GAME OVER" en rouge si timer expiré
- **Rôle**: "Role: Soldat" en blanc sous le chronomètre
- **Messages temporaires**: pile de messages avec fondu sur 5 secondes, couleur selon le type (warning=jaune, danger=rouge, success=vert)

Timer source: `getNowSeconds()` avec fallback chain `getTimestamp()` → `os.time()` → `getGameTime():getWorldAgeHours() * 3600`.

Réception `AlertMessage` (events serveur), `RoleAssigned` (confirmation rôle), `RoleDenied` (trop de joueurs).

#### `server/EscapadeExpressServer.lua` — Logique serveur

Autorité pour toutes les mécaniques sensibles en MP. Gère, avec coords centralisées via `EE_Config`:

- **Rôles choisis côté joueur** (EE-13): `OpenRolePicker`, `ChooseRole`, `RoleUnavailable`, `SyncRolePickerState`
- **Slots de rôles**: `Server.playerSlots` par username, rejoin conservé, guard anti-duplication d'items via `Server.roleLoadouts`, refus des 5e+ joueurs avec `RoleDenied`
- **Roster initial**: `selectionRoster`, `selectionConfirmed`, `selectionDenied` pour retarder le départ réel du scénario
- **Spawn vehicule**: `addVehicleDebug("Base.Van")` au parking, réparé, réservoir vide, pas de clé
- **Spawn bidon**: `sq:SpawnWorldInventoryItem("Base.PetrolCan")` à une location distincte du parking
- **Timer serveur**: `prepareScenario()` prépare l'environnement; `Server.startTime` n'est défini qu'après la fin de la sélection initiale puis sync via `SyncTimer`
- **Events scripts** (EE-07): `serverEveryMinutes()` déclenche coupure elec (~45min), warning incendie (~1h54), incendie (~2h dans une boutique aléatoire), game over (3h). `serverEveryHours()` spawn progressif de zombies (3 → 10 → 25 par entrée)
- **Coupure électrique**: `setHaveElectricity(false)` sur 200x200 squares (étages 0 et 1) autour du centre du mall
- **Incendie**: `IsoFireManager.StartFire()` + `addSound()` pour attirer les zombies
- **Game over**: guard anti-double, 50 zombies par entrée, broadcast `GameOver` + `AlertMessage`
- **Revive** (EE-05): monitoring `checkDownedPlayers()` via `EveryOneMinute`. Détection down (health < 0.15), `markPlayerDowned()` centralisé, `getNearbyReviverType()` retourne "medic"/"other"/nil. Timings: medic 30 sec, autre 1 min, sinon respawn au point de départ (distinct du parking). Supporte solo et MP via `getScenarioPlayers()` (getOnlinePlayers → fallback getPlayer)

### Séparation client / serveur

| Responsabilité | Client | Serveur |
|----------------|--------|---------|
| Registration challenge (OnChallengeQuery) | ✅ | — |
| Spawn position | ✅ | — |
| Day length (temps réel) | ✅ (SandboxVars + setMinutesPerDay) | ✅ (prepareScenario) |
| Timer (startTime) | reçoit SyncTimer | ✅ (autorité, après sélection initiale) |
| Timer (affichage HUD) | ✅ | — |
| Events scripts (coupure, incendie, zombies, game over) | — | ✅ |
| Rôles (picker, items, skills) | fallback solo + UI picker | ✅ (autorité) |
| Véhicule + bidon (spawn) | — | ✅ |
| Revive (détection, health, respawn) | — | ✅ |
| Mort (prévention immédiate) | ✅ | ✅ (backup) |
| HUD (chronomètre, rôle, messages) | ✅ | — |
| Warnings temporels ("Plus que 30 min!") | ✅ | — |
| Refus 5e joueur | — | ✅ (RoleDenied) |

### Flux réseau

```
Client                              Serveur
  │                                   │
  ├── RolePickerReady ──────────────► │ (ouvre le picker ou resync un rôle existant)
  │ ◄── OpenRolePicker ────────────── │
  │ ◄── SyncRolePickerState ───────── │
  │ ├── ChooseRole ─────────────────► │ (validation serveur)
  │ ◄── RoleAssigned / RoleUnavailable│
  │ ◄── RoleDenied ────────────────── │
  │ ◄── SyncTimer ─────────────────── │
  │                                   │
  │ ◄── AlertMessage ──────────────── │ (coupure elec, fumée, incendie, game over)
  │ ◄── GameOver ──────────────────── │
  │                                   │
  ├── PlayerDown ───────────────────► │ (serveur confirme + monitoring revive)
  │                                   │     └── checkDownedPlayers EveryOneMinute
  │ ◄── PlayerDown ────────────────── │ (broadcast aux autres clients)
  │ ◄── PlayerRevived ─────────────── │ (medic 30s / other 1min)
  │ ◄── PlayerRespawned ───────────── │ (respawn départ si seul)
```

### Moddata du joueur (modData.EE_*)

| Champ | Côté | Usage |
|-------|------|-------|
| `EE_role` | client+serveur | clé du rôle assigné (soldat/voleur/local_/medic) |
| `EE_reviveEnabled` | client+serveur | active la prévention de mort |
| `EE_localRoleApplied` | client | anti-duplication fallback solo |
| `EE_roleSelectionDenied` | client | évite de re-demander un picker après refus |
| `EE_downed` | client+serveur | joueur à terre |
| `EE_downTime` | client+serveur | timestamp du down (heures de jeu) |
| `EE_downX/Y/Z` | client+serveur | position du down |

### Événements Lua utilisés

| Event | Fichier | Usage |
|-------|---------|-------|
| `OnChallengeQuery` | client | enregistre le challenge |
| `OnGameStart` | client+serveur | init scénario, préparation, spawn vehicule/bidon |
| `OnCreatePlayer` | client | re-trigger OnNewGame (late join / rejoin) |
| `EveryOneMinute` | client+serveur | warnings temporels (client), events + revive (serveur) |
| `EveryHours` | serveur | spawn progressif de zombies |
| `OnPlayerDeath` | client | prévention mort, envoie PlayerDown |
| `OnPostUIDraw` | client | rendu HUD (timer, rôle, messages) |
| `OnServerCommand` | client | réception messages serveur |
| `OnClientCommand` | serveur | réception commandes client |

## Coordonnées (PLACEHOLDERS)

Toutes les coordonnées sont des **placeholders** basés sur cell 37x28 (Xonic's Mega Mall).

| Variable | Valeur | Fichier | Usage |
|----------|--------|---------|-------|
| SPAWN | xcell=37, ycell=28, x=120, y=120, z=0 | client | Spawn arrière-boutique |
| PARKING_X/Y/Z | 11250, 8550, 0 | client+serveur | Parking (véhicule) |
| GAS_CAN_LOCATION | 11170, 8490, 0 | client+serveur | Bidon d'essence |
| RESPAWN_X/Y/Z | 11220, 8520, 0 | serveur | Point de respawn (distinct du parking) |
| MALL_ENTRANCES[1-3] | 11200/11100/11300, 8400/8500/8450 | serveur | Spawn zombies |
| SHOPS[1-4] | 11180-11220, 8430-8470 | serveur | Incendie aléatoire |
| cutPower center | 11200, 8450, radius 100 | serveur | Zone coupure élec |

Procédure d'ajustement:
1. Lancer le jeu avec Xonic's Mega Mall + Escapade Express
2. Mode debug (Sandbox > Debug Mode)
3. Téléporter à la position souhaitée
4. Lire les coords (F3 ou console: `getPlayer():getX()`)
5. Convertir: `xcell = floor(x/300)`, `x = x - (xcell*300)`
6. Mettre à jour dans `EscapadeExpress.lua` et `EscapadeExpressServer.lua`

## Tickets et état d'avancement

Voir `project-state.md` pour le backlog complet et `specs/` pour les spécifications détaillées.

| Ticket | Description | Statut |
|--------|-------------|--------|
| EE-01 | Initialisation du scénario | ✅ |
| EE-02 | Commandes réseau client/serveur | ✅ |
| EE-03 | Spawn du bidon (API correcte) | ✅ |
| EE-04 | Remplacement getTimestampMs() | ✅ |
| EE-05 | Logique de revive (medic/other/respawn) | ✅ |
| EE-06 | Assignation des rôles (slots déterministes) | ✅ |
| EE-07 | Synchro multi des events (autorité serveur) | ✅ |
| EE-08 | Nettoyer les messages dupliqués | ✅ |
| EE-09 | Centraliser les placeholders de coords | ✅ |
| EE-10 | Plan de test solo + LAN | ✅ |
| EE-11 | Définir les objets de chaque rôle | ✅ |
| EE-12 | Nouveaux rôles: roster étendu 16 rôles + Civil | ✅ |
| EE-13 | Choix de rôle post-spawn avec UI | ✅ |
| EE-14 | Explosion du véhicule d'escape après démarrage | ✅ |
| EE-15 | Clé, batterie déchargée et hordes par ramassage | ✅ |
| EE-16 | Rôle Builder (construction illimitée) | ⏳ |

## Repo

https://github.com/ksdok/escapade-express