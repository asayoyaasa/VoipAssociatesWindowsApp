; VoIP Associates Windows Installer
; NSIS MUI2 script — produces VoIP-Associates-Setup-1.0.0.exe

Unicode True

!define APP_NAME        "VoIP Associates"
!define APP_VERSION     "1.0.0"
!define APP_EXE         "VoIPAssociates.exe"
!define APP_REG_KEY     "Software\VoIPAssociates"
!define UNINSTALL_KEY   "Software\Microsoft\Windows\CurrentVersion\Uninstall\VoIPAssociates"
!define SRC_BIN         "C:\voipapp\linphone-desktop\build-win64\OUTPUT\bin"
!define SRC_SHARE       "C:\voipapp\linphone-desktop\build-win64\OUTPUT\share\VoIPAssociates"
!define SRC_ROOTCA      "C:\voipapp\linphone-sdk\sdk-install\share\linphone\rootca.pem"
!define ICON_FILE       "C:\voipapp\linphone-desktop\Linphone\data\icon.ico"

Name "${APP_NAME} ${APP_VERSION}"
OutFile "C:\voipapp\installer\VoIP-Associates-Setup-1.0.0.exe"
InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKLM "${APP_REG_KEY}" "InstallDir"
RequestExecutionLevel admin
SetCompressor /SOLID lzma
SetCompressorDictSize 32

!include "MUI2.nsh"

; Installer pages
!define MUI_ICON "${ICON_FILE}"
!define MUI_UNICON "${ICON_FILE}"
!define MUI_WELCOMEPAGE_TITLE "Welcome to ${APP_NAME} Setup"
!define MUI_WELCOMEPAGE_TEXT "This wizard will install ${APP_NAME} ${APP_VERSION} on your computer.$\r$\n$\r$\nClick Next to continue."
!define MUI_FINISHPAGE_RUN "$INSTDIR\${APP_EXE}"
!define MUI_FINISHPAGE_RUN_TEXT "Launch ${APP_NAME}"
!define MUI_FINISHPAGE_LINK "Visit voip.associates"
!define MUI_FINISHPAGE_LINK_LOCATION "https://voip.associates/"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

; ---------------------------------------------------------------------------
; Install
; ---------------------------------------------------------------------------

