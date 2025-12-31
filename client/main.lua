local QBCore = exports['qb-core']:GetCoreObject()
local isRenting = false
local rentalBlip = nil

CreateThread(function()
    local blip = AddBlipForCoord(Config.RentalLocation.Coords.x, Config.RentalLocation.Coords.y, Config.RentalLocation.Coords.z)
    SetBlipSprite(blip, Config.RentalLocation.Blip.Sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.RentalLocation.Blip.Scale)
    SetBlipColour(blip, Config.RentalLocation.Blip.Color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.RentalLocation.Blip.Label)
    EndTextCommandSetBlipName(blip)
    rentalBlip = blip
end)

CreateThread(function()
    local pedModel = GetHashKey('s_m_y_airworker')
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(1)
    end

    local ped = CreatePed(4, pedModel, Config.RentalLocation.Coords.x, Config.RentalLocation.Coords.y, Config.RentalLocation.Coords.z - 1.0, Config.RentalLocation.Coords.w, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)

    if Config.Target.Enabled then
        local targetOptions = {}
        
        if exports['qb-menu'] then
            table.insert(targetOptions, {
                type = "client",
                event = "minik-rentacar:openMenu",
                icon = "fas fa-car",
                label = "Araç Kirala"
            })
        else
            for i, vehicle in ipairs(Config.RentalVehicles) do
                table.insert(targetOptions, {
                    icon = "fas fa-car",
                    label = string.format("%s Kirala ($%d)", vehicle.label, vehicle.price),
                    action = function()
                        TriggerEvent('minik-rentacar:rentVehicle', { vehicleIndex = i })
                    end
                })
            end
        end
        
        exports['qb-target']:AddTargetEntity(ped, {
            options = targetOptions,
            distance = 2.5
        })
    end
end)

RegisterNetEvent('minik-rentacar:openMenu', function()
    if isRenting then
        QBCore.Functions.Notify('Zaten bir işlem yapıyorsun!', 'error')
        return
    end

    QBCore.Functions.TriggerCallback('minik-rentacar:checkCooldown', function(canRent, timeLeft)
        if not canRent then
            QBCore.Functions.Notify(string.format('Daha önce araç kiraladın. %d dakika sonra tekrar kiralayabilirsin.', timeLeft), 'error')
            return
        end

        OpenRentalMenu()
    end)
end)

function OpenRentalMenu()
    if not exports['qb-menu'] then
        QBCore.Functions.Notify('Menü sistemi bulunamadı!', 'error')
        return
    end

    local menuOptions = {}
    
    for i, vehicle in ipairs(Config.RentalVehicles) do
        table.insert(menuOptions, {
            header = vehicle.label,
            txt = string.format('Fiyat: $%d', vehicle.price),
            params = {
                event = 'minik-rentacar:rentVehicle',
                args = {
                    vehicleIndex = i
                }
            }
        })
    end

    table.insert(menuOptions, {
        header = "Kapat",
        txt = "",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    })

    exports['qb-menu']:openMenu(menuOptions)
end

RegisterNetEvent('minik-rentacar:rentVehicle', function(data)
    local vehicleIndex = nil
    
    if type(data) == 'table' and data.vehicleIndex then
        vehicleIndex = data.vehicleIndex
    elseif type(data) == 'number' then
        vehicleIndex = data
    end
    
    if not vehicleIndex or vehicleIndex < 1 or vehicleIndex > #Config.RentalVehicles then
        QBCore.Functions.Notify('Geçersiz araç seçimi!', 'error')
        return
    end
    
    local vehicle = Config.RentalVehicles[vehicleIndex]
    
    if not vehicle then
        QBCore.Functions.Notify('Geçersiz araç seçimi!', 'error')
        return
    end

    if isRenting then
        QBCore.Functions.Notify('Zaten bir işlem yapıyorsun!', 'error')
        return
    end

    isRenting = true
    QBCore.Functions.TriggerCallback('minik-rentacar:checkCooldown', function(canRent, timeLeft)
        if not canRent then
            isRenting = false
            QBCore.Functions.Notify(string.format('Daha önce araç kiraladın. %d dakika sonra tekrar kiralayabilirsin.', timeLeft), 'error')
            return
        end

        QBCore.Functions.TriggerCallback('minik-rentacar:rentVehicle', function(success, message)
            isRenting = false
            if success then
                QBCore.Functions.Notify(message, 'success')
                SpawnRentalVehicle(vehicle)
            else
                QBCore.Functions.Notify(message, 'error')
            end
        end, vehicleIndex)
    end)
end)

function IsVehicleAtSpawnLocation()
    local spawnCoords = Config.RentalLocation.SpawnCoords
    local checkRadius = Config.RentalLocation.SpawnCheckRadius
    
    local vehicles = GetGamePool('CVehicle')
    for _, veh in ipairs(vehicles) do
        if DoesEntityExist(veh) then
            local vehCoords = GetEntityCoords(veh)
            local distance = #(vector3(spawnCoords.x, spawnCoords.y, spawnCoords.z) - vehCoords)
            
            if distance <= checkRadius then
                return true, veh
            end
        end
    end
    
    return false, nil
end

function SpawnRentalVehicle(vehicle)
    local hasVehicle, existingVehicle = IsVehicleAtSpawnLocation()
    
    if hasVehicle then
        QBCore.Functions.Notify('Spawn konumunda zaten bir araç var! Lütfen önce mevcut aracı kaldırın.', 'error')
        return
    end
    
    local playerPed = PlayerPedId()
    local coords = Config.RentalLocation.SpawnCoords

    QBCore.Functions.SpawnVehicle(vehicle.model, function(veh)
        if not DoesEntityExist(veh) then
            QBCore.Functions.Notify('Araç spawn edilemedi!', 'error')
            return
        end
        
        SetEntityHeading(veh, coords.w)
        SetVehicleNumberPlateText(veh, vehicle.plate .. math.random(1000, 9999))
        SetEntityAsMissionEntity(veh, true, true)
        SetVehicleEngineOn(veh, true, true, false)
        SetVehicleFuelLevel(veh, 100.0)
        
        SetVehicleModKit(veh, 0)
        SetVehicleMod(veh, 11, 3, false) -- Engine
        SetVehicleMod(veh, 12, 2, false) -- Brakes
        SetVehicleMod(veh, 13, 2, false) -- Transmission
        SetVehicleMod(veh, 15, 3, false) -- Suspension
        
        local plate = GetVehicleNumberPlateText(veh)
        local vehicleProps = QBCore.Functions.GetVehicleProperties(veh)
        TriggerServerEvent('minik-rentacar:setVehicleOwner', plate, vehicle.model, vehicleProps)
        
        GiveVehicleKey(plate, veh)
        
        QBCore.Functions.Notify(string.format('%s kiraladın! Plaka: %s', vehicle.label, plate), 'success')
    end, coords, true)
end

function GiveVehicleKey(plate, vehicle)
    if GetResourceState('qb-vehiclekeys') == 'started' then
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
        return
    end
    
    if exports['cd_garage'] then
        exports['cd_garage']:AddKey(plate)
        return
    end
    
    if exports['qb-vehicleshop'] then
        exports['qb-vehicleshop']:GiveKeys(plate)
        return
    end
    
    TriggerEvent('vehiclekeys:client:GiveKeys', plate)
end

RegisterNetEvent('minik-rentacar:notify', function(message, msgType)
    QBCore.Functions.Notify(message, msgType or 'primary')
end)

