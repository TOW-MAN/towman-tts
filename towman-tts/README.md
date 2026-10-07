# towman-tts

**towman-tts** is a proximity-based **Text-To-Speech (TTS)** script built for the **QBCore Framework** in FiveM. This script allows players to type messages into an in-game UI and broadcast them as spoken audio to nearby players. It features a real-time, network-synced 3D "Typing..." text bubble overlay above characters' heads while they use the system.

---

## 💡 Inspiration & Motivation

This project was born out of two major frustrations with standard FiveM text systems. First, typical chat systems break immersion during serious roleplay scenes—text just appears out of nowhere, leaving you guessing *who* is talking or *when* they are formulating a thought. `towman-tts` bridges this gap by combining physical movement restrictions (so characters don't awkwardly run around while typing) with a network-synced 3D visual "Typing..." bubble directly above the player's head.

Second, while looking for solutions, I noticed a massive paywall surrounding in-game Text-To-Speech. Existing resources often force server owners to register for expensive, external AI voice APIs that charge per character. Most community servers run on a strict budget and simply cannot afford these ongoing costs. I built `towman-tts` to provide a completely free, local alternative that routes data directly to baseline browser web speech engines, delivering a high-quality, immersive audio experience without costing server owners a single penny.

---

## ✨ Features

* **Configurable Proximity Audio:** Audio volume dynamically scales based on a customizable hearing distance vector (set to 10.0 meters by default), fading out seamlessly as you walk away.
* **HTML5 Voice Modulation:** Built-in support for fine-tuning text-to-speech engine delivery using precise `SpeechRate` (0.5 to 2.0) and `SpeechPitch` (0 to 2) modifiers.
* **Proactive Content Moderation:** Integrates a built-in profanity/slur filter (`Config.BlacklistedWords`) that automatically intercepts and completely blocks prohibited phrases before they are processed or broadcasted.
* **Native `ox_lib` Notifications:** Dispatches clean, real-time alert popups (configured with native top-screen warning notifications) directly to the player's UI if they trigger the word blacklist.
* **3D Visual Indicators:** Renders an official QBCore orange "Typing..." text bubble above a player's head when they have the input menu active.
* **State Synchronization:** Combines server events, client decorators, and FiveM State Bags (`Entity().state`) to cleanly sync typing states across all network clients without performance hitching.
* **Movement Safeguard:** Automatically freezes character physical movements (WASD, steering, and melee/shooting attacks) while the input window is active to prevent accidental inputs.

---

## 🛠️ Prerequisites & Dependencies

To use this script, you must have the following running on your FiveM server:
* **[QBCore Framework Core](https://github.com)**
* **[ox_lib](https://github.com)** (Used for optimized performance utilities, alerts, data handling, and background helpers)
* **[xSound](https://github.com/Xogy/xsound)** (Used for advanced audio handling, streaming, and distance attenuation)
* A companion NUI frontend UI that accepts the script's visual payloads and integrates with xSound for audio playback.

---

## 📦 Installation & Setup

1. Place the folder named `towman-tts` inside your server's `resources` directory (e.g., `[standalone]/towman-tts` or `[scripts]/towman-tts`).
2. Ensure your internal files are organized cleanly as follows:
   ```text
   towman-tts/
   ├── fxmanifest.lua
   ├── config.lua
   ├── client.lua
   ├── server.lua
   └── html/
       └── ui.html
   ```
3. Add the resources to your `server.cfg`. To avoid script dependency errors during server initialization, ensure they are started in this exact order:
   ```cfg
   ensure qb-core
   ensure ox_lib
   ensure xsound
   ensure towman-tts
   ```

### `fxmanifest.lua` Configuration
```lua
fx_version 'cerulean'
game 'gta5'

author 'TOW_MAN'
description 'No-API Proximity Text-To-Speech Interface with Config for QBCore'
version '1.2.0'

dependencies {
    'qb-core',
    'ox_lib',
    'xsound'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    -- Include your UI styles, scripts, or audio assets here
}
```

---

## ⚙️ Configuration (`config.lua`)

You can fully customize the audio delivery bounds and speech behavior directly from the configurations file:

```lua
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
```

---

## 💻 Usage & Integration

### Commands
* `/tts` - Opens the Text-To-Speech UI input bar.

### Keybindings
* **No Default Keybind:** By default, no key is pre-assigned to prevent overlapping with existing server keybinds. 
* Players must manually assign their own opening key natively via **Esc > Settings > Key Bindings > FiveM > Open Text-To-Speech (TTS) Input Bar**.

### Developer NUI Payloads
Your frontend HTML/JS interface must handle these specific NUI messages sent from the script engine:

* **`openTTSBox`**: Triggered when the user runs the command to open the input window.
* **`playTTS`**: Dispatched to clients within proximity who are authorized to hear the audio. Because your script filters out words from `Config.BlacklistedWords` on the Lua side before broadcasting, your UI doesn't have to worry about text filtering. It receives the following structure:
  ```json
  {
    "action": "playTTS",
    "text": "The message string",
    "gender": "male/female",
    "volume": 0.85, 
    "expression": "normal/excited/sad/angry",
    "rate": 1.0,
    "pitch": 1.0
  }
  ```

---

## 🤝 Support & Updates

If you run into any issues while setting up the script or notice bugs that need fixing, please feel free to reach out! You can:
* **Open an Issue:** Submit a bug report or feature request on the [Issues page](../../issues).
* **Contribute:** Pull requests are always welcome if you want to help improve the code or optimize features.

## 📄 License

This project is open-source. Feel free to modify, expand, and adapt it for your server communities.