Section "Main Application" SEC_MAIN
  SectionIn RO

  ; Visual C++ Redistributable (silent, no reboot prompt)
  SetOutPath "$TEMP"
  File "${SRC_BIN}\vc_redist.x64.exe"
  ExecWait '"$TEMP\vc_redist.x64.exe" /install /quiet /norestart'
  Delete "$TEMP\vc_redist.x64.exe"

  ; --- exe + Qt DLLs + SDK DLLs (all .dll in bin root) ---
  SetOutPath "$INSTDIR"
  File /x "linphone.exe" /x "linphone_app.pdb" /x "vc_redist.x64.exe" \
       "${SRC_BIN}\*.exe"
  File "${SRC_BIN}\*.dll"

  ; --- Qt plugin subdirectories ---
  SetOutPath "$INSTDIR\generic"
  File /r "${SRC_BIN}\generic\*"

  SetOutPath "$INSTDIR\iconengines"
  File /r "${SRC_BIN}\iconengines\*"

  SetOutPath "$INSTDIR\imageformats"
  File /r "${SRC_BIN}\imageformats\*"

  SetOutPath "$INSTDIR\networkinformation"
  File /r "${SRC_BIN}\networkinformation\*"

  SetOutPath "$INSTDIR\platforms"
  File /r "${SRC_BIN}\platforms\*"

  SetOutPath "$INSTDIR\qml"
  File /r "${SRC_BIN}\qml\*"

  SetOutPath "$INSTDIR\qmltooling"
  File /r "${SRC_BIN}\qmltooling\*"

  SetOutPath "$INSTDIR\styles"
  File /r "${SRC_BIN}\styles\*"

  SetOutPath "$INSTDIR\tls"
  File /r "${SRC_BIN}\tls\*"

  SetOutPath "$INSTDIR\translations"
  File /r "${SRC_BIN}\translations\*"

  ; --- SDK mediastreamer2 audio plugins ---
  ; Placed at lib\mediastreamer\plugins\ so the app's Paths.cpp finds them
  ; (MSPLUGINS_DIR = "lib/mediastreamer/plugins", resolved from exe dir)
  SetOutPath "$INSTDIR\lib\mediastreamer\plugins"
  File /r "${SRC_BIN}\lib\mediastreamer\plugins\*"

  ; --- Factory config ---
  SetOutPath "$INSTDIR\share\VoIPAssociates"
  File "${SRC_SHARE}\linphonerc-factory"

  ; --- Root CA (required for TLS SIP registration and HTTPS) ---
  SetOutPath "$INSTDIR\share\linphone"
  File "${SRC_ROOTCA}"

  ; --- Shortcuts ---
  CreateDirectory "$SMPROGRAMS\${APP_NAME}"
  CreateShortcut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" \
                 "$INSTDIR\${APP_EXE}" "" "$INSTDIR\${APP_EXE}" 0
  CreateShortcut "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk" \
                 "$INSTDIR\Uninstall.exe"
  CreateShortcut "$DESKTOP\${APP_NAME}.lnk" \
                 "$INSTDIR\${APP_EXE}" "" "$INSTDIR\${APP_EXE}" 0

  ; --- Registry ---
  WriteRegStr   HKLM "${APP_REG_KEY}" "InstallDir" "$INSTDIR"
  WriteRegStr   HKLM "${APP_REG_KEY}" "Version"    "${APP_VERSION}"

  WriteRegStr   HKLM "${UNINSTALL_KEY}" "DisplayName"     "${APP_NAME}"
  WriteRegStr   HKLM "${UNINSTALL_KEY}" "DisplayVersion"  "${APP_VERSION}"
  WriteRegStr   HKLM "${UNINSTALL_KEY}" "Publisher"       "VoIP Associates"
  WriteRegStr   HKLM "${UNINSTALL_KEY}" "URLInfoAbout"    "https://voip.associates/"
  WriteRegStr   HKLM "${UNINSTALL_KEY}" "DisplayIcon"     "$INSTDIR\${APP_EXE}"
  WriteRegStr   HKLM "${UNINSTALL_KEY}" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr   HKLM "${UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegDWORD HKLM "${UNINSTALL_KEY}" "NoModify"        1
  WriteRegDWORD HKLM "${UNINSTALL_KEY}" "NoRepair"        1

  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

; ---------------------------------------------------------------------------
; Uninstall
; ---------------------------------------------------------------------------

Section "Uninstall"
  ; Remove installed tree
  RMDir /r "$INSTDIR\generic"
  RMDir /r "$INSTDIR\iconengines"
  RMDir /r "$INSTDIR\imageformats"
  RMDir /r "$INSTDIR\networkinformation"
  RMDir /r "$INSTDIR\platforms"
  RMDir /r "$INSTDIR\qml"
  RMDir /r "$INSTDIR\qmltooling"
  RMDir /r "$INSTDIR\styles"
  RMDir /r "$INSTDIR\tls"
  RMDir /r "$INSTDIR\translations"
  RMDir /r "$INSTDIR\lib"
  RMDir /r "$INSTDIR\share\VoIPAssociates"
  RMDir /r "$INSTDIR\share\linphone"
  RMDir  "$INSTDIR\share"
  Delete "$INSTDIR\*.dll"
  Delete "$INSTDIR\*.exe"
  Delete "$INSTDIR\*.pdb"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir  "$INSTDIR"

  ; Shortcuts
  Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk"
  RMDir  "$SMPROGRAMS\${APP_NAME}"
  Delete "$DESKTOP\${APP_NAME}.lnk"

  ; Registry
  DeleteRegKey HKLM "${UNINSTALL_KEY}"
  DeleteRegKey HKLM "${APP_REG_KEY}"
SectionEnd
