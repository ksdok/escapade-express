-- ============================================================
-- ESCAPADE EXPRESS - Logique serveur (autorite MP)
-- Role assignment, items/skills, revive, vehicule, power, fire
-- ============================================================

require "EscapadeExpressConfig"

local Server = {
    playerSlots = {},
    roleLoadouts = {},
    selectionRoster = {},
    selectionConfirmed = {},
    selectionDenied = {},
    scenarioPrepared = false,
    escapeVehicle = nil,
    vehicleStartDetected = false,
    vehicleExploded = false,
    vehicleExplodeTickDelay = nil,
    vehicleExplodeTickCounter = 0,
    vehicleExplosionTickActive = false,
    gameStarted = false,
    gasCanSpawned = false,
    startTime = nil,
    powerOutageDone = false,
    fireDone = false,
    fireWarningDone = false,
    gameOver = false,
}

-- ============================================================
-- CONSTANTES
-- ============================================================

local PARKING_X = EE_Config.parking.x
local PARKING_Y = EE_Config.parking.y
local PARKING_Z = EE_Config.parking.z

local GAS_CAN_LOCATION = EE_Config.gasCan
local RESPAWN_X = EE_Config.respawn.x
local RESPAWN_Y = EE_Config.respawn.y
local RESPAWN_Z = EE_Config.respawn.z

local DURATION_HOURS = 3
local POWER_OUTAGE_TIME = 0.75
local FIRE_TIME = 2.0
local FIRE_WARNING_TIME = 1.9

local MALL_ENTRANCES = EE_Config.entrances
local SHOPS = EE_Config.shops
local POWER_OUTAGE_CENTER = EE_Config.powerOutageCenter
local POWER_OUTAGE_RADIUS = EE_Config.powerOutageRadius

local vehicleExplosionTick = nil

