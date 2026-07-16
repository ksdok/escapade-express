# EE-13 (M) - Ajouter un choix de role au lancement du scenario

## Contexte

Le scenario assigne aujourd'hui un role automatiquement (`soldat`, `voleur`,
`local_`, `medic`). En pratique:

- le joueur passe d'abord par l'ecran vanilla de profession du jeu;
- en solo, on veut quand meme pouvoir choisir son role de scenario;
- en multi LAN, les joueurs doivent pouvoir choisir explicitement leur role;
- le serveur doit rester autorite pour valider qu'un role n'est pas deja pris.

Le besoin n'est PAS de remplacer le flux vanilla de creation de personnage.
Le besoin est d'ajouter une **selection de role custom juste apres le spawn**.

## Probleme actuel

1. Le role est assigne automatiquement, sans choix utilisateur.
2. L'ecran vanilla de profession (Pompier, Sans emploi, etc.) peut creer une
   confusion avec les roles du scenario.
3. En multi, l'assignation implicite ne garantit pas que chaque joueur obtienne
   le role qu'il veut jouer.
4. Le timer ne doit pas penaliser les joueurs pendant qu'ils lisent/choisissent
   leur role.

## Objectif

Ajouter une phase de **selection de role post-spawn**:

- une UI custom s'ouvre apres le chargement en partie;
- le joueur choisit 1 role parmi les roles disponibles;
- le serveur confirme ou refuse ce role;
- les items/skills sont appliques seulement apres validation;
- le timer du scenario demarre a la fin de la phase de selection initiale.

## Non-objectifs

- Ne pas supprimer ou remplacer l'ecran vanilla de profession.
- Ne pas rework tout le systeme d'objets des roles (traite par EE-11).
- Ne pas ajouter les nouveaux roles de EE-12 dans ce ticket.
- Ne pas corriger l'UI HUD globale (positionnement traite a part).

## UX recommandee

### A. Regle de test / usage

Le joueur choisit encore une profession vanilla avant le spawn.

**Recommandation de scenario:**
- demander aux joueurs de prendre **Sans emploi**;
- le vrai choix gameplay se fait ensuite dans la fenetre de role.

Cette recommandation est une convention d'usage, pas un blocage technique.

### B. Fenetre de selection de role

A l'apparition du joueur dans le monde:

- ouvrir une fenetre modale `Choisis ton role`;
- afficher les 4 roles avec:
  - nom du role;
  - resume court (fantassin / furtif / support / soin);
  - liste compacte des points forts;
- afficher l'etat de disponibilite:
  - `Disponible`
  - `Pris par <username>`
  - `Indisponible` (si role deja lock)
- bouton principal: `Choisir ce role`
- bouton secondaire solo uniquement: aucun besoin

### C. Pendant la selection

Tant que le role n'est pas confirme:

- le joueur ne recoit pas encore son loadout;
- le timer du scenario ne demarre pas;
- le joueur est considere dans une phase de pre-game.

Implementation minimale recommandee:
- garder la fenetre ouverte au centre;
- ne pas chercher a bloquer tout le controle clavier dans ce ticket;
- l'autorite principale reste: pas de role applique + timer non demarre.

### D. Confirmation

Quand le joueur choisit un role:

- le client envoie `ChooseRole` au serveur avec `roleKey`;
- le serveur identifie le joueur via l'argument `player` de `OnClientCommand` (ne pas faire confiance a un `username` envoye par le client);
- le serveur verifie si le role est libre;
- si oui:
  - lock le role pour ce username;
  - applique items/skills;
  - renvoie `RoleAssigned`;
  - ferme la fenetre cote client;
- sinon:
  - renvoie `RoleUnavailable`;
  - laisse la fenetre ouverte;
  - affiche un message `Ce role vient d'etre pris`.

## Regles multi / autorite serveur

## A. Slots bases sur role choisi

EE-06 a deja introduit `playerSlots` et `roleLoadouts`.

Pour EE-13, la source de verite devient:

- `Server.playerSlots[username] = roleKey` uniquement apres choix valide;
- un role n'est reserve qu'apres validation serveur;
- un joueur qui revient garde son role si deja assigne.

## B. Rejoin

Si un joueur deja connu rejoint la partie:

- ne pas re-afficher le picker si `playerSlots[username]` existe;
- resynchroniser directement son role;
- ne pas re-appliquer le loadout si `roleLoadouts[username]` existe deja.

## C. Surplus de joueurs

Si les 4 roles sont deja pris:

- le picker peut s'ouvrir, mais tous les roles apparaitront indisponibles;
- toute tentative renvoie `RoleUnavailable` ou `RoleDenied`;
- message affiche: `Trop de joueurs pour ce scenario!`.

## Timer / debut de scenario

### A. Nouveau principe

Le timer ne doit plus demarrer au simple `OnGameStart`.
Il doit demarrer **apres la phase initiale de selection**.

### B. Roster initial

Au moment ou la selection commence, le serveur capture un roster initial:

```lua
Server.selectionRoster = {
  [username] = true,
}
Server.selectionConfirmed = {
  [username] = roleKey,
}
```

### C. Demarrage du timer

Le timer demarre quand:

- tous les joueurs du `selectionRoster` ont un role confirme; ou
- ils ont ete explicitement refuses (>4 joueurs).

