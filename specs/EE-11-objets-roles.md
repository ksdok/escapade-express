# EE-11 (S) - Verrouiller les loadouts de depart des roles

## Contexte

La spec EE-11 d'origine etait devenue obsolete apres EE-12:

- le roster contient maintenant **16 roles uniques + Civil**
- l'equipement auto (`equipped`) est deja actif cote client et serveur
- les loadouts ne sont plus de simples placeholders

EE-11 devient donc un ticket de **rebalancing / finition** des loadouts de
depart, avec une priorite immediate sur les 4 roles historiques
(Soldat, Voleur, Local, Medic) pour les parties LAN debutants.

## Probleme constate

Dans l'etat actuel du code, la baseline suivante n'etait pas respectee pour
les 4 roles de base:

- chaque role doit avoir au minimum:
  - 1 arme
  - 1 bandage
  - 1 torche
  - 1 source d'eau

Ecarts identifies:

- **Soldat**: pas d'eau
- **Voleur**: pas d'eau
- **Local**: pas de torche
- **Medic**: pas d'arme, pas d'eau

## Decision de cette passe

Cette passe EE-11 ne rebat pas tout le roster EE-12.
Elle verrouille une **V1 jouable** pour les roles historiques:

### Soldat
- Ajout `Base.HuntingKnife` x1
- Ajout `Base.WaterBottleFull` x1
- Equipement secondaire: `Base.HuntingKnife`

### Voleur
- Ajout `Base.WaterBottleFull` x1

### Local
- Ajout `Base.Torch` x1
- Ajout `Base.Battery` x1

### Medic
- Ajout `Base.KitchenKnife` x1
- Ajout `Base.WaterBottleFull` x1
- Equipement principal: `Base.KitchenKnife`

## Roles valides avec l'utilisateur (pause de validation)

### Soldat - VALIDE
Skills:
- Aiming 9
- Reloading 10
- Lightfooted 5
- Nimble 9
- Sneaking 4
- Strength 7
- Fitness 7
- Short Blade 8
- Long Blade 7
- Sprinting 4

Items:
- `Base.Pistol` x1
- `Base.HuntingKnife` x1
- `Base.9mmClip` x2
- `Base.Bullets9mm` x30
- `Base.Bandage` x3
- `Base.Torch` x1
- `Base.Battery` x2
- `Base.WaterBottleFull` x1
- `Base.Bag_DuffelBag` x1
- `Base.HoodieDOWN_WhiteTINT` x1
- `Base.Trousers` x1

Dans le sac:
- `Base.Bandage` x3
- `Base.WaterBottleFull` x1

### Voleur - VALIDE
Skills:
- Lightfooted 8
- Nimble 6
- Sneaking 9
- Strength 3
- Fitness 7
- Short Blade 8
- Short Blunt 7
- Long Blunt 7
- Sprinting 6

Items:
- `Base.Crowbar` x1
- `Base.Screwdriver` x1
- `Base.Bandage` x2
- `Base.Torch` x1
- `Base.Battery` x1
- `Base.WaterBottleFull` x1
- `Base.Bag_Schoolbag` x1
- `Base.HoodieDOWN_WhiteTINT` x1
- `Base.Trousers` x1
- `Base.Shoes_Black` x1

Dans le sac:
- `Base.Bandage` x2
- `Base.WaterBottleFull` x1

### Local - VALIDE
Skills:
- Cooking 4
- Carpentry 4
- PlantScavenging 3
- Fitness 3
- Strength 3

Items:
- `Base.Hammer` x1
- `Base.Nails` x20
- `Base.Saw` x1
- `Base.WaterBottleFull` x2
- `Base.TinnedBeans` x2
- `Base.TinOpener` x1
- `Base.Bandage` x2
- `Base.Torch` x1
- `Base.Battery` x1
- `Base.Bag_NormalHikingBag` x1
- `Base.Map` x1

Dans le sac:
- `Base.WaterBottleFull` x2
- `Base.TinnedBeans` x2
- `Base.TinOpener` x1
- `Base.Bandage` x2
- `Base.Map` x1

### Medic - VALIDE
Skills:
- First Aid / Doctor 10
- Fitness 6
- Lightfooted 5
- Strength 4
- Sneaking 3
- Nimble 5
- Sprinting 3

