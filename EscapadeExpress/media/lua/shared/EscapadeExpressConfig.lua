-- ============================================================
-- ESCAPADE EXPRESS - Configuration des coordonnees
-- TOUTES LES VALEURS SONT DES PLACEHOLDERS bases sur Xonic's Mega Mall
-- (cell 37x28). Ajuster en jeu avec le mode debug, puis mettre a jour
-- ce fichier unique pour synchroniser client + serveur.
--
-- Procedure:
-- 1. Lancer le jeu avec Xonic's Mega Mall + Escapade Express
-- 2. Activer le mode debug
-- 3. Aller a la position souhaitee
-- 4. Lire les coords monde (ex: getPlayer():getX(), getPlayer():getY())
-- 5. Convertir si necessaire avec worldToCell / cellToWorld
-- 6. Remplacer les PLACEHOLDERS ci-dessous
-- ============================================================

EE_Config = EE_Config or {}

function EE_Config.worldToCell(worldX, worldY)
    local xcell = math.floor(worldX / 300)
    local ycell = math.floor(worldY / 300)
    local x = worldX - (xcell * 300)
    local y = worldY - (ycell * 300)
    return xcell, ycell, x, y
end

function EE_Config.cellToWorld(xcell, ycell, x, y)
    return xcell * 300 + x, ycell * 300 + y
end

function EE_Config.worldPointToCellPoint(worldX, worldY, worldZ)
    local xcell, ycell, x, y = EE_Config.worldToCell(worldX, worldY)
    return {
        xcell = xcell,
        ycell = ycell,
        x = x,
        y = y,
        z = worldZ or 0,
    }
end

function EE_Config.worldRectToCellSpawns(x1, y1, x2, y2, z)
    local minX = math.min(x1, x2)
    local maxX = math.max(x1, x2)
    local minY = math.min(y1, y2)
    local maxY = math.max(y1, y2)
    local spawns = {}

    for y = minY, maxY do
        for x = minX, maxX do
            spawns[#spawns + 1] = EE_Config.worldPointToCellPoint(x, y, z)
        end
    end

    return spawns
end

-- Spawn valide releve en jeu: rectangle interieur du mall.
-- `spawn` sert d'ancre/metadata; `spawnTiles` couvre toute la zone jouable.
EE_Config.spawnArea = {x1 = 11367, y1 = 8946, x2 = 11375, y2 = 8944, z = 0}
EE_Config.spawn = EE_Config.worldPointToCellPoint(11371, 8945, 0)
EE_Config.spawnTiles = EE_Config.worldRectToCellSpawns(
    EE_Config.spawnArea.x1,
    EE_Config.spawnArea.y1,
    EE_Config.spawnArea.x2,
    EE_Config.spawnArea.y2,
    EE_Config.spawnArea.z
)

-- Zone safe initiale pour laisser le temps de choisir un role.
EE_Config.safeStart = {x = 11371, y = 8945, z = 0, radius = 50}

-- Parking valide releve en jeu
EE_Config.parking = {x = 11370, y = 8955, z = 0}

-- PLACEHOLDER: remplacer par les coords reelles du point de respawn
EE_Config.respawn = {x = 11220, y = 8520, z = 0}

-- PLACEHOLDER: remplacer par les vraies entrees du mall pour les spawns zombies
EE_Config.entrances = {
    {x = 11200, y = 8400, z = 0}, -- nord
    {x = 11100, y = 8500, z = 0}, -- sud
    {x = 11300, y = 8450, z = 0}, -- est
}

-- PLACEHOLDER: remplacer par de vraies boutiques candidates pour l'incendie
EE_Config.shops = {
    {x = 11180, y = 8430, z = 0},
    {x = 11220, y = 8470, z = 0},
    {x = 11150, y = 8460, z = 0},
    {x = 11200, y = 8420, z = 0},
}

-- Bidon d'essence valide releve en jeu
EE_Config.gasCan = {x = 11174, y = 8432, z = 4}

-- PLACEHOLDERS EE-15: cle et batterie cachees a ajuster en jeu
EE_Config.carKey = {x = 11601, y = 8681, z = 0}
EE_Config.carBattery = {x = 11520, y = 8405, z = 0}

-- PLACEHOLDER: remplacer par le vrai centre de la zone de coupure electrique
EE_Config.powerOutageCenter = {x = 11200, y = 8450, z = 0}
EE_Config.powerOutageRadius = 100
