return {
    Debug = false,
    RequiredCops = 1,
    PedModel = `U_M_Y_SmugMech_01`,
    PedCoords = vec4(4.95, -723.95, 31.17, 157.79),
    FuelScript = {
        enable = false,
        name = 'LegacyFuel',
    },
    DeliveryCoords = { -- Random delivery location assigned.
        vec3(806.18, 2181.29, 52.25),
        vec3(-86.47, 1880.51, 197.31),
        vec3(2135.38, 4780.8, 40.97),
    },
    Min = 6500, -- min payout
    Max = 8700, -- max payout
    Cooldown = 30,-- 30 minutes until the delivery timer is up and the heist fails.
    VehicleList = {
        'furia',
        'vacca',
        'adder',
        'zentorno',
        'cheetah',
        'entityxf',
        'reaper',
        'autarch',
        'taipan',
        'sm722',
        'italirsx',
        'comet5',
        'tenf',
        'growler',
        'coquette3',
        'coquette4',
        'jester3',
    },
    SpawnLocations = {
        {enter = vec4(895.6, -887.01, 27.22, 272.95), spawn = vec4(889.92, -888.78, 26.78, 95.02)},
        {enter = vec4(929.51, -2307.92, 30.65, 269.95), spawn = vec4(926.26, -2307.63, 30.51, 89.03)},
        {enter = vec4(1084.72, -2289.35, 30.23, 87.84), spawn = vec4(1086.98, -2289.59, 30.2, 266.24)},
        {enter = vec4(995.39, -1854.3, 31.04, 351.38), spawn = vec4(995.21, -1857.85, 30.89, 175.66)},
        {enter = vec4(18.44, -209.74, 52.86, 66.85), spawn = vec4(21.5, -210.66, 52.86, 249.84)},
        {enter = vec4(-786.76, -798.91, 20.62, 1.5), spawn = vec4(-786.65, -801.61, 20.62, 181.0)},
        {enter = vec4(-1173.53, -1173.81, 5.62, 20.09), spawn = vec4(-1172.56, -1176.49, 5.62, 195.17)},
    },
}