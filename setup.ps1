# Windows powershell setup script

# Clear duplicate path variables
function Path-Clear-Duplicates {
    $RegKey = ([Microsoft.Win32.Registry]::LocalMachine).OpenSubKey(
        "SYSTEM\CurrentControlSet\Control\Session Manager\Environment", $True
    );

    $PathValue = $RegKey.GetValue("Path", $Null, "DoNotExpandEnvironmentNames");
    $PathValues = $PathValue.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries);
    $IsDuplicate = $False;
    $NewValues = @();

    ForEach ($Value in $PathValues) 
    { 
        if ($NewValues -notcontains $Value) 
        { 
            $NewValues += $Value;
        } 
        else 
        { 
            $IsDuplicate = $True;
        } 
    } 

    if ($IsDuplicate) 
    { 
        $NewValue = $NewValues -join ";" 
            $RegKey.SetValue("Path", $NewValue, [Microsoft.Win32.RegistryValueKind]::ExpandString) 
            Write-Host "Duplicate PATH entry found and new PATH built removing all duplicates. ";
    } 
    else 
    { 
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

function Setup-Path {
    New-Item -ItemType Directory -Force -Path "~/bin" 2>&1 | out-null
        $NonStandardPath = @("~\bin", "C:\Program Files\Neovim\bin")
        Add-To-Path-Arbitrary $NonStandardPath;

        Path-Clear-Duplicates;
}

Setup-Path;

$nextShellPath = ".\setup_common.sh" | Convert-Path;
$shellPathWsl = "wslpath '$nextShellPath'" | wsl -d Ubuntu;
$homePathFull = "~" | Convert-Path;
$homePathWsl = "wslpath '$homePathFull'" | wsl -d Ubuntu;
wsl -d Ubuntu bash $shellPathWsl $homePathWsl windows;

git config --global user.signingKey D373CFDA7EE381FE;

mkdir "$HOME\.config"
[System.Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', "$HOME\.config", [System.EnvironmentVariableTarget]::Machine)
$source = "~\.config" | Convert-Path;
$dest = $env:APPDATA;
$exclude = @("~\.config\nvim\", "~\.config\gh\*");
Get-ChildItem $source -Recurse -Exclude $exclude | Copy-Item -Destination {Join-Path $dest $_.FullName.Substring($source.length)} 2>&1 | out-null;
$source = "~\.config" | Convert-Path;
$dest = $env:APPDATA;
$exclude = @("~\.config\nvim\", "~\.config\gh\*");
Get-ChildItem $source -Recurse -Exclude $exclude | Copy-Item -Destination {Join-Path $dest $_.FullName.Substring($source.length)} 2>&1 | out-null;
