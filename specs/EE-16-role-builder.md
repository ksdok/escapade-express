# EE-16 — Rôle Builder (constructeur illimité)

## Contexte

Le scénario manque d'un rôle de support construction. Le rôle Builder peut construire sans se soucier du poids ni des ressources: tous les skills de construction à 10, inventaire illimité (`setUnlimitedCarry`), stock massif de ressources au spawn, et re-garnissage périodique.

## État actuel du code

### Serveur (`EscapadeExpressServer.lua`)
- `ROLE_ORDER` (ligne 57): liste de 16 rôles + civil
- `ROLE_NAMES` (ligne 64): noms d'affichage
- `ROLE_DEFS` (ligne 88): définitions (skills, items, equipped, stats, bagContents)
- `applyRole(player, roleKey)` (ligne 1138): applique items + skills + équipement + stats
- `applyRoleStats(player, stats)` (ligne 968): applique panic, hunger, thirst, fatigue, endurance
- `applyPerkLevel(player, perk, level)`: applique un niveau de skill

### Client (`EscapadeExpress.lua`)
- `ROLE_NAMES` (ligne 27): doublon client pour le fallback solo
- `ROLE_DEFS` (ligne 47): doublon client pour le fallback solo
- `applyRoleLocally(player, roleKey)` (ligne 966): applique le rôle en solo

### Role Picker (`EscapadeExpressRolePicker.lua`)
- `ROLE_ORDER` (ligne 11): liste pour l'affichage
- `ROLE_INFO` (ligne 19): résumés + forces pour l'affichage du picker

## Spécification

### 1. Nouveau rôle "builder"

Clé: `builder`
Nom d'affichage: "Builder"

#### Skills (tous à 10)
```lua
skills = {
    {Perks.Carpentry, 10},      -- menuiserie: murs, portes, barricades
    {Perks.Electricity, 10},    -- électricité: générateurs, panneaux
    {Perks.MetalWelding, 10},   -- soudure: barricades métal, murs
    {Perks.Mechanics, 10},      -- mécanique: réparation véhicule
    {Perks.Tailoring, 10},      -- couture: réparation vêtements
    {Perks.Cooking, 10},        -- cuisine: préparer à manger
    {Perks.Strength, 7},        -- force: portage
    {Perks.Fitness, 5},         -- fitness
}
```

#### Items (stock de construction massif)
```lua
items = {
    -- Outils
    {"Base.Hammer", 1},
    {"Base.Saw", 1},
    {"Base.Screwdriver", 1},
    {"Base.Wrench", 1},
    {"Base.WeldingMask", 1},
    {"Base.BlowTorch", 1},
    {"Base.Crowbar", 1},
    {"Base.Sledgehammer", 1},        -- demolition
    {"Base.GardenSaw", 1},           -- scie élagage
    {"Base.TinOpener", 1},
    {"Base.Torch", 1},
    {"Base.Battery", 3},

    -- Ressources de construction (grand stock)
    {"Base.Plank", 50},
    {"Base.Nails", 200},
    {"Base.SheetMetal", 20},
    {"Base.ScrapMetal", 30},
    {"Base.Wire", 10},
    {"Base.DuctTape", 10},
    {"Base.Rope", 5},
    {"Base.MetalPipe", 10},
    {"Base.Glue", 5},
    {"Base.MetalBar", 10},
    {"Base.Screws", 100},

    -- Survie
    {"Base.Bandage", 5},
    {"Base.WaterBottleFull", 2},
    {"Base.TinnedBeans", 3},
    {"Base.TinnedSoup", 3},

    -- Sac + vêtements
    {"Base.Bag_BigHikingBag", 1},
    {"Base.Boilersuit", 1},           -- combinaison de travail
    {"Base.Trousers", 1},
    {"Base.Shoes_ArmyBoots", 1},
}
```

#### Équipement
```lua
equipped = {
    primary = "Base.Crowbar",
    bag = "Base.Bag_BigHikingBag",
    clothes = {
        "Base.Boilersuit",
        "Base.Trousers",
        "Base.Shoes_ArmyBoots",
    },
}
```

#### Stats
```lua
stats = { endurance = 0.3, panic = 20 }
```

### 2. Capacités spéciales du Builder

#### setUnlimitedCarry(true)
Le Builder peut porter un poids illimité. À appliquer dans `applyRole()` après les items, si le rôle est `builder`:

```lua
if roleKey == "builder" then
    player:setUnlimitedCarry(true)
end
```

#### Re-garnissage périodique des ressources
Toutes les 10 minutes (via `EveryTenMinutes` côté serveur), re-ajouter des ressources consommées au Builder:

