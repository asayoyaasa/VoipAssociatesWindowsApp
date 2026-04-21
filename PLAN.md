# VoIP Associates Windows Softphone — Build Plan

**Approach:** Fork and rebrand Linphone Desktop (Qt/C++ + liblinphone SDK)  
**Target:** Windows 10/11 installer, branded as "VoIP Associates Softphone"  
**License note:** Linphone Desktop is GPLv3. Distributing a modified version requires your source code to also be publicly available under GPLv3.

---

## Tech Stack

| Layer | Technology |
|---|---|
| SIP engine | liblinphone (via linphone-sdk) |
| UI framework | Qt 6.11.0 (QML + C++) |
| Build system | CMake 3.22+ |
| Compiler | MSVC 2022 (Visual Studio 2022) |
| Packaging | NSIS or Qt IFW (installer) |
| Source base | linphone-desktop (forked) |

---

## Repository Structure

```
VOIP ASSOCIATES WINDOWS APP/
├── PLAN.md                          ← this file
├── HANDOFF.md                       ← session state for new agents
├── build_sdk.bat                    ← Phase 1 build script (complete, keep)
├── rebuild_sdk_cxx.bat              ← Phase 1b: adds CXX wrapper to SDK (complete)
├── build_desktop.bat                ← Phase 2 build script (complete)
├── linphone-sdk/                    ← SDK source + built artifacts
│   ├── build-win64/                 ← CMake build dir
│   └── sdk-install/                 ← installed SDK output (headers + libs)
├── linphone-desktop/                ← UI source (forked, Phase 2 complete)
│   └── build-win64/                 ← desktop build dir
└── installer/                       ← NSIS script + installer assets (Phase 6)
```

> **Junction:** `C:\voipapp` is a Windows directory junction pointing to this project root.
> All build scripts use `C:\voipapp\...` paths to avoid spaces in CMake/Qt paths.

---

## Phase 0 — Environment Setup ✅ COMPLETE

All tools installed and verified on 2026-04-21.

| Tool | Path |
|---|---|
| Visual Studio 2022 | `C:\Program Files\Microsoft Visual Studio\18\Community` |
| CMake | `C:\Program Files\CMake\bin\` |
| Qt 6.11.0 | `C:\Qt\6.11.0\msvc2022_64\` |
| Ninja | `C:\Qt\Tools\Ninja\ninja.exe` |
| MSYS2 | `C:\msys64\` |
| 7-Zip | `C:\Program Files\7-Zip\` |
| Doxygen | `C:\Program Files\doxygen\bin\` |
| NASM | `C:\Users\tigaa\AppData\Local\bin\NASM\` |
| OpenSSL | `C:\Program Files\OpenSSL-Win64\` |
| Python packages | `pystache` (pip) |

> **CRITICAL PATH NOTE:** VS 2022 is installed at `\18\` not `\2022\`. Always use:
> `C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat`

---

## Phase 1 — Build Linphone SDK ✅ COMPLETE

**Completed:** 2026-04-21  
**Build scripts:** `build_sdk.bat` + `rebuild_sdk_cxx.bat`  
**Install prefix:** `linphone-sdk\sdk-install\`

### Confirmed output
- `sdk-install\lib\liblinphone.lib` ✅
- `sdk-install\lib\liblinphone++.lib` ✅
- `sdk-install\include\linphone\core.h` ✅
- `sdk-install\share\LibLinphone\cmake\LibLinphoneConfig.cmake` ✅
- `sdk-install\share\LinphoneCxx\cmake\LinphoneCxxConfig.cmake` ✅

### CMake flags used
```
-G "Ninja"
-DCMAKE_BUILD_TYPE=RelWithDebInfo
-DENABLE_CXX_WRAPPER=ON              ← added in rebuild_sdk_cxx.bat
-DENABLE_VIDEO=OFF
-DENABLE_ADVANCED_IM=OFF
-DENABLE_DB_STORAGE=OFF
-DENABLE_VCARD=OFF
-DENABLE_UNIT_TESTS=OFF
-DENABLE_TESTS=OFF
-DENABLE_SPEEX=OFF
-DBUILD_XERCESC_SHARED_LIBS=OFF      ← NOTE: XERCESC not XERCES (with C)
-DENABLE_DOC=OFF
-DCMAKE_INSTALL_PREFIX=<sdk-install>
```

### Non-obvious fixes applied (DO NOT UNDO)
1. `external/srtp/CMakeLists.txt` — renamed `ENABLE_MBEDTLS` → `SRTP_ENABLE_MBEDTLS`, etc.
2. `external/srtp/` — replaced BC fork with GitHub upstream `cisco/libsrtp` v2
3. `external/jsoncpp/` — replaced with GitHub upstream `open-source-parsers/jsoncpp`
4. Speex disabled — BC's fork has no CMakeLists.txt
5. `coreapi/help/doc/doxygen/Doxyfile.in` — `GENERATE_HTML = NO` to prevent Windows MAX_PATH overflow
6. `wrappers/cpp/genwrapper.py` — added `linphone_config_is_readonly` + `linphone_core_new_with_config` to `functionBl` blacklist

---

## Phase 2 — Clone and Configure Linphone Desktop ✅ COMPLETE

**Completed:** 2026-04-21  
**Build script:** `build_desktop.bat`  
**Output:** `linphone-desktop\build-win64\bin\linphone.exe` ✅

All three CMake stages pass: configure (exit 0), build (exit 0), install (exit 0).

### What was done
- Shallow-cloned linphone-desktop from GitHub mirror
- Created Windows junction `C:\voipapp` → project root (avoids path-with-spaces bugs in Qt6LinguistTools)
- Created `sdk-install\share\linphone\cmake\linphoneTargets.cmake` shim (bridges path mismatch in `FindLibLinphone.cmake`)
- Patched `Mediastreamer2Targets.cmake` — added `MS2_PLUGINS_DIR` property
- Patched `LibLinphoneTargets.cmake` — added `LIBLINPHONE_PLUGINS_DIR` property; fixed `jsoncpp_lib` → `jsoncpp` name
- Added `target_link_directories(${TARGET_NAME} PRIVATE "${LINPHONE_OUTPUT_DIR}/lib")` to `Linphone/CMakeLists.txt` so MSVC finds all SDK `.lib` files by bare name
- Patched `FindBCToolbox.cmake` — fallback for imported targets + `include(BCToolboxCMakeUtils.cmake)`
- Made Qt6NetworkAuth conditional on `ENABLE_APP_OAUTH2` in `Linphone/CMakeLists.txt`
- Replaced `OIDCModel.hpp/.cpp` with stub (no Qt NetworkAuth dependency)
- Added `#include <QUrl>` to `ChatMessageContentCore.hpp`
- Added `LINPHONESDK_VERSION` fallback in `Linphone/CMakeLists.txt`
- Fixed PDB install to skip IMPORTED targets