Items:
- `Base.KitchenKnife` x1
- `Base.Bandage` x5
- `Base.Disinfectant` x2
- `Base.Pills` x2
- `Base.Antibiotics` x1
- `Base.Torch` x1
- `Base.Battery` x2
- `Base.WaterBottleFull` x1
- `Base.Bag_DuffelBag` x1
- `Base.Trousers` x1
- `Base.Shoes_Black` x1

Dans le sac:
- `Base.Bandage` x5
- `Base.Disinfectant` x2
- `Base.Pills` x2
- `Base.Antibiotics` x1
- `Base.WaterBottleFull` x1

### Rambo - VALIDE
Skills:
- Strength 10
- Fitness 9
- Axe 9
- Sneak 0
- Lightfooted 0
- Nimble 10
- Reloading 7
- Aiming 8
- Long Blade 8
- Short Blade 8
- Long Blunt 8
- Short Blunt 8
- Spear 8
- PlantScavenging 8
- Sprinting 7

Items:
- `Base.Axe` x1
- lance avec machette x1 (`itemId` exact B41 a confirmer au moment du codage)
- `Base.KitchenKnife` x2
- `Base.Bandage` x4
- `Base.WaterBottleFull` x1
- `Base.Bag_NormalHikingBag` x1
- `Base.Jacket_Black` x1
- `Base.Trousers` x1
- `Base.Shoes_Black` x1
- `Base.Torch` x1
- `Base.Battery` x1

Dans le sac:
- `Base.Bandage` x4
- `Base.WaterBottleFull` x1

### Sniper - VALIDE
Skills:
- Aiming 9
- Reloading 8
- Sneak 8
- Lightfooted 6
- Nimble 5
- Strength 5
- Fitness 5
- Sprinting 4

Items:
- `Base.HuntingRifle` x1
- `Base.308Clip` x1
- `Base.308Bullets` x50
- `Base.x4Scope` x1
- `Base.HuntingKnife` x1
- `Base.Bandage` x2
- `Base.WaterBottleFull` x1
- `Base.Bag_NormalHikingBag` x1
- `Base.Jacket_ArmyCamoGreen` x1
- `Base.Trousers` x1
- `Base.Shoes_Black` x1
- `Base.Torch` x1
- `Base.Battery` x1

Dans le sac:
- `Base.Bandage` x2
- `Base.WaterBottleFull` x1

### Samourai - VALIDE
Skills:
- Fitness 8
- Strength 9
- Nimble 10
- Sneak 5
- Lightfooted 8
- Sprinting 4
- Long Blade 10
- Short Blade 10
- Spear 10
- First Aid 6

Items:
- `Base.Katana` x1
- `Base.KitchenKnife` x2
- `Base.Bandage` x3
- `Base.WaterBottleFull` x1
- `Base.Bag_NormalHikingBag` x1
- `Base.HoodieDOWN_WhiteTINT` x1
- `Base.Trousers` x1
- `Base.Shoes_Black` x1
- `Base.Torch` x1
- `Base.Battery` x1

Dans le sac:
- `Base.Bandage` x3
- `Base.WaterBottleFull` x1

### Geek - VALIDE
Skills:
- Electrical 8
- Mechanics 8
- Nimble 3
- Strength 2
- Fitness 3
- Aiming 3
- Reloading 3
- Sneaking 10
- Lightfooted 8

Items:
- `Base.Screwdriver` x1
- `Base.Wrench` x1
- `Base.ElectronicsScrap` x5
- `Base.ScrapMetal` x3
- `Base.Wire` x2
- `Base.LightBulb` x2
- `Base.DuctTape` x2
- `Base.ElectronicsMag1` x1
- `Base.ElectronicsMag2` x1
- `Base.BookMechanic1` x1
- `Base.Bandage` x2
- `Base.WaterBottleFull` x1
- `Base.Bag_Schoolbag` x1
- `Base.HoodieDOWN_WhiteTINT` x1
- `Base.Trousers` x1
- `Base.Shoes_Black` x1
- `Base.Torch` x1
- `Base.Battery` x3

Dans le sac:
- `Base.Bandage` x2
- `Base.WaterBottleFull` x1
- composants / magazines / livre

### Survivaliste - VALIDE
Skills:
- PlantScavenging 7
- Trapping 10
- Fishing 8
- Carpentry 8
- Cooking 7
- Fitness 7
- Strength 7
- Sneaking 7
- Lightfooted 5
- Aiming 6
- Reloading 6