```lua
local function refillBuilderResources()
    if Server.gameOver then return end
    for _, player in ipairs(getScenarioPlayers()) do
        local modData = player:getModData()
        if modData.EE_role == "builder" then
            local inv = player:getInventory()
            -- Compter ce qu'il a, compléter jusqu'au seuil
            local thresholds = {
                {item = "Base.Plank", target = 50},
                {item = "Base.Nails", target = 200},
                {item = "Base.Sheet", target = 20},
                {item = "Base.ScrapMetal", target = 30},
                {item = "Base.DuctTape", target = 10},
                {item = "Base.Wire", target = 10},
            }
            for _, t in ipairs(thresholds) do
                local current = inv:getNumberOfItem(t.item) or 0
                if current < t.target then
                    local needed = t.target - current
                    if needed > 1 then
                        inv:AddItems(t.item, needed)
                    elseif needed == 1 then
                        inv:AddItem(t.item)
                    end
                end
            end
        end
    end
end
```

À hooker: `Events.EveryTenMinutes.Add(refillBuilderResources)` côté serveur.

### 3. Ajout dans les structures existantes

#### `ROLE_ORDER` (serveur + client + picker)
Ajouter `"builder"` dans la liste. Position: après `"mule"`, avant la fin.
Le roster passe de 17 à 18 rôles sélectionnables (17 rôles uniques + Civil).

#### `ROLE_NAMES` (serveur + client)
```lua
builder = "Builder",
```

#### `ROLE_DEFS` (serveur + client)
Nouvelle entrée complète (skills + items + equipped + stats).

#### `ROLE_INFO` (picker)
```lua
builder = {
    name = "Builder",
    summary = "Construction / ressources illimitees",
    strengths = "Outils, planches, poids illimite, re-garnissage",
},
```

### 4. Fallback solo

`applyRoleLocally` dans `EscapadeExpress.lua` doit aussi appliquer `setUnlimitedCarry(true)` pour le rôle builder. Le re-garnissage périodique en solo est géré par le même hook `EveryTenMinutes` côté serveur (en solo, le code serveur s'exécute localement).

### 5. Reset

`resetScenarioState()`: pas de changement spécifique au builder. Le re-garnissage s'arrête naturellement quand `Server.gameOver` est true. Si un nouveau scénario démarre, le joueur re-choisit un rôle et `applyRole` ré-applique `setUnlimitedCarry` si nécessaire.

Note: `setUnlimitedCarry` est un flag sur le joueur. Si le joueur change de rôle (pas possible dans le scénario actuel — le rôle est fixe), le flag reste. Ce n'est pas un problème car le rôle est définitif.

## Fichiers à modifier

### `media/lua/server/EscapadeExpressServer.lua`
- `ROLE_ORDER`: ajouter `"builder"`
- `ROLE_NAMES`: ajouter `builder = "Builder"`
- `ROLE_DEFS`: ajouter définition complète du rôle builder
- `applyRole()`: ajouter `setUnlimitedCarry(true)` si `roleKey == "builder"`
- Nouvelle fonction `refillBuilderResources()`: re-garnissage périodique
- Hook `Events.EveryTenMinutes.Add(refillBuilderResources)`

### `media/lua/client/LastStand/EscapadeExpress.lua`
- `ROLE_NAMES`: ajouter `builder = "Builder"`
- `ROLE_DEFS`: ajouter définition (doublon pour fallback solo)
- `applyRoleLocally()`: ajouter `setUnlimitedCarry(true)` si `roleKey == "builder"`

### `media/lua/client/EscapadeExpressRolePicker.lua`
- `ROLE_ORDER`: ajouter `"builder"`
- `ROLE_INFO`: ajouter entrée builder (name, summary, strengths)

## Hors scope

- Ne pas modifier les rôles existants
- Ne pas ajouter de UI de menu de construction custom (le Builder utilise le menu vanilla)
- Ne pas modifier la logique de revive ou de timer
- `setTimedActionInstantCheat` (construction instantanée) est délibérément exclu — ça casserait l'immersion et le rythme du scénario

## Critères d'acceptation

1. Le rôle "Builder" apparaît dans le picker de rôles (grille 3 colonnes)
2. Le Builder démarre avec tous les skills de construction à 10
3. Le Builder a un stock massif de ressources (planches, clous, métal, etc.)
4. Le Builder peut porter un poids illimité (`setUnlimitedCarry`)
5. Toutes les 10 minutes, les ressources du Builder sont re-garnies si elles ont baissé
6. Le re-garnissage s'arrête quand le game over est déclenché
7. Fonctionne en solo (fallback local) et en multi LAN
8. Le roster passe de 17 à 18 rôles sélectionnables (17 rôles uniques + Civil)

## Taille estimée

Small (S) — ajout d'une entrée dans 3 structures de données existantes + 1 fonction de re-garnissage + 1 appel `setUnlimitedCarry`