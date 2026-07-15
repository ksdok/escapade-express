# EE-06 (M) - Fiabiliser l'assignation des 4 roles et des items/skills au lancement du scenario

## Contexte

L'assignation des roles se fait cote serveur dans `EscapadeExpressServer.lua`.
Le client envoie `sendClientCommand("EscapadeExpress", "PlayerReady", {username=...})`
via `OnNewGame` / `OnCreatePlayer`. Le serveur assigne un role par ordre de join
(`ROLE_ORDER = {"soldat", "voleur", "local_", "medic"}`) via un compteur
`Server.roleCounter`.

## Probleme actuel

1. **Ordre de join non deterministe**: `Server.roleCounter` s'incremente a chaque
   `PlayerReady` recu. En MP, l'ordre d'arrivee des clients n'est pas garanti.
   Si un joueur se deconnecte et revient, `PlayerReady` est renvoye et le compteur
   s'incremente again -- le joueur peut obtenir un role different.

2. **Pas de verification du nombre de joueurs**: `ROLE_ORDER` a 4 entrees. Si un
   5e joueur se connecte, `roleCounter % 4 + 1` lui assigne un role en boucle. Pas
   de guard pour refuser ou gerer un surplus.

3. **Re-assignation au rejoin**: Le guard `if not roleKey then` empeche la
   double-assignation, mais `modData.EE_role` est set par le serveur uniquement.
   Si le modData du joueur est reset (nouveau personnage), `EE_role` est nil et
   le serveur re-assigne un nouveau role + redonne tous les items.

4. **Items donnes en double au rejoin**: `applyRole` ajoute les items sans verifier
   si le joueur les a deja. Si le serveur re-applique le role, les items sont
   dupliques.

5. **Le client affiche "Mon role: X" via Say() ET l'UI affiche "Role: X" via
   AlertMessage**: Double affichage (couvre partiellement EE-08).

## Spec corrective

### A. Assignation deterministe par slot fixe

Remplacer le compteur sequentiel par un systeme de slots:

```lua
-- Serveur: table des slots par username
Server.playerSlots = {}  -- { [username] = roleKey }

local function assignRole(player)
    local username = player:getUsername()
    local modData = player:getModData()

    -- Si le joueur a deja un role assigne, ne pas re-assigner
    if Server.playerSlots[username] then
        return Server.playerSlots[username]
    end

    -- Trouver le premier slot libre dans ROLE_ORDER
    local takenRoles = {}
    for _, role in pairs(Server.playerSlots) do
        takenRoles[role] = true
    end

    for _, roleKey in ipairs(ROLE_ORDER) do
        if not takenRoles[roleKey] then
            Server.playerSlots[username] = roleKey
            return roleKey
        end
    end

    -- Tous les slots sont pris (>4 joueurs)
    return nil
end
```

### B. Guard contre >4 joueurs

Si `assignRole` retourne nil (tous les slots pris):
- Ne pas donner d'items ni skills
- Envoyer un message au client: "Trop de joueurs pour ce scenario!"
- Le joueur spawnera en mode spectateur minimal (ou en survie basique)

### C. Anti-duplication d'items via etat serveur

Ne pas se reposer uniquement sur `modData.EE_role`, car ce state peut etre
recree lors d'un rejoin. Garder une trace serveur des loadouts deja accordes:

```lua
Server.roleLoadouts = {}  -- { [username] = roleKey }

local function applyRole(player, roleKey)
    local username = player:getUsername()
    local modData = player:getModData()

    -- Toujours resynchroniser le role dans le modData
    modData.EE_role = roleKey
    modData.EE_reviveEnabled = true

    -- Loadout deja attribue dans cette session serveur
    if Server.roleLoadouts[username] == roleKey then
        return false
    end

    -- ... donner items + skills + stats ...

    Server.roleLoadouts[username] = roleKey
    return true
end
```

### D. Pas de cleanup au deconnect en B41

La doc Build 41 ne fournit pas ici un hook serveur `OnDisconnect` avec
`IsoPlayer` exploitable pour liberer proprement un slot. La logique la plus
sure est donc:

- conserver `Server.playerSlots[username]` pendant toute la session serveur;
- re-utiliser ce slot lors d'un nouveau `PlayerReady` du meme username;
- ne jamais recycler un slot en cours de scenario, meme si le joueur quitte.