### Next step
Run `linphone-desktop\build-win64\bin\linphone.exe` to verify it launches before starting Phase 3.

---

## Phase 3 — Rebrand: Identity and Assets ⬅ NEXT

**Goal:** Replace all Linphone identity with VoIP Associates branding.  
**Estimated time:** 2–4 hours

### 3.1 App name and IDs

In `CMakeLists.txt` and `Linphone/application_info.cmake`:
- `LINPHONEAPP_APPLICATION_NAME` → `"VoIP Associates"`
- `LINPHONEAPP_EXECUTABLE_NAME` → `"VoIPAssociates"`
- Bundle ID → `"com.voipassociates.desktop"`
- Vendor → `"VoIP Associates"`
- Version → `"1.0.0"`

### 3.2 Window title and About dialog

Grep `linphone-desktop/Linphone/` for `"Linphone"` strings and replace:
- Window title → `"VoIP Associates"`
- About box → VoIP Associates name, website, support email
- First-run / welcome screen → remove linphone.org references

### 3.3 App icon

Replace:
- SVG logo in `Linphone/data/` or `assets/images/`
- `.ico` file (multi-size: 16, 32, 48, 256px)
- Windows resource file: update icon path

### 3.4 Color theme

Find the QML theme/constants file (search for `Theme.qml` or `ConstantsCpp.qml`):
- Primary: `#0EA5E9` (VoIP Associates cyan-blue)
- Dark bg: `#0F172A`
- Surface: `#1E293B`
- End-call red: `#EF4444`

---

## Phase 4 — UI Customization

**Goal:** Simplify UI to match VoIP Associates feature set.  
**Estimated time:** 1–2 days

- Remove/hide video call UI (SDK already built without video)
- Remove instant messaging / chat tab
- Remove "Create Linphone account" / linphone.org signup
- Simplify account setup wizard to: Display Name, Username, Password, Domain, Port
- Match dialer and in-call screen layout to Android app

---

## Phase 5 — SIP Configuration Defaults

**Goal:** Pre-configure SIP to match Android app behaviour.

Key settings to apply at `LinphoneCore` init (find `CoreManager.cpp` or equivalent):
```cpp
linphone_core_set_user_agent(core, "VoIP Associates Official App", "1.0");
linphone_core_set_stun_server(core, "stun.l.google.com:19302");
// enable ICE+STUN via NatPolicy
linphone_core_enable_video_capture(core, FALSE);
linphone_core_enable_video_display(core, FALSE);
linphone_core_enable_keep_alive(core, TRUE);
// account expires = 1800
```

---

## Phase 6 — Packaging (Windows Installer)

**Goal:** Produce a `.exe` installer.

1. Run `windeployqt --qmldir ../Linphone/ui VoIPAssociates.exe`
2. Write NSIS script in `installer/voipassociates.nsi`
3. `makensis installer/voipassociates.nsi` → `VoIP-Associates-Setup-1.0.0.exe`

---

## Phase 7 — GitHub Release

1. `gh release create v1.0.0 VoIP-Associates-Setup-1.0.0.exe`

---

## Phase 8 — Testing Checklist

On a clean Windows machine (no Qt/VS installed):
- [ ] Installer runs, app launches from Start Menu
- [ ] Can add SIP account and register
- [ ] Outgoing + incoming calls work, audio both directions
- [ ] Hold, DTMF, transfer work
- [ ] No "Linphone" text anywhere in UI
- [ ] About dialog shows VoIP Associates branding
- [ ] Uninstaller cleans up completely

---

## Phase Overview

| Phase | Status |
|---|---|
| 0 — Environment setup | ✅ Complete |
| 1 — Build linphone-sdk | ✅ Complete |
| 2 — Configure linphone-desktop | ✅ Complete — `linphone.exe` builds and installs |
| 3 — Rebrand | Not started |
| 4 — UI customisation | Not started |
| 5 — SIP defaults | Not started |
| 6 — Packaging (NSIS) | Not started |
| 7 — GitHub release | Not started |
| 8 — Testing | Not started |
