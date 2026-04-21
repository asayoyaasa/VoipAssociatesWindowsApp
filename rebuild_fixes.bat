@echo off
setlocal

call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 (
    echo ERROR: vcvars64.bat failed
    exit /b 1
)

set PATH=%PATH%;C:\Qt\Tools\Ninja;C:\Program Files\7-Zip;C:\msys64\usr\bin;C:\msys64\mingw64\bin;C:\Program Files\doxygen\bin;C:\Users\tigaa\AppData\Local\bin\NASM;C:\Program Files\OpenSSL-Win64\bin

set SDK_BUILD=C:\voipapp\linphone-sdk\build-win64
set SDK_INSTALL=C:\voipapp\linphone-sdk\sdk-install
set DESKTOP_DIR=C:\voipapp\linphone-desktop

echo ===================================================
echo Step 1: Incremental rebuild of mediastreamer2.dll
echo         (fixes plumb_av_recorder NULL resampler crash)
echo ===================================================
cd /d "%SDK_BUILD%"
ninja mediastreamer2
if errorlevel 1 (
    echo ERROR: mediastreamer2 rebuild failed
    exit /b 1
)
ninja install
if errorlevel 1 (
    echo ERROR: mediastreamer2 install failed
    exit /b 1
)
echo mediastreamer2.dll rebuilt successfully.

echo.
echo ===================================================
echo Step 2: Incremental rebuild of desktop app
echo         (fixes SimpleCaptureGraph NULL resampler crash)
echo ===================================================
cd /d "%DESKTOP_DIR%\build-win64"
ninja Linphone
if errorlevel 1 (
    echo ERROR: desktop app rebuild failed
    exit /b 1
)
cmake --install .
if errorlevel 1 (
    echo ERROR: desktop app install failed
    exit /b 1
)
echo Desktop app rebuilt successfully.

echo.
echo ===================================================
echo Step 3: Copy updated DLLs to OUTPUT/bin
echo ===================================================
copy /y "%SDK_INSTALL%\bin\mediastreamer2.dll" "%DESKTOP_DIR%\build-win64\OUTPUT\bin\mediastreamer2.dll"
if errorlevel 1 (
    echo WARNING: Could not copy mediastreamer2.dll to OUTPUT/bin - check path
)
copy /y "%DESKTOP_DIR%\build-win64\bin\VoIPAssociates.exe" "%DESKTOP_DIR%\build-win64\OUTPUT\bin\VoIPAssociates.exe"
if errorlevel 1 (
    echo WARNING: Could not copy VoIPAssociates.exe to OUTPUT/bin - check path
)

echo.
echo ===================================================
echo Step 4: Rebuild installer with makensis
echo ===================================================
cd /d "C:\voipapp\installer"
"C:\Program Files (x86)\NSIS\makensis.exe" voipassociates.nsi
if errorlevel 1 (
    echo ERROR: NSIS build failed
    exit /b 1
)
echo Installer rebuilt: VoIP-Associates-Setup-1.0.0.exe

echo.
echo ALL DONE. Test the app, then run the installer on the other PC.
endlocal