Cela garantit qu'un rejoin garde le meme role et qu'un 5e joueur ne peut pas
prendre le slot d'un joueur temporairement deco.

## Fichiers a modifier

- `media/lua/server/EscapadeExpressServer.lua`:
  - Remplacer `Server.roleCounter` par `Server.playerSlots`
  - Ajouter `Server.roleLoadouts` pour memoriser les loadouts deja attribues
  - Nouvelle fonction `assignRole(player)` avec slots
  - Guard dans `applyRole` contre duplication
  - Guard dans `onClientCommand PlayerReady` contre >4 joueurs
- `media/lua/client/LastStand/EscapadeExpress.lua`:
  - Gerer un event `RoleDenied` pour le joueur en surplus
  - Supprimer le `Say("Mon role: X")` si l'UI affiche deja le role
- `media/lua/client/EscapadeExpressUI.lua`:
  - Afficher `RoleDenied` comme alerte locale

## Critere d'acceptation

1. 4 joueurs max, un role chacun, pas de duplicata
2. Un joueur qui se deconnecte et revient garde son role
3. Un 5e joueur n'obtient pas de role et recoit un message
4. Les items ne sont jamais dupliques lors d'un rejoin / double `PlayerReady`
5. Aucun role n'est recycle en cours de scenario et au plus 4 usernames ont un slot

## Plan de test minimal

### Test 1 - Solo smoke test
1. Lancer une nouvelle partie avec le scenario.
2. Verifier qu'un role est assigne apres `PlayerReady`.
3. Verifier qu'un seul message de role apparait (UI, pas de doublon `Say`).
4. Verifier que les items du role sont presents une seule fois dans l'inventaire.
5. Quitter puis recharger si possible dans la meme session serveur/test et verifier qu'aucun item supplementaire n'est ajoute.

Resultat attendu:
- role visible et coherent;
- aucun doublon d'items;
- aucun message de role duplique.

### Test 2 - LAN 4 joueurs
1. Faire rejoindre 4 joueurs avec usernames distincts.
2. Noter le role recu par chaque joueur.
3. Verifier que les 4 roles sont tous differents: `soldat`, `voleur`, `local_`, `medic`.
4. Verifier que chaque joueur recoit une seule fois son loadout.
5. Faire renvoyer `PlayerReady` (reconnexion, recreate player, ou relance si applicable) pour un joueur deja assigne.

Resultat attendu:
- 4 joueurs max avec 4 roles uniques;
- le joueur deja connu garde le meme role;
- aucun item/skill n'est reattribue en double.

### Test 3 - Rejoin d'un joueur
1. En LAN, faire quitter un joueur deja assigne.
2. Faire revenir le meme username.
3. Verifier qu'il retrouve le meme role.
4. Verifier que le slot n'a pas ete donne a un autre joueur entre-temps.
5. Verifier que son inventaire/loadout n'est pas duplique au retour.

Resultat attendu:
- meme username => meme role;
- slot conserve pendant toute la session;
- pas de duplication d'items.

### Test 4 - 5e joueur refuse
1. Lancer une session avec 4 joueurs deja assignes.
2. Faire rejoindre un 5e joueur avec un username jamais vu.
3. Verifier qu'il ne recoit aucun role.
4. Verifier qu'il voit le message `Trop de joueurs pour ce scenario!`.
5. Verifier qu'il ne recoit ni loadout ni revive specifique au scenario.

Resultat attendu:
- aucun 5e role cree;
- aucun slot recycle;
- message d'erreur visible cote client.

### Test 5 - Double `PlayerReady`
1. Sur un joueur deja assigne, provoquer deux emissions de `PlayerReady` si possible.
2. Observer les logs serveur et l'inventaire du joueur.
3. Verifier que le serveur resynchronise le role sans re-appliquer le loadout.

Resultat attendu:
- role identique apres chaque `PlayerReady`;
- aucun item ajoute en plus;
- logs serveur montrant `Role resynchronise` plutot qu'une nouvelle assignation.

## Dependencies

- Aucune (independant des autres tickets)
- EE-11 (definition des objets) modifiera les `ROLE_DEFS` mais pas la logique
  d'assignation

## Taille estimee

Medium (M) -- refactoring du systeme d'assignation + tests de edge cases