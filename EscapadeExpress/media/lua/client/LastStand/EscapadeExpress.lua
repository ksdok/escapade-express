-- ============================================================
-- ESCAPADE EXPRESS - Scenario principal (client/LastStand)
-- Sortie du Xonic's Mega Mall en 3h, scenario coop B41
-- Base sur le pattern Pillow's Random Scenarios
-- ============================================================

require "EscapadeExpressShared"
require "EscapadeExpressConfig"

EscapadeExpress = {}

-- ============================================================
-- COORDONNEES (source shared unique)
-- Toutes les valeurs reelles/placeholders vivent dans EE_Config.
-- ============================================================

local SPAWN = EE_Config.spawn
local SPAWN_TILES = EE_Config.spawnTiles or {SPAWN}
local PARKING = EE_Config.parking

-- ============================================================
-- CONSTANTES DU SCENARIO
-- ============================================================

local DURATION_HOURS = 3

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
    builder = "Builder",
    civil = "Civil",
}

local ROLE_DEFS = {
    soldat = {
        skills = {
            {Perks.Aiming, 9},
            {Perks.Reloading, 10},
            {Perks.Lightfoot, 5},
            {Perks.Nimble, 9},
            {Perks.Sneak, 4},
            {Perks.Strength, 7},
            {Perks.Fitness, 7},
            {Perks.SmallBlade, 8},
            {Perks.LongBlade, 7},
            {Perks.Sprinting, 4},
        },
        items = {
            {"Base.Pistol", 1},
            {"Base.HuntingKnife", 1},
            {"Base.9mmClip", 2},
            {"Base.Bullets9mm", 30},
            {"Base.Bandage", 3},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.WaterBottleFull", 1},
            {"Base.Bag_DuffelBag", 1},
            {"Base.HoodieDOWN_WhiteTINT", 1},
            {"Base.Trousers", 1},
        },
        bagContents = {
            {"Base.Bandage", 3},
            {"Base.WaterBottleFull", 1},
        },
        equipped = {
            primary = "Base.Pistol",
            secondary = "Base.HuntingKnife",
            bag = "Base.Bag_DuffelBag",
            clothes = {
                "Base.HoodieDOWN_WhiteTINT",
                "Base.Trousers",
            },
        },
    },
    voleur = {
        skills = {
            {Perks.Lightfoot, 8},
            {Perks.Nimble, 6},
            {Perks.Sneak, 9},
            {Perks.Strength, 3},
            {Perks.Fitness, 7},
            {Perks.SmallBlade, 8},
            {Perks.SmallBlunt, 7},
            {Perks.LongBlunt, 7},
            {Perks.Sprinting, 6},
        },
        items = {
            {"Base.Crowbar", 1},
            {"Base.Screwdriver", 1},
            {"Base.Bandage", 2},
            {"Base.Torch", 1},
            {"Base.Battery", 1},
            {"Base.WaterBottleFull", 1},
            {"Base.Bag_Schoolbag", 1},
            {"Base.HoodieDOWN_WhiteTINT", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
        },
        bagContents = {
            {"Base.Bandage", 2},
            {"Base.WaterBottleFull", 1},
        },
        equipped = {
            primary = "Base.Crowbar",
            bag = "Base.Bag_Schoolbag",
            clothes = {
                "Base.HoodieDOWN_WhiteTINT",
                "Base.Trousers",
                "Base.Shoes_Black",
            },
        },
    },
    local_ = {
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
            {"Base.Torch", 1},
            {"Base.Battery", 1},
            {"Base.Bag_NormalHikingBag", 1},
            {"Base.Map", 1},
        },
        bagContents = {
            {"Base.WaterBottleFull", 2},
            {"Base.TinnedBeans", 2},
            {"Base.TinOpener", 1},
            {"Base.Bandage", 2},
            {"Base.Map", 1},
        },
        equipped = {
            primary = "Base.Hammer",
            bag = "Base.Bag_NormalHikingBag",
        },
    },
    medic = {
        skills = {
            {Perks.Doctor, 10},
            {Perks.Fitness, 6},
            {Perks.Lightfoot, 5},
            {Perks.Strength, 4},
            {Perks.Sneak, 3},
            {Perks.Nimble, 5},
            {Perks.Sprinting, 3},
        },
        items = {
            {"Base.KitchenKnife", 1},
            {"Base.Bandage", 5},
            {"Base.Disinfectant", 2},
            {"Base.Pills", 2},
            {"Base.Antibiotics", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.WaterBottleFull", 1},
            {"Base.Bag_DuffelBag", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_Black", 1},
        },
        bagContents = {
            {"Base.Bandage", 5},
            {"Base.Disinfectant", 2},
            {"Base.Pills", 2},
            {"Base.Antibiotics", 1},
            {"Base.WaterBottleFull", 1},
        },
        equipped = {
            primary = "Base.KitchenKnife",
            bag = "Base.Bag_DuffelBag",
            clothes = {
                "Base.Trousers",
                "Base.Shoes_Black",
            },
        },
    },
    rambo = {
        skills = {
            {Perks.Strength, 10},
            {Perks.Fitness, 9},
            {Perks.Axe, 9},
            {Perks.Sneak, 0},
            {Perks.Lightfoot, 0},
            {Perks.Nimble, 10},
            {Perks.Reloading, 7},
            {Perks.Aiming, 8},
            {Perks.LongBlade, 8},
            {Perks.SmallBlade, 8},
            {Perks.LongBlunt, 8},
            {Perks.SmallBlunt, 8},
            {Perks.Spear, 8},
            {Perks.PlantScavenging, 8},
            {Perks.Sprinting, 7},
        },
        items = {
            {"Base.Axe", 1},
            {"Base.SpearMachete", 1},
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
        bagContents = {
            {"Base.Bandage", 4},
            {"Base.WaterBottleFull", 1},
        },
        equipped = {
            primary = "Base.Axe",
            secondary = "Base.SpearMachete",
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
        skills = {
            {Perks.Aiming, 9},
            {Perks.Reloading, 8},
            {Perks.Sneak, 8},
            {Perks.Lightfoot, 6},
            {Perks.Nimble, 5},
            {Perks.Strength, 5},
            {Perks.Fitness, 5},
            {Perks.Sprinting, 4},
        },
        items = {
            {"Base.HuntingRifle", 1},
            {"Base.308Clip", 1},
            {"Base.308Bullets", 50},
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
        bagContents = {
            {"Base.Bandage", 2},
            {"Base.WaterBottleFull", 1},
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
        skills = {
            {Perks.Fitness, 8},
            {Perks.Strength, 9},
            {Perks.Nimble, 10},
            {Perks.Sneak, 5},
            {Perks.Lightfoot, 8},
            {Perks.Sprinting, 4},
            {Perks.LongBlade, 10},
            {Perks.SmallBlade, 10},
            {Perks.Spear, 10},
            {Perks.Doctor, 6},
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
        bagContents = {
            {"Base.Bandage", 3},
            {"Base.WaterBottleFull", 1},
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
        skills = {
            {Perks.Electrical, 8},
            {Perks.Mechanics, 8},
            {Perks.Nimble, 3},
            {Perks.Strength, 2},
            {Perks.Fitness, 3},
            {Perks.Aiming, 3},
            {Perks.Reloading, 3},
            {Perks.Sneak, 10},
            {Perks.Lightfoot, 8},
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
        bagContents = {
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
        skills = {
            {Perks.PlantScavenging, 7},
            {Perks.Trapping, 10},
            {Perks.Fishing, 8},
            {Perks.Carpentry, 8},
            {Perks.Cooking, 7},
            {Perks.Fitness, 7},
            {Perks.Strength, 7},
            {Perks.Sneak, 7},
            {Perks.Lightfoot, 5},
            {Perks.Aiming, 6},
            {Perks.Reloading, 6},
        },
        items = {
            {"Base.HuntingRifle", 1},
            {"Base.308Clip", 1},
            {"Base.308Bullets", 40},
            {"Base.x4Scope", 1},
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
            {"Base.Bag_ALICEpack", 1},
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
        bagContents = {
            {"Base.308Bullets", 40},
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
            {"Base.BookTrapping1", 1},
            {"Base.BookFishing1", 1},
            {"Base.Rope", 1},
            {"Base.DuctTape", 1},
        },
        equipped = {
            primary = "Base.HuntingRifle",
            secondary = "Base.HandAxe",
            bag = "Base.Bag_ALICEpack",
            clothes = {
                "Base.Jacket_CoatArmy",
                "Base.Trousers",
                "Base.Shoes_Strapped",
            },
        },
        stats = { panic = 15, endurance = 0.4 },
    },
    pompier = {
        skills = {
            {Perks.Fitness, 7},
            {Perks.Strength, 7},
            {Perks.Axe, 9},
            {Perks.Doctor, 8},
            {Perks.Nimble, 8},
            {Perks.Aiming, 6},
            {Perks.Reloading, 4},
            {Perks.Sneak, 2},
            {Perks.Lightfoot, 3},
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
            {"Base.Disinfectant", 1},
            {"Base.Pills", 1},
            {"Base.WaterBottleFull", 2},
            {"Base.Bag_ALICEpack", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.Hammer", 1},
            {"Base.Crowbar", 1},
        },
        bagContents = {
            {"Base.Bandage", 4},
            {"Base.AlcoholWipes", 2},
            {"Base.Splint", 1},
            {"Base.Disinfectant", 1},
            {"Base.Pills", 1},
            {"Base.WaterBottleFull", 2},
        },
        equipped = {
            primary = "Base.Axe",
            secondary = "Base.Extinguisher",
            bag = "Base.Bag_ALICEpack",
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
        skills = {
            {Perks.Mechanics, 10},
            {Perks.Electrical, 6},
            {Perks.Carpentry, 4},
            {Perks.Fitness, 5},
            {Perks.Strength, 5},
            {Perks.Nimble, 5},
            {Perks.Aiming, 3},
            {Perks.Reloading, 3},
            {Perks.Sneak, 2},
            {Perks.Lightfoot, 2},
        },
        items = {
            {"Base.Wrench", 1},
            {"Base.Crowbar", 1},
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
            {"Base.Bag_ALICEpack", 1},
            {"Base.Jacket_Black", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_ArmyBoots", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
        },
        bagContents = {
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
        },
        equipped = {
            primary = "Base.Crowbar",
            secondary = "Base.Wrench",
            bag = "Base.Bag_ALICEpack",
            clothes = {
                "Base.Jacket_Black",
                "Base.Trousers",
                "Base.Shoes_ArmyBoots",
            },
        },
        stats = { panic = 25, fatigue = 0.05 },
    },
    athlete = {
        skills = {
            {Perks.Fitness, 10},
            {Perks.Strength, 5},
            {Perks.Nimble, 8},
            {Perks.Lightfoot, 8},
            {Perks.Sneak, 5},
            {Perks.Sprinting, 10},
            {Perks.Aiming, 3},
            {Perks.Reloading, 2},
        },
        items = {
            {"Base.KitchenKnife", 1},
            {"Base.Bandage", 2},
            {"Base.WaterBottleFull", 2},
            {"Base.GranolaBar", 3},
            {"Base.PillsVitamins", 1},
            {"Base.Bag_Schoolbag", 1},
            {"Base.HoodieDOWN_WhiteTINT", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_BlueTrainers", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 1},
        },
        bagContents = {
            {"Base.WaterBottleFull", 2},
            {"Base.GranolaBar", 3},
            {"Base.PillsVitamins", 1},
        },
        equipped = {
            primary = "Base.KitchenKnife",
            bag = "Base.Bag_Schoolbag",
            clothes = {
                "Base.HoodieDOWN_WhiteTINT",
                "Base.Trousers",
                "Base.Shoes_BlueTrainers",
            },
        },
        stats = { endurance = 0.85, panic = 20, fatigue = 0 },
    },
    eclaireur = {
        skills = {
            {Perks.Sneak, 10},
            {Perks.Lightfoot, 10},
            {Perks.Nimble, 8},
            {Perks.PlantScavenging, 7},
            {Perks.Fitness, 6},
            {Perks.Strength, 7},
            {Perks.Sprinting, 9},
            {Perks.Aiming, 4},
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
        bagContents = {
            {"Base.Map", 1},
            {"Base.x4Scope", 1},
            {"Base.WaterBottleFull", 1},
            {"Base.GranolaBar", 2},
            {"Base.Bandage", 2},
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
        skills = {
            {Perks.Strength, 10},
            {Perks.Fitness, 6},
            {Perks.Sprinting, 6},
            {Perks.Electrical, 8},
            {Perks.Mechanics, 7},
            {Perks.Aiming, 5},
            {Perks.Reloading, 4},
            {Perks.Nimble, 4},
            {Perks.Sneak, 1},
            {Perks.Lightfoot, 1},
        },
        items = {
            {"Base.PipeBomb", 10},
            {"Base.PipeBombTriggered", 6},
            {"Base.Aerosolbomb", 10},
            {"Base.AerosolbombTriggered", 6},
            {"Base.Molotov", 8},
            {"Base.SmokeBomb", 3},
            {"Base.Sledgehammer", 1},
            {"Base.DuctTape", 2},
            {"Base.ScrapMetal", 3},
            {"Base.Wire", 2},
            {"Base.ElectronicsScrap", 3},
            {"Base.PropaneTank", 1},
            {"Base.Bandage", 3},
            {"Base.WaterBottleFull", 1},
            {"Base.Bag_ALICEpack", 1},
            {"Base.Jacket_Black", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_ArmyBoots", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.Lighter", 1},
        },
        bagContents = {
            {"Base.PipeBomb", 10},
            {"Base.PipeBombTriggered", 6},
            {"Base.Aerosolbomb", 10},
            {"Base.AerosolbombTriggered", 6},
            {"Base.Molotov", 8},
            {"Base.SmokeBomb", 3},
        },
        equipped = {
            primary = "Base.Sledgehammer",
            bag = "Base.Bag_ALICEpack",
            clothes = {
                "Base.Jacket_Black",
                "Base.Trousers",
                "Base.Shoes_ArmyBoots",
            },
        },
        stats = { panic = 10, endurance = 0.4 },
    },
    invincible = {
        skills = {
            {Perks.Aiming, 10},
            {Perks.Reloading, 10},
            {Perks.Strength, 10},
            {Perks.Fitness, 10},
            {Perks.Sneak, 10},
            {Perks.Lightfoot, 10},
            {Perks.Nimble, 10},
            {Perks.Sprinting, 10},
            {Perks.Axe, 10},
            {Perks.LongBlade, 10},
            {Perks.SmallBlade, 10},
            {Perks.LongBlunt, 10},
            {Perks.SmallBlunt, 10},
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
        bagContents = {
            {"Base.556Clip", 3},
            {"Base.556Bullets", 60},
            {"Base.Bullets44", 24},
            {"Base.44Clip", 2},
            {"Base.Bandage", 5},
            {"Base.AlcoholWipes", 3},
            {"Base.Splint", 2},
            {"Base.Pills", 2},
            {"Base.PillsBeta", 1},
            {"Base.PillsVitamins", 1},
            {"Base.Antibiotics", 1},
            {"Base.WaterBottleFull", 2},
        },
        equipped = {
            primary = "Base.AssaultRifle",
            secondary = "Base.Katana",
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
        skills = {
            {Perks.Strength, 10},
            {Perks.Fitness, 7},
            {Perks.Sprinting, 10},
            {Perks.Carpentry, 4},
            {Perks.Nimble, 4},
            {Perks.Sneak, 2},
            {Perks.Lightfoot, 2},
            {Perks.Aiming, 1},
            {Perks.Reloading, 1},
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
            {"Base.Hat_Army", 1},
            {"Base.Jacket_CoatArmy", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_ArmyBoots", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 2},
            {"Base.DuctTape", 2},
            {"Base.Rope", 1},
        },
        bagContents = {
            {"Base.Bandage", 3},
            {"Base.WaterBottleFull", 2},
            {"Base.TinnedBeans", 3},
            {"Base.TinnedSoup", 3},
            {"Base.TinOpener", 1},
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
    builder = {
        skills = {
            {Perks.Carpentry, 10},
            {Perks.Electricity, 10},
            {Perks.MetalWelding, 10},
            {Perks.Mechanics, 10},
            {Perks.Tailoring, 10},
            {Perks.Cooking, 10},
            {Perks.Strength, 7},
            {Perks.Fitness, 5},
        },
        items = {
            {"Base.Hammer", 1},
            {"Base.Saw", 1},
            {"Base.Screwdriver", 1},
            {"Base.Wrench", 1},
            {"Base.WeldingMask", 1},
            {"Base.BlowTorch", 1},
            {"Base.Crowbar", 1},
            {"Base.Sledgehammer", 1},
            {"Base.GardenSaw", 1},
            {"Base.TinOpener", 1},
            {"Base.Torch", 1},
            {"Base.Battery", 3},
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
            {"Base.Bandage", 5},
            {"Base.WaterBottleFull", 2},
            {"Base.TinnedBeans", 3},
            {"Base.TinnedSoup", 3},
            {"Base.Bag_BigHikingBag", 1},
            {"Base.Boilersuit", 1},
            {"Base.Trousers", 1},
            {"Base.Shoes_ArmyBoots", 1},
        },
        bagContents = {
            {"Base.Plank", 20},
            {"Base.Nails", 80},
            {"Base.SheetMetal", 8},
            {"Base.ScrapMetal", 12},
            {"Base.Wire", 4},
            {"Base.DuctTape", 4},
            {"Base.Rope", 2},
            {"Base.MetalPipe", 4},
            {"Base.Glue", 2},
            {"Base.MetalBar", 4},
            {"Base.Screws", 40},
            {"Base.Bandage", 5},
            {"Base.WaterBottleFull", 2},
            {"Base.TinnedBeans", 3},
            {"Base.TinnedSoup", 3},
        },
        equipped = {
            primary = "Base.Crowbar",
            bag = "Base.Bag_BigHikingBag",
            clothes = {
                "Base.Boilersuit",
                "Base.Trousers",
                "Base.Shoes_ArmyBoots",
            },
        },
        stats = { endurance = 0.3, panic = 20 },
    },
    civil = {
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

-- State global (partage entre fichiers client)
EE_startTime = nil
EE_gameOver = false

local timeWarningsShown = {}
local runtimeHooksRegistered = false
local soloPickerFallbackAt = nil
local soloFallbackTickRegistered = false
local engineStartReported = false
local keyItemsReported = { bidon = false, batterie = false }
local vehicleEngineApiWarningShown = false
local soloVehicleExplosionVehicle = nil
local soloVehicleExplosionTickDelay = nil
local soloVehicleExplosionTickCounter = 0
local soloVehicleExplosionTickRegistered = false

local function isSinglePlayerRuntime()
    if isClient ~= nil then
        return not isClient()
    end

    if getOnlinePlayers ~= nil then
        local onlinePlayers = getOnlinePlayers()
        return onlinePlayers == nil or onlinePlayers:size() == 0
    end

    return true
end

local function addItemsToContainer(container, itemId, count)
    if container == nil or itemId == nil or count == nil or count <= 0 then return end

    for _ = 1, count do
        container:AddItem(itemId)
    end
end

local function buildItemCounts(items)
    local counts = {}
    if items == nil then return counts end

    for _, itemDef in ipairs(items) do
        local itemId = itemDef[1]
        local count = itemDef[2] or 1
        counts[itemId] = (counts[itemId] or 0) + count
    end

    return counts
end

local function addRoleItems(inv, bagItem, bagItemId, items, bagContents)
    if inv == nil or items == nil then return end

    local bagContainer = bagItem and bagItem:getItemContainer() or nil
    local bagCounts = buildItemCounts(bagContents)

    for _, itemDef in ipairs(items) do
        local itemId = itemDef[1]
        local totalCount = itemDef[2] or 1

        if itemId ~= bagItemId then
            local bagCount = 0
            if bagContainer ~= nil and bagCounts[itemId] ~= nil then
                bagCount = math.min(totalCount, bagCounts[itemId])
            end
            local invCount = totalCount - bagCount

            if invCount > 1 then
                inv:AddItems(itemId, invCount)
            elseif invCount == 1 then
                inv:AddItem(itemId)
            end

            addItemsToContainer(bagContainer, itemId, bagCount)
        end
    end
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

local function applyRoleLocally(player, roleKey)
    if player == nil or roleKey == nil then return false end

    local def = ROLE_DEFS[roleKey]
    if def == nil then return false end

    local modData = player:getModData()
    if modData.EE_localRoleApplied == roleKey then
        modData.EE_role = roleKey
        modData.EE_reviveEnabled = true
        return false
    end

    local inv = player:getInventory()
    local roleBag = nil

    if def.equipped and def.equipped.bag then
        roleBag = inv:AddItem(def.equipped.bag)
    end

    addRoleItems(inv, roleBag, def.equipped and def.equipped.bag or nil, def.items, def.bagContents)

    for _, skillDef in ipairs(def.skills) do
        local perk, level = skillDef[1], skillDef[2]
        applyPerkLevel(player, perk, level)
    end

    equipRoleItems(player, inv, def.equipped)
    applyRoleStats(player, def.stats)

    if player.setUnlimitedCarry ~= nil then
        player:setUnlimitedCarry(roleKey == "builder")
    end

    modData.EE_role = roleKey
    modData.EE_reviveEnabled = true
    modData.EE_localRoleApplied = roleKey

    return true
end

local function syncWarningStateFromTimer()
    timeWarningsShown = {}

    if EE_startTime == nil then return end

    local elapsed = getGameTime():getWorldAgeHours() - EE_startTime
    local remainingMin = math.floor((DURATION_HOURS - elapsed) * 60)

    if remainingMin < 120 then timeWarningsShown[120] = true end
    if remainingMin < 60 then timeWarningsShown[60] = true end
    if remainingMin < 30 then timeWarningsShown[30] = true end
    if remainingMin < 10 then timeWarningsShown[10] = true end
end

EscapadeExpress.ApplyRoleLocally = function(player, roleKey)
    return applyRoleLocally(player, roleKey)
end

EscapadeExpress.StartLocalScenarioTimer = function()
    if EE_startTime == nil then
        EE_startTime = getGameTime():getWorldAgeHours()
        syncWarningStateFromTimer()
    end
end

local function enforceRealTimeDayLength()
    if SandboxVars ~= nil then
        SandboxVars.DayLength = 26
    end

    if getGameTime ~= nil then
        local gameTime = getGameTime()
        if gameTime ~= nil and gameTime.setMinutesPerDay ~= nil then
            gameTime:setMinutesPerDay(60 * 24)
        end
    end
end

local function ensureSoloFallbackTickRegistered()
    if soloFallbackTickRegistered then return end
    Events.OnTick.Add(EscapadeExpress.TickRolePickerFallback)
    soloFallbackTickRegistered = true
end

local function unregisterSoloFallbackTick()
    if not soloFallbackTickRegistered then return end
    Events.OnTick.Remove(EscapadeExpress.TickRolePickerFallback)
    soloFallbackTickRegistered = false
end

local gameStartEventRegistered = false
local scenarioInitialized = false

-- ============================================================
-- 1. REGISTRATION (pattern Pillow's)
-- ============================================================

EscapadeExpress.Add = function()
    addChallenge(EscapadeExpress)
end

-- ============================================================
-- 2. HOOKS D'EVENEMENTS
-- ============================================================

local function isVehicleEngineStarted(vehicle)
    if vehicle == nil then return false end

    if vehicle.isEngineStarted ~= nil then
        return vehicle:isEngineStarted()
    end

    if vehicle.isEngineRunning ~= nil then
        return vehicle:isEngineRunning()
    end

    if not vehicleEngineApiWarningShown then
        print("[EE] WARNING: aucune API etat moteur disponible sur BaseVehicle")
        vehicleEngineApiWarningShown = true
    end

    return false
end

local function showLocalAlert(text, alertType)
    if triggerEvent ~= nil then
        triggerEvent("OnServerCommand", "EscapadeExpress", "AlertMessage", {
            text = text,
            type = alertType,
        })
        return
    end

    local pl = getPlayer()
    if pl ~= nil then
        pl:Say(text)
    end
end

local function isLikelyEscapeVehicle(vehicle)
    if vehicle == nil or vehicle.getSquare == nil then return false end

    local sq = vehicle:getSquare()
    if sq == nil then return false end

    return sq:getZ() == PARKING.z
        and math.abs(sq:getX() - PARKING.x) <= 4
        and math.abs(sq:getY() - PARKING.y) <= 4
end

local function unregisterSoloVehicleExplosionTick()
    if not soloVehicleExplosionTickRegistered then return end

    Events.OnTick.Remove(EscapadeExpress.TickSoloVehicleExplosion)
    soloVehicleExplosionTickRegistered = false
end

local function resetSoloVehicleExplosionState()
    unregisterSoloVehicleExplosionTick()
    soloVehicleExplosionVehicle = nil
    soloVehicleExplosionTickDelay = nil
    soloVehicleExplosionTickCounter = 0
end

local function ensureSoloVehicleExplosionTickRegistered()
    if soloVehicleExplosionTickRegistered then return end

    Events.OnTick.Add(EscapadeExpress.TickSoloVehicleExplosion)
    soloVehicleExplosionTickRegistered = true
end

local function scheduleSoloVehicleExplosion(vehicle)
    if vehicle == nil then return end

    soloVehicleExplosionVehicle = vehicle
    soloVehicleExplosionTickDelay = ZombRand(120, 181)
    soloVehicleExplosionTickCounter = 0
    ensureSoloVehicleExplosionTickRegistered()
    showLocalAlert("Le moteur s'etouffe...", "warning")
end

local function hasAnyCarBattery(inv)
    if inv == nil or inv.contains == nil then return false end

    return inv:contains("Base.CarBattery1")
        or inv:contains("Base.CarBattery2")
        or inv:contains("Base.CarBattery3")
end

local function registerRuntimeHooks()
    if runtimeHooksRegistered then return end

    runtimeHooksRegistered = true
    Events.EveryOneMinute.Add(EscapadeExpress.EveryMinutes)
    Events.OnPlayerDeath.Add(EscapadeExpress.OnPlayerDeath)
    Events.OnCreatePlayer.Add(EscapadeExpress.OnCreatePlayer)
    Events.OnPlayerUpdate.Add(EscapadeExpress.OnPlayerUpdate)
end

EscapadeExpress.OnGameStart = function()
    enforceRealTimeDayLength()
    registerRuntimeHooks()
    EscapadeExpress.OnNewGame()
end

EscapadeExpress.OnInitWorld = function()
    scenarioInitialized = false

    if not gameStartEventRegistered then
        Events.OnGameStart.Add(EscapadeExpress.OnGameStart)
        gameStartEventRegistered = true
    end
end

-- ============================================================
-- 3. NOUVELLE PARTIE - initialisation
-- ============================================================

EscapadeExpress.OnNewGame = function()
    local pl = getPlayer()
    if pl == nil then return end
    if pl:getHoursSurvived() > 1 then return end

    if not scenarioInitialized then
        scenarioInitialized = true

        EE_startTime = nil
        EE_gameOver = false
        timeWarningsShown = {}
        soloPickerFallbackAt = nil
        engineStartReported = false
        keyItemsReported = { bidon = false, batterie = false }
        resetSoloVehicleExplosionState()

        pl:getModData().EE_reviveEnabled = true
        pl:getModData().EE_role = nil
        pl:getModData().EE_localRoleApplied = nil
        pl:getModData().EE_roleSelectionDenied = false

        pl:Say("On est pieges dans le mall! Trouvez le bidon, la cle et une batterie pour fuir!")
    else
        pl:getModData().EE_reviveEnabled = true
    end

    if pl:getHoursSurvived() <= 1 then
        keyItemsReported = { bidon = false, batterie = false }
    end

    if pl:getModData().EE_role ~= nil or pl:getModData().EE_roleSelectionDenied then
        return
    end

    if sendClientCommand ~= nil then
        if isSinglePlayerRuntime() and soloPickerFallbackAt == nil then
            soloPickerFallbackAt = EE_getNowSeconds() + 3
            ensureSoloFallbackTickRegistered()
        end

        sendClientCommand("EscapadeExpress", "RolePickerReady", {
            username = pl:getUsername()
        })
        return
    end

    if isSinglePlayerRuntime() and not EscapadeExpressRolePicker.isVisible() then
        EscapadeExpressRolePicker.openLocal()
    end
end

EscapadeExpress.OnCreatePlayer = function()
    EscapadeExpress.OnNewGame()
end

EscapadeExpress.TickRolePickerFallback = function()
    if soloPickerFallbackAt == nil then
        unregisterSoloFallbackTick()
        return
    end

    if not isSinglePlayerRuntime() then
        soloPickerFallbackAt = nil
        unregisterSoloFallbackTick()
        return
    end

    local pl = getPlayer()
    if pl == nil then return end
    if pl:getModData().EE_role ~= nil then
        soloPickerFallbackAt = nil
        unregisterSoloFallbackTick()
        return
    end

    if EscapadeExpressRolePicker.isVisible() then
        soloPickerFallbackAt = nil
        unregisterSoloFallbackTick()
        return
    end

    if EE_getNowSeconds() >= soloPickerFallbackAt then
        soloPickerFallbackAt = nil
        unregisterSoloFallbackTick()
        EscapadeExpressRolePicker.openLocal()
    end
end

-- ============================================================
-- 4. STUBS REQUIS (pattern Pillow's)
-- ============================================================

EscapadeExpress.setSandBoxVars = function()
    if SandboxVars ~= nil then
        SandboxVars.DayLength = 26
    end
end
EscapadeExpress.RemovePlayer = function(p) end
EscapadeExpress.AddPlayer = function(p) end
EscapadeExpress.Render = function() end

-- ============================================================
-- 5. SPAWN
-- ============================================================

EscapadeExpress.spawns = SPAWN_TILES
local spawn = EscapadeExpress.spawns[1] or SPAWN

-- ============================================================
-- 6. METADATA
-- ============================================================

EscapadeExpress.id = "EscapadeExpress"
EscapadeExpress.image = "media/lua/client/LastStand/EscapadeExpress.png"
EscapadeExpress.gameMode = "Escapade Express"
EscapadeExpress.world = "Muldraugh, KY"
EscapadeExpress.xcell = spawn.xcell
EscapadeExpress.ycell = spawn.ycell
EscapadeExpress.x = spawn.x
EscapadeExpress.y = spawn.y
EscapadeExpress.z = spawn.z
EscapadeExpress.enableSandbox = true

-- ============================================================
-- 7. ENREGISTREMENT FINAL
-- ============================================================

Events.OnChallengeQuery.Add(EscapadeExpress.Add)

-- ============================================================
-- 8. LOGIQUE PERIODIQUE (cote client)
-- ============================================================

EscapadeExpress.EveryMinutes = function()
    if EE_startTime == nil or EE_gameOver then return end

    local pl = getPlayer()
    if pl == nil then return end

    local elapsed = getGameTime():getWorldAgeHours() - EE_startTime
    local remaining = DURATION_HOURS - elapsed

    if remaining <= 0 then
        return
    end

    local remainingMin = math.floor(remaining * 60)

    if remainingMin <= 120 and not timeWarningsShown[120] then
        timeWarningsShown[120] = true
        pl:Say("Plus que 2 heures!")
    elseif remainingMin <= 60 and not timeWarningsShown[60] then
        timeWarningsShown[60] = true
        pl:Say("Plus que 1 heure!")
    elseif remainingMin <= 30 and not timeWarningsShown[30] then
        timeWarningsShown[30] = true
        pl:Say("Plus que 30 minutes! Depechez-vous!")
    elseif remainingMin <= 10 and not timeWarningsShown[10] then
        timeWarningsShown[10] = true
        pl:Say("Plus que 10 minutes!")
    end
end

-- ============================================================
-- 9. MORT DU JOUEUR (prevention cote client)
-- ============================================================

EscapadeExpress.TickSoloVehicleExplosion = function()
    if soloVehicleExplosionVehicle == nil or soloVehicleExplosionTickDelay == nil then
        resetSoloVehicleExplosionState()
        return
    end

    soloVehicleExplosionTickCounter = soloVehicleExplosionTickCounter + 1
    if soloVehicleExplosionTickCounter < soloVehicleExplosionTickDelay then
        return
    end

    local vehicle = soloVehicleExplosionVehicle
    resetSoloVehicleExplosionState()

    local sq = vehicle and vehicle.getSquare and vehicle:getSquare() or nil
    if sq == nil then
        print("[EE] WARNING: impossible de trouver le square du vehicule solo a exploser")
        return
    end

    IsoFireManager.explode(getCell(), sq, 50)
    showLocalAlert("LE VEHICULE EXPLOSE!", "danger")
end

EscapadeExpress.OnPlayerUpdate = function(player)
    if EE_gameOver or player == nil then return end

    local localPlayer = getPlayer()
    if localPlayer == nil or player ~= localPlayer then return end

    local inv = player:getInventory()
    if sendClientCommand ~= nil and inv ~= nil then
        if not keyItemsReported.bidon and inv:contains("Base.PetrolCan") then
            keyItemsReported.bidon = true
            sendClientCommand("EscapadeExpress", "KeyItemFound", { item = "bidon" })
        end

        if not keyItemsReported.batterie and hasAnyCarBattery(inv) then
            keyItemsReported.batterie = true
            sendClientCommand("EscapadeExpress", "KeyItemFound", { item = "batterie" })
        end
    end

    if engineStartReported then return end

    local vehicle = player:getVehicle()
    if vehicle == nil or not isVehicleEngineStarted(vehicle) then return end

    if isSinglePlayerRuntime() then
        if not isLikelyEscapeVehicle(vehicle) then return end

        engineStartReported = true
        scheduleSoloVehicleExplosion(vehicle)
        return
    end

    if sendClientCommand == nil then return end

    engineStartReported = true
    sendClientCommand("EscapadeExpress", "VehicleStarted", {})
end

EscapadeExpress.OnPlayerDeath = function(player)
    if player == nil then return end

    local modData = player:getModData()
    if modData.EE_reviveEnabled and not EE_gameOver then
        if modData.EE_downed then return end

        player:setHealth(0.01)
        player:setKnockedDown(true)
        player:setDoDeathSound(false)
        modData.EE_downed = true
        modData.EE_downTime = getGameTime():getWorldAgeHours()
        modData.EE_downX = player:getX()
        modData.EE_downY = player:getY()
        modData.EE_downZ = player:getZ()

        sendClientCommand("EscapadeExpress", "PlayerDown", {
            x = modData.EE_downX,
            y = modData.EE_downY,
            z = modData.EE_downZ
        })

        player:Say("Je suis a terre! Quelqu'un peut me ranimer!")
    end
end

-- ============================================================
-- 10. RECEPTION COMMANDES SERVEUR
-- ============================================================

local function onServerCommand(module, command, data)
    if module ~= "EscapadeExpress" then return end

    if command == "RoleAssigned" then
        local pl = getPlayer()
        if pl and data.username == pl:getUsername() then
            pl:getModData().EE_role = data.role
            pl:getModData().EE_localRoleApplied = data.role
            pl:getModData().EE_roleSelectionDenied = false
            soloPickerFallbackAt = nil
            unregisterSoloFallbackTick()
        end
    elseif command == "RoleDenied" then
        local pl = getPlayer()
        if pl and data.username == pl:getUsername() then
            pl:getModData().EE_role = nil
            pl:getModData().EE_reviveEnabled = false
            pl:getModData().EE_roleSelectionDenied = true
            soloPickerFallbackAt = nil
            unregisterSoloFallbackTick()
        end
    elseif command == "PlayerDown" then
        local pl = getPlayer()
        if pl and data and data.username and data.username ~= pl:getUsername() then
            pl:Say(data.username .. " est a terre! Allez le ranimer!")
        end
    elseif command == "PlayerRevived" then
        local pl = getPlayer()
        if pl and data.username == pl:getUsername() then
            local modData = pl:getModData()
            modData.EE_downed = false
            modData.EE_downTime = nil
            modData.EE_downX = nil
            modData.EE_downY = nil
            modData.EE_downZ = nil
            if data.reviverType == "medic" then
                pl:Say("Le medic m'a ranime!")
            else
                pl:Say("Je suis ranime!")
            end
        elseif pl then
            pl:Say(data.username .. " est de retour!")
        end
    elseif command == "PlayerRespawned" then
        local pl = getPlayer()
        if pl and data.username == pl:getUsername() then
            local modData = pl:getModData()
            modData.EE_downed = false
            modData.EE_downTime = nil
            modData.EE_downX = nil
            modData.EE_downY = nil
            modData.EE_downZ = nil
            pl:Say("Je me reveille au point de depart...")
        elseif pl then
            pl:Say(data.username .. " a ete renvoye au point de depart.")
        end
    elseif command == "SyncTimer" then
        EE_startTime = data and data.startTime or nil
        syncWarningStateFromTimer()
    elseif command == "GameOver" then
        EE_gameOver = true
    elseif command == "Message" then
        local pl = getPlayer()
        if pl and data and data.text then
            pl:Say(data.text)
        end
    end
end
Events.OnServerCommand.Add(onServerCommand)
