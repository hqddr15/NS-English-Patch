!include "MUI2.nsh"
!include "FileFunc.nsh"

; Global variable to store the web mode
Var WebMode

; Name and file
Name "Web Address Checker"
OutFile "WebChecker.exe"

; Default installation folder
InstallDir "$PROGRAMFILES\WebChecker"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

; Interface Settings
!define MUI_ABORTWARNING

; Pages
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE CheckWebAddr
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

; Languages
!insertmacro MUI_LANGUAGE "English"

; Function to check web address files
Function CheckWebAddr
    ; Initialize WebMode
    StrCpy $WebMode ""
    
    ; Check if index.html exists
    IfFileExists "$INSTDIR\index.html" CheckIndexHtml CheckIndex1Html
    
    CheckIndexHtml:
        ; Read index.html and check for nsc/ns
        Push "$INSTDIR\index.html"
        Call ScanFileForWebMode
        Pop $0
        StrCmp $0 "" CheckIndex1Html FoundWebMode
    
    CheckIndex1Html:
        ; Check if index1.html exists
        IfFileExists "$INSTDIR\index1.html" ScanIndex1Html NoFilesFound
        
        ScanIndex1Html:
            ; Read index1.html and check for nsc/ns
            Push "$INSTDIR\index1.html"
            Call ScanFileForWebMode
            Pop $0
            StrCmp $0 "" NoWebModeFound FoundWebMode
    
    NoFilesFound:
        MessageBox MB_OK|MB_ICONSTOP "Error: Neither index.html nor index1.html found in the selected directory."
        Abort
    
    NoWebModeFound:
        MessageBox MB_OK|MB_ICONSTOP "Error: No 'nsc' or 'ns' text found in the HTML files."
        Abort
    
    FoundWebMode:
        StrCpy $WebMode $0
        ; Optional: Show success message
        ; MessageBox MB_OK "Web mode detected: $WebMode"
        
FunctionEnd

; Function to scan a file for nsc or ns
; Input: File path on stack
; Output: WebMode value on stack ("nsc", "ns", or "")
Function ScanFileForWebMode
    Exch $0 ; File path
    Push $1 ; File handle
    Push $2 ; Line buffer
    Push $3 ; Result
    
    StrCpy $3 "" ; Initialize result
    
    ; Open file for reading
    FileOpen $1 "$0" r
    IfErrors ScanFileError
    
    ScanLoop:
        ; Read line from file
        FileRead $1 $2
        IfErrors ScanFileEnd
        
        ; Check for "nsc" first (higher priority)
        ${StrLoc} $R0 $2 "nsc" ">"
        StrCmp $R0 "" CheckForNs FoundNsc
        
        FoundNsc:
            StrCpy $3 "nsc"
            Goto ScanFileEnd
            
        CheckForNs:
            ; Check for "ns"
            ${StrLoc} $R0 $2 "ns" ">"
            StrCmp $R0 "" ScanLoop FoundNs
            
        FoundNs:
            ; Only set to "ns" if we haven't found "nsc" yet
            StrCmp $3 "" 0 ScanLoop
            StrCpy $3 "ns"
            Goto ScanLoop ; Continue scanning for "nsc"
    
    ScanFileEnd:
        FileClose $1
        Goto ScanFileReturn
        
    ScanFileError:
        StrCpy $3 ""
        
    ScanFileReturn:
        Pop $2
        Pop $1
        Exch $3
        Exch
        Pop $0
FunctionEnd

; Installer Section
Section "Main" SecMain
    SetOutPath "$INSTDIR"
    ; Your installation files would go here
    WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

; Uninstaller
Section "Uninstall"
    Delete "$INSTDIR\Uninstall.exe"
    RMDir "$INSTDIR"
SectionEnd