Note d'implementation:
- l'initialisation technique du scenario (hooks, spawn vehicule, spawn bidon) peut rester preparee au chargement;
- en revanche `Server.startTime` doit rester `nil` tant que la phase initiale de selection n'est pas terminee.

Pseudo-logique:

```lua
local function maybeStartScenarioTimer()
    for username, _ in pairs(Server.selectionRoster) do
        if not Server.selectionConfirmed[username] and not Server.selectionDenied[username] then
            return false
        end
    end

    if not Server.gameStarted then
        Server.gameStarted = true
        Server.startTime = getGameTime():getWorldAgeHours()
        syncTimerToClients()
    end

    return true
end
```

### D. Late joiners

Si un joueur rejoint apres le debut reel du scenario:

- ne pas reinitialiser le timer;
- il choisit parmi les roles restants s'il en reste;
- sinon il est refuse.

## Commandes reseau a ajouter

### Client -> Serveur

- `RolePickerReady`
  - signale que le client est spawn et pret a voir le picker
- `ChooseRole`
  - payload: `{ roleKey }`

### Serveur -> Client

- `OpenRolePicker`
  - payload: roles + disponibilites
- `RoleAssigned`
  - deja existant, a reutiliser
- `RoleUnavailable`
  - payload: `{ roleKey, reason }`
- `RoleDenied`
  - deja existant pour surplus de joueurs
- `SyncRolePickerState`
  - payload: mapping des roles deja pris

## Structure technique recommandee

### Option retenue: UI dediee

Ajouter un fichier client separe pour la selection:

- `media/lua/client/EscapadeExpressRolePicker.lua`

Responsabilites:
- dessiner la fenetre;
- afficher les roles;
- afficher les roles deja pris;
- envoyer `ChooseRole`;
- fermer la fenetre quand `RoleAssigned` est recu.

### Variante solo toleree si necessaire

Objectif prioritaire: garder le meme flux client -> serveur en multi.

Si le runtime solo de PZ ne delivre pas fiablement les commandes client/serveur pour ce scenario, une variante locale est acceptable **uniquement en solo**:
- ouvrir le meme picker cote client;
- appliquer le role localement apres confirmation locale;
- demarrer `EE_startTime` seulement apres ce choix;
- ne jamais retomber sur l'auto-assignation immediate `soldat`.

Cette variante ne change pas la cible MP: en multijoueur, le serveur reste l'autorite.

### Fichiers a modifier

- `media/lua/client/LastStand/EscapadeExpress.lua`
  - ne plus appliquer de fallback solo automatique immediat;
  - demander l'ouverture du picker apres spawn;
  - ne plus supposer qu'un role existe des `OnNewGame`.
- `media/lua/client/EscapadeExpressUI.lua`
  - continuer a lire `EE_role` une fois assigne;
  - ne rien afficher tant que le role n'est pas confirme.
- `media/lua/client/EscapadeExpressRolePicker.lua` (nouveau)
  - UI de selection et reactions reseau.
- `media/lua/server/EscapadeExpressServer.lua`
  - remplacer `PlayerReady` auto-assignant par une logique:
    - ouverture picker;
    - validation `ChooseRole`;
    - gestion du roster initial;
    - demarrage du timer quand la selection initiale est terminee.

## Detail des roles affiches

Version minimale pour la fenetre:

```lua
local ROLE_SUMMARIES = {
  soldat = {
    name = "Soldat",
    summary = "Combat / protection",
  },
  voleur = {
    name = "Voleur",
    summary = "Furtivite / utilitaire",
  },
  local_ = {
    name = "Local",
    summary = "Survie / ressources",
  },
  medic = {
    name = "Medic",
    summary = "Soin / support",
  },
}
```

Le detail complet des objets reste dans `ROLE_DEFS`.

## Critere d'acceptation

1. En solo, une fenetre de choix de role apparait apres le spawn.
2. En solo, le joueur peut choisir Soldat / Voleur / Local / Medic.
3. En multi, deux joueurs ne peuvent jamais valider le meme role.
4. Si un role est pris entre l'ouverture et le clic, le serveur le refuse proprement.
5. Le timer ne demarre pas avant la fin de la selection initiale.
6. Un joueur qui rejoin garde son role sans repasser par le picker.
7. Les loadouts ne sont jamais dupliques.
8. Si plus de 4 joueurs sont presents, les joueurs en surplus sont refuses proprement.

## Risques / points d'attention

1. **Roster initial**: il faut definir precisement quand il est capture.
2. **Flow solo**: le fallback solo actuel devra etre remplace par le picker.
3. **Profession vanilla**: elle reste visible avant le spawn; la doc devra bien dire `prendre Sans emploi`.
4. **UI modale PZ**: il faut choisir un composant simple et robuste (panel custom / modal).
5. **Late join**: verifier que `SyncRolePickerState` suffit a tenir les clients a jour.

## Dependencies

- **EE-06 requis**: base slots/loadouts/rejoin
- **EE-11 utile ensuite**: ajuster le contenu des roles une fois le picker en place
- **EE-12 dependra de ce ticket** si on veut plus tard permettre le choix parmi >4 roles

## Taille estimee

Medium (M) -- nouvelle UI client + refonte du flux d'assignation + timer retarde