Items:
- `Base.HuntingRifle` x1
- `Base.308Clip` x1
- `Base.308Bullets` x40
- `Base.x4Scope` x1
- `Base.HandAxe` x1
- `Base.HuntingKnife` x1
- `Base.Matches` x1
- `Base.Lighter` x1
- `camping.CampfireKit` x1
- `camping.SteelAndFlint` x1
- `camping.CampingTentKit` x1
- `Base.CannedCornedBeef` x2
- `Base.TinnedSoup` x2
- `Base.Crackers` x2
- `Base.GranolaBar` x2
- `Base.Peanuts` x2
- `Base.WaterBottleFull` x2
- `Base.TinOpener` x1
- `Base.Bandage` x3
- `Base.Splint` x1
- `Base.AlcoholWipes` x2
- `Base.Bag_ALICEpack` x1
- `Base.Jacket_CoatArmy` x1
- `Base.Trousers` x1
- `Base.Shoes_Strapped` x1
- `Base.Torch` x1
- `Base.Battery` x2
- `Base.BookTrapping1` x1
- `Base.BookFishing1` x1
- `Base.Rope` x1
- `Base.DuctTape` x1

Dans le sac:
- `Base.308Bullets` x40
- `Base.Matches` x1
- `Base.Lighter` x1
- `camping.CampfireKit` x1
- `camping.SteelAndFlint` x1
- `camping.CampingTentKit` x1
- `Base.CannedCornedBeef` x2
- `Base.TinnedSoup` x2
- `Base.Crackers` x2
- `Base.GranolaBar` x2
- `Base.Peanuts` x2
- `Base.WaterBottleFull` x2
- `Base.TinOpener` x1
- `Base.Bandage` x3
- `Base.Splint` x1
- `Base.AlcoholWipes` x2
- `Base.BookTrapping1` x1
- `Base.BookFishing1` x1
- `Base.Rope` x1
- `Base.DuctTape` x1

Equipe:
- primaire: `Base.HuntingRifle`
- secondaire: `Base.HandAxe`
- sac: `Base.Bag_ALICEpack`

### Pompier - VALIDE
Skills:
- Fitness 7
- Strength 7
- Axe 9
- Doctor 8
- Nimble 8
- Aiming 6
- Reloading 4
- Sneaking 2
- Lightfooted 3

Items:
- `Base.Axe` x1
- `Base.Extinguisher` x1
- `Base.Hat_Fireman` x1
- `Base.Jacket_Fireman` x1
- `Base.Trousers_Fireman` x1
- `Base.Shoes_ArmyBoots` x1
- `Base.Bandage` x4
- `Base.AlcoholWipes` x2
- `Base.Splint` x1
- `Base.Disinfectant` x1
- `Base.Pills` x1
- `Base.WaterBottleFull` x2
- `Base.Bag_ALICEpack` x1
- `Base.Torch` x1
- `Base.Battery` x2
- `Base.Hammer` x1
- `Base.Crowbar` x1

Dans le sac:
- `Base.Bandage` x4
- `Base.AlcoholWipes` x2
- `Base.Splint` x1
- `Base.Disinfectant` x1
- `Base.Pills` x1
- `Base.WaterBottleFull` x2

Equipe:
- primaire: `Base.Axe`
- secondaire: `Base.Extinguisher`
- sac: `Base.Bag_ALICEpack`

### Mecanicien - VALIDE
Skills:
- Mechanics 10
- Electrical 6
- Carpentry 4
- Fitness 5
- Strength 5
- Nimble 5
- Aiming 3
- Reloading 3
- Sneaking 2
- Lightfooted 2

Items:
- `Base.Wrench` x1
- `Base.Crowbar` x1
- `Base.LugWrench` x1
- `Base.TirePump` x1
- `Base.BlowTorch` x1
- `Base.PropaneTank` x1
- `Base.Screwdriver` x1
- `Base.Hammer` x1
- `Base.DuctTape` x2
- `Base.ScrapMetal` x3
- `Base.Wire` x2
- `Base.BookMechanic1` x1
- `Base.Bandage` x2
- `Base.WaterBottleFull` x1
- `Base.Bag_ALICEpack` x1
- `Base.Jacket_Black` x1
- `Base.Trousers` x1
- `Base.Shoes_ArmyBoots` x1
- `Base.Torch` x1
- `Base.Battery` x2

