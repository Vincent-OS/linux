<#
    Vincent OS Kernel, the Linux Kernel for Vincent OS.
    Copyright (C) 2024 - v38armageddon

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#>
<#
    .SYNOPSIS
        This script is used to build the Vincent OS Kernel manually.

    .DESCRIPTION
        The script build the Vincent OS Kernel manually for distributions that
        are not based on Arch Linux or if, and only if, you really have
        problems to build with Arch Build System.
    
    .PARAMETER -Help
        Show the help message.
    
    .PARAMETER -NoRust
        Do not build the Rust part. Only for debugging purposes.
    
    .PARAMETER -Check
        Check if all tools are installed.
    
    .NOTES
        I know some of you gonna hate me for doing this but I feel funny to
        add PowerShell script to Vincent OS (and because I deliver PowerShell
        package in the installation).
#>

[cmdletbinding()]
param (
    [parameter(Mandatory=$false)]
    [switch]$Help,
    [parameter(Mandatory=$false)]
    [switch]$NoRust,
    [parameter(Mandatory=$false)]
    [switch]$CheckTools
)

# Collect the numbers of CPU threads in linux
$procCount = (Get-Content /proc/cpuinfo | Select-String -Pattern "processor" | Measure-Object).Count
if ($procCount -lt 1) {
    $procCount = 2
}
Write-Host "Number of CPU threads: $procCount"

if ($Help) {
    Write-Host @"
Invoke-BuildManual.ps1 [options]
    -Help: Show the help message.
    -NoRust: Do not build the Rust part. Only for debugging purposes.
    -CheckTools: Check if all tools are installed.
"@
    return
}
elseif ($NoRust) {
    try {
        Set-Location ../../ # Go to the kernel source directory

        # Save the .config file and clean old builds
        Write-Host "Saving the .config file..."
        make olddefconfig

        Write-Host "Cleaning old builds..."
        make clean

        # Build the kernel
        Write-Host "Building the kernel..."
        make -j $procCount
        $installProcess = Read-Host "Kernel is now built! Do you want to install it? [Y/n]"
        if ($installProcess -eq "Y") {
            Write-Host "Installing the kernel modules..."
            make modules_install
            
            Write-Host "Installing the kernel..."
            make install
            return 0
        }
        elseif ($installProcess -eq "n") {
            Write-Host "Kernel will not be installed. Exiting..."
            return 0
        }
        else {
            $installProcess
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Error "An error occurred during the build process: $errorMessage"
        $errorMessage | Out-File -FilePath "/var/log/KERNEL_Build_error.log" -Append
        return 2
    }
}
elseif ($CheckTools) {
    Write-Warning "If you see that some tools are not installed,"
    Write-Warning "please double check using your package manager."
    Write-Warning "Before performing a build."
    $tools = @("make", "gcc", "base-devel", "xmlto", "kmod", "inetutils", "bc", "libelf", "git", "cpio", "perl", "tar", "xz", "llvm", "rustup")
    $tools | ForEach-Object {
        $toolCheck = if (Get-Command $_ -ErrorAction SilentlyContinue) {
            Write-Host "Tool $_ is installed."
        } 
        else {
            Write-Error "Tool $_ is not installed."
            return 1
        }
        if ($toolCheck -eq 1) {
            Write-Error "Tool $_ is not installed."
        }
    }
}
else {
    try {
        Set-Location ../../ # Go to the kernel source directory

        # Save the .config file and clean old builds
        Write-Host "Saving the .config file..."
        make LLVM=1 olddefconfig

        Write-Host "Cleaning old builds..."
        make LLVM=1 clean

        # Build the kernel
        Write-Host "Building the kernel..."
        make LLVM=1 -j $procCount
        $installProcess = Read-Host "Kernel is now built! Do you want to install it? [Y/n]"
        if ($installProcess -eq "Y") {
            Write-Host "Installing the kernel modules..."
            make LLVM=1 modules_install
            
            Write-Host "Installing the kernel..."
            make LLVM=1 install
            return 0
        }
        elseif ($installProcess -eq "n") {
            Write-Host "Kernel will not be installed. Exiting..."
            return 0
        }
        else {
            $installProcess
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Error "An error occurred during the build process: $errorMessage"
        $errorMessage | Out-File -FilePath "/var/log/KERNEL_Build_error.log" -Append
        return 2
    }
}
