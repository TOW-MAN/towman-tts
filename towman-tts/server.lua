local QBCore = exports['qb-core']:GetCoreObject()

-- Broadcasts the spoken text out loud
RegisterNetEvent('qb-localtts:server:BroadcastSpeech', function(coords, gender, text, expression)
    TriggerClientEvent('qb-localtts:client:PlaySpeech', -1, coords, gender, text, expression)
end)

-- Syncs whether a specific player is currently typing or not
RegisterNetEvent('qb-localtts:server:SetTypingStatus', function(isTyping)
    local src = source
    local targetPed = GetPlayerPed(src)
    
    if isTyping then
        Entity(targetPed).state:set('Player_Is_TTS_Typing', true, true)
        TriggerClientEvent('qb-localtts:client:SyncTypingDecor', -1, src, true)
    else
        Entity(targetPed).state:set('Player_Is_TTS_Typing', false, true)
        TriggerClientEvent('qb-localtts:client:SyncTypingDecor', -1, src, false)
    end
end)