Dans le sac:
- `Base.LugWrench` x1
- `Base.TirePump` x1
- `Base.BlowTorch` x1
- `Base.PropaneTank` x1
- `Base.Screwdriver` x1
- `Base.Hammer` x1
- `Base.DuctTape` x2
- `Base.ScrapMetal` x3
- `Base.Wire` x2
- `Base.BookMechanic1` x1

Equipe:
- primaire: `Base.Crowbar`
- secondaire: `Base.Wrench`
- sac: `Base.Bag_ALICEpack`

### Athlete - VALIDE
Skills:
- Fitness 10
- Strength 5
- Nimble 8
- Lightfooted 8
- Sneaking 5
- Sprinting 10
- Aiming 3
- Reloading 2

Items:
- `Base.KitchenKnife` x1
- `Base.Bandage` x2
- `Base.WaterBottleFull` x2
- `Base.GranolaBar` x3
- `Base.PillsVitamins` x1
- `Base.Bag_Schoolbag` x1
- `Base.HoodieDOWN_WhiteTINT` x1
- `Base.Trousers` x1
- `Base.Shoes_BlueTrainers` x1
- `Base.Torch` x1
- `Base.Battery` x1

Dans le sac:
- `Base.WaterBottleFull` x2
- `Base.GranolaBar` x3
- `Base.PillsVitamins` x1

Equipe:
- primaire: `Base.KitchenKnife`
- sac: `Base.Bag_Schoolbag`

### Eclaireur - VALIDE
Skills:
- Sneaking 10
- Lightfooted 10
- Nimble 8
- PlantScavenging 7
- Fitness 6
- Strength 7
- Sprinting 9
- Aiming 4
- Reloading 3
- Carpentry 2

Items:
- `Base.Machete` x1
- `Base.Map` x1
- `Base.x4Scope` x1
- `Base.Torch` x1
- `Base.Battery` x2
- `Base.Bandage` x2
- `Base.WaterBottleFull` x1
- `Base.GranolaBar` x2
- `Base.Bag_NormalHikingBag` x1
- `Base.Jacket_ArmyCamoDesert` x1
- `Base.Trousers` x1
- `Base.Shoes_Strapped` x1
- `Base.Lighter` x1
- `Base.Rope` x1

Dans le sac:
- `Base.Map` x1
- `Base.x4Scope` x1
- `Base.WaterBottleFull` x1
- `Base.GranolaBar` x2
- `Base.Bandage` x2
- `Base.Lighter` x1
- `Base.Rope` x1

Equipe:
- primaire: `Base.Machete`
- sac: `Base.Bag_NormalHikingBag`

Notes:
- En vanilla, il n'y a pas de vraies jumelles utilisables pour le repérage longue distance.
- `Base.x4Scope` est retenu comme proxy utilitaire léger, sans donner de fusil à l'Éclaireur.

### Demolisseur - VALIDE
Skills:
- Strength 10
- Fitness 6
- Sprinting 6
- Electrical 8
- Mechanics 7
- Aiming 5
- Reloading 4
- Nimble 4
- Sneaking 1
- Lightfooted 1

Items:
- `Base.PipeBomb` x10
- `Base.PipeBombTriggered` x6
- `Base.Aerosolbomb` x10
- `Base.AerosolbombTriggered` x6
- `Base.Molotov` x8
- `Base.SmokeBomb` x3
- `Base.Sledgehammer` x1
- `Base.DuctTape` x2
- `Base.ScrapMetal` x3
- `Base.Wire` x2
- `Base.ElectronicsScrap` x3
- `Base.PropaneTank` x1
- `Base.Bandage` x3
- `Base.WaterBottleFull` x1
- `Base.Bag_ALICEpack` x1
- `Base.Jacket_Black` x1
- `Base.Trousers` x1
- `Base.Shoes_ArmyBoots` x1
- `Base.Torch` x1
- `Base.Battery` x2
- `Base.Lighter` x1

Dans le sac:
- `Base.PipeBomb` x10
- `Base.PipeBombTriggered` x6
- `Base.Aerosolbomb` x10
- `Base.AerosolbombTriggered` x6
- `Base.Molotov` x8
- `Base.SmokeBomb` x3

