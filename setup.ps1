# Windows powershell setup script
function Test-Administrator {  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

# Clear duplicate path variables
function Remove-Path-Duplicates {

    $RegKey = ([Microsoft.Win32.Registry]::LocalMachine).OpenSubKey(
        "SYSTEM\CurrentControlSet\Control\Session Manager\Environment", $True
    );

    $PathValue = $RegKey.GetValue("Path", $Null, "DoNotExpandEnvironmentNames");
    $PathValues = $PathValue.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries);
    $IsDuplicate = $False;
    $NewValues = @();

    ForEach ($Value in $PathValues) { 
        if ($NewValues -notcontains $Value) { 
            $NewValues += $Value;
        } 
        else { 
            $IsDuplicate = $True;
        } 
    } 

    if ($IsDuplicate) { 
        $NewValue = $NewValues -join ";" 
        $RegKey.SetValue("Path", $NewValue, [Microsoft.Win32.RegistryValueKind]::ExpandString) 
        Write-Host "Duplicate PATH entry found and new PATH built removing all duplicates. ";
    } 
    else { 
        Write-Host "No Duplicate PATH entries found. The PATH will remain the same.";
    } 

    $RegKey.Close();
}

function Add-To-Path-Resolved {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $NewPathSafe
    )
    Process {
        $oldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path;

        $newPath = "$oldPath;$NewPathSafe";
        Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath;
    }
}

function Add-To-Path-Arbitrary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $NewPathArbitrary
    )
    $NewPathArbitrary | Convert-Path | Add-To-Path-Resolved;
}

function Update-Path {
    New-Item -ItemType Directory -Force -Path "~/bin" 2>&1 | out-null
    $NonStandardPath = @("~\bin", "C:\Program Files\Neovim\bin")
    Add-To-Path-Arbitrary $NonStandardPath;

    Remove-Path-Duplicates;
}

if ( Test-Administrator ) {
    Update-Path;
    [System.Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', "$HOME\.config", [System.EnvironmentVariableTarget]::Machine)
}
else {
    Write-Host "Unable to edit path because script was not run as administrator"
    Write-Host "Unable to edit 'XDG_CONFIG_HOME' because script was not run as administrator"
}

Write-Host "Running bash script"
$nextShellPath = ".\setup_common.sh" | Convert-Path;
$shellPathWsl = "wslpath '$nextShellPath'" | wsl -d Ubuntu;
$homePathFull = "~" | Convert-Path;
$homePathWsl = "wslpath '$homePathFull'" | wsl -d Ubuntu;
wsl -d Ubuntu bash $shellPathWsl $homePathWsl windows;

git config --global user.signingKey D373CFDA7EE381FE;

Write-Host "Setting up nvim path in vscode settings"
$nvim_path = Get-Command nvim | ForEach-Object { $_.Source };
$vscode_path = "~\.config\Code\User\settings.json"
$a = Get-Content "$vscode_path" -raw | ConvertFrom-Json
$a | ForEach-Object { $_."vim.neovimPath" = "$nvim_path" }
$a | ConvertTo-Json -depth 32 | set-content "$vscode_path"

Write-Host "Copying settings from .convig to AppData if necessary"
mkdir -Force "$HOME\.config" | Out-Null
$source = "$HOME\.config" | Convert-Path;
$dest = $env:APPDATA;
$exclude = @("~\.config\nvim\", "~\.config\gh\*");
Get-ChildItem $source -Recurse -Exclude $exclude | Copy-Item -Destination { Join-Path $dest $_.FullName.Substring($source.length) } 2>&1 | out-null;
$source = "~\.config" | Convert-Path;
$dest = $env:APPDATA;
$exclude = @("~\.config\nvim\", "~\.config\gh\*");
Get-ChildItem $source -Recurse -Exclude $exclude | Copy-Item -Destination { Join-Path $dest $_.FullName.Substring($source.length) } 2>&1 | out-null;

Write-Host "Done setting up";
