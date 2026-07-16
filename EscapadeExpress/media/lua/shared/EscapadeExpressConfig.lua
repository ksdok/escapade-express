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

-- PLACEHOLDER: remplacer par les coords reelles du spawn arriere-boutique
EE_Config.spawn = {xcell = 37, ycell = 28, x = 120, y = 120, z = 0}

-- PLACEHOLDER: remplacer par les coords reelles du parking du mall
EE_Config.parking = {x = 11250, y = 8550, z = 0}

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

-- PLACEHOLDER: remplacer par la vraie position du bidon d'essence
EE_Config.gasCan = {x = 11170, y = 8490, z = 0}

-- PLACEHOLDER: remplacer par le vrai centre de la zone de coupure electrique
EE_Config.powerOutageCenter = {x = 11200, y = 8450, z = 0}
EE_Config.powerOutageRadius = 100

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
