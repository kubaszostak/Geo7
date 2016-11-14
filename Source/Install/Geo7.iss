; Script generated by the Inno Setup Script Wizard.
; http://www.jrsoftware.org/

#define AppName "Geo7"
#define AppVersion "v3.0.0-beta.7"

#define AppPublisher "Kuba Szostak"
#define AppURL "https://github.com/kubaszostak/Geo7/"
#define AutoCadDir "\Autodesk\ApplicationPlugins\Geo7.AutoCAD.2013.bundle"      
#define BricsCadDir "\Bricsys\Geo7"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{1276A3CC-E7F7-4E0F-9935-2157242BA701}

AppName={#AppName}
AppVersion={#AppVersion}       
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL=https://github.com/kubaszostak/Geo7/issues
;AppUpdatesURL={#AppURL}
DefaultDirName={pf}{#AutoCadDir}
DisableDirPage=yes
DefaultGroupName={#AppName}
AllowNoIcons=yes
;LicenseFile=P:\Programs\#DevUtils\Inno Setup 5\license.txt
OutputBaseFilename={#AppName}-{#AppVersion}
Compression=lzma/normal
SolidCompression=yes
ShowLanguageDialog=auto
OutputDir=..\..\install\
;InfoAfterFile=post-install-info-pl.rtf
;WizardImageFile=geo7-wizzard-4.bmp
ArchitecturesInstallIn64BitMode=x64 ia64
SignTool=osd-ksz

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"

[Files]
;Source: "Geo7.AutoCAD.2013.bundle\*"; DestDir: "{pf}{#AutoCadDir}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: AcComponent
Source: "..\..\bin\BricsCAD_V15\Support\Geo7\*"; DestDir: "{pf}{#BricsCadDir}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: BcComponent

[Messages]
;polish.ClickFinish=Wst��ka Geo7 zostanie automatycznie wczytana po uruchomieniu programu AutoCAD. 
;english.ClickFinish=Geo7 ribbon will be loaded at AutoCAD startup.

[Components]
Name: "BcComponent"; Description: "Geo7 for BricsCAD"; Types: full; Flags: checkablealone; Check: IsBricsCadInstalled
;Name: "AcComponent"; Description: "Geo7 for AutoCAD"; Types: full; Check: IsAutoCADCadInstalled

[Types]
Name: "full"; Description: "Full installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom





;------------------------------------------------------------------------------

[CustomMessages]
english.BcMessage=asdf

[Code]

function IsBricsCadInstalled: boolean;
begin
  result:= RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Bricsys\Bricscad');
  // HKEY_LOCAL_MACHINE\SOFTWARE\Bricsys\Bricscad\V15x64
end;


function IsAutoCADCadInstalled: boolean;
begin
  result:= RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Autodesk\AutoCAD' + 'ignore-autocad');
  //HKEY_LOCAL_MACHINE\SOFTWARE\Autodesk\AutoCAD
end;


function IsDotNetDetected(version: string; service: cardinal): boolean;
// Indicates whether the specified version and service pack of the .NET Framework is installed.
//
// version -- Specify one of these strings for the required .NET Framework version:
//    'v1.1.4322'     .NET Framework 1.1
//    'v2.0.50727'    .NET Framework 2.0
//    'v3.0'          .NET Framework 3.0
//    'v3.5'          .NET Framework 3.5
//    'v4\Client'     .NET Framework 4.0 Client Profile
//    'v4\Full'       .NET Framework 4.0 Full Installation
//
// service -- Specify any non-negative integer for the required service pack level:
//    0               No service packs required
//    1, 2, etc.      Service pack 1, 2, etc. required
var
    key: string;
    install, serviceCount: cardinal;
    success: boolean;
begin
    key := 'SOFTWARE\Microsoft\NET Framework Setup\NDP\' + version;
    // .NET 3.0 uses value InstallSuccess in subkey Setup
    if Pos('v3.0', version) = 1 then begin
        success := RegQueryDWordValue(HKLM, key + '\Setup', 'InstallSuccess', install);
    end else begin
        success := RegQueryDWordValue(HKLM, key, 'Install', install);
    end;
    // .NET 4.0 uses value Servicing instead of SP
    if Pos('v4', version) = 1 then begin
        success := success and RegQueryDWordValue(HKLM, key, 'Servicing', serviceCount);
    end else begin
        success := success and RegQueryDWordValue(HKLM, key, 'SP', serviceCount);
    end;
    result := success and (install = 1) and (serviceCount >= service);
end;


function InitializeSetup(): Boolean;
begin
    result:= true;

    if not IsDotNetDetected('v4\Full', 0) then 
    begin
        MsgBox('This application requires Microsoft .NET Framework 4.0.'#13#13
            'Please install this version from www.microsoft.com/net/downloads/'#13
            'and then re-run setup program.', mbError, MB_OK);
        result := false; 
    end
    else if not (IsBricsCadInstalled or IsAutoCADCadInstalled) then 
    begin     
        MsgBox('This application requires AutoCAD or BricsCAD installed on this computer. Setup will terminate.' , mbError, MB_OK);
        result := false;
    end;
end;

procedure DeinitializeSetup();    
var msg: string;  
begin
    msg:= '';
    if IsComponentSelected('AcComponent') then 
    begin
      msg:= msg + 'Geo7 ribbon will be loaded at AutoCAD startup.'#13#13#13#13;
    end; 
            
    if IsComponentSelected('BcComponent') then 
    begin
      msg:= msg + 'Add "C:\Program Files\Bricsys\Geo7\Geo7.BricsCAD.dll" to "..\BricsCAD\Support\autoload.rx" file.'#13#13#13#13;
    end;

    if Length(msg) > 1 then 
    begin
      MsgBox(msg , mbInformation, MB_OK);
    end;
end;


function NextButtonClick(CurPageID: Integer): Boolean;
var HasSelectedComponent: boolean;
begin
  Result:= True;

  if (CurPageID = wpSelectComponents) then
  begin
    HasSelectedComponent:= IsComponentSelected('AcComponent') or IsComponentSelected('BcComponent');
    if not HasSelectedComponent then 
    begin                
      MsgBox('Select at least one component.' , mbError, MB_OK);
      Result:= False;
    end;
  end;      
end;

