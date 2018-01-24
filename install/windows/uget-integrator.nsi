; uget-integrator is a tool to integrate uGet Download manager
; with Google Chrome, Chromium, Vivaldi and Opera in Linux and Windows.

; Copyright (C) 2016  Gobinath

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;--------------------------------
!macro StrRep output string old new
    Push `${string}`
    Push `${old}`
    Push `${new}`
    !ifdef __UNINSTALL__
        Call un.StrRep
    !else
        Call StrRep
    !endif
    Pop ${output}
!macroend

!macro Func_StrRep un
    Function ${un}StrRep
        Exch $R2 ;new
        Exch 1
        Exch $R1 ;old
        Exch 2
        Exch $R0 ;string
        Push $R3
        Push $R4
        Push $R5
        Push $R6
        Push $R7
        Push $R8
        Push $R9

        StrCpy $R3 0
        StrLen $R4 $R1
        StrLen $R6 $R0
        StrLen $R9 $R2
        loop:
            StrCpy $R5 $R0 $R4 $R3
            StrCmp $R5 $R1 found
            StrCmp $R3 $R6 done
            IntOp $R3 $R3 + 1 ;move offset by 1 to check the next character
            Goto loop
        found:
            StrCpy $R5 $R0 $R3
            IntOp $R8 $R3 + $R4
            StrCpy $R7 $R0 "" $R8
            StrCpy $R0 $R5$R2$R7
            StrLen $R6 $R0
            IntOp $R3 $R3 + $R9 ;move offset by length of the replacement string
            Goto loop
        done:

        Pop $R9
        Pop $R8
        Pop $R7
        Pop $R6
        Pop $R5
        Pop $R4
        Pop $R3
        Push $R0
        Push $R1
        Pop $R0
        Pop $R1
        Pop $R0
        Pop $R2
        Exch $R1
    FunctionEnd
!macroend

!define StrRep "!insertmacro StrRep"
!insertmacro Func_StrRep ""

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General
  !define _VERSION "2.0.7.0"
  !define _PROGRAM_NAME "uget-integrator"

  ;Name and file
  Name "uGet Chrome Wrapper"
  OutFile "${_PROGRAM_NAME}_${_VERSION}.exe"

  ;Default installation folder
  InstallDir $PROGRAMFILES\${_PROGRAM_NAME}

  ;Get installation folder from registry if available
  InstallDirRegKey HKLM "Software\${_PROGRAM_NAME}" "Install_Dir"

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_LICENSE "../../LICENSE"
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Version Information
  VIProductVersion "${_VERSION}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "uGet Integrator"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "Integrate uGet Download Manager with Google Chrome, Chromium, Vivaldi, Opera and Mozilla Firefox"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "ugetdm.com"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "Copyright 2018 ugetdm.com"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "uGet Integrator installer"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${_VERSION}"
  
