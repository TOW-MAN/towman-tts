Config = {}

-- Max distance (in meters) that nearby players can hear the TTS audio
Config.MaxHearingDistance = 10.0

-- Voice modulation defaults (HTML5 speech engine baseline standard)
Config.SpeechRate = 1.0  -- Speed of talking (0.5 to 2.0)
Config.SpeechPitch = 1.0 -- Vocal pitch (0 to 2)

-- List of words that are completely banned from being spoken via TTS
-- Keep these lowercase inside the quotation marks so the filter catches them seamlessly
Config.BlacklistedWords = {
    "blacklistedword",
    "blacklistedword2"
}

-- Notification wrapper when a blacklisted word is caught using ox_lib text alerts
Config.Notify = function(text)
    exports['ox_lib']:notify({
        title = 'System Warning',
        description = text,
        type = 'error',
        position = 'top'
    })
end
