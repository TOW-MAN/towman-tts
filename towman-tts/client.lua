local QBCore = exports['qb-core']:GetCoreObject()
local isOpen = false

if not Config then
    Config = {
        MaxHearingDistance = 25.0
    }
end

-- Beautiful, authentic rounded conversation bubble rendering function
local function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    
    if onScreen then
        -- 1. Setup text properties (Vibrant Orange Word Indicator)
        SetTextScale(0.42, 0.42) 
        SetTextFont(4) -- Clean, modern font style
        SetTextProportional(1)
        SetTextColour(255, 130, 0, 255) -- Bold QBCore Orange
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        
        local dynamicText = "Typing..."
        AddTextComponentString(dynamicText)
        
        -- 2. Render an official rounded text bubble texture directly behind the word
        HasStreamedTextureDictLoaded("hud_textures")
        if HasStreamedTextureDictLoaded("hud_textures") then
            DrawSprite("hud_textures", "chat_bubble", _x, _y + 0.018, 0.075, 0.038, 0.0, 15, 15, 15, 210)
        else
            RequestStreamedTextureDict("hud_textures", true)
        end

        -- 3. Draw text over the bubble layer cleanly
        DrawText(_x, _y)
    end
end

-- Re-usable function to trigger the UI opening logic
local function OpenTTSMenu()
    if isOpen then return end
    
    isOpen = true
    SetNuiFocus(true, true) 
    SendNUIMessage({
        action = "openTTSBox"
    })
    TriggerServerEvent('qb-localtts:server:SetTypingStatus', true)
end

RegisterCommand('tts', function()
    OpenTTSMenu()
end, false)

-- Registers the command into the GTA V Key Bindings settings menu natively.
RegisterKeyMapping('tts', 'Open Text-To-Speech (TTS) Input Bar', 'keyboard', '')

-- NUI callback triggered when user presses Enter (UPDATED WITH BLACKLIST WORD SCANNER)
RegisterNUICallback('submitTTS', function(data, cb)
    local text = data.text
    local gender = data.gender
    local expression = data.expression or "normal"
    
    -- Convert text payload to lowercase for seamless structural screening
    local lowerText = string.lower(text)
    local containsBlacklistedWord = false

    -- Intercept and scan phrase string indices against your config list arrays
    if Config.BlacklistedWords then
        for _, word in ipairs(Config.BlacklistedWords) do
            if string.find(lowerText, string.lower(word), 1, true) then
                containsBlacklistedWord = true
                break
            end
        end
    end

    -- Filter Breach Execution
    if containsBlacklistedWord then
        if Config.Notify then
            Config.Notify("Your message contains blacklisted terminology and cannot be spoken!")
        else
            TriggerEvent('chat:addMessage', { color = { 255, 0, 0 }, args = { "System", "Your message contains blacklisted terminology!" } })
        end
        cb('ok')
        return -- Hard stops execution pipeline so the message never broadcasts to the server layer!
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    TriggerServerEvent('qb-localtts:server:BroadcastSpeech', playerCoords, gender, text, expression)
    cb('ok')
end)

-- NUI callback triggered ONLY when the player hits Escape
RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false) 
    isOpen = false
    TriggerServerEvent('qb-localtts:server:SetTypingStatus', false)
    cb('ok')
end)

-- Proximity audio reception handler
RegisterNetEvent('qb-localtts:client:PlaySpeech', function(speakerCoords, gender, text, expression)
    local playerPed = PlayerPedId()
    local myCoords = GetEntityCoords(playerPed)
    local distance = #(myCoords - speakerCoords)
    local maxDistance = Config.MaxHearingDistance 

    if distance <= maxDistance then
        local volume = 1.0 - (distance / maxDistance)
        if volume < 0.1 then volume = 0.1 end

        SendNUIMessage({
            action = "playTTS",
            text = text,
            gender = gender,
            volume = volume,
            expression = expression
        })
    end
end)

-- Loop to draw bubbles and safely disable movement keys when the menu is active
CreateThread(function()
    RequestStreamedTextureDict("hud_textures", true)

    while true do
        local sleep = 500
        
        -- SAFEGUARD: If the TTS menu is open, freeze the player's physical movements completely
        if isOpen then
            sleep = 0
            -- Disables character movement inputs (WASD, steering, attacking)
            DisableControlAction(0, 30, true)  -- Move LR
            DisableControlAction(0, 31, true)  -- Move UD
            DisableControlAction(0, 32, true)  -- Move W
            DisableControlAction(0, 33, true)  -- Move S
            DisableControlAction(0, 34, true)  -- Move A
            DisableControlAction(0, 35, true)  -- Move D
            DisableControlAction(0, 24, true)  -- Attack / Left Click
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 140, true) -- Light Melee Attack (R)
            DisableControlAction(0, 141, true) -- Heavy Melee Attack (Q)
            DisableControlAction(0, 142, true) -- Melee Attack (LClick)
        end

        local myPed = PlayerPedId()
        local myCoords = GetEntityCoords(myPed)

        for _, player in ipairs(GetActivePlayers()) do
            local targetPed = GetPlayerPed(player)
            
            if DecorExistOn(targetPed, "Player_Is_TTS_Typing") and DecorGetBool(targetPed, "Player_Is_TTS_Typing") then
                local headCoords = GetPedBoneCoords(targetPed, 31086, 0.0, 0.0, 0.0)
                local distance = #(myCoords - headCoords)

                if distance < 25.0 then
                    sleep = 0
                    local bubblePosition = vec3(headCoords.x, headCoords.y, headCoords.z + 0.45)
                    DrawText3D(bubblePosition, "...")
                end
            end
        end
        Wait(sleep)
    end
end)

-- State Sync Event Receiver
RegisterNetEvent('qb-localtts:client:SyncTypingDecor', function(targetServerId, status)
    local targetPlayer = GetPlayerFromServerId(targetServerId)
    if targetPlayer ~= -1 then
        local targetPed = GetPlayerPed(targetPlayer)
        DecorSetBool(targetPed, "Player_Is_TTS_Typing", status)
    end
end)

-- Setup State Decorator types on script launch
CreateThread(function()
    DecorRegister("Player_Is_TTS_Typing", 2)
end)