;--------------------------------
; The stuff to install
Section "${_PROGRAM_NAME} (required)"

	SectionIn RO

	; Set output path to the installation directory.
	SetOutPath $INSTDIR

	; Put the script
	File "..\..\${_PROGRAM_NAME}\bin\${_PROGRAM_NAME}"

	Rename $INSTDIR\${_PROGRAM_NAME} $INSTDIR\${_PROGRAM_NAME}.py

	; Replace \ by \\ in the installation path
	${StrRep} $0 "$INSTDIR" "\" "\\"
	
	; Put the ${_PROGRAM_NAME}.bat file
	File "..\..\${_PROGRAM_NAME}\windows\${_PROGRAM_NAME}.bat"

	; Update the com.ugetdm.chrome.json file
	FileOpen $9 $INSTDIR\com.ugetdm.chrome.json w ;Opens a Empty File an fills it
	FileWrite $9 '{"name":"com.ugetdm.chrome","description":"Integrate uGet with Google Chrome","path":"$0\\${_PROGRAM_NAME}.bat","type":"stdio","allowed_origins":["chrome-extension://efjgjleilhflffpbnkaofpmdnajdpepi/","chrome-extension://akcbnhoidebjpiefdkmaaicfgdpbnoac/"]}$\r$\n'
	FileClose $9 ;Closes the filled file

    ; Update the com.ugetdm.firefox.json file
	FileOpen $9 $INSTDIR\com.ugetdm.firefox.json w ;Opens a Empty File an fills it
	FileWrite $9 '{"name":"com.ugetdm.firefox","description":"Integrate uGet with Mozilla Firefox","path":"$0\\${_PROGRAM_NAME}.bat","type":"stdio","allowed_extensions":["uget-integration@slgobinath"]}$\r$\n'
	FileClose $9 ;Closes the filled file
	
	; Put the icon
	File "uget-icon.ico"

	; Write the installation path into the registry
	WriteRegStr HKLM SOFTWARE\${_PROGRAM_NAME} "Install_Dir" "$INSTDIR"
	WriteRegStr HKCU "SOFTWARE\Google\Chrome\NativeMessagingHosts\com.ugetdm.chrome" "" "$INSTDIR\com.ugetdm.chrome.json"
	WriteRegStr HKLM "SOFTWARE\Google\Chrome\NativeMessagingHosts\com.ugetdm.chrome" "" "$INSTDIR\com.ugetdm.chrome.json"
	WriteRegStr HKCU "SOFTWARE\Mozilla\NativeMessagingHosts\com.ugetdm.firefox" "" "$INSTDIR\com.ugetdm.firefox.json"
	WriteRegStr HKLM "SOFTWARE\Mozilla\NativeMessagingHosts\com.ugetdm.firefox" "" "$INSTDIR\com.ugetdm.firefox.json"


	; Write the uninstall keys for Windows
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_PROGRAM_NAME}" "DisplayName" "uGet Integrator"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_PROGRAM_NAME}" "Publisher" "ugetdm.com"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_PROGRAM_NAME}" "HelpLink" "http://ugetdm.com/help"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_PROGRAM_NAME}" "URLUpdateInfo" "http://ugetdm.com/downloads"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_PROGRAM_NAME}" "URLInfoAbout" "http://ugetdm.com/about"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_PROGRAM_NAME}" "DisplayVersion" "${_VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_PROGRAM_NAME}" "UninstallString" '"$INSTDIR\uninstall.exe"'
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_PROGRAM_NAME}" "DisplayIcon" "$INSTDIR\uget-icon.ico,0"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_PROGRAM_NAME}" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_PROGRAM_NAME}" "NoRepair" 1
	WriteUninstaller "uninstall.exe"

SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"

	; Remove registry keys
	DeleteRegKey HKCU "SOFTWARE\Google\Chrome\NativeMessagingHosts\com.ugetdm.chrome"
	DeleteRegKey HKLM "SOFTWARE\Google\Chrome\NativeMessagingHosts\com.ugetdm.chrome"
	DeleteRegKey HKCU "SOFTWARE\Mozilla\NativeMessagingHosts\com.ugetdm.firefox"
	DeleteRegKey HKLM "SOFTWARE\Mozilla\NativeMessagingHosts\com.ugetdm.firefox"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_PROGRAM_NAME}"
	DeleteRegKey HKLM SOFTWARE\${_PROGRAM_NAME}

	; Remove files and uninstaller
	Delete $INSTDIR\${_PROGRAM_NAME}.py
	Delete $INSTDIR\${_PROGRAM_NAME}.bat
	Delete $INSTDIR\com.ugetdm.chrome.json
	Delete $INSTDIR\com.ugetdm.firefox.json
	Delete $INSTDIR\uget-icon.ico
	Delete $INSTDIR\uninstall.exe

	; Remove directories used
	RMDir "$INSTDIR"

SectionEnd

;--------------------------------
; uninstall the previous version
Function .onInit
 
  ReadRegStr $R0 HKLM \
  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${_PROGRAM_NAME}" \
  "UninstallString"
  StrCmp $R0 "" done
 
  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
  "${_PROGRAM_NAME} is already installed. $\n$\nClick `OK` to remove the \
  previous version or `Cancel` to cancel this upgrade." \
  IDOK uninst
  Abort
 
;Run the uninstaller
uninst:
  ClearErrors
  Exec $R0
done:
 
FunctionEnd