Config = {}

Config.Debug = false
Config.Locale = 'tr'

-- Framework
Config.Framework = 'qb'

Config.RentalLocation = {
    Coords = vector4(-1037.0, -2737.0, 20.17, 240.0), 
    Blip = {
        Sprite = 326,
        Color = 3,
        Scale = 0.8,
        Label = "Araç Kiralama"
    },
    SpawnCoords = vector4(-1030.0, -2730.0, 20.17, 240.0),
    SpawnCheckRadius = 3.0 -
}

Config.RentalVehicles = {
    {
        model = 'sentinel',      -- Sentinel (eski)
        label = 'Sentinel',
        price = 500,              -- Kiralama ücreti
        plate = 'RENTAL'         -- Plaka
    },
    {
        model = 'futo',          -- Futo (eski)
        label = 'Futo',
        price = 400,
        plate = 'RENTAL'
    },
    {
        model = 'blista',        -- Blista (eski)
        label = 'Blista',
        price = 350,
        plate = 'RENTAL'
    }
}

-- Bekleme süresi (gerçek saat ile)
Config.CooldownTime = 30 -- dakika

Config.ContractItem = 'kiralama_kontrati'

Config.MoneyType = 'cash' -- 'cash', 'bank', 'crypto'

Config.Target = {
    Enabled = true,
    System = 'qb-target'
}

