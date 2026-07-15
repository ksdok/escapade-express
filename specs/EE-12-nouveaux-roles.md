# EE-12 (M) - Ajouter de nouveaux roles: Rambo, Sniper, Samourai

## Contexte

Le scenario a actuellement 4 roles (Soldat, Voleur, Local, Medic) assignes
par ordre de join via `ROLE_ORDER`. L'utilisateur veut ajouter 3 nouveaux roles:
Rambo, Sniper, Samourai.

## Concept des nouveaux roles

### Rambo
- Profil: combattant rapproche agressif, gros degats, peu de discretion
- Style: charge dans le tas, multi-zombies, tanky
- Skills:
  - Strength 6, Fitness 5, Axe 5, Melee 4
  - Sneak 0, Lightfoot 0 (bruyant)
  - Reloading 1, Aiming 1 (mauvais au tir)
- Items:
  - Axe x1 (arme principale)
  - KitchenKnife x2 (armes secondaires)
  - Bandage x4 (comme Rambo, se soigne en plein combat)
  - WaterBottleFull x1
  - Bag_NormalHikingBag x1
  - HoodieDOWNBlackTINT x1, Trousers x1, Shoes_Black x1
  - Torch x1, Battery x1
- Mecanique specifique:
  - Endurance plus haute au spawn (setEndurance(0.7))
  - Panic plus basse (setPanic(10)) -- Rambo a pas peur

### Sniper
- Profil: tireur d'elite a longue distance, faible au melee
- Style: couvre les autres de loin, one-shot les zombies isoles
- Skills:
  - Aiming 7, Reloading 5
  - Sneak 4, Lightfoot 4 ( discret pour positionner)
  - Strength 2, Fitness 2 (peu de stamina)
  - Melee 1 (mauvais au melee)
- Items:
  - HuntingRifle x1 (arme principale)
  - Bullets308 x20 (munitions)
  - KitchenKnife x1 (backup melee)
  - Bandage x2
  - WaterBottleFull x1
  - Bag_NormalHikingBag x1
  - HoodieDOWNGreenTINT x1 (camouflage), Trousers x1, Shoes_Black x1
  - Torch x1, Battery x1, Binoculars x1
- Mecanique specifique:
  - Pas de panic bonus (setPanic(20)) -- le sniper garde son sang-froid
  - Pas de mouvement rapide (Fitness 2)

