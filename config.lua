-- Made by Sahbes

Config = {}

Config.Locale = 'en'

Config.TimeDifference = 1

Config.ProcessTime = 5

Config.RefreshTimes = {

    7,
    18,
    24

}

Config.OpenTimes = {

    ["Weed"] = {

        -- Smorgens 9u - 12u
        9,
        10,
        11,

        -- Middag 14u - 17u
        14,
        15,
        16,

        -- Savonds 20u - 24u
        19,
        20,
        21,
        22,
        23,


        -- Snachts 2u - 6u
        2,
        3,
        4,
        5

    },

    ["Coke"] = {

        -- Smorgens 9u - 12u
        9,
        10,
        11,

        -- Middag 14u - 17u
        14,
        15,
        16,

        -- Savonds 20u - 24u
        20,
        21,
        22,
        23,


        -- Snachts 2u - 6u
        2,
        3,
        4,
        5

    },

    ["Meth"] = {

        -- Smorgens 9u - 12u
        9,
        10,
        11,

        -- Middag 14u - 17u
        14,
        15,
        16,
        17,

        -- Savonds 20u - 24u
        20,
        21,
        22,
        23,


        -- Snachts 2u - 6u
        2,
        3,
        4,
        5

    }

}

Config.MaxPickup = {

    ["Weed"] = 700,

    ["Coke"] = 500,

    ["Meth"] = 200

}

Config.RequiredCops = {

    ["Weed"] = 0,

    ["Coke"] = 0,

    ["Meth"] = 0

}

Config.Locations = {

    ["Weed"] = {
        {location = vector3(3930.6204, -4697.3315, 4.1943)},
        {location = vector3(4763.3276, -4720.7329, 1.9668)},
        {location = vector3(5311.3271, -5597.4194, 64.3804)},
        {location = vector3(5118.6865, -5521.8374, 54.1326)},
    },

    ["Coke"] = {
        {location = vector3(5356.2314, -5426.0171, 49.2400)},
        {location = vector3(5433.4644, -5448.6523, 40.6380)},
        {location = vector3(5433.4644, -5448.6523, 40.6380)},
        {location = vector3(5538.0859, -5780.6875, 11.0870)},
    },

    ["Meth"] = {
        {location = vector3(4989.5757, -5177.1763, 2.5026)},
        {location = vector3(4821.6294, -5023.1675, 31.6460)},
        {location = vector3(4889.3994, -5736.2236, 26.3509)},
        {location = vector3(4952.5508, -5888.9814, 13.9007)},
    }

}

Config.Files = {

    ["Weed"] = 'client_source/weed.lua',

    ["Coke"] = 'client_source/coke.lua',

    ["Meth"] = 'client_source/meth.lua',

    ["Pooch"] = 'client_source/pooch.lua',

}