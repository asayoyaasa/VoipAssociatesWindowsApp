# VoIP Associates Windows Softphone

A branded Windows SIP softphone for VoIP Associates, built on top of [Linphone Desktop](https://gitlab.linphone.org/BC/public/linphone-desktop) (Qt 6 / QML + liblinphone SDK).

---

## Features

- SIP audio calling (UDP/TCP/TLS)
- DTMF, hold, call transfer
- Contact and call history
- ICE/STUN NAT traversal
- Echo cancellation (WebRTC AEC)
- Opus, PCMA/PCMU, G.722 codecs
- Windows toast notifications
- Single executable installer — no separate runtime required

---

## Download

Get the latest installer from [Releases](https://github.com/asayoyaasa/VoipAssociatesWindowsApp/releases).

**Requirements:** Windows 10 or 11, 64-bit.  
The installer bundles all dependencies (VC++ runtime, Qt 6, codec DLLs). No internet connection required to install.

---

## Building from Source

### Prerequisites

Install all tools before starting. Exact paths matter — do not change install locations.

| Tool | Version | Notes |
|---|---|---|
| Visual Studio 2022 | Community or higher | Install with "Desktop development with C++" workload |
| CMake | 3.22+ | Add to PATH |
| Qt | 6.11.0 | Install `msvc2022_64` kit via Qt Online Installer |
| Ninja | bundled with Qt | `C:\Qt\Tools\Ninja\ninja.exe` |
| NSIS | 3.x | For building the installer |
| MSYS2 | latest | Required for some SDK build helpers |
| Python 3 | 3.8+ | Install `pystache` via pip |
| OpenSSL | Win64 | `C:\Program Files\OpenSSL-Win64\` |
| NASM | latest | For opus/srtp assembly |
| 7-Zip | latest | Used by SDK build scripts |

> **Important:** Visual Studio 2022 installs to `\18\` not `\2022\`. All build scripts use:  
> `C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat`

### Step 1 — Create the directory junction

The build requires a path without spaces. Create a Windows junction once:

```bat
mklink /J C:\voipapp "C:\Users\YourName\path\to\VoIP ASSOCIATES WINDOWS APP"
```

All build scripts use `C:\voipapp\...` paths.

### Step 2 — Clone submodules

```bat
cd C:\voipapp
git clone https://github.com/BelledonneCommunications/linphone-desktop linphone-desktop
git clone --recurse-submodules https://gitlab.linphone.org/BC/public/linphone-sdk linphone-sdk
```

> **Note:** If GitLab is inaccessible, use the copies already in this repo's working tree (they are gitignored from the main repo but exist on disk after the first build).

### Step 3 — Build the SDK (one-time, ~1–2 hours)

```bat
C:\voipapp\build_sdk.bat
C:\voipapp\rebuild_sdk_cxx.bat
```

This produces `linphone-sdk\sdk-install\` with all headers, static libs, and DLLs.

**Do not re-run these unless resetting the SDK from scratch.** They contain non-obvious patches to srtp, jsoncpp, and genwrapper.py that must not be lost.

### Step 4 — Build the desktop app

```bat
C:\voipapp\build_desktop.bat
```

On success: `linphone-desktop\build-win64\OUTPUT\bin\VoIPAssociates.exe`

### Step 5 — Build the installer

```bat
"C:\Program Files (x86)\NSIS\makensis.exe" C:\voipapp\installer\voipassociates.nsi
```

Output: `installer\VoIP-Associates-Setup-1.0.0.exe`

### Incremental rebuild (after code changes)

```bat
C:\voipapp\rebuild_fixes.bat
```

Rebuilds only what changed (mediastreamer2 DLL if SDK source changed, then the app, then the installer).

---

## Project Structure

```
VoIP ASSOCIATES WINDOWS APP/
├── build_sdk.bat           — Phase 1: full SDK build (run once)
├── rebuild_sdk_cxx.bat     — Phase 1b: adds C++ wrapper to SDK (run once)
├── build_desktop.bat       — Phase 2+: full desktop configure + build + install
├── rebuild_fixes.bat       — Fast incremental rebuild for day-to-day changes
├── installer/
│   └── voipassociates.nsi  — NSIS installer script
├── linphone-sdk/           — SDK source + build output (gitignored)
└── linphone-desktop/       — App source — fork of Linphone Desktop (gitignored)
    └── Linphone/           — All C++ and QML application source
```

> `linphone-sdk/` and `linphone-desktop/` are their own Git repositories and are gitignored in this repo. They live on disk after building.

---

## Key Customisation Points

| What | Where |
|---|---|
| App name, version, bundle ID | `linphone-desktop/Linphone/application_info.cmake` |
| SIP defaults (user-agent, STUN, keep-alive) | `linphone-desktop/Linphone/model/core/CoreModel.cpp` → `CoreModel::start()` |
| Factory SIP config (expires, ICE, codecs) | `linphone-desktop/Linphone/data/config/linphonerc-factory` |
| Color theme | `linphone-desktop/Linphone/view/Style/DefaultStyle.qml`, `Themes.qml` |
| App icon | `linphone-desktop/Linphone/data/icon/icon.ico` |
| Logo / splash | `linphone-desktop/Linphone/data/image/logo.svg`, `splashscreen-logo.svg` |
| Installer script | `installer/voipassociates.nsi` |

---

## Known Limitations

- **No video** — SDK built with `ENABLE_VIDEO=OFF`. Video call UI is hidden.
- **No chat** — disabled in factory config and UI.
- **No call recording audio quality guarantee** — the speex DSP resampler is not compiled in (BC's speex fork has no CMakeLists.txt). Call recording infrastructure is present but sample-rate conversion is skipped. Workaround patches are in place to prevent crashes.
- **Unsigned binaries** — SmartScreen will warn on first run until the exe and installer are code-signed.

---

## License

This project is a fork of [Linphone Desktop](https://gitlab.linphone.org/BC/public/linphone-desktop), which is licensed under the **GNU General Public License v3.0**. All modifications in this repository are also distributed under GPLv3.

See [LICENSE](https://www.gnu.org/licenses/gpl-3.0.en.html) for details.

---

## Contact

**VoIP Associates**  
[voip.associates](https://voip.associates)
