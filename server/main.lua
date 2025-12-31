local QBCore = exports['qb-core']:GetCoreObject()

local rentalHistory = {}


QBCore.Functions.CreateCallback('minik-rentacar:checkCooldown', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb(false, 0)
        return
    end

    local citizenid = Player.PlayerData.citizenid
    
    if not rentalHistory[citizenid] then
        cb(true, 0)
        return
    end

    local lastRentalTime = rentalHistory[citizenid]
    local currentTime = os.time()
    local timeDiff = currentTime - lastRentalTime
    local minutesPassed = math.floor(timeDiff / 60)
    
    if minutesPassed >= Config.CooldownTime then
        cb(true, 0)
    else
        local timeLeft = Config.CooldownTime - minutesPassed
        cb(false, timeLeft)
    end
end)

QBCore.Functions.CreateCallback('minik-rentacar:rentVehicle', function(source, cb, vehicleIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb(false, 'Oyuncu bulunamadı!')
        return
    end

    local vehicle = Config.RentalVehicles[vehicleIndex]
    if not vehicle then
        cb(false, 'Geçersiz araç!')
        return
    end

    local citizenid = Player.PlayerData.citizenid
    
    if rentalHistory[citizenid] then
        local lastRentalTime = rentalHistory[citizenid]
        local currentTime = os.time()
        local timeDiff = currentTime - lastRentalTime
        local minutesPassed = math.floor(timeDiff / 60)
        
        if minutesPassed < Config.CooldownTime then
            local timeLeft = Config.CooldownTime - minutesPassed
            cb(false, string.format('Daha önce araç kiraladın. %d dakika sonra tekrar kiralayabilirsin.', timeLeft))
            return
        end
    end

    local moneyType = Config.MoneyType
    local hasMoney = false
    local moneyAmount = 0

    if moneyType == 'cash' then
        moneyAmount = Player.PlayerData.money.cash
        hasMoney = moneyAmount >= vehicle.price
    elseif moneyType == 'bank' then
        moneyAmount = Player.PlayerData.money.bank
        hasMoney = moneyAmount >= vehicle.price
    elseif moneyType == 'crypto' then
        moneyAmount = Player.PlayerData.money.crypto
        hasMoney = moneyAmount >= vehicle.price
    end

    if not hasMoney then
        cb(false, string.format('Yeterli paran yok! Gerekli: $%d', vehicle.price))
        return
    end

    if moneyType == 'cash' then
        Player.Functions.RemoveMoney('cash', vehicle.price, 'vehicle-rental')
    elseif moneyType == 'bank' then
        Player.Functions.RemoveMoney('bank', vehicle.price, 'vehicle-rental')
    elseif moneyType == 'crypto' then
        Player.Functions.RemoveMoney('crypto', vehicle.price, 'vehicle-rental')
    end


    rentalHistory[citizenid] = os.time()
    

    Player.Functions.AddItem(Config.ContractItem, 1, false, {
        vehicle = vehicle.label,
        price = vehicle.price,
        rentalTime = os.date('%Y-%m-%d %H:%M:%S'),
        plate = vehicle.plate
    })
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ContractItem], 'add')
    

    print(string.format('[minik-rentacar] %s (%s) %s aracını kiraladı. Fiyat: $%d', 
        Player.PlayerData.name, citizenid, vehicle.label, vehicle.price))
    
    cb(true, string.format('%s aracını başarıyla kiraladın!', vehicle.label))
end)


RegisterNetEvent('minik-rentacar:setVehicleOwner', function(plate, model, vehicleProps)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        return
    end


    GiveVehicleKeyServer(src, plate)
    
   
    print(string.format('[minik-rentacar] %s (%s) plakalı %s aracı kiralık olarak kaydedildi. Anahtar verildi.', 
        plate, Player.PlayerData.citizenid, model))
end)

function GiveVehicleKeyServer(src, plate)
    if exports['qb-vehiclekeys'] then
        exports['qb-vehiclekeys']:GiveKeys(src, plate)
        return
    end
    
    if exports['cd_garage'] then
        exports['cd_garage']:AddKey(src, plate)
        return
    end
    
    if exports['qb-vehicleshop'] then
        exports['qb-vehicleshop']:GiveKeys(src, plate)
        return
    end
    
    TriggerClientEvent('vehiclekeys:client:GiveKeys', src, plate)
end

AddEventHandler('playerDropped', function()
end)

QBCore.Commands.Add('resetrental', 'Oyuncunun kiralama cooldown\'unu sıfırla', {
    {name = 'id', help = 'Oyuncu ID'}
}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        return
    end

    if not QBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('QBCore:Notify', src, 'Yetkin yok!', 'error')
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('QBCore:Notify', src, 'Geçersiz ID!', 'error')
        return
    end

    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Oyuncu bulunamadı!', 'error')
        return
    end

    local citizenid = TargetPlayer.PlayerData.citizenid
    rentalHistory[citizenid] = nil
    
    TriggerClientEvent('QBCore:Notify', src, string.format('%s oyuncusunun kiralama cooldown\'u sıfırlandı.', TargetPlayer.PlayerData.name), 'success')
    TriggerClientEvent('QBCore:Notify', targetId, 'Kiralama cooldown\'un sıfırlandı!', 'success')
end)

