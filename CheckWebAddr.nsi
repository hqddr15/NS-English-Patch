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
    Push $0 ; File counter to track if any files were found
    StrCpy $0 "0"
    
    ; Check if index.html exists
    IfFileExists "$INSTDIR\index.html" CheckIndexHtml CheckIndex1Html
    
    CheckIndexHtml:
        StrCpy $0 "1" ; Mark that we found at least one file
        ; Read index.html and check for nsc/ns
        Push "$INSTDIR\index.html"
        Call ScanFileForWebMode
        Pop $1
        StrCmp $1 "" CheckIndex1Html FoundWebMode
    
    CheckIndex1Html:
        ; Check if index1.html exists
        IfFileExists "$INSTDIR\index1.html" ScanIndex1Html CheckIndex1sHtml
        
        ScanIndex1Html:
            StrCpy $0 "1" ; Mark that we found at least one file
            ; Read index1.html and check for nsc/ns
            Push "$INSTDIR\index1.html"
            Call ScanFileForWebMode
            Pop $1
            StrCmp $1 "" CheckIndex1sHtml FoundWebMode
    
    CheckIndex1sHtml:
        ; Check if index1s.html exists
        IfFileExists "$INSTDIR\index1s.html" ScanIndex1sHtml CheckIndex2Html
        
        ScanIndex1sHtml:
            StrCpy $0 "1" ; Mark that we found at least one file
            ; Read index1s.html and check for nsc/ns
            Push "$INSTDIR\index1s.html"
            Call ScanFileForWebMode
            Pop $1
            StrCmp $1 "" CheckIndex2Html FoundWebMode
    
    CheckIndex2Html:
        ; Check if index2.html exists
        IfFileExists "$INSTDIR\index2.html" ScanIndex2Html CheckFilesResult
        
        ScanIndex2Html:
            StrCpy $0 "1" ; Mark that we found at least one file
            ; Read index2.html and check for nsc/ns
            Push "$INSTDIR\index2.html"
            Call ScanFileForWebMode
            Pop $1
            StrCmp $1 "" CheckFilesResult FoundWebMode
    
    CheckFilesResult:
        ; Check if any files were found
        StrCmp $0 "0" NoFilesFound NoWebModeFound
    
    NoFilesFound:
        Pop $0
        MessageBox MB_OK|MB_ICONSTOP "Error: None of the required HTML files (index.html, index1.html, index1s.html, index2.html) found in the selected directory."
        Abort
    
    NoWebModeFound:
        Pop $0
        MessageBox MB_OK|MB_ICONSTOP "Error: No 'nsc' or 'ns' text found in any of the HTML files."
        Abort
    
    FoundWebMode:
        Pop $0
        StrCpy $WebMode $1
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