-- Roles: 16 roles uniques pour les slots prioritaires, Civil restant
-- selectionnable manuellement et attribuable en fallback automatique.
local ROLE_ORDER = {
    "soldat", "voleur", "local_", "medic",
    "rambo", "sniper", "samourai", "geek",
    "survivaliste", "pompier", "mecanicien", "athlete",
    "eclaireur", "demolisseur", "invincible", "mule",
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

-- ============================================================
-- DEFINITION DES ROLES (items + skills + equipement + stats)
-- ============================================================

local ROLE_DEFS = {
    soldat = {
        name = "Soldat",
        skills = {
            {Perks.Aiming, 4},
            {Perks.Reloading, 3},
            {Perks.Fitness, 4},
            {Perks.Strength, 4},
            {Perks.Sneak, 2},
        },
        items = {
            {"Base.Pistol", 1},
            {"Base.9mmClip", 2},
            {"Base.Bullets9mm", 30},
            {"Base.Bandage", 3},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.HoodieDOWN_WhiteTINT", 1},
            {"Base.Trousers", 1},
        },
        equipped = {
            primary = "Base.Pistol",
            clothes = {
                "Base.HoodieDOWN_WhiteTINT",
                "Base.Trousers",
            },
        },
    },
    voleur = {
        name = "Voleur",
        skills = {
            {Perks.Sneak, 5},
            {Perks.Lightfoot, 5},
            {Perks.Nimble, 5},
            {Perks.Electrical, 2},
            {Perks.Fitness, 3},
        },
        items = {
            {"Base.Crowbar", 1},
            {"Base.Screwdriver", 1},
            {"Base.Bandage", 2},
            {"Base.Torch", 1},
            {"Base.Battery", 1},
            {"Base.HoodieDOWN_WhiteTINT", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
        },
        equipped = {
            primary = "Base.Crowbar",
            clothes = {
                "Base.HoodieDOWN_WhiteTINT",
                "Base.Trousers",
                "Base.Shoes_Black",
            },
        },
    },
    local_ = {
        name = "Local",
        skills = {
            {Perks.Cooking, 4},
            {Perks.Carpentry, 4},
            {Perks.PlantScavenging, 3},
            {Perks.Fitness, 3},
            {Perks.Strength, 3},
        },
        items = {
            {"Base.Hammer", 1},
            {"Base.Nails", 20},
            {"Base.Saw", 1},
            {"Base.WaterBottleFull", 2},
            {"Base.TinnedBeans", 2},
            {"Base.TinOpener", 1},
            {"Base.Bandage", 2},
            {"Base.Bag_NormalHikingBag", 1},
            {"Base.Map", 1},
        },
        equipped = {
            primary = "Base.Hammer",
            bag = "Base.Bag_NormalHikingBag",
        },
    },
    medic = {
        name = "Medic",
        skills = {
            {Perks.Doctor, 6},
            {Perks.Fitness, 3},
            {Perks.Strength, 3},
            {Perks.Aiming, 2},
        },
        items = {
            {"Base.Bandage", 5},
            {"Base.Disinfectant", 2},
            {"Base.Pills", 2},
            {"Base.Antibiotics", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.Bag_DuffelBag", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
        },
        equipped = {
            bag = "Base.Bag_DuffelBag",
            clothes = {
                "Base.Trousers",
                "Base.Shoes_Black",
            },
        },
    },
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
        equipped = {
            primary = "Base.Axe",
            bag = "Base.Bag_NormalHikingBag",
            clothes = {
                "Base.Jacket_Black",
                "Base.Trousers",
                "Base.Shoes_Black",
            },
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
        equipped = {
            primary = "Base.HuntingRifle",
            bag = "Base.Bag_NormalHikingBag",
            clothes = {
                "Base.Jacket_ArmyCamoGreen",
                "Base.Trousers",
                "Base.Shoes_Black",
            },
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
        equipped = {
            primary = "Base.Katana",
            bag = "Base.Bag_NormalHikingBag",
            clothes = {
                "Base.HoodieDOWN_WhiteTINT",
                "Base.Trousers",
                "Base.Shoes_Black",
            },
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
        equipped = {
            primary = "Base.Screwdriver",
            bag = "Base.Bag_Schoolbag",
            clothes = {
                "Base.HoodieDOWN_WhiteTINT",
                "Base.Trousers",
                "Base.Shoes_Black",
            },
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
        equipped = {
            primary = "Base.HandAxe",
            bag = "Base.Bag_SurvivorBag",
            clothes = {
                "Base.Jacket_CoatArmy",
                "Base.Trousers",
                "Base.Shoes_Strapped",
            },
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
        equipped = {
            primary = "Base.Axe",
            bag = "Base.Bag_NormalHikingBag",
            clothes = {
                "Base.Hat_Fireman",
                "Base.Jacket_Fireman",
                "Base.Trousers_Fireman",
                "Base.Shoes_ArmyBoots",
            },
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
        equipped = {
            primary = "Base.Wrench",
            bag = "Base.Bag_NormalHikingBag",
            clothes = {
                "Base.Jacket_Black",
                "Base.Trousers",
                "Base.Shoes_ArmyBoots",
            },
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
        equipped = {
            primary = "Base.KitchenKnife",
            bag = "Base.Bag_NormalHikingBag",
            clothes = {
                "Base.HoodieDOWN_WhiteTINT",
                "Base.Trousers",
                "Base.Shoes_BlueTrainers",
            },
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
        equipped = {
            primary = "Base.Machete",
            bag = "Base.Bag_NormalHikingBag",
            clothes = {
                "Base.Jacket_ArmyCamoDesert",
                "Base.Trousers",
                "Base.Shoes_Strapped",
            },
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
        equipped = {
            primary = "Base.Sledgehammer",
            bag = "Base.Bag_BigHikingBag",
            clothes = {
                "Base.Jacket_Black",
                "Base.Trousers",
                "Base.Shoes_ArmyBoots",
            },
        },
        stats = { panic = 10, endurance = 0.4 },
    },
    invincible = {
        name = "Invincible",
        skills = {
            {Perks.Aiming, 10},
            {Perks.Reloading, 10},
            {Perks.Strength, 10},
            {Perks.Fitness, 10},
            {Perks.Sneak, 10},
            {Perks.Lightfoot, 10},
            {Perks.Nimble, 10},
            {Perks.Axe, 10},
            {Perks.Doctor, 10},
            {Perks.Carpentry, 10},
            {Perks.Mechanics, 10},
            {Perks.Electrical, 10},
            {Perks.Cooking, 10},
            {Perks.PlantScavenging, 10},
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
            {"Base.Map", 1},
            {"Base.Bag_ALICEpack_Army", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 3},
            {"Base.DuctTape", 2},
            {"Base.Rope", 1},
        },
        equipped = {
            primary = "Base.AssaultRifle",
            bag = "Base.Bag_ALICEpack_Army",
            clothes = {
                "Base.Hat_RiotHelmet",
                "Base.Jacket_CoatArmy",
                "Base.Trousers",
                "Base.Shoes_ArmyBoots",
            },
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
        equipped = {
            primary = "Base.Crowbar",
            bag = "Base.Bag_ALICEpack_Army",
            clothes = {
                "Base.Hat_Army",
                "Base.Jacket_CoatArmy",
                "Base.Trousers",
                "Base.Shoes_ArmyBoots",
            },
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
        equipped = {
            primary = "Base.KitchenKnife",
            bag = "Base.Bag_Schoolbag",
            clothes = {
                "Base.HoodieDOWN_WhiteTINT",
                "Base.Trousers",
                "Base.Shoes_Black",
            },
        },
        stats = { panic = 50, endurance = 0.2, fatigue = 0.15 },
    },
}

-- ============================================================
-- OUTILS SERVEUR
-- ============================================================

local function syncTimerToClients()
    if Server.startTime == nil then return end

    sendServerCommand("EscapadeExpress", "SyncTimer", {
        startTime = Server.startTime
    })
end

local function broadcastAlert(text, alertType)
    sendServerCommand("EscapadeExpress", "AlertMessage", {
        text = text,
        type = alertType
    })
end

local function isRoleSelectable(roleKey)
    if roleKey == "civil" then
        return true
    end

    for _, selectableRole in ipairs(ROLE_ORDER) do
        if selectableRole == roleKey then
            return true
        end
    end
    return false
end

local function equipRoleItems(player, inv, equipped)
    if player == nil or inv == nil or equipped == nil then return end

    if equipped.primary then
        local primary = inv:FindAndReturn(equipped.primary)
        if primary then
            player:setPrimaryHandItem(primary)
        end
    end

    if equipped.secondary then
        local secondary = inv:FindAndReturn(equipped.secondary)
        if secondary then
            player:setSecondaryHandItem(secondary)
        end
    end

    if equipped.bag then
        local bag = inv:FindAndReturn(equipped.bag)
        if bag then
            player:setClothingItem_Back(bag)
        end
    end

    if equipped.clothes then
        for _, clothId in ipairs(equipped.clothes) do
            local cloth = inv:FindAndReturn(clothId)
            if cloth and cloth:getBodyLocation() ~= nil then
                player:setWornItem(cloth:getBodyLocation(), cloth)
            end
        end
    end
end

local function applyRoleStats(player, stats)
    local playerStats = player:getStats()
    playerStats:setPanic(30)
    playerStats:setHunger(0.2)
    playerStats:setThirst(0.2)
    playerStats:setFatigue(0)

    if stats == nil then return end

    if stats.endurance ~= nil then
        playerStats:setEndurance(stats.endurance)
    end
    if stats.panic ~= nil then
        playerStats:setPanic(stats.panic)
    end
    if stats.fatigue ~= nil then
        playerStats:setFatigue(stats.fatigue)
    end
    if stats.hunger ~= nil then
        playerStats:setHunger(stats.hunger)
    end
    if stats.thirst ~= nil then
        playerStats:setThirst(stats.thirst)
    end
end

local function grantCivilRole(player)
    local username = player and player:getUsername() or nil
    if username ~= nil then
        Server.playerSlots[username] = "civil"
        Server.selectionConfirmed[username] = "civil"
        Server.selectionDenied[username] = nil
    end
    return "civil"
end

-- ============================================================
-- ASSIGNATION ET APPLICATION DES ROLES
-- ============================================================

local function getAssignedRole(username)
    if username == nil then return nil end
    return Server.playerSlots[username]
end

local function isRoleTaken(roleKey, exceptUsername)
    for username, takenRole in pairs(Server.playerSlots) do
        if takenRole ~= "civil" and username ~= exceptUsername and takenRole == roleKey then
            return true, username
        end
    end

    return false, nil
end

local function hasFreeRole(exceptUsername)
    for _, roleKey in ipairs(ROLE_ORDER) do
        local taken = isRoleTaken(roleKey, exceptUsername)
        if not taken then
            return true
        end
    end

    return false
end

local function buildRolePickerState()
    local result = {}

    for _, roleKey in ipairs(ROLE_ORDER) do
        local taken, username = isRoleTaken(roleKey)
        result[roleKey] = {
            taken = taken,
            takenBy = username,
        }
    end

    result.civil = {
        taken = false,
        takenBy = nil,
    }

    return result
end

local function broadcastRolePickerState()
    sendServerCommand("EscapadeExpress", "SyncRolePickerState", {
        roleStates = buildRolePickerState()
    })
end

local function markSelectionDenied(username)
    if username == nil then return end
    Server.selectionDenied[username] = true
    Server.selectionConfirmed[username] = nil
end

local function markSelectionConfirmed(username, roleKey)
    if username == nil then return end
    Server.selectionConfirmed[username] = roleKey
    Server.selectionDenied[username] = nil
end

local function addPlayerToInitialRoster(username)
    if username == nil or Server.gameStarted then return end
    Server.selectionRoster[username] = true
end

local function maybeStartScenarioTimer()
    if not Server.scenarioPrepared or Server.gameStarted then
        return false
    end

    for username, _ in pairs(Server.selectionRoster) do
        if not Server.selectionConfirmed[username] and not Server.selectionDenied[username] then
            return false
        end
    end

    if next(Server.selectionRoster) == nil then
        return false
    end

    Server.gameStarted = true
    Server.gameOver = false
    Server.powerOutageDone = false
    Server.fireDone = false
    Server.fireWarningDone = false
    Server.startTime = getGameTime():getWorldAgeHours()

    print("[EE] Timer du scenario demarre, startTime=" .. tostring(Server.startTime))
    syncTimerToClients()
    return true
end

local function isPassivePerk(perk)
    return perk == Perks.Strength or perk == Perks.Fitness
end

local function applyPerkLevel(player, perk, level)
    if player == nil or perk == nil or level == nil then return end

    local xp = player:getXp()
    xp:setXPToLevel(perk, level)

    if isPassivePerk(perk) and player.setPerkLevelDebug ~= nil then
        player:setPerkLevelDebug(perk, level)
    end

    if player.getPerkLevel ~= nil then
        local currentLevel = player:getPerkLevel(perk)

        if currentLevel ~= nil and player.LevelPerk ~= nil then
            while currentLevel < level do
                player:LevelPerk(perk, false)
                currentLevel = currentLevel + 1
            end
        end

        if currentLevel ~= nil and player.LoseLevel ~= nil then
            while currentLevel > level do
                player:LoseLevel(perk)
                currentLevel = currentLevel - 1
            end
        end
    end

    xp:setXPToLevel(perk, level)
end

local function applyRole(player, roleKey)
    local def = ROLE_DEFS[roleKey]
    if not def then return false end

    local username = player:getUsername()
    local modData = player:getModData()
    modData.EE_role = roleKey
    modData.EE_reviveEnabled = true

    if username ~= nil and Server.roleLoadouts[username] == roleKey then
        return false
    end

    local inv = player:getInventory()

    for _, itemDef in ipairs(def.items) do
        local itemId, count = itemDef[1], itemDef[2]
        if count > 1 then
            inv:AddItems(itemId, count)
        else
            inv:AddItem(itemId)
        end
    end

    for _, skillDef in ipairs(def.skills) do
        local perk, level = skillDef[1], skillDef[2]
        applyPerkLevel(player, perk, level)
    end

    equipRoleItems(player, inv, def.equipped)
    applyRoleStats(player, def.stats)

    if username ~= nil then
        Server.roleLoadouts[username] = roleKey
    end

    return true
end

-- ============================================================
-- SPAWN DU VEHICULE D'ESCAPE
-- ============================================================

local function spawnEscapeVehicle()
    if Server.escapeVehicle ~= nil then return end

    local sq = getCell():getGridSquare(PARKING_X, PARKING_Y, PARKING_Z)
    if sq == nil then
        print("[EE] ERREUR: Impossible de trouver le square du parking")
        return
    end

    local car = addVehicleDebug("Base.Van", IsoDirections.E, nil, sq)
    if car == nil then
        print("[EE] ERREUR: Impossible de spawner le vehicule")
        return
    end

    car:repair()

    local gasTank = car:getPartById("GasTank")
    if gasTank then
        gasTank:setContainerContentAmount(0)
    end

    Server.escapeVehicle = car
    print("[EE] Vehicule d'escape spawn au parking (" .. PARKING_X .. "," .. PARKING_Y .. ")")
end

local function unregisterVehicleExplosionTick()
    if not Server.vehicleExplosionTickActive or vehicleExplosionTick == nil then return end

    Events.OnTick.Remove(vehicleExplosionTick)
    Server.vehicleExplosionTickActive = false
end

local function explodeEscapeVehicle()
    if Server.vehicleExploded then return false end

    unregisterVehicleExplosionTick()
    Server.vehicleExplodeTickDelay = nil
    Server.vehicleExplodeTickCounter = 0

    if Server.escapeVehicle == nil then
        Server.vehicleExploded = true
        print("[EE] WARNING: Aucun vehicule d'escape a faire exploser")
        return false
    end

    local sq = Server.escapeVehicle:getSquare()
    if sq == nil then
        Server.vehicleExploded = true
        print("[EE] WARNING: Impossible de trouver le square du vehicule d'escape")
        return false
    end

    Server.vehicleExploded = true
    IsoFireManager.explode(getCell(), sq, 50)
    broadcastAlert("LE VEHICULE EXPLOSE!", "danger")
    print("[EE] Vehicule d'escape explose")
    return true
end

vehicleExplosionTick = function()
    if Server.vehicleExploded or not Server.vehicleStartDetected or Server.vehicleExplodeTickDelay == nil then
        unregisterVehicleExplosionTick()
        return
    end

    Server.vehicleExplodeTickCounter = Server.vehicleExplodeTickCounter + 1
    if Server.vehicleExplodeTickCounter >= Server.vehicleExplodeTickDelay then
        explodeEscapeVehicle()
    end
end

local function scheduleEscapeVehicleExplosion()
    if Server.escapeVehicle == nil then return false end
    if Server.vehicleStartDetected or Server.vehicleExploded then return false end

    local delayTicks = ZombRand(120, 181)
    Server.vehicleStartDetected = true
    Server.vehicleExplodeTickDelay = delayTicks
    Server.vehicleExplodeTickCounter = 0

    if not Server.vehicleExplosionTickActive then
        Events.OnTick.Add(vehicleExplosionTick)
        Server.vehicleExplosionTickActive = true
    end

    broadcastAlert("Le moteur s'etouffe...", "warning")
    print("[EE] Explosion du vehicule programmee dans " .. tostring(delayTicks) .. " ticks")
    return true
end

-- ============================================================
-- SPAWN DU BIDON D'ESSENCE
-- ============================================================

local function spawnGasCan()
    if Server.gasCanSpawned then return end

    local sq = getCell():getGridSquare(GAS_CAN_LOCATION.x, GAS_CAN_LOCATION.y, GAS_CAN_LOCATION.z)
    if sq == nil then
        print("[EE] ERREUR: Impossible de trouver le square du bidon d'essence")
        return
    end

    sq:AddWorldInventoryItem("Base.PetrolCan", 0.5, 0.5, 0.0)
    Server.gasCanSpawned = true
    print("[EE] Bidon d'essence spawn (" .. GAS_CAN_LOCATION.x .. "," .. GAS_CAN_LOCATION.y .. ")")
end

-- ============================================================
-- INITIALISATION DU SCENARIO
-- ============================================================

local function resetScenarioState()
    unregisterVehicleExplosionTick()

    Server.playerSlots = {}
    Server.roleLoadouts = {}
    Server.selectionRoster = {}
    Server.selectionConfirmed = {}
    Server.selectionDenied = {}
    Server.scenarioPrepared = false
    Server.escapeVehicle = nil
    Server.vehicleStartDetected = false
    Server.vehicleExploded = false
    Server.vehicleExplodeTickDelay = nil
    Server.vehicleExplodeTickCounter = 0
    Server.vehicleExplosionTickActive = false
    Server.gameStarted = false
    Server.gasCanSpawned = false
    Server.startTime = nil
    Server.powerOutageDone = false
    Server.fireDone = false
    Server.fireWarningDone = false
    Server.gameOver = false
end

local function prepareScenario()
    if Server.scenarioPrepared then return false end

    if SandboxVars ~= nil then
        SandboxVars.DayLength = 26
    end

    if getGameTime ~= nil then
        local gameTime = getGameTime()
        if gameTime ~= nil and gameTime.setMinutesPerDay ~= nil then
            gameTime:setMinutesPerDay(60 * 24)
        end
    end

    Server.scenarioPrepared = true
    Server.gameOver = false
    Server.startTime = nil

    spawnEscapeVehicle()
    spawnGasCan()

    print("[EE] Scenario prepare, en attente du choix des roles")
    return true
end

-- ============================================================
-- COUPURE ELECTRIQUE (serveur = autorite)
-- ============================================================

local function cutPower()
    print("[EE] Coupure electrique!")

    local centerX = POWER_OUTAGE_CENTER.x
    local centerY = POWER_OUTAGE_CENTER.y
    local radius = POWER_OUTAGE_RADIUS

    for dx = -radius, radius do
        for dy = -radius, radius do
            local sq = getCell():getGridSquare(centerX + dx, centerY + dy, 0)
            if sq then
                sq:setHaveElectricity(false)
            end
        end

        for dy2 = -radius, radius do
            local sq1 = getCell():getGridSquare(centerX + dx, centerY + dy2, 1)
            if sq1 then
                sq1:setHaveElectricity(false)
            end
        end
    end

    broadcastAlert("COUPURE DE COURANT! Les lumieres sont eteintes.", "warning")
end

-- ============================================================
-- INCENDIE (serveur = autorite)
-- ============================================================

local function startFire(data)
    local sq = getCell():getGridSquare(data.x, data.y, data.z)
    if sq == nil then return end

    print("[EE] Incendie demarre a (" .. data.x .. "," .. data.y .. ")")
    IsoFireManager.StartFire(getCell(), sq, true, 100)

    addSound(nil, data.x, data.y, data.z, 100, 200)
    broadcastAlert("INCENDIE! Le feu se propage dans le mall!", "danger")
end

-- ============================================================
-- SPAWN ZOMBIES (serveur = autorite)
-- ============================================================

local function spawnZombies(data)
    local count = data.count or 5
    local sq = getCell():getGridSquare(data.x, data.y, data.z)
    if sq == nil then return end

    addZombiesInOutfit(data.x, data.y, data.z, count, nil, 0)
    print("[EE] " .. count .. " zombies spawn a (" .. data.x .. "," .. data.y .. ")")
end

-- ============================================================
-- GAME OVER (horde massive)
-- ============================================================

local function triggerGameOver()
    if Server.gameOver then return end

    Server.gameOver = true
    print("[EE] GAME OVER - horde massive!")

    for _, ent in ipairs(MALL_ENTRANCES) do
        local sq = getCell():getGridSquare(ent.x, ent.y, ent.z)
        if sq then
            addZombiesInOutfit(ent.x, ent.y, ent.z, 50, nil, 0)
        end
    end

    sendServerCommand("EscapadeExpress", "GameOver", {})
    broadcastAlert("TEMPS ECOULE! Les zombies envahissent tout!", "danger")
end

-- ============================================================
-- REVIVE - MONITORING DES JOUEURS A TERRE
-- ============================================================

local REVIVE_TIME_MEDIC = 30 / 3600
local REVIVE_TIME_OTHER = 1 / 60
local REVIVE_HEALTH = 0.5
local RESPAWN_HEALTH = 0.3
local REVIVE_RADIUS = 10

local function getScenarioPlayers()
    local result = {}

    if getOnlinePlayers ~= nil then
        local onlinePlayers = getOnlinePlayers()
        if onlinePlayers ~= nil and onlinePlayers:size() > 0 then
            for i = 0, onlinePlayers:size() - 1 do
                result[#result + 1] = onlinePlayers:get(i)
            end
            return result
        end
    end

    if getPlayer ~= nil then
        local singlePlayer = getPlayer()
        if singlePlayer ~= nil then
            result[#result + 1] = singlePlayer
        end
    end

    return result
end

local function markPlayerDowned(player, x, y, z)
    local modData = player:getModData()
    if modData.EE_downed then
        return false
    end

    modData.EE_downed = true
    modData.EE_downTime = getGameTime():getWorldAgeHours()
    modData.EE_downX = x ~= nil and x or player:getX()
    modData.EE_downY = y ~= nil and y or player:getY()
    modData.EE_downZ = z ~= nil and z or player:getZ()

    player:setKnockedDown(true)
    player:setDoDeathSound(false)
    player:setHealth(0.01)

    print("[EE] " .. player:getUsername() .. " est a terre!")
    sendServerCommand("EscapadeExpress", "PlayerDown", {
        username = player:getUsername()
    })

    return true
end

local function getNearbyReviverType(downedPlayer, radius)
    radius = radius or REVIVE_RADIUS
    local hasOtherNearby = false

    for _, p in ipairs(getScenarioPlayers()) do
        if p:getUsername() ~= downedPlayer:getUsername() then
            local otherData = p:getModData()
            if not otherData.EE_downed then
                local dx = math.abs(p:getX() - downedPlayer:getX())
                local dy = math.abs(p:getY() - downedPlayer:getY())
                if dx <= radius and dy <= radius then
                    local role = otherData.EE_role
                    if role == "medic" then
                        return "medic"
                    end
                    hasOtherNearby = true
                end
            end
        end
    end

    if hasOtherNearby then
        return "other"
    end

    return nil
end

local function clearDownedState(player)
    local modData = player:getModData()
    modData.EE_downed = false
    modData.EE_downTime = nil
    modData.EE_downX = nil
    modData.EE_downY = nil
    modData.EE_downZ = nil
end

local function revivePlayer(player, reviverType)
    player:setHealth(REVIVE_HEALTH)
    player:setKnockedDown(false)
    clearDownedState(player)

    print("[EE] " .. player:getUsername() .. " est ranime (" .. reviverType .. ")")
    sendServerCommand("EscapadeExpress", "PlayerRevived", {
        username = player:getUsername(),
        reviverType = reviverType
    })
end

local function respawnPlayerAtStart(player)
    player:setHealth(RESPAWN_HEALTH)
    player:setKnockedDown(false)
    player:setX(RESPAWN_X)
    player:setY(RESPAWN_Y)
    player:setZ(RESPAWN_Z)
    clearDownedState(player)

    print("[EE] " .. player:getUsername() .. " respawn au depart")
    sendServerCommand("EscapadeExpress", "PlayerRespawned", {
        username = player:getUsername()
    })
end

local function checkDownedPlayers()
    for _, p in ipairs(getScenarioPlayers()) do
        local modData = p:getModData()

        if not modData.EE_downed and p:getHealth() < 0.15 and modData.EE_reviveEnabled then
            markPlayerDowned(p)
        end

        if modData.EE_downed and modData.EE_downTime then
            local elapsed = getGameTime():getWorldAgeHours() - modData.EE_downTime
            local reviverType = getNearbyReviverType(p)

            if reviverType == "medic" and elapsed >= REVIVE_TIME_MEDIC then
                revivePlayer(p, reviverType)
            elseif elapsed >= REVIVE_TIME_OTHER then
                if reviverType == "medic" or reviverType == "other" then
                    revivePlayer(p, reviverType)
                else
                    respawnPlayerAtStart(p)
                end
            end
        end
    end
end

-- ============================================================
-- MONITORING PERIODIQUE DES EVENTS
-- ============================================================

local function serverEveryMinutes()
    if Server.startTime == nil or Server.gameOver then return end

    local elapsed = getGameTime():getWorldAgeHours() - Server.startTime

    if not Server.powerOutageDone and elapsed >= POWER_OUTAGE_TIME then
        Server.powerOutageDone = true
        cutPower()
    end

    if not Server.fireWarningDone and elapsed >= FIRE_WARNING_TIME then
        Server.fireWarningDone = true
        broadcastAlert("Je sens de la fumee...", "warning")
    end

    if not Server.fireDone and elapsed >= FIRE_TIME then
        Server.fireDone = true
        local shop = SHOPS[ZombRand(#SHOPS) + 1]
        startFire({x = shop.x, y = shop.y, z = shop.z})
    end

    if elapsed >= DURATION_HOURS then
        triggerGameOver()
    end
end

local function serverEveryHours()
    if Server.startTime == nil or Server.gameOver then return end

    local elapsed = getGameTime():getWorldAgeHours() - Server.startTime
    local count = 3

    if elapsed >= 1 then count = 10 end
    if elapsed >= 2 then count = 25 end

    for _, entrance in ipairs(MALL_ENTRANCES) do
        spawnZombies({
            x = entrance.x,
            y = entrance.y,
            z = entrance.z,
            count = count,
        })
    end
end

-- ============================================================
-- GAME START
-- ============================================================

local function onGameStart()
    resetScenarioState()
    prepareScenario()
end
Events.OnGameStart.Add(onGameStart)

Events.EveryOneMinute.Add(checkDownedPlayers)
Events.EveryOneMinute.Add(serverEveryMinutes)
Events.EveryHours.Add(serverEveryHours)

-- ============================================================
-- RECEPTION COMMANDES CLIENT
-- ============================================================

local function onClientCommand(module, command, player, data)
    if module ~= "EscapadeExpress" then return end

    if command == "RolePickerReady" then
        prepareScenario()

        local username = player:getUsername()
        local assignedRole = getAssignedRole(username)

        if assignedRole ~= nil then
            markSelectionConfirmed(username, assignedRole)
            applyRole(player, assignedRole)

            sendServerCommand("EscapadeExpress", "RoleAssigned", {
                username = username,
                role = assignedRole,
                roleName = ROLE_NAMES[assignedRole] or assignedRole
            })

            if Server.gameStarted then
                syncTimerToClients()
            else
                maybeStartScenarioTimer()
            end
            return
        end

        if not Server.gameStarted then
            addPlayerToInitialRoster(username)
        end

        if not hasFreeRole(username) then
            local fallbackRole = grantCivilRole(player)
            local loadoutGranted = applyRole(player, fallbackRole)
            if loadoutGranted then
                print("[EE] Fallback Civil assigne: " .. tostring(username))
            else
                print("[EE] Fallback Civil resynchronise: " .. tostring(username))
            end

            sendServerCommand("EscapadeExpress", "RoleAssigned", {
                username = username,
                role = fallbackRole,
                roleName = ROLE_NAMES[fallbackRole] or fallbackRole
            })

            if Server.gameStarted then
                syncTimerToClients()
            else
                maybeStartScenarioTimer()
            end
            return
        end

        sendServerCommand("EscapadeExpress", "OpenRolePicker", {
            username = username,
            roleStates = buildRolePickerState()
        })
        broadcastRolePickerState()

    elseif command == "ChooseRole" then
        prepareScenario()

        local username = player:getUsername()
        local roleKey = data and data.roleKey or nil

        if roleKey == nil or ROLE_DEFS[roleKey] == nil or not isRoleSelectable(roleKey) then
            sendServerCommand("EscapadeExpress", "RoleUnavailable", {
                username = username,
                roleKey = roleKey,
                text = "Role invalide.",
                roleStates = buildRolePickerState()
            })
            return
        end

        local assignedRole = getAssignedRole(username)
        if assignedRole ~= nil then
            applyRole(player, assignedRole)
            sendServerCommand("EscapadeExpress", "RoleAssigned", {
                username = username,
                role = assignedRole,
                roleName = ROLE_NAMES[assignedRole] or assignedRole
            })
            if Server.gameStarted then
                syncTimerToClients()
            else
                maybeStartScenarioTimer()
            end
            return
        end

        if not Server.gameStarted then
            addPlayerToInitialRoster(username)
        end

        local taken, takenBy = isRoleTaken(roleKey, username)
        if taken then
            sendServerCommand("EscapadeExpress", "RoleUnavailable", {
                username = username,
                roleKey = roleKey,
                text = "Ce role vient d'etre pris par " .. tostring(takenBy) .. ".",
                roleStates = buildRolePickerState()
            })
            return
        end

        Server.playerSlots[username] = roleKey
        markSelectionConfirmed(username, roleKey)

        local loadoutGranted = applyRole(player, roleKey)
        if loadoutGranted then
            print("[EE] Role assigne: " .. tostring(username) .. " = " .. (ROLE_NAMES[roleKey] or roleKey))
        else
            print("[EE] Role resynchronise: " .. tostring(username) .. " = " .. (ROLE_NAMES[roleKey] or roleKey))
        end

        sendServerCommand("EscapadeExpress", "RoleAssigned", {
            username = username,
            role = roleKey,
            roleName = ROLE_NAMES[roleKey] or roleKey
        })
        broadcastRolePickerState()

        if Server.gameStarted then
            syncTimerToClients()
        else
            maybeStartScenarioTimer()
        end

    elseif command == "VehicleStarted" then
        if Server.escapeVehicle == nil or Server.vehicleStartDetected or Server.vehicleExploded then
            return
        end

        local vehicle = player and player:getVehicle() or nil
        if vehicle == nil or vehicle ~= Server.escapeVehicle then
            return
        end

        scheduleEscapeVehicleExplosion()
    elseif command == "PlayerDown" then
        local downX = data and data.x or nil
        local downY = data and data.y or nil
        local downZ = data and data.z or nil
        markPlayerDowned(player, downX, downY, downZ)
    end
end
Events.OnClientCommand.Add(onClientCommand)
