# Windows powershell setup script

# Move files into home directory
function Move-Home {
	
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, ValueFromPipeline))]
		$PathArgument
	)

	Process {
		if ( (Get-Item $PathArgument) -is [System.IO.DirectoryInfo] ) {
			# Add '-Exclude $exclude' to Get-ChildItem to exclude files
			Get-ChildItem $PathArgument -Recurse | Copy-Item -Destination {Join-Path $dest $_.FullName.Substring($source.length)}
		}
		else if ( Test-Path -Path $Path -PathType Leaf ) {
			Copy-Item -Destination $HOME $PathArgument
		}
		else {
			Write-Warning "Provided path $PathArgument was not a directory or file path"
		}
	}
}

# Clear duplicate path variables
function Path-Clear-Duplicates {
    $RegKey = ([Microsoft.Win32.Registry]::LocalMachine).OpenSubKey("SYSTEM\CurrentControlSet\Control\Session Manager\Environment", $True) 
    $PathValue = $RegKey.GetValue("Path", $Null, "DoNotExpandEnvironmentNames") 
    Write-host "Original path :" + $PathValue  
    $PathValues = $PathValue.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries) 
    $IsDuplicate = $False 
    $NewValues = @() 
      
    ForEach ($Value in $PathValues) 
    { 
        if ($NewValues -notcontains $Value) 
        { 
            $NewValues += $Value 
        } 
        else 
        { 
            $IsDuplicate = $True 
        } 
    } 
      
    if ($IsDuplicate) 
    { 
        $NewValue = $NewValues -join ";" 
        $RegKey.SetValue("Path", $NewValue, [Microsoft.Win32.RegistryValueKind]::ExpandString) 
        Write-Host "Duplicate PATH entry found and new PATH built removing all duplicates. New Path :" + $NewValue 
    } 
    else 
    { 
        Write-Host "No Duplicate PATH entries found. The PATH will remain the same." 
    } 
      
    $RegKey.Close() 
}

function Add-To-Path-Resolved {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, ValueFromPipeline))]
		$NewPathSafe
	)
	Process {
		$oldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path

		$newPath = "$oldPath;$NewPathSafe"
		Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
	}
}

function Add-To-Path-Arbitrary {
	param (
		$NewPathArbitrary
	)
	$NewArbitraryPath | Convert-Path | Add-To-Path-Resolved
}

function Setup-Path {
	$Non-Standard-Paths = "~/bin"
	Add-To-Path-Arbitrary $Non-Standard-Path

	Path-Clear-Duplicate
}

Setup-Path

$nextShellPath = ".\setup_common.sh" | Convert-Path
$shellPathWsl = "wslpath '$nextShellPath'" | wsl -d Ubuntu
$homePathFull = "~" | ConvertPath
$homePathWsl = "wslpath '$homePathFull'" | wsl -d Ubuntu
wsl -d Ubuntu bash "$shellPathWsl $homePathWsl windows"

git config --global user.signingKey D373CFDA7EE381FE

Get-ChildItem -Path "~\.config" -Exclude "~\.config\gh\*" -Recurse | Move-Item -Destination "$env:APPDATA"