### Samourai
- Profil: maitre du katana, discipline, equilibre entre offense et defense
- Style: combat melee elegant, contre-attaques, mobility
- Skills:
  - Melee 6, Axe 0 (n'utilise pas de hache)
  - Fitness 5, Strength 4, Nimble 5
  - Sneak 3, Lightfoot 3
  - Aiming 0, Reloading 0 (pas d'armes a feu)
- Items:
  - Katana x1 (arme principale -- si dispo en vanilla B41, sinon HuntingKnife)
  - KitchenKnife x2 (armes secondaires)
  - Bandage x3
  - WaterBottleFull x1
  - Bag_NormalHikingBag x1
  - HoodieDOWNWhiteTINT x1, Trousers x1, Shoes_Black x1
  - Torch x1, Battery x1
- Mecanique specifique:
  - Mouvement plus rapide (setEndurance(0.5))
  - Panic modere (setPanic(15)) -- discipline

## Probleme d'architecture

### A. Systeme d'assignation actuel limite a 4

`ROLE_ORDER` a 4 entrees. Avec 7 roles, il faut adapter:

Option 1: **7 roles fixes, assignation par ordre de join (1-7)**
- Simple mais limite a 7 joueurs max
- Au-dela: pas de role

Option 2: **Selection de role au lancement**
- Le joueur choisit son role dans un menu au spawn
- Plus flexible mais necessite une UI custom

Option 3: **4 roles parmi 7, rotation aleatoire**
- 4 roles tires aleatoirement parmi les 7 a chaque partie
- Rejouabilite mais frustration possible (ne pas avoir son role prefere)

### Recommandation: Option 1 (7 roles par ordre de join)

C'est la plus simple et coherente avec le pattern Pillow's. Le systeme de slots
de EE-06 gere deja >4 joueurs.

## Implementation

### A. Etendre ROLE_DEFS et ROLE_ORDER

```lua
local ROLE_ORDER = {"soldat", "voleur", "local_", "medic", "rambo", "sniper", "samourai"}

local ROLE_DEFS = {
    -- ... roles existants ...

    rambo = {
        name = "Rambo",
        skills = {
            {Perks.Strength, 6},
            {Perks.Fitness, 5},
            {Perks.Axe, 5},
            {Perks.Melee, 4},
            {Perks.Sneak, 0},
            {Perks.Lightfoot, 0},
            {Perks.Reloading, 1},
            {Perks.Aiming, 1},
        },
        items = {
            {"Base.Axe", 1},
            {"Base.KitchenKnife", 2},
            {"Base.Bandage", 4},
            {"Base.WaterBottleFull", 1},
            {"Base.Bag_NormalHikingBag", 1},
            {"Base.HoodieDOWNBlackTINT", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 1},
        },
        stats = {
            endurance = 0.7,
            panic = 10,
        },
    },
    sniper = {
        name = "Sniper",
        skills = {
            {Perks.Aiming, 7},
            {Perks.Reloading, 5},
            {Perks.Sneak, 4},
            {Perks.Lightfoot, 4},
            {Perks.Strength, 2},
            {Perks.Fitness, 2},
            {Perks.Melee, 1},
        },
        items = {
            {"Base.HuntingRifle", 1},
            {"Base.Bullets308", 20},
            {"Base.KitchenKnife", 1},
            {"Base.Bandage", 2},
            {"Base.WaterBottleFull", 1},
            {"Base.Bag_NormalHikingBag", 1},
            {"Base.HoodieDOWNGreenTINT", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 1},
            {"Base.Binoculars", 1},
        },
        stats = {
            panic = 20,
        },
    },
    samourai = {
        name = "Samourai",
        skills = {
            {Perks.Melee, 6},
            {Perks.Fitness, 5},
            {Perks.Strength, 4},
            {Perks.Nimble, 5},
            {Perks.Sneak, 3},
            {Perks.Lightfoot, 3},
        },
        items = {
            {"Base.Katana", 1},  -- si dispo en B41 vanilla, sinon HuntingKnife
            {"Base.KitchenKnife", 2},
            {"Base.Bandage", 3},
            {"Base.WaterBottleFull", 1},
            {"Base.Bag_NormalHikingBag", 1},
            {"Base.HoodieDOWNWhiteTINT", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 1},
        },
        stats = {
            endurance = 0.5,
            panic = 15,
        },
    },
}
```

### B. Stats specifiques par role

Ajouter un bloc `stats` optionnel dans `ROLE_DEFS` et l'appliquer dans
`applyRole`:

```lua
-- Dans applyRole, apres setStats de base:
if def.stats then
    if def.stats.endurance then
        player:getStats():setEndurance(def.stats.endurance)
    end
    if def.stats.panic then
        player:getStats():setPanic(def.stats.panic)
    end
end
```

### C. Mettre a jour les roleNames cote UI

```lua
-- EscapadeExpressUI.lua, drawRole():
local roleNames = {
    soldat = "Soldat",
    voleur = "Voleur",
    local_ = "Local",
    medic = "Medic",
    rambo = "Rambo",
    sniper = "Sniper",
    samourai = "Samourai",
}
```

### D. Verifier les items vanilla B41

A verifier dans le wiki PZ ou en jeu:
- `Base.Katana` -- existe en B41 vanilla? (si non, utiliser `Base.HuntingKnife`)
- `Base.HuntingRifle` -- nom exact de l'item?
- `Base.Bullets308` -- nom exact? (peut etre `Base.308Round` ou similaire)
- `Base.Binoculars` -- existe en B41?
- `Perks.Axe`, `Perks.Melee` -- noms exacts des perks?

## Fichiers a modifier

- `media/lua/server/EscapadeExpressServer.lua`:
  - Etendre `ROLE_ORDER` (ligne 22)
  - Etendre `ROLE_DEFS` (ligne 40-122)
  - Etendre `ROLE_NAMES` (ligne 23-28)
  - Ajouter bloc `stats` dans `applyRole` (ligne 128-168)
- `media/lua/client/EscapadeExpressUI.lua`:
  - Etendre `roleNames` (ligne 80-85)

## Critere d'acceptation

1. Les 3 nouveaux roles (Rambo, Sniper, Samourai) sont jouables
2. Chaque role a des skills, items et stats distincts
3. L'assignation fonctionne jusqu'a 7 joueurs
4. Les stats specifiques (endurance, panic) s'appliquent au spawn
5. L'UI affiche le nom correct des nouveaux roles
6. Tous les items utilises existent en B41 vanilla

## Dependencies

- **EE-06 requis avant**: Le systeme de slots de EE-06 gere l'assignation pour
  >4 joueurs. Sans EE-06, le compteur modulo va cycler.
- **EE-11 requis avant**: La definition des objets des roles existants doit etre
  validee avant d'ajouter les nouveaux.
- Verifier la disponibilite des items vanilla (Katana, HuntingRifle, etc.)

## Taille estimee

Medium (M) -- 3 nouvelles definitions de roles + stats specifiques + verification des items