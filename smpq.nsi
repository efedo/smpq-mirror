;
;    smpq.nsi - Windows NSIS Installer for StormLib MPQ archiving utility
;    Copyright (C) 2010 - 2016  Pali Rohár <pali.rohar@gmail.com>
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;

;--------------------------------

!ifdef QUIET
!verbose 2
!endif

!define redefine "!insertmacro redefine"
!macro redefine symbol value
!undef ${symbol}
!define ${symbol} "${value}"
!macroend

;--------------------------------

!include "MUI2.nsh"

;--------------------------------

!define NAME "SMPQ"
!define DESCRIPTION "StormLib MPQ archiving utility"
!define VIVERSION "${VERSION}.0.0"
!define HOMEPAGE "https://launchpad.net/smpq"
!define LICENSE "GPL v3"
!define COPYRIGHT "Copyright (c) 2010 - 2016 by Pali Rohar"

;--------------------------------

!define EXE "smpq.exe"
!define README "README"
!define COPYING "COPYING"
!define CHANGELOG "CHANGELOG"
!define UNINSTALL "uninstall.exe"
!define INSTALLER "${NAME}-${VERSION}.exe"
!define INSTALLDIR "$PROGRAMFILES\${NAME}\"
!define LANGUAGE "English"

!ifdef x86_64
${redefine} INSTALLER "${NAME}-${VERSION}-x86_64.exe"
${redefine} INSTALLDIR "$PROGRAMFILES64\${NAME}\"
${redefine} NAME "${NAME} (64 bit)"
!endif

!define REGKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"

;--------------------------------

LangString INSTALLER_RUNNING ${LANG_ENGLISH} "${NAME} Installer is already running"
LangString REMOVEPREVIOUS ${LANG_ENGLISH} "Removing previous installation"
LangString DESC_REMOVEEXE ${LANG_ENGLISH} "Remove ${NAME} executable"

!ifdef x86_64
LangString x86_64_ONLY ${LANG_ENGLISH} "This version is for 64 bits computers only"
!endif

;--------------------------------

SetCompressor lzma

!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${COPYING}"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "${LANGUAGE}"

;--------------------------------

Name "${NAME}"
OutFile "${INSTALLER}"
InstallDir "${INSTALLDIR}"
InstallDirRegKey HKLM "${REGKEY}" "InstallLocation"

VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${NAME} Installer - ${DESCRIPTION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "InternalName" "${NAME} Installer"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "${COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "License" "${LICENSE}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "Homepage" "${HOMEPAGE}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "OriginalFilename" "${INSTALLER}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${NAME} Installer"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${VERSION}"
VIProductVersion "${VIVERSION}"

BrandingText "${NAME} - ${DESCRIPTION}, version ${VERSION}  ${HOMEPAGE}"
ShowInstDetails Show
ShowUnInstDetails Show
XPStyle on
RequestExecutionLevel admin

;--------------------------------

Function .onInit

	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "${NAME}") i .r1 ?e'
	Pop $0
	StrCmp $0 0 +3

	MessageBox MB_OK|MB_ICONEXCLAMATION "$(INSTALLER_RUNNING)"
	Abort

!ifdef x86_64

	System::Call "kernel32::GetCurrentProcess() i .s"
	System::Call "kernel32::IsWow64Process(i s, *i .r0)"
	IntCmp $0 0 0 0 +3

	MessageBox MB_OK|MB_ICONSTOP "$(x86_64_ONLY)"
	Abort

!endif

FunctionEnd

;--------------------------------

Section "-${NAME}" UninstallPrevious

	SectionIn RO

	ReadRegStr $0 HKLM "${REGKEY}" "InstallLocation"
	StrCmp $0 "" +7

	DetailPrint "$(REMOVEPREVIOUS)"
	SetDetailsPrint none
	ExecWait "$0\${UNINSTALL} /S _?=$0"
	Delete "$0\${UNINSTALL}"
	RMDir $0
	SetDetailsPrint lastused

SectionEnd

Section "${NAME}"

	SectionIn RO

	SetOutPath $INSTDIR
	File "${EXE}"
	File "${README}"
	File "${COPYING}"
	File "${CHANGELOG}"
	WriteRegStr HKLM "${REGKEY}" "DisplayName" "${NAME} - ${DESCRIPTION}"
	WriteRegStr HKLM "${REGKEY}" "UninstallString" "$\"$INSTDIR\${UNINSTALL}$\""
	WriteRegStr HKLM "${REGKEY}" "QuietUninstallString" "$\"$INSTDIR\${UNINSTALL}$\" /S"
	WriteRegStr HKLM "${REGKEY}" "InstallLocation" "$INSTDIR"
	WriteRegStr HKLM "${REGKEY}" "DisplayIcon" "$\"$INSTDIR\${EXE}$\",0"
	WriteRegStr HKLM "${REGKEY}" "DisplayVersion" "${VERSION}"
	WriteRegStr HKLM "${REGKEY}" "HelpLink" "${HOMEPAGE}"
	WriteRegStr HKLM "${REGKEY}" "URLUpdateInfo" "${HOMEPAGE}"
	WriteRegStr HKLM "${REGKEY}" "URLInfoAbout" "${HOMEPAGE}"
	WriteRegDWORD HKLM "${REGKEY}" "NoModify" 1
	WriteRegDWORD HKLM "${REGKEY}" "NoRepair" 1
	WriteUninstaller "$INSTDIR\${UNINSTALL}"

SectionEnd

;--------------------------------

Section "un.${NAME}" Executable

	SectionIn RO

	Delete "$INSTDIR\${EXE}"
	Delete "$INSTDIR\${README}"
	Delete "$INSTDIR\${COPYING}"
	Delete "$INSTDIR\${CHANGELOG}"
	DeleteRegKey /ifempty HKLM "${REGKEY}"
	Delete "$INSTDIR\${UNINSTALL}"
	RMDir "$INSTDIR"

SectionEnd

!insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${Executable} $(DESC_REMOVEEXE)
!insertmacro MUI_UNFUNCTION_DESCRIPTION_END

;--------------------------------

!ifndef UPX
!define UPX "upx"
!endif

!ifndef UPX_FLAGS
!define UPX_FLAGS "-9"
!else
${redefine} UPX_FLAGS "${UPX_FLAGS} -9"
!endif

!ifdef QUIET
${redefine} UPX_FLAGS "${UPX_FLAGS} -qq"
!endif

!packhdr "exehead.tmp" "${UPX} ${UPX_FLAGS} exehead.tmp"
;!finalize "gpg --armor --sign --detach-sig %1"

;--------------------------------
