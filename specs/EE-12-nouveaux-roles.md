# EE-12 (L) - Ajouter de nouveaux roles: Rambo, Sniper, Samourai, Geek, Survivaliste, Pompier, Mecanicien, Athlete, Eclaireur, Demolisseur, Invincible, Mule, Civil

## Contexte

Le scenario a actuellement 4 roles (Soldat, Voleur, Local, Medic) choisis via
le role picker UI (EE-13). L'utilisateur veut ajouter 12 nouveaux roles.

Avec 16 roles au total, le scenario supporte jusqu'a 16 joueurs en LAN. Au-dela de
16 joueurs, les joueurs supplementaires recoivent le role **Civil** -- un citoyen
lambda qui faisait ses courses dans le centre commercial quand l'apocalypse a commence.

## Item IDs verifies

Source: pz-item-browser (https://github.com/KevinLinTW1021/pz-item-browser)
Base de donnees: 2283 items vanilla B41, verifies le 2026-07-16.

### Corrections d'items vs l'ancienne spec

| Ancien ID | Nouveau ID | Raison |
|-----------|-----------|--------|
| `Base.Bullets308` | `Base.308Bullets` | ID correct en B41 |
| `Base.Binoculars` | `Base.x4Scope` | Binoculars n'existe pas en B41 vanilla; scope x4 disponible |
| `Base.HoodieDOWNBlackTINT` | `Base.Jacket_Black` | Hoodie n'a qu'une variante (WhiteTINT) en B41; Leather Jacket noir |
| `Base.HoodieDOWNGreenTINT` | `Base.Jacket_ArmyCamoGreen` | Hoodie n'a pas de variante verte; Military Green Camo Jacket |

### Items confirmes pour les nouveaux roles (tous verifies OK)

- `Base.Aerosolbomb` (Aerosol Bomb, Explosives) -- bombe aerosol
- `Base.AerosolbombTriggered` (Aerosol Bomb with Timer, Explosives) -- bombe aerosol avec minuteur
- `Base.PipeBomb` (Pipe Bomb, Explosives) -- bombe tuyau
- `Base.PipeBombTriggered` (Pipe Bomb with Timer, Explosives) -- bombe tuyau avec minuteur
- `Base.Molotov` (Molotov Cocktail, Explosives) -- cocktail molotov
- `Base.SmokeBomb` (Smoke Bomb, Explosives) -- bombe fumigene
- `Base.Extinguisher` (Extinguisher, Drainable) -- extincteur
- `Base.Hat_Fireman` (Firefighter Helmet, Clothing) -- casque de pompier
- `Base.Jacket_Fireman` (Firefighter Jacket, Clothing) -- veste de pompier
- `Base.Trousers_Fireman` (Firefighter Pants, Clothing) -- pantalon de pompier
- `Base.Sledgehammer` (Sledgehammer, ToolWeapon) -- masse
- `Base.AssaultRifle` (M16 Assault Rifle, Weapon) -- fusil d'assaut M16
- `Base.556Bullets` (.556 Ammo, Normal) -- munitions 5.56mm
- `Base.556Clip` (.556 Magazine, Normal) -- chargeur 5.56mm
- `Base.Revolver_Long` (Magnum, Weapon) -- magnum .44
- `Base.Bullets44` (.44 Magnum Bullets, Normal) -- munitions .44
- `Base.44Clip` (.44 Magazine, Normal) -- chargeur .44
- `Base.Pistol2` (M1911 Pistol, Weapon) -- pistolet .45
- `Base.Bullets45` (.45 Auto, Normal) -- munitions .45
- `Base.45Clip` (.45 Auto Magazine, Normal) -- chargeur .45
- `Base.Hat_RiotHelmet` (Riot Helmet, Clothing) -- casque anti-emeute
- `Base.Jacket_CoatArmy` (Army Coat, Clothing) -- manteau militaire
- `Base.Hat_Army` (Military Helmet, Clothing) -- casque militaire
- `Base.Bag_ALICEpack_Army` (Military Backpack, Container) -- sac militaire (plus grand)
- `Base.Bag_ALICEpack` (Large Backpack, Container) -- grand sac
- `Base.Bag_SurvivorBag` (Backpack, Container) -- sac de survivant
- `Base.Bag_BigHikingBag` (Big Hiking Bag, Container) -- grand sac de rando
- `Base.Shoes_ArmyBoots` (Military Boots, Clothing) -- bottes militaires
- `Base.Shoes_BlueTrainers` (Sneakers, Clothing) -- baskets
- `Base.Shoes_RedTrainers` (Sneakers, Clothing) -- baskets rouges
- `Base.BlowTorch` (Propane Torch, Drainable) -- chalumeau
- `Base.PropaneTank` (Propane Tank, Drainable) -- bouteille de gaz
- `Base.LugWrench` (Lug Wrench, Normal) -- croix de demontage pneus
- `Base.TirePump` (Tire Pump, Normal) -- pompe a pneus
- `Base.Jacket_ArmyCamoGreen` (Military Green Camo Jacket, Clothing) -- veste camo verte
- `Base.Jacket_ArmyCamoDesert` (Military Desert Camo Jacket, Clothing) -- veste camo desert
- `Base.Chainsaw` (Chainsaw, Weapon) -- tronconneuse
- `Base.Machete` (Machete, Weapon) -- machette
- `Base.Sledgehammer` (Sledgehammer, ToolWeapon) -- masse
- `Base.Bandage` (Bandage, Normal) -- bandage
- `Base.Torch` (Flashlight, Drainable) -- lampe torche
- `Base.Battery` (Battery, Drainable) -- batterie
- `Base.WaterBottleFull` (Water Bottle, Drainable) -- bouteille d'eau
- `Base.Pills` (Painkillers, Drainable) -- antidouleurs
- `Base.PillsBeta` (Beta Blockers, Drainable) -- beta-bloquants
- `Base.PillsVitamins` (Vitamins, Drainable) -- vitamines
- `Base.Bandage` (Bandage, Normal) -- bandage
- `Base.AlcoholWipes` (Alcohol Wipes, Drainable) -- lingettes alcoolisees
- `Base.Splint` (Splint, Normal) -- attelle
- `Base.DuctTape` (Duct Tape, Drainable) -- ruban adhesif
- `Base.Rope` (Rope, Normal) -- corde
- `Base.ScrapMetal` (Scrap Metal, Normal) -- ferraille
- `Base.Wire` (Wire, Drainable) -- fil de fer
- `Base.ElectronicsScrap` (Electronics Scrap, Normal) -- composants electroniques
- `Base.Lighter` (Lighter, Drainable) -- briquet
- `Base.Matches` (Matches, Drainable) -- allumettes
- `Base.Map` (Map, Map) -- carte
- `Base.Trousers` (Pants, Clothing) -- pantalon
- `Base.HoodieDOWN_WhiteTINT` (Hoodie, Clothing) -- hoodie
- `Base.Shoes_Black` (Shoes, Clothing) -- chaussures
- `Base.Shoes_Strapped` (Strapped Shoes, Clothing) -- chaussures a scratch
- `Base.Wrench` (Wrench, ToolWeapon) -- cle a molette
- `Base.Screwdriver` (Screwdriver, Weapon) -- tournevis
- `Base.Hammer` (Hammer, Weapon) -- marteau
- `Base.Nails` (Nails, Normal) -- clous
- `Base.Saw` (Saw, Normal) -- scie
- `Base.Crowbar` (Crowbar, Weapon) -- pied-de-biche
- `Base.Katana` (Katana, Weapon) -- katana
- `Base.Axe` (Axe, Weapon) -- hache
- `Base.HandAxe` (Hand Axe, ToolWeapon) -- petite hache
- `Base.HuntingKnife` (Hunting Knife, Weapon) -- couteau de chasse
- `Base.KitchenKnife` (Kitchen Knife, Weapon) -- couteau de cuisine
- `Base.Pistol` (M9 Pistol, Weapon) -- pistolet 9mm
- `Base.9mmClip` (9mm Magazine, Normal) -- chargeur 9mm
- `Base.Bullets9mm` (9mm Rounds, Normal) -- munitions 9mm
- `Base.HuntingRifle` (MSR788 Rifle, Weapon) -- fusil de chasse
- `Base.308Bullets` (.308 Ammo, Normal) -- munitions .308
- `Base.308Clip` (.308 Magazine, Normal) -- chargeur .308
- `Base.x4Scope` (x4 Scope, WeaponPart) -- lunette x4
- `Base.Shotgun` (JS-2000 Shotgun, Weapon) -- fusil a pompe
- `Base.ShotgunShells` (Shotgun Shells, Normal) -- cartouches
- `Base.GranolaBar` (Granola Bar, Food) -- barre granola
- `Base.Crackers` (Crackers, Food) -- crackers
- `Base.Peanuts` (Peanuts, Food) -- cacahuetes
- `Base.TinnedBeans` (Canned Beans, Food) -- haricots en conserve
- `Base.TinnedSoup` (Canned Vegetable Soup, Food) -- soupe en conserve
- `Base.CannedChili` (Canned Chili, Food) -- chili en conserve
- `Base.CannedCornedBeef` (Canned Corned Beef, Food) -- corned beef
- `Base.TinOpener` (Can Opener, Normal) -- ouvre-boite
- `Base.Bag_NormalHikingBag` (Hiking Bag, Container) -- sac de randonnee
- `Base.Bag_Schoolbag` (School Bag, Container) -- sac d'ecole
- `Base.Bag_DuffelBag` (Duffel Bag, Container) -- sac de sport
- `Base.Antibiotics` (Antibiotics, Food) -- antibiotiques
- `Base.Disinfectant` (Bottle of Disinfectant, Drainable) -- desinfectant
- `Base.Jacket_Black` (Leather Jacket, Clothing) -- veste en cuir noir
- `Base.ElectronicsMag1` (Electronics Magazine Vol. 1, Literature)
- `Base.ElectronicsMag2` (Electronics Magazine Vol. 2, Literature)
- `Base.BookMechanic1` (Mechanics Vol. 1, Literature)
- `Base.BookCarpentry1` (Carpentry Vol. 1, Literature)
- `Base.BookTrapping1` (Trapping Vol. 1, Literature)
- `Base.BookFishing1` (Fishing Vol. 1, Literature)
- `Base.BlowTorch` (Propane Torch, Drainable) -- chalumeau
- `camping.CampfireKit` (Campfire Materials, Normal) -- kit feu de camp
- `camping.SteelAndFlint` (Flint and Steel, Normal) -- silex et acier
- `camping.CampingTentKit` (Tent Kit, Normal) -- kit tente
- `farming.CarrotSeed` (Carrot Seeds, Normal) -- graines de carotte
- `Base.Fertilizer` (NPK Fertilizer, Drainable) -- engrais
- `Base.Needle` (Needle, Normal) -- a coudre
- `Base.Thread` (Thread, Drainable) -- fil
- `Base.Twine` (Twine, Material) -- ficelle

## Concept des 12 nouveaux roles

### Rambo
- Profil: combattant rapproche agressif, gros degats, peu de discretion
- Style: charge dans le tas, multi-zombies, tanky
- Skills:
  - Strength 6, Fitness 5, Axe 5
  - Sneak 0, Lightfoot 0 (bruyant)
  - Reloading 1, Aiming 1 (mauvais au tir)
- Items:
  - `Base.Axe` x1 (arme principale)
  - `Base.KitchenKnife` x2 (armes secondaires)
  - `Base.Bandage` x4 (se soigne en plein combat)
  - `Base.WaterBottleFull` x1
  - `Base.Bag_NormalHikingBag` x1
  - `Base.Jacket_Black` x1 (Leather Jacket)
  - `Base.Trousers` x1
  - `Base.Shoes_Black` x1
  - `Base.Torch` x1
  - `Base.Battery` x1
- Mecanique specifique:
  - Endurance plus haute au spawn (setEndurance(0.7))
  - Panic plus basse (setPanic(10)) -- Rambo a pas peur

### Sniper
- Profil: tireur d'elite a longue distance, faible au melee
- Style: couvre les autres de loin, one-shot les zombies isoles
- Skills:
  - Aiming 7, Reloading 5
  - Sneak 4, Lightfoot 4 (discret pour positionner)
  - Strength 2, Fitness 2 (peu de stamina)
- Items:
  - `Base.HuntingRifle` x1 (MSR788 Rifle)
  - `Base.308Clip` x1 (chargeur)
  - `Base.308Bullets` x20 (munitions)
  - `Base.x4Scope` x1 (lunette x4)
  - `Base.HuntingKnife` x1 (backup melee)
  - `Base.Bandage` x2
  - `Base.WaterBottleFull` x1
  - `Base.Bag_NormalHikingBag` x1
  - `Base.Jacket_ArmyCamoGreen` x1 (camouflage)
  - `Base.Trousers` x1
  - `Base.Shoes_Black` x1
  - `Base.Torch` x1
  - `Base.Battery` x1
- Mecanique specifique:
  - Panic modere (setPanic(20)) -- sang-froid
  - Pas de mouvement rapide (Fitness 2)

### Samourai
- Profil: maitre du katana, discipline, equilibre entre offense et defense
- Style: combat melee elegant, contre-attaques, mobility
- Skills:
  - Fitness 5, Strength 4, Nimble 5
  - Sneak 3, Lightfoot 3
  - Aiming 0, Reloading 0 (pas d'armes a feu)
- Items:
  - `Base.Katana` x1 (arme principale)
  - `Base.KitchenKnife` x2 (armes secondaires)
  - `Base.Bandage` x3
  - `Base.WaterBottleFull` x1
  - `Base.Bag_NormalHikingBag` x1
  - `Base.HoodieDOWN_WhiteTINT` x1
  - `Base.Trousers` x1
  - `Base.Shoes_Black` x1
  - `Base.Torch` x1
  - `Base.Battery` x1
- Mecanique specifique:
  - Mouvement plus rapide (setEndurance(0.5))
  - Panic modere (setPanic(15)) -- discipline

### Geek
- Profil: tres intelligent, expert en electronique et mecanique, faible au combat
- Style: bidouilleur, repare/bricole, fabrique des gadgets, support technique
- Skills:
  - Electrical 6, Mechanics 5
  - Nimble 3 (agilite pour fuir)
  - Strength 2, Fitness 2 (peu sportif)
  - Aiming 1, Reloading 1 (mauvais au tir)
  - Sneak 3 (sait se faire discret)
- Items:
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
- Mecanique specifique:
  - Panic plus haute (setPanic(40)) -- moins habitue au danger
  - Fatigue plus haute (setFatigue(0.1)) -- reste tard devant son ordi
- Roleplay: "Le cerveau de l'equipe. Repare le vehicule, fabrique des gadgets,
  pirater des systemes electroniques."

### Survivaliste
- Profil: expert en survie, sait crafter, nourriture, feu, pieges
- Style: autonome, prefere la nature, robuste, pragmatique
- Skills:
  - PlantScavenging 5, Trapping 4, Fishing 3
  - Carpentry 4, Cooking 3
  - Fitness 4, Strength 4
  - Sneak 2, Lightfoot 2
  - Aiming 2, Reloading 2
- Items:
  - `Base.HandAxe` x1 (arme + outil)
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
  - `Base.Bag_SurvivorBag` x1
  - `Base.Jacket_CoatArmy` x1
  - `Base.Trousers` x1
  - `Base.Shoes_Strapped` x1
  - `Base.Torch` x1
  - `Base.Battery` x2
  - `Base.BookTrapping1` x1
  - `Base.BookFishing1` x1
  - `Base.Rope` x1
  - `Base.DuctTape` x1
- Mecanique specifique:
  - Panic basse (setPanic(15)) -- habitue aux situations extremes
  - Endurance moderee (setEndurance(0.4))
- Roleplay: "Peut survivre seul en pleine nature. Connaît les plantes
  comestibles, pose des pieges, peche, fait du feu."

### Pompier (NOUVEAU)
- Profil: sauveur, resistant au feu, expert en intervention d'urgence
- Style: directement lie a l'evenement incendie (~2h), protege l'equipe du feu
- Skills:
  - Fitness 5, Strength 5
  - Axe 4 (hache de pompier)
  - Doctor 2 (premiers secours)
  - Nimble 3 (mobilite en zone dangereuse)
  - Aiming 2, Reloading 2
  - Sneak 1, Lightfoot 1 (bruyant mais peu importe)
- Items:
  - `Base.Axe` x1 (hache de pompier -- arme principale + demolition)
  - `Base.Extinguisher` x1 (eteint le feu -- cle pour l'evenement incendie)
  - `Base.Hat_Fireman` x1 (casque de pompier -- protection)
  - `Base.Jacket_Fireman` x1 (veste de pompier -- protection feu)
  - `Base.Trousers_Fireman` x1 (pantalon de pompier)
  - `Base.Shoes_ArmyBoots` x1 (bottes robustes)
  - `Base.Bandage` x4 (premiers secours)
  - `Base.AlcoholWipes` x2
  - `Base.Splint` x1
  - `Base.WaterBottleFull` x2
  - `Base.Bag_NormalHikingBag` x1
  - `Base.Torch` x1
  - `Base.Battery` x2
  - `Base.Hammer` x1 (demolition de portes/murs)
  - `Base.Crowbar` x1 (forcement d'entrees)
- Mecanique specifique:
  - Panic basse (setPanic(15)) -- habitue au danger
  - Endurance haute (setEndurance(0.6)) -- tres bonne condition physique
- Roleplay: "Le hero. Peut eteindre l'incendie avec son extincteur, franchir
  les obstacles a la hache, et soigner les blessures legeres."

### Mecanicien (NOUVEAU)
- Profil: expert en mecanique vehicule, repare et prepare le vehicule d'evasion
- Style: directement lie a l'objectif du scenario (vehicule sans essence)
- Skills:
  - Mechanics 7, Electrical 3
  - Carpentry 2 (bricolage general)
  - Fitness 3, Strength 4
  - Aiming 2, Reloading 2
  - Sneak 2, Lightfoot 2
- Items:
  - `Base.Wrench` x1 (outil principal)
  - `Base.LugWrench` x1 (demontage pneus)
  - `Base.TirePump` x1 (gonflage pneus)
  - `Base.BlowTorch` x1 (soudures)
  - `Base.PropaneTank` x1 (carburant chalumeau)
  - `Base.Screwdriver` x1
  - `Base.Hammer` x1
  - `Base.DuctTape` x2 (reparations rapides)
  - `Base.ScrapMetal` x3 (materiaux)
  - `Base.Wire` x2
  - `Base.BookMechanic1` x1 (livre mecanique)
  - `Base.Bandage` x2
  - `Base.WaterBottleFull` x1
  - `Base.Bag_NormalHikingBag` x1
  - `Base.Jacket_Black` x1 (veste de mecano)
  - `Base.Trousers` x1
  - `Base.Shoes_ArmyBoots` x1 (bottes de chantier)
  - `Base.Torch` x1
  - `Base.Battery` x2
- Mecanique specifique:
  - Panic modere (setPanic(25))
  - Fatigue moderee (setFatigue(0.05)) -- habitue au travail physique
- Roleplay: "L'expert du vehicule. Repare le van, change les pneus, soude les
  pieces. Indispensable pour l'evasion finale."

### Athlete (NOUVEAU)
- Profil: mobilite pure, court vite, esquive, traverse le mall rapidement
- Style: eclaireur rapide, va chercher les items a l'autre bout du mall
- Skills:
  - Fitness 7, Strength 3
  - Nimble 5, Lightfoot 4
  - Sneak 3, Aiming 2, Reloading 2
- Items:
  - `Base.KitchenKnife` x1 (arme legerement)
  - `Base.Bandage` x2
  - `Base.WaterBottleFull` x2 (plus d'eau -- transpire beaucoup)
  - `Base.GranolaBar` x3 (barres energetiques)
  - `Base.PillsVitamins` x1 (vitamines -- endurance)
  - `Base.Bag_NormalHikingBag` x1
  - `Base.HoodieDOWN_WhiteTINT` x1
  - `Base.Trousers` x1
  - `Base.Shoes_BlueTrainers` x1 (baskets de course)
  - `Base.Torch` x1
  - `Base.Battery` x1
- Mecanique specifique:
  - Endurance tres haute (setEndurance(0.85)) -- peut courir longtemps
  - Panic modere (setPanic(20))
  - Fatigue basse (setFatigue(0)) -- en pleine forme
- Roleplay: "Le plus rapide. Traverse le mall en un eclair, va chercher les
  items eloignes, esquive les zombies. Mais faible au combat."

### Eclaireur (NOUVEAU)
- Profil: exploration, cartographie, reperage des menaces et ressources
- Style: discret, repere les zombies et guide l'equipe vers les objectifs
- Skills:
  - Sneak 5, Lightfoot 5, Nimble 4
  - PlantScavenging 4 (trouve des ressources)
  - Fitness 4, Strength 3
  - Aiming 3, Reloading 3
  - Carpentry 2 (petits abris)
- Items:
  - `Base.Machete` x1 (arme principale -- leger et silencieux)
  - `Base.Map` x1 (carte du mall)
  - `Base.x4Scope` x1 (lunette pour observer a distance)
  - `Base.Torch` x1
  - `Base.Battery` x2
  - `Base.Bandage` x2
  - `Base.WaterBottleFull` x1
  - `Base.GranolaBar` x2
  - `Base.Bag_NormalHikingBag` x1
  - `Base.Jacket_ArmyCamoDesert` x1 (camo discret)
  - `Base.Trousers` x1
  - `Base.Shoes_Strapped` x1 (chaussures silencieuses)
  - `Base.Lighter` x1
  - `Base.Rope` x1 (acces zones elevees)
- Mecanique specifique:
  - Endurance moderee (setEndurance(0.5))
  - Panic basse (setPanic(15)) -- habitue a l'inconnu
- Roleplay: "Les yeux de l'equipe. Repere les zombies, trouve les ressources,
  guide l'equipe vers le vehicule et le bidon. Discret et autonome."

### Demolisseur (NOUVEAU)
- Profil: explosions, degagement de passages, chaos controle
- Style: fait sauter les obstacles, attire les zombies avec le bruit puis les
  detruit, cree des raccourcis en explosant les murs
- Skills:
  - Electrical 4 (circuits de detonation)
  - Mechanics 4 (fabrication d'engins)
  - Strength 4, Fitness 3
  - Aiming 3, Reloading 3 (pour les grenades)
  - Sneak 1, Lightfoot 1 (bruyant par nature)
- Items:
  - `Base.PipeBomb` x5 (bombes tuyau -- beaucoup de grenades)
  - `Base.PipeBombTriggered` x3 (bombes avec minuteur)
  - `Base.Aerosolbomb` x5 (bombes aerosol -- beaucoup)
  - `Base.AerosolbombTriggered` x3 (aerosol avec minuteur)
  - `Base.Molotov` x4 (cocktails molotov)
  - `Base.SmokeBomb` x3 (fumigenes pour couverture)
  - `Base.Sledgehammer` x1 (demolition manuelle)
  - `Base.DuctTape` x2
  - `Base.ScrapMetal` x3
  - `Base.Wire` x2
  - `Base.ElectronicsScrap` x3
  - `Base.PropaneTank` x1 (matiere explosive)
  - `Base.Bandage` x3
  - `Base.WaterBottleFull` x1
  - `Base.Bag_BigHikingBag` x1 (gros sac pour stocker les explosifs)
  - `Base.Jacket_Black` x1
  - `Base.Trousers` x1
  - `Base.Shoes_ArmyBoots` x1 (protection)
  - `Base.Torch` x1
  - `Base.Battery` x2
  - `Base.Lighter` x1 (indispensable pour les molotovs)
- Mecanique specifique:
  - Panic basse (setPanic(10)) -- adore les explosions
  - Endurance moderee (setEndurance(0.4))
- Roleplay: "Le chaos controle. Fait sauter les murs pour creer des raccourcis,
  detruit les groupes de zombies aux grenades, attire les zombis avec le bruit
  puis les fait exploser. Attention aux degats collateraux!"

### Invincible (NOUVEAU)
- Profil: tout au max, les meilleures armes, les meilleures protections, mobile
- Style: surpuissant, un vrai one-man army, equilibre total
- Skills:
  - Aiming 7, Reloading 6
  - Strength 7, Fitness 7
  - Sneak 5, Lightfoot 5, Nimble 5
  - Melee 6, Axe 6
  - Doctor 4, Carpentry 4, Mechanics 4, Electrical 4
  - Cooking 3, PlantScavenging 3
- Items:
  - `Base.AssaultRifle` x1 (M16 -- meilleure arme a feu)
  - `Base.556Clip` x3 (3 chargeurs)
  - `Base.556Bullets` x60 (60 munitions)
  - `Base.Revolver_Long` x1 (Magnum -- backup puissant)
  - `Base.Bullets44` x24 (munitions .44)
  - `Base.44Clip` x2 (chargeurs .44)
  - `Base.Katana` x1 (katana -- meilleur melee)
  - `Base.Sledgehammer` x1 (masse -- demolition)
  - `Base.Hat_RiotHelmet` x1 (casque anti-emeute -- meilleure protection tete)
  - `Base.Jacket_CoatArmy` x1 (manteau militaire -- meilleure protection corps)
  - `Base.Trousers` x1
  - `Base.Shoes_ArmyBoots` x1 (bottes militaires)
  - `Base.Bandage` x5
  - `Base.AlcoholWipes` x3
  - `Base.Splint` x2
  - `Base.Pills` x2
  - `Base.PillsBeta` x1 (beta-bloquants -- anti-panic)
  - `Base.PillsVitamins` x1
  - `Base.Antibiotics` x1
  - `Base.WaterBottleFull` x2
  - `Base.Bag_ALICEpack_Army` x1 (sac militaire -- plus grand)
  - `Base.Torch` x1
  - `Base.Battery` x3
  - `Base.DuctTape` x2
  - `Base.Rope` x1
- Mecanique specifique:
  - Endurance tres haute (setEndurance(0.8))
  - Panic tres basse (setPanic(5)) -- quasi rien ne l'effraie
  - Fatigue nulle (setFatigue(0)) -- pleine forme
- Roleplay: "L'ultimate. Tout au max, les meilleures armes, les meilleures
  protections. Un one-man army. A reserver pour celui qui veut etre
  intouchable, ou pour equilibrer si un joueur est beaucoup moins experimente
  que les autres."

### Mule (NOUVEAU)
- Profil: porteur, grosse capacite de transport, robuste, peu de combat
- Style: le dos de l'equipe, transporte le bidon, les ressources, les items
  lourds que les autres ne peuvent pas porter
- Skills:
  - Strength 7 (peut porter des charges lourdes)
  - Fitness 5 (endurance pour la marche)
  - Carpentry 2 (bricolage basique)
  - Aiming 1, Reloading 1 (mauvais au combat)
  - Sneak 2, Lightfoot 2
  - Nimble 3
- Items:
  - `Base.Bag_ALICEpack_Army` x1 (sac militaire -- plus grande capacite)
  - `Base.Bag_DuffelBag` x1 (sac de sport -- stockage supplementaire)
  - `Base.Crowbar` x1 (defense minimale + forcement)
  - `Base.Bandage` x3
  - `Base.WaterBottleFull` x2
  - `Base.TinnedBeans` x3 (nourriture pour le groupe)
  - `Base.TinnedSoup` x3
  - `Base.TinOpener` x1
  - `Base.WaterBottleFull` x2 (eau pour le groupe)
  - `Base.PetrolCan` x1 (bidon d'essence -- directement utile pour l'evasion!)
  - `Base.Hat_Army` x1 (casque -- protection)
  - `Base.Jacket_CoatArmy` x1 (manteau -- protection)
  - `Base.Trousers` x1
  - `Base.Shoes_ArmyBoots` x1 (bottes -- marches longues)
  - `Base.Torch` x1
  - `Base.Battery` x2
  - `Base.DuctTape` x2
  - `Base.Rope` x1
- Mecanique specifique:
  - Endurance moderee (setEndurance(0.5)) -- habitue a porter
  - Panic modere (setPanic(25))
- Roleplay: "Le porteur. Le plus gros sac, le plus de place, transporte les
  ressources pour toute l'equipe. Commence meme avec un bidon d'essence --
  un atout majeur pour l'evasion. Mais faible au combat."

### Civil (FALLBACK)
- Profil: citoyen lambda qui faisait ses courses dans le centre commercial quand
  l'apocalypse a commence. Aucun entrainement, aucune specialite.
- Style: survie basique, peur elevee, equipement du quotidien. Role de fallback
  attribue automatiquement aux joueurs au-dela de 16.
- Skills:
  - Fitness 1, Strength 1
  - Sneak 1, Lightfoot 1
  - Aiming 0, Reloading 0
  - Nimble 1
- Items:
  - `Base.KitchenKnife` x1 (recupere dans le mall)
  - `Base.Bandage` x1
  - `Base.WaterBottleFull` x1
  - `Base.GranolaBar` x1 (restes de courses)
  - `Base.Bag_Schoolbag` x1 (petit sac)
  - `Base.HoodieDOWN_WhiteTINT` x1
  - `Base.Trousers` x1
  - `Base.Shoes_Black` x1
  - `Base.Torch` x1
  - `Base.Battery` x1
- Mecanique specifique:
  - Panic tres haute (setPanic(50)) -- pas habitue au danger
  - Endurance basse (setEndurance(0.2)) -- pas sportif
  - Fatigue moderee (setFatigue(0.15)) -- stresse
- Roleplay: "Un civil qui faisait ses courses. Pas de competences particulieres,
  juste de la chance (ou de la malchance) d'etre encore vivant."

## Probleme d'architecture

### A. Systeme d'assignation

Le role picker UI (EE-13) affiche actuellement 4 roles. Avec 16 roles, il faut:

1. Etendre `ROLE_ORDER` a 16 entrees
2. Etendre `ROLE_DEFS` avec les 12 nouveaux roles
3. Le systeme de slots de EE-06 gere deja >4 joueurs
4. Le role picker (EscapadeExpressRolePicker.lua) affichera les 16 roles
5. La fenetre du picker devra scroller ou reduire la hauteur par role

### B. Limite de joueurs

Avec 16 roles au picker + le Civil, le scenario supporte 17 roles jouables.
Au-dela:
- Le picker s'ouvre mais tous les roles sont pris (y compris Civil)
- Le joueur supplementaire recoit automatiquement le role **Civil**
- Le role Civil apparait dans le picker -- un joueur peut le choisir
  volontairement pour un mode difficile
- Pas de limite stricte de joueurs -- tous les joueurs au-dela de 17 sont des Civils

### C. Hauteur du role picker

Le picker actuel a `rowHeight = 92` et `height = 460` pour 4 roles.

Pour 17 roles, deux options:
- Option A: `height = 92 * 17 + 70 = 1634` -- tres grand, peut deborder de l'ecran
- Option B: Reduire `rowHeight = 60` -> `height = 60 * 17 + 70 = 1090` -- plus compact
- Option C (recommandee): `rowHeight = 65`, `height = 65 * 17 + 70 = 1175`, avec scroll
  via `ISPanel: setScrollable(true)` ou `ISScrollingListBox`

Recommandation: reduire rowHeight a 65 et ajouter du scroll si l'ecran est
trop petit. Les informations affichees par role (nom, resume, forces, statut)
tiennent en 65px si on compacte le texte.

## Implementation

### A. Etendre ROLE_ORDER et ROLE_NAMES

Cote serveur (EscapadeExpressServer.lua):
```lua
local ROLE_ORDER = {
    "soldat", "voleur", "local_", "medic",
    "rambo", "sniper", "samourai", "geek", "survivaliste",
    "pompier", "mecanicien", "athlete", "eclaireur",
    "demolisseur", "invincible", "mule",
    "civil",  -- fallback pour les joueurs au-dela de 16
}

local ROLE_NAMES = {
    soldat = "Soldat",
    voleur = "Voleur",
    local_ = "Local",
    medic = "Medic",
    rambo = "Rambo",
    sniper = "Sniper",
    samourai = "Samourai",
    geek = "Geek",
    survivaliste = "Survivaliste",
    pompier = "Pompier",
    mecanicien = "Mecanicien",
    athlete = "Athlete",
    eclaireur = "Eclaireur",
    demolisseur = "Demolisseur",
    invincible = "Invincible",
    mule = "Mule",
    civil = "Civil",
}
```

Cote client (EscapadeExpressRolePicker.lua):
```lua
local ROLE_ORDER = {
    "soldat", "voleur", "local_", "medic",
    "rambo", "sniper", "samourai", "geek", "survivaliste",
    "pompier", "mecanicien", "athlete", "eclaireur",
    "demolisseur", "invincible", "mule",
    "civil",  -- mode difficile: les joueurs peuvent choisir Civil volontairement
}

local ROLE_INFO = {
    soldat = {
        name = "Soldat",
        summary = "Combat / protection",
        strengths = "Pistolet, robustesse, couverture",
    },
    voleur = {
        name = "Voleur",
        summary = "Furtivite / utilitaire",
        strengths = "Discretion, crowbar, mobilite",
    },
    local_ = {
        name = "Local",
        summary = "Survie / ressources",
        strengths = "Outils, vivres, sac a dos",
    },
    medic = {
        name = "Medic",
        summary = "Soin / support",
        strengths = "Bandages, soins, secours",
    },
    rambo = {
        name = "Rambo",
        summary = "Combat rapproche / tank",
        strengths = "Hache, endurance, tanky, peur de rien",
    },
    sniper = {
        name = "Sniper",
        summary = "Tir a longue distance",
        strengths = "Fusil .308, lunette x4, discret",
    },
    samourai = {
        name = "Samourai",
        summary = "Maitre du katana / mobility",
        strengths = "Katana, discipline, agilite",
    },
    geek = {
        name = "Geek",
        summary = "Cerveau / electronique / mecanique",
        strengths = "Reparations, gadgets, crafting",
    },
    survivaliste = {
        name = "Survivaliste",
        summary = "Autonomie / nature / survie",
        strengths = "Feu, pieges, peche, nourriture, robustesse",
    },
    pompier = {
        name = "Pompier",
        summary = "Sauveur / resistant au feu",
        strengths = "Extincteur, hache, protection feu, secours",
    },
    mecanicien = {
        name = "Mecanicien",
        summary = "Expert vehicule / reparations",
        strengths = "Repare le van, soude, change les pneus",
    },
    athlete = {
        name = "Athlete",
        summary = "Mobilite pure / vitesse",
        strengths = "Court vite, esquive, endurance elevee",
    },
    eclaireur = {
        name = "Eclaireur",
        summary = "Exploration / cartographie",
        strengths = "Discret, repere les menaces, guide l'equipe",
    },
    demolisseur = {
        name = "Demolisseur",
        summary = "Explosions / demolition / chaos",
        strengths = "Grenades, bombes, molotovs, sledgehammer",
    },
    invincible = {
        name = "Invincible",
        summary = "Tout au max / one-man army",
        strengths = "M16 + Magnum + Katana, meilleures protections",
    },
    mule = {
        name = "Mule",
        summary = "Porteur / transport / stockage",
        strengths = "Gros sac, bidon d'essence, nourriture pour le groupe",
    },
    civil = {
        name = "Civil",
        summary = "Citoyen lambda / mode difficile",
        strengths = "Aucune -- pour les joueurs qui veulent un vrai challenge",
    },
}
```

### B. Etendre ROLE_DEFS (serveur)

```lua
local ROLE_DEFS = {
    -- ... roles existants (soldat, voleur, local_, medic) inchanges ...

    rambo = {
        name = "Rambo",
        skills = {
            {Perks.Strength, 6},
            {Perks.Fitness, 5},
            {Perks.Axe, 5},
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
            {"Base.Jacket_Black", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 1},
        },
        stats = { endurance = 0.7, panic = 10 },
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
        },
        items = {
            {"Base.HuntingRifle", 1},
            {"Base.308Clip", 1},
            {"Base.308Bullets", 20},
            {"Base.x4Scope", 1},
            {"Base.HuntingKnife", 1},
            {"Base.Bandage", 2},
            {"Base.WaterBottleFull", 1},
            {"Base.Bag_NormalHikingBag", 1},
            {"Base.Jacket_ArmyCamoGreen", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 1},
        },
        stats = { panic = 20 },
    },
    samourai = {
        name = "Samourai",
        skills = {
            {Perks.Fitness, 5},
            {Perks.Strength, 4},
            {Perks.Nimble, 5},
            {Perks.Sneak, 3},
            {Perks.Lightfoot, 3},
        },
        items = {
            {"Base.Katana", 1},
            {"Base.KitchenKnife", 2},
            {"Base.Bandage", 3},
            {"Base.WaterBottleFull", 1},
            {"Base.Bag_NormalHikingBag", 1},
            {"Base.HoodieDOWN_WhiteTINT", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 1},
        },
        stats = { endurance = 0.5, panic = 15 },
    },
    geek = {
        name = "Geek",
        skills = {
            {Perks.Electrical, 6},
            {Perks.Mechanics, 5},
            {Perks.Nimble, 3},
            {Perks.Strength, 2},
            {Perks.Fitness, 2},
            {Perks.Aiming, 1},
            {Perks.Reloading, 1},
            {Perks.Sneak, 3},
        },
        items = {
            {"Base.Screwdriver", 1},
            {"Base.Wrench", 1},
            {"Base.ElectronicsScrap", 5},
            {"Base.ScrapMetal", 3},
            {"Base.Wire", 2},
            {"Base.LightBulb", 2},
            {"Base.DuctTape", 2},
            {"Base.ElectronicsMag1", 1},
            {"Base.ElectronicsMag2", 1},
            {"Base.BookMechanic1", 1},
            {"Base.Bandage", 2},
            {"Base.WaterBottleFull", 1},
            {"Base.Bag_Schoolbag", 1},
            {"Base.HoodieDOWN_WhiteTINT", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 3},
        },
        stats = { panic = 40, fatigue = 0.1 },
    },
    survivaliste = {
        name = "Survivaliste",
        skills = {
            {Perks.PlantScavenging, 5},
            {Perks.Trapping, 4},
            {Perks.Fishing, 3},
            {Perks.Carpentry, 4},
            {Perks.Cooking, 3},
            {Perks.Fitness, 4},
            {Perks.Strength, 4},
            {Perks.Sneak, 2},
            {Perks.Lightfoot, 2},
            {Perks.Aiming, 2},
            {Perks.Reloading, 2},
        },
        items = {
            {"Base.HandAxe", 1},
            {"Base.HuntingKnife", 1},
            {"Base.Matches", 1},
            {"Base.Lighter", 1},
            {"camping.CampfireKit", 1},
            {"camping.SteelAndFlint", 1},
            {"camping.CampingTentKit", 1},
            {"Base.CannedCornedBeef", 2},
            {"Base.TinnedSoup", 2},
            {"Base.Crackers", 2},
            {"Base.GranolaBar", 2},
            {"Base.Peanuts", 2},
            {"Base.WaterBottleFull", 2},
            {"Base.TinOpener", 1},
            {"Base.Bandage", 3},
            {"Base.Splint", 1},
            {"Base.AlcoholWipes", 2},
            {"Base.Bag_SurvivorBag", 1},
            {"Base.Jacket_CoatArmy", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Strapped", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.BookTrapping1", 1},
            {"Base.BookFishing1", 1},
            {"Base.Rope", 1},
            {"Base.DuctTape", 1},
        },
        stats = { panic = 15, endurance = 0.4 },
    },
    pompier = {
        name = "Pompier",
        skills = {
            {Perks.Fitness, 5},
            {Perks.Strength, 5},
            {Perks.Axe, 4},
            {Perks.Doctor, 2},
            {Perks.Nimble, 3},
            {Perks.Aiming, 2},
            {Perks.Reloading, 2},
            {Perks.Sneak, 1},
            {Perks.Lightfoot, 1},
        },
        items = {
            {"Base.Axe", 1},
            {"Base.Extinguisher", 1},
            {"Base.Hat_Fireman", 1},
            {"Base.Jacket_Fireman", 1},
            {"Base.Trousers_Fireman", 1},
            {"Base.Shoes_ArmyBoots", 1},
            {"Base.Bandage", 4},
            {"Base.AlcoholWipes", 2},
            {"Base.Splint", 1},
            {"Base.WaterBottleFull", 2},
            {"Base.Bag_NormalHikingBag", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.Hammer", 1},
            {"Base.Crowbar", 1},
        },
        stats = { panic = 15, endurance = 0.6 },
    },
    mecanicien = {
        name = "Mecanicien",
        skills = {
            {Perks.Mechanics, 7},
            {Perks.Electrical, 3},
            {Perks.Carpentry, 2},
            {Perks.Fitness, 3},
            {Perks.Strength, 4},
            {Perks.Aiming, 2},
            {Perks.Reloading, 2},
            {Perks.Sneak, 2},
            {Perks.Lightfoot, 2},
        },
        items = {
            {"Base.Wrench", 1},
            {"Base.LugWrench", 1},
            {"Base.TirePump", 1},
            {"Base.BlowTorch", 1},
            {"Base.PropaneTank", 1},
            {"Base.Screwdriver", 1},
            {"Base.Hammer", 1},
            {"Base.DuctTape", 2},
            {"Base.ScrapMetal", 3},
            {"Base.Wire", 2},
            {"Base.BookMechanic1", 1},
            {"Base.Bandage", 2},
            {"Base.WaterBottleFull", 1},
            {"Base.Bag_NormalHikingBag", 1},
            {"Base.Jacket_Black", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_ArmyBoots", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
        },
        stats = { panic = 25, fatigue = 0.05 },
    },
    athlete = {
        name = "Athlete",
        skills = {
            {Perks.Fitness, 7},
            {Perks.Strength, 3},
            {Perks.Nimble, 5},
            {Perks.Lightfoot, 4},
            {Perks.Sneak, 3},
            {Perks.Aiming, 2},
            {Perks.Reloading, 2},
        },
        items = {
            {"Base.KitchenKnife", 1},
            {"Base.Bandage", 2},
            {"Base.WaterBottleFull", 2},
            {"Base.GranolaBar", 3},
            {"Base.PillsVitamins", 1},
            {"Base.Bag_NormalHikingBag", 1},
            {"Base.HoodieDOWN_WhiteTINT", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_BlueTrainers", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 1},
        },
        stats = { endurance = 0.85, panic = 20, fatigue = 0 },
    },
    eclaireur = {
        name = "Eclaireur",
        skills = {
            {Perks.Sneak, 5},
            {Perks.Lightfoot, 5},
            {Perks.Nimble, 4},
            {Perks.PlantScavenging, 4},
            {Perks.Fitness, 4},
            {Perks.Strength, 3},
            {Perks.Aiming, 3},
            {Perks.Reloading, 3},
            {Perks.Carpentry, 2},
        },
        items = {
            {"Base.Machete", 1},
            {"Base.Map", 1},
            {"Base.x4Scope", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.Bandage", 2},
            {"Base.WaterBottleFull", 1},
            {"Base.GranolaBar", 2},
            {"Base.Bag_NormalHikingBag", 1},
            {"Base.Jacket_ArmyCamoDesert", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Strapped", 1},
            {"Base.Lighter", 1},
            {"Base.Rope", 1},
        },
        stats = { endurance = 0.5, panic = 15 },
    },
    demolisseur = {
        name = "Demolisseur",
        skills = {
            {Perks.Electrical, 4},
            {Perks.Mechanics, 4},
            {Perks.Strength, 4},
            {Perks.Fitness, 3},
            {Perks.Aiming, 3},
            {Perks.Reloading, 3},
            {Perks.Sneak, 1},
            {Perks.Lightfoot, 1},
        },
        items = {
            {"Base.PipeBomb", 5},
            {"Base.PipeBombTriggered", 3},
            {"Base.Aerosolbomb", 5},
            {"Base.AerosolbombTriggered", 3},
            {"Base.Molotov", 4},
            {"Base.SmokeBomb", 3},
            {"Base.Sledgehammer", 1},
            {"Base.DuctTape", 2},
            {"Base.ScrapMetal", 3},
            {"Base.Wire", 2},
            {"Base.ElectronicsScrap", 3},
            {"Base.PropaneTank", 1},
            {"Base.Bandage", 3},
            {"Base.WaterBottleFull", 1},
            {"Base.Bag_BigHikingBag", 1},
            {"Base.Jacket_Black", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_ArmyBoots", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.Lighter", 1},
        },
        stats = { panic = 10, endurance = 0.4 },
    },
    invincible = {
        name = "Invincible",
        skills = {
            {Perks.Aiming, 7},
            {Perks.Reloading, 6},
            {Perks.Strength, 7},
            {Perks.Fitness, 7},
            {Perks.Sneak, 5},
            {Perks.Lightfoot, 5},
            {Perks.Nimble, 5},
            {Perks.Doctor, 4},
            {Perks.Carpentry, 4},
            {Perks.Mechanics, 4},
            {Perks.Electrical, 4},
            {Perks.Cooking, 3},
            {Perks.PlantScavenging, 3},
        },
        items = {
            {"Base.AssaultRifle", 1},
            {"Base.556Clip", 3},
            {"Base.556Bullets", 60},
            {"Base.Revolver_Long", 1},
            {"Base.Bullets44", 24},
            {"Base.44Clip", 2},
            {"Base.Katana", 1},
            {"Base.Sledgehammer", 1},
            {"Base.Hat_RiotHelmet", 1},
            {"Base.Jacket_CoatArmy", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_ArmyBoots", 1},
            {"Base.Bandage", 5},
            {"Base.AlcoholWipes", 3},
            {"Base.Splint", 2},
            {"Base.Pills", 2},
            {"Base.PillsBeta", 1},
            {"Base.PillsVitamins", 1},
            {"Base.Antibiotics", 1},
            {"Base.WaterBottleFull", 2},
            {"Base.Bag_ALICEpack_Army", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 3},
            {"Base.DuctTape", 2},
            {"Base.Rope", 1},
        },
        stats = { endurance = 0.8, panic = 5, fatigue = 0 },
    },
    mule = {
        name = "Mule",
        skills = {
            {Perks.Strength, 7},
            {Perks.Fitness, 5},
            {Perks.Carpentry, 2},
            {Perks.Aiming, 1},
            {Perks.Reloading, 1},
            {Perks.Sneak, 2},
            {Perks.Lightfoot, 2},
            {Perks.Nimble, 3},
        },
        items = {
            {"Base.Bag_ALICEpack_Army", 1},
            {"Base.Bag_DuffelBag", 1},
            {"Base.Crowbar", 1},
            {"Base.Bandage", 3},
            {"Base.WaterBottleFull", 2},
            {"Base.TinnedBeans", 3},
            {"Base.TinnedSoup", 3},
            {"Base.TinOpener", 1},
            {"Base.PetrolCan", 1},
            {"Base.Hat_Army", 1},
            {"Base.Jacket_CoatArmy", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_ArmyBoots", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.DuctTape", 2},
            {"Base.Rope", 1},
        },
        stats = { endurance = 0.5, panic = 25 },
    },
    civil = {
        name = "Civil",
        skills = {
            {Perks.Fitness, 1},
            {Perks.Strength, 1},
            {Perks.Sneak, 1},
            {Perks.Lightfoot, 1},
            {Perks.Nimble, 1},
            {Perks.Aiming, 0},
            {Perks.Reloading, 0},
        },
        items = {
            {"Base.KitchenKnife", 1},
            {"Base.Bandage", 1},
            {"Base.WaterBottleFull", 1},
            {"Base.GranolaBar", 1},
            {"Base.Bag_Schoolbag", 1},
            {"Base.HoodieDOWN_WhiteTINT", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 1},
        },
        stats = { panic = 50, endurance = 0.2, fatigue = 0.15 },
    },
}
```

### C. Stats specifiques par role

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
    if def.stats.fatigue then
        player:getStats():setFatigue(def.stats.fatigue)
    end
end
```

### D. Mettre a jour les roleNames cote UI

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
    geek = "Geek",
    survivaliste = "Survivaliste",
    pompier = "Pompier",
    mecanicien = "Mecanicien",
    athlete = "Athlete",
    eclaireur = "Eclaireur",
    demolisseur = "Demolisseur",
    invincible = "Invincible",
    mule = "Mule",
    civil = "Civil",
}
```

### E. Ajuster la hauteur du role picker

Pour 17 roles, reduire rowHeight et ajouter du scroll:

```lua
-- EscapadeExpressRolePicker.lua
-- Option recommandee: rowHeight = 65, scroll si necessaire
self.rowHeight = 65  -- etait 92
-- height: 65 * 17 + 70 (header) = 1175
-- Si l'ecran est trop petit, utiliser setScrollable ou un scrollbar

-- Dans EscapadeExpressRolePicker.open():
local width = 620
local height = 1110  -- ou utiliser getCore():getScreenHeight() - 40 avec scroll
```

Alternative: utiliser `ISScrollingListBox` ou `ISPanel` avec scrollbar integree
pour s'adapter a toutes les tailles d'ecran.

### F. Perks utilises (tous confirmes en B41)

- `Perks.Electrical` -- confirme
- `Perks.Mechanics` -- confirme
- `Perks.Trapping` -- confirme
- `Perks.Fishing` -- confirme
- `Perks.PlantScavenging` -- confirme (deja utilise par le Local)
- `Perks.Axe` -- confirme (skill de hache)
- `Perks.Nimble` -- confirme (deja utilise par le Voleur)
- `Perks.Carpentry` -- confirme (deja utilise par le Local)
- `Perks.Cooking` -- confirme (deja utilise par le Local)
- `Perks.Doctor` -- confirme (deja utilise par le Medic)
- `Perks.Sneak` -- confirme
- `Perks.Lightfoot` -- confirme
- `Perks.Fitness` -- confirme
- `Perks.Strength` -- confirme
- `Perks.Aiming` -- confirme
- `Perks.Reloading` -- confirme

Note: `Perks.Computers` n'existe pas en B41. Le Geek utilise Electrical +
Mechanics a la place. `Perks.Melee` n'existe pas non plus en B41 (les skills
de melee sont par type d'arme: Axe, Blunt, etc.).

## Fichiers a modifier

- `media/lua/server/EscapadeExpressServer.lua`:
  - Etendre `ROLE_ORDER` (ligne 55)
  - Etendre `ROLE_NAMES` (ligne 56-61)
  - Etendre `ROLE_DEFS` (ligne 67-149) avec les 12 nouveaux roles
  - Ajouter bloc `stats` dans `applyRole` (apres ligne 296)
  - Ajouter gestion `fatigue` dans le bloc stats
- `media/lua/client/EscapadeExpressUI.lua`:
  - Etendre `roleNames` (ligne 84-89)
- `media/lua/client/EscapadeExpressRolePicker.lua`:
  - Etendre `ROLE_ORDER` (ligne 8)
  - Etendre `ROLE_INFO` (ligne 9-30) avec les 12 nouveaux roles
  - Reduire `rowHeight` (ligne 104) de 92 a 65
  - Ajuster `height` dans `open()` (ligne 249) pour 16 roles
  - Ajouter scroll si necessaire
- `media/lua/client/LastStand/EscapadeExpress.lua`:
  - Etendre `ROLE_NAMES` (ligne 33-38)
  - Etendre `ROLE_DEFS` (ligne 40-118) avec les memes definitions que le serveur
    (pour le fallback solo)

## Critere d'acceptation

1. Les 12 nouveaux roles sont jouables
2. Chaque role a des skills, items et stats distincts
3. L'assignation fonctionne jusqu'a 16 joueurs
4. Les stats specifiques (endurance, panic, fatigue) s'appliquent au spawn
5. L'UI affiche le nom correct des nouveaux roles
6. Le role picker affiche les 16 roles sans debordement (scroll si necessaire)
7. Tous les items utilises existent en B41 vanilla (verifies via pz-item-browser)
8. Un 17e joueur+ recoit automatiquement le role Civil (fallback, pas de rejet)
9. Le fallback solo fonctionne avec n'importe quel des 16 roles
10. Le Demolisseur a beaucoup de grenades (PipeBomb x5, Aerosolbomb x5, Molotov x4, etc.)
11. L'Invincible a tout au max (skills 7, M16 + Magnum + Katana, meilleures protections)
12. La Mule a un gros sac + un bidon d'essence + de la nourriture pour le groupe

## Tableau recapitulatif des 16 roles

| Role | Style | Arme principale | Force | Faiblesse |
|------|-------|-----------------|-------|-----------|
| Soldat | Combat equilibre | Pistolet 9mm | Aiming 4, Strength 4 | Pas de melee |
| Voleur | Furtif | Crowbar | Sneak 5, Lightfoot 5 | Pas d'arme a feu |
| Local | Survie urbaine | Hammer | Carpentry 4, Cooking 4 | Pas de combat |
| Medic | Soin | (aucune) | Doctor 6 | Pas de combat ni survie |
| Rambo | Tank melee | Axe | Strength 6, Fitness 5 | Bruyant, mauvais au tir |
| Sniper | Tir longue distance | HuntingRifle .308 | Aiming 7 | Faible au melee, peu de stamina |
| Samourai | Katana / mobility | Katana | Fitness 5, Nimble 5 | Pas d'armes a feu |
| Geek | Cerveau / crafting | Screwdriver | Electrical 6, Mechanics 5 | Faible au combat, panicux |
| Survivaliste | Autonomie / nature | HandAxe | PlantScavenging 5, Trapping 4 | Pas de spec combat |
| Pompier | Sauveur / anti-feu | Axe + Extinguisher | Fitness 5, Strength 5 | Bruyant, peu precis au tir |
| Mecanicien | Repare vehicule | Wrench | Mechanics 7 | Combat limite |
| Athlete | Vitesse / mobilite | KitchenKnife | Fitness 7, Nimble 5 | Tres faible au combat |
| Eclaireur | Exploration / discret | Machete | Sneak 5, Lightfoot 5 | Combat limite |
| Demolisseur | Explosions / chaos | Sledgehammer + grenades | Electrical 4, Mechanics 4 | Bruyant, dangereux pour l'equipe |
| Invincible | Tout au max | M16 + Magnum + Katana | Tous skills 5-7 | Aucune (intentionnel) |
| Mule | Porteur / transport | Crowbar | Strength 7 | Tres mauvais au combat |
| Civil | Fallback / lambda | KitchenKnife | Fitness 1, Strength 1 | Aucune competences, panic elevee |

## Dependencies

- **EE-06 requis**: Le systeme de slots de EE-06 gere l'assignation pour
  >4 joueurs.
- **EE-13 requis**: Le role picker UI est necessaire pour laisser le joueur
  choisir parmi 16 roles.
- **EE-11**: La definition des objets des roles existants (Soldat, Voleur,
  Local, Medic) doit etre validee avant l'implementation.

## Taille estimee

Large (L) -- 12 nouvelles definitions de roles + stats specifiques + ajustement
UI picker avec scroll + verification des items (deja fait dans cette spec)