@echo off
REM Rebuild only the C++ wrapper (LinphoneCxx) for liblinphone.
REM Run this after the main SDK build is complete.
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 (
    echo ERROR: vcvars64.bat failed
    exit /b 1
)
set PATH=%PATH%;C:\Program Files\7-Zip;C:\msys64\usr\bin;C:\msys64\mingw64\bin;C:\Program Files\doxygen\bin;C:\Users\tigaa\AppData\Local\bin\NASM;C:\Program Files\OpenSSL-Win64\bin
set SDK_DIR=C:\Users\tigaa\OneDrive\Documents\VOIP ASSOCIATES WINDOWS APP\linphone-sdk

echo Reconfiguring SDK with ENABLE_CXX_WRAPPER=ON ...
cd /d "%SDK_DIR%\build-win64"
cmake .. -G "Ninja" ^
  -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
  -DENABLE_VIDEO=OFF ^
  -DENABLE_ADVANCED_IM=OFF ^
  -DENABLE_DB_STORAGE=OFF ^
  -DENABLE_VCARD=OFF ^
  -DENABLE_UNIT_TESTS=OFF ^
  -DENABLE_TESTS=OFF ^
  -DENABLE_SPEEX=OFF ^
  -DBUILD_XERCESC_SHARED_LIBS=OFF ^
  -DENABLE_DOC=OFF ^
  -DENABLE_CXX_WRAPPER=ON ^
  "-DCMAKE_INSTALL_PREFIX=%SDK_DIR%\sdk-install"
echo CMAKE_CONFIGURE_EXIT=%ERRORLEVEL%
if errorlevel 1 exit /b 1

echo Building C++ wrapper ...
cmake --build . --target liblinphone++ --parallel
echo CMAKE_BUILD_EXIT=%ERRORLEVEL%
if errorlevel 1 exit /b 1

echo Installing ...
cmake --install .
echo CMAKE_INSTALL_EXIT=%ERRORLEVEL%
if errorlevel 1 exit /b 1

echo.
echo Done. Verify with:
echo   dir "%SDK_DIR%\sdk-install\share\LinphoneCxx\cmake\"
