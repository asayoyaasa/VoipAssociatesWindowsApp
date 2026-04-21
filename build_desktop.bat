@echo off
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 (
    echo ERROR: vcvars64.bat failed
    exit /b 1
)
set PATH=%PATH%;C:\Qt\Tools\Ninja;C:\Program Files\7-Zip;C:\msys64\usr\bin;C:\msys64\mingw64\bin;C:\Program Files\doxygen\bin;C:\Users\tigaa\AppData\Local\bin\NASM;C:\Program Files\OpenSSL-Win64\bin
set SDK_DIR=C:\voipapp\linphone-sdk\sdk-install
set DESKTOP_DIR=C:\voipapp\linphone-desktop
mkdir "%DESKTOP_DIR%\build-win64" 2>nul
cd /d "%DESKTOP_DIR%\build-win64"
cmake .. -G "Ninja" ^
  -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
  -DLINPHONE_QT_ONLY=ON ^
  "-DLINPHONE_OUTPUT_DIR=%SDK_DIR%" ^
  "-DQt6_DIR=C:\Qt\6.11.0\msvc2022_64\lib\cmake\Qt6" ^
  "-DCMAKE_PREFIX_PATH=C:\Qt\6.11.0\msvc2022_64;%SDK_DIR%" ^
  "-DCMAKE_INSTALL_PREFIX=C:\voipapp\linphone-desktop\app-install" ^
  "-DLINPHONEAPP_APPLICATION_NAME=VoIP Associates" ^
  -DLINPHONEAPP_EXECUTABLE_NAME=VoIPAssociates ^
  -DLINPHONEAPP_VERSION=1.0.0
echo CMAKE_CONFIGURE_EXIT=%ERRORLEVEL%
if errorlevel 1 exit /b 1
cmake --build . --parallel
echo CMAKE_BUILD_EXIT=%ERRORLEVEL%
if errorlevel 1 exit /b 1
cmake --install .
echo CMAKE_INSTALL_EXIT=%ERRORLEVEL%