Equipe:
- primaire: `Base.Sledgehammer`
- sac: `Base.Bag_ALICEpack`

### Invincible - VALIDE
Skills:
- Aiming 10
- Reloading 10
- Strength 10
- Fitness 10
- Sneaking 10
- Lightfooted 10
- Nimble 10
- Sprinting 10
- Axe 10
- LongBlade 10
- SmallBlade 10
- LongBlunt 10
- SmallBlunt 10
- Doctor 10
- Carpentry 10
- Mechanics 10
- Electrical 10
- Cooking 10
- PlantScavenging 10

Items:
- `Base.AssaultRifle` x1
- `Base.556Clip` x3
- `Base.556Bullets` x60
- `Base.Revolver_Long` x1
- `Base.Bullets44` x24
- `Base.44Clip` x2
- `Base.Katana` x1
- `Base.Sledgehammer` x1
- `Base.Hat_RiotHelmet` x1
- `Base.Jacket_CoatArmy` x1
- `Base.Trousers` x1
- `Base.Shoes_ArmyBoots` x1
- `Base.Bandage` x5
- `Base.AlcoholWipes` x3
- `Base.Splint` x2
- `Base.Pills` x2
- `Base.PillsBeta` x1
- `Base.PillsVitamins` x1
- `Base.Antibiotics` x1
- `Base.WaterBottleFull` x2
- `Base.Map` x1
- `Base.Bag_ALICEpack_Army` x1
- `Base.Torch` x1
- `Base.Battery` x3
- `Base.DuctTape` x2
- `Base.Rope` x1

Dans le sac:
- `Base.556Clip` x3
- `Base.556Bullets` x60
- `Base.Bullets44` x24
- `Base.44Clip` x2
- `Base.Bandage` x5
- `Base.AlcoholWipes` x3
- `Base.Splint` x2
- `Base.Pills` x2
- `Base.PillsBeta` x1
- `Base.PillsVitamins` x1
- `Base.Antibiotics` x1
- `Base.WaterBottleFull` x2

Equipe:
- primaire: `Base.AssaultRifle`
- secondaire: `Base.Katana`
- sac: `Base.Bag_ALICEpack_Army`

### Mule - VALIDE
Skills:
- Strength 10
- Fitness 7
- Sprinting 10
- Carpentry 4
- Nimble 4
- Sneaking 2
- Lightfooted 2
- Aiming 1
- Reloading 1

Items:
- `Base.Bag_ALICEpack_Army` x1
- `Base.Bag_DuffelBag` x1
- `Base.Crowbar` x1
- `Base.Bandage` x3
- `Base.WaterBottleFull` x2
- `Base.TinnedBeans` x3
- `Base.TinnedSoup` x3
- `Base.TinOpener` x1
- `Base.PetrolCan` x1
- `Base.Hat_Army` x1
- `Base.Jacket_CoatArmy` x1
- `Base.Trousers` x1
- `Base.Shoes_ArmyBoots` x1
- `Base.Torch` x1
- `Base.Battery` x2
- `Base.DuctTape` x2
- `Base.Rope` x1

Dans le sac:
- `Base.Bandage` x3
- `Base.WaterBottleFull` x2
- `Base.TinnedBeans` x3
- `Base.TinnedSoup` x3
- `Base.TinOpener` x1
- `Base.PetrolCan` x1
- `Base.DuctTape` x2
- `Base.Rope` x1

Equipe:
- primaire: `Base.Crowbar`
- sac: `Base.Bag_ALICEpack_Army`

### Civil - VALIDE
Skills:
- Fitness 1
- Strength 1
- Sneaking 1
- Lightfooted 1
- Nimble 1
- Aiming 0
- Reloading 0

Items:
- `Base.KitchenKnife` x1
- `Base.Bandage` x1
- `Base.WaterBottleFull` x1
- `Base.GranolaBar` x1
- `Base.Bag_Schoolbag` x1
- `Base.HoodieDOWN_WhiteTINT` x1
- `Base.Trousers` x1
- `Base.Shoes_Black` x1
- `Base.Torch` x1
- `Base.Battery` x1

Dans le sac:
- rien

Equipe:
- primaire: `Base.KitchenKnife`
- sac: `Base.Bag_Schoolbag`

### Roles encore a valider plus tard
- aucun

## Reste a faire pour reprendre facilement

