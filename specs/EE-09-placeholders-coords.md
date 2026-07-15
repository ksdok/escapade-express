# EE-09 (S) - Definir et documenter les placeholders de coords du mall dans le code

## Contexte

Toutes les coordonnees du scenario sont des placeholders bases sur cell 37x28
(Xonic's Mega Mall). Les coordonnees reelles doivent etre determinees en jeu
avec le mode debug.

## Coordonnees placeholders actuelles

### Dans EscapadeExpress.lua (client)

| Variable | Valeur | Usage |
|----------|--------|-------|
| `SPAWN` | xcell=37, ycell=28, x=120, y=120, z=0 | Spawn arriere-boutique |
| `PARKING_X/Y/Z` | 11250, 8550, 0 | Parking du mall (vehicule) |
| `MALL_ENTRANCES[1]` | 11200, 8400, 0 | Entree nord (spawn zombies) |
| `MALL_ENTRANCES[2]` | 11100, 8500, 0 | Entree sud |
| `MALL_ENTRANCES[3]` | 11300, 8450, 0 | Entree est |
| `SHOPS[1-4]` | 11180-11220, 8430-8470, 0 | Boutiques pour incendie |
| `GAS_CAN_LOCATION` | 11170, 8490, 0 | Bidon d'essence |

### Dans EscapadeExpressServer.lua (serveur)

| Variable | Valeur | Usage |
|----------|--------|-------|
| `PARKING_X/Y/Z` | 11250, 8550, 0 | Parking (vehicule) |
| `GAS_CAN_LOCATION` | 11170, 8490, 0 | Bidon d'essence |
| `RESPAWN_X/Y/Z` | 11220, 8520, 0 | Point de respawn |
| `cutPower centerX/Y` | 11200, 8450, 0 | Centre de la zone coupure elec |
| `triggerGameOver entrances` | 11200/11100/11300, 8400/8500/8450, 0 | Entrees horde finale |

## Probleme

1. **Duplication entre client et serveur**: `PARKING_X/Y/Z`, `GAS_CAN_LOCATION`
   et `MALL_ENTRANCES` sont definis dans les deux fichiers avec les memes valeurs.
   Si on corrige un placeholder, il faut le faire dans 2 fichiers.

2. **Pas de commentaire `PLACEHOLDER`**: Les variables ont un commentaire
   "placeholder" sur la ligne de definition, mais pas de marker systematique
   pour les retrouver avec un grep.

3. **Pas de conversion documentee**: Les coords monde (11250) ne sont pas
   converties en xcell/ycell/x/y dans le code la ou c'est necessaire.

## Spec corrective

### A. Centraliser les coords dans un fichier shared

Creer `media/lua/shared/EscapadeExpressConfig.lua`:

```lua
-- ============================================================
-- ESCAPADE EXPRESS - Configuration des coordonnees
-- TOUTES LES VALEURS SONT DES PLACEHOLDERS (cell 37x28)
-- Ajuster en jeu avec le mode debug, puis mettre a jour ce fichier.
--
-- Procedure:
-- 1. Lancer le jeu avec Xonic's Mega Mall + Escapade Express
-- 2. Mode debug (Sandbox > Debug Mode)
-- 3. Teleporter a la position souhaitee
-- 4. Lire les coords (F3 ou console: getPlayer():getX())
-- 5. Convertir: xcell = floor(x/300), x = x - (xcell*300)
-- 6. Mettre a jour les valeurs ci-dessous
-- ============================================================

EE_Config = {
    -- Spawn arriere-boutique (format cell)
    spawn = {xcell = 37, ycell = 28, x = 120, y = 120, z = 0},

    -- Parking du mall (format monde)
    parking = {x = 11250, y = 8550, z = 0},

    -- Point de respawn (distinct du parking)
    respawn = {x = 11220, y = 8520, z = 0},

    -- Entrees du mall pour spawn zombies (format monde)
    entrances = {
        {x = 11200, y = 8400, z = 0},  -- nord
        {x = 11100, y = 8500, z = 0},  -- sud
        {x = 11300, y = 8450, z = 0},  -- est
    },

    -- Boutiques pour incendie (format monde)
    shops = {
        {x = 11180, y = 8430, z = 0},
        {x = 11220, y = 8470, z = 0},
        {x = 11150, y = 8460, z = 0},
        {x = 11200, y = 8420, z = 0},
    },

    -- Bidon d'essence (format monde)
    gasCan = {x = 11170, y = 8490, z = 0},

    -- Centre de la zone de coupure elec (format monde)
    powerOutageCenter = {x = 11200, y = 8450, z = 0},
    powerOutageRadius = 100,  -- tiles
}

-- Conversion: world coords -> cell coords
function EE_Config.worldToCell(worldX, worldY)
    local xcell = math.floor(worldX / 300)
    local ycell = math.floor(worldY / 300)
    local x = worldX - (xcell * 300)
    local y = worldY - (ycell * 300)
    return xcell, ycell, x, y
end

-- Conversion: cell coords -> world coords
function EE_Config.cellToWorld(xcell, ycell, x, y)
    return xcell * 300 + x, ycell * 300 + y
end
```

### B. Utiliser EE_Config dans les deux fichiers

Remplacer les constantes locales par des references a `EE_Config`:

```lua
-- EscapadeExpress.lua
local SPAWN = EE_Config.spawn
local PARKING_X = EE_Config.parking.x
-- etc.

-- EscapadeExpressServer.lua
local PARKING_X = EE_Config.parking.x
local GAS_CAN_LOCATION = EE_Config.gasCan
-- etc.
```

### C. Marker PLACEHOLDER grep-able

Chaque bloc de coords dans EE_Config commence par:
```lua
-- PLACEHOLDER: remplacer par les coords reelles du mall
```

Permet de retrouver tous les placeholders avec:
```bash
grep -rn "PLACEHOLDER" media/lua/shared/EscapadeExpressConfig.lua
```

## Fichiers a modifier

- **Nouveau**: `media/lua/shared/EscapadeExpressConfig.lua`
- `media/lua/client/LastStand/EscapadeExpress.lua`: remplacer constantes par EE_Config
- `media/lua/server/EscapadeExpressServer.lua`: remplacer constantes par EE_Config

## Critere d'acceptation

1. Toutes les coords sont definies dans un seul fichier shared
2. `grep -rn PLACEHOLDER` trouve toutes les valeurs a ajuster
3. Client et serveur utilisent la meme source de coords
4. Les fonctions de conversion world<->cell sont disponibles
5. Le fichier shared est charge avant client/server (ordre: shared > client > server)

## Dependencies

- Aucune (independant)
- EE-07 (synchro events) deplacera certaines coords cote serveur -- faire EE-09
  avant ou en meme temps que EE-07 pour eviter de dupliquer les constantes

## Taille estimee

Small (S) -- extraction des constantes + creation d'un fichier shared