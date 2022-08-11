ESX = nil
local _wheel = nil
local _lambo = nil
-- local _isShowCar = config.ShowCar
local _wheelPos = vector3(978.0117, 50.34866, 73.77611)
local _baseWheelPos = vector3(978.0117, 50.34866, 73.67611)

local casinoprops = {}

local Keys = {
    ["ESC"] = 322, ["BACKSPACE"] = 177, ["E"] = 38, ["ENTER"] = 18, ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173
}
local _isRolling = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while not ESX.IsPlayerLoaded() do 
        Citizen.Wait(500)
    end

    if ESX.IsPlayerLoaded() then
        local model = GetHashKey('vw_prop_vw_luckywheel_02a')
        local baseWheelModel = GetHashKey('vw_prop_vw_luckywheel_01a')

        Citizen.CreateThread(function()
            RequestModel(baseWheelModel)
            while not HasModelLoaded(baseWheelModel) do
                Citizen.Wait(0)
            end

            _basewheel = CreateObject(baseWheelModel, _baseWheelPos.x, _baseWheelPos.y, _baseWheelPos.z, false, false, true)
            SetEntityHeading(_basewheel, 327.99411010742)
            SetModelAsNoLongerNeeded(baseWheelModel)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end

            _wheel = CreateObject(model, 978.0117, 50.34866, 73.92611, false, false, true)
            SetEntityHeading(_wheel, 327.99411010742)
            SetModelAsNoLongerNeeded(model)
            spawnveh()
            table.insert(casinoprops, _wheel)
            table.insert(casinoprops, _basewheel)
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        if _lambo ~= nil then
            local _heading = GetEntityHeading(_lambo)
            local _z = _heading - 0.3
            SetEntityHeading(_lambo, _z)
        end
        Citizen.Wait(5)
    end
end)

RegisterNetEvent("GMD_Casinopack:doRoll")
AddEventHandler("GMD_Casinopack:doRoll", function(_priceIndex)
    _isRolling = true
    SetEntityHeading(_wheel, 327.99411010742)
    SetEntityRotation(_wheel, 0.0, 0.0, 0.0, 1, true)
    Citizen.CreateThread(function()
        local speedIntCnt = 1
        local rollspeed = 1.0
        -- local _priceIndex = math.random(1, 20)
        local _winAngle = (_priceIndex - 1) * 18
        local _rollAngle = _winAngle + (360 * 8)
        local _midLength = (_rollAngle / 2)
        local intCnt = 0
        while speedIntCnt > 0 do
            local retval = GetEntityRotation(_wheel, 1)
            if _rollAngle > _midLength then
                speedIntCnt = speedIntCnt + 1
            else
                speedIntCnt = speedIntCnt - 1
                if speedIntCnt < 0 then
                    speedIntCnt = 0
                    
                end
            end
            intCnt = intCnt + 1
            rollspeed = speedIntCnt / 10
            local _y = retval.y - rollspeed
            _rollAngle = _rollAngle - rollspeed
            -- if _rollAngle < 5.0 then
            --     if _y > _winAngle then
            --         _y = _winAngle
            --     end
            -- end
            SetEntityRotation(_wheel, 0.0, _y,  327.99411010742, 2, true)
            Citizen.Wait(0)
        end
    end)
end)

RegisterNetEvent("GMD_Casinopack:rollFinished")
AddEventHandler("GMD_Casinopack:rollFinished", function()
    _isRolling = false
end)


function doRoll()
    if not _isRolling then
        _isRolling = true
        local playerPed = PlayerPedId()
        local _lib = 'anim_casino_a@amb@casino@games@lucky7wheel@female'
        if IsPedMale(playerPed) then
            _lib = 'anim_casino_a@amb@casino@games@lucky7wheel@male'
        end
        local lib, anim = _lib, 'enter_right_to_baseidle'
        ESX.Streaming.RequestAnimDict(lib, function()
            local _movePos = vector3(976.94, 50.25, 74.68)
            TaskGoStraightToCoord(playerPed, _movePos.x, _movePos.y, _movePos.z, 1.0, -1, 34.52, 337.36)
            local _isMoved = false
            while not _isMoved do
                local coords = GetEntityCoords(PlayerPedId())
                if coords.x >= (_movePos.x - 0.01) and coords.x <= (_movePos.x + 0.01) and coords.y >= (_movePos.y - 0.01) and coords.y <= (_movePos.y + 0.01) then
                    _isMoved = true
                end
                Citizen.Wait(0)
            end
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end
            TaskPlayAnim(playerPed, lib, 'enter_to_armraisedidle', 8.0, -8.0, -1, 0, 0, false, false, false)
            while IsEntityPlayingAnim(playerPed, lib, 'enter_to_armraisedidle', 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end
            TriggerServerEvent("GMD_Casinopack:getLucky")
            TaskPlayAnim(playerPed, lib, 'armraisedidle_to_spinningidle_high', 8.0, -8.0, -1, 0, 0, false, false, false)
        end)
    end
end

-- Menu Controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local Cost = Config.WheelCost
        local coords = GetEntityCoords(PlayerPedId())
        if(GetDistanceBetweenCoords(coords, _wheelPos.x, _wheelPos.y, _wheelPos.z, true) < 1.5) and not _isRolling then
            ESX.ShowHelpNotification('Drücke ~INPUT_CONTEXT~ um das Glücksrad für '..Cost..' $ zu drehen.')
            if IsControlJustReleased(0, Keys['E']) then
                doRoll()
            end
        end
    end
end)

function spawnveh()
    local Spawn = vector3(Config.CasinoCarPos.Spawn.x, Config.CasinoCarPos.Spawn.y, Config.CasinoCarPos.Spawn.z)
    local carmodel = GetHashKey(Config.Carmodel)

    RequestModel(carmodel)
    while not HasModelLoaded(carmodel) do
        Citizen.Wait(0)
    end

    ESX.Game.SpawnLocalVehicle(carmodel,  Spawn, function(vehicle)
        Citizen.Wait(10)
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleOnGroundProperly(vehicle)
        Citizen.Wait(10)
        FreezeEntityPosition(vehicle, true)
        SetEntityInvincible(vehicle, true)
        SetVehicleDoorsLocked(vehicle, 2)
        _lambo = vehicle
        table.insert(casinoprops, _lambo)
    end)
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for _,wheel in pairs(casinoprops) do
            DeleteEntity(_wheel)
            DeleteEntity(_basewheel)
            DeleteEntity(_lambo)
        end
	end
end)