### 1. Etat de l'implementation apres cette passe
Les roles valides ci-dessus sont maintenant **portes dans le code** pour:
- Soldat
- Voleur
- Local
- Medic
- Rambo
- Sniper
- Samourai
- Geek
- Survivaliste

Fichiers alignes:
- `EscapadeExpress/media/lua/server/EscapadeExpressServer.lua`
- `EscapadeExpress/media/lua/client/LastStand/EscapadeExpress.lua`
- `EscapadeExpress/media/lua/client/EscapadeExpressRolePicker.lua`
- `README.md`

Points faits dans le code:
1. `ROLE_DEFS` mis a jour cote serveur
2. Miroir exact cote client (fallback solo)
3. Sacs / armes / vetements `equipped` ajustes pour les loadouts valides
4. Verification syntaxe `luac -p` OK sur les fichiers Lua modifies

### 2. Rangement direct dans le sac
La demande utilisateur est maintenant **implementee** via un champ optionnel
`bagContents` dans les `ROLE_DEFS`.

Comportement actuel:
- si le role a un sac (`equipped.bag`), le sac est cree puis equipe
- les items listes dans `bagContents` sont ajoutes directement au conteneur du sac
- le reste du loadout reste dans l'inventaire principal
- la meme logique est appliquee cote serveur et dans le fallback client local

### 3. Points techniques confirmes
- **Rambo**: l'`itemId` Build 41 retenu pour la **lance avec machette** est `Base.SpearMachete`
- Mapper les noms exprimes par l'utilisateur vers les perks Lua B41:
  - Running -> `Perks.Sprinting`
  - Sneaking -> `Perks.Sneak`
  - Lightfooted -> `Perks.Lightfoot`
  - First Aid / Doctor -> `Perks.Doctor`
  - Mechanic -> `Perks.Mechanics`
- **Tracking** ne doit pas etre utilise en Build 41; pour Rambo il a ete remplace par
  `Perks.PlantScavenging`

### 4. Reprendre la validation des roles restants plus tard
Ordre de reprise conseille:
1. Pompier
2. Mecanicien
3. Athlete
4. Eclaireur
5. Demolisseur
6. Invincible
7. Mule
8. Civil

### 5. Fichiers secondaires ajustes
- `EscapadeExpress/media/lua/client/EscapadeExpressRolePicker.lua`
  - `ROLE_INFO` / `strengths` mis a jour pour les roles modifies
- `README.md`
  - documentation publique des 4 roles historiques mise a jour

### 6. Verification minimale apres patch code
- [x] verifier que serveur et client ont exactement les memes `ROLE_DEFS` pour les roles modifies
- [ ] verifier que le spawn solo applique les memes skills/items que le multijoueur
- [ ] verifier qu'un role avec sac spawn bien avec eau / bandages / soins dans le sac
- [x] verifier qu'aucune erreur Lua n'apparait au chargement du mod (`luac -p` OK)

## Portee

Inclus dans EE-11:

- mise a jour des `ROLE_DEFS` serveur
- miroir des `ROLE_DEFS` client (fallback solo)
- ajustement du texte du role picker pour refleter les nouveaux points forts
- mise a jour du README racine sur les 4 roles historiques

Non inclus dans cette passe:

- rebalance complet des 16+ roles EE-12
- refonte des skills
- ajout de sacs a dos a tous les roles
- tuning fin de la difficulte LAN

## Fichiers a modifier

- `EscapadeExpress/media/lua/server/EscapadeExpressServer.lua`
- `EscapadeExpress/media/lua/client/LastStand/EscapadeExpress.lua`
- `EscapadeExpress/media/lua/client/EscapadeExpressRolePicker.lua`
- `README.md`

## Critere d'acceptation

1. Soldat, Voleur, Local et Medic respectent tous la baseline:
   - 1 arme minimum
   - 1 bandage minimum
   - 1 torche minimum
   - 1 source d'eau minimum
2. Les definitions client et serveur restent synchronisees
3. Le fallback solo conserve les memes loadouts que le multijoueur
4. Le role picker ne ment pas sur les forces majeures des 4 roles de base

## Notes

- Aucun appel Context7 supplementaire n'est requis pour cette passe:
  la spec etait surtout obsolete par rapport au code deja present.
- Un futur ticket pourra faire une vraie validation utilisateur role par role
  si vous voulez pousser le balancing LAN plus loin.
