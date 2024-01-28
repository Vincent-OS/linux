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
        package in the installation (of course, it's optional)).
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
$procCount = nproc --all
Write-Host "Number of CPU threads: $procCount"

if ($Help) {
    Write-Host "Invoke-BuildManual.ps1 [options]"
    Write-Host "    -Help: Show the help message."
    Write-Host "    -NoRust: Do not build the Rust part. Only for debugging purposes."
    Write-Host "    -CheckTools: Check if all tools are installed."
    return
}
elseif ($NoRust) {
    BuildManualNoRust
}
elseif ($CheckTools) {
    CheckTools
}
else {
    BuildManual
}

function BuildManual {
    # Build the kernel
    Write-Host "Building the kernel..."
    make LLVM=1 -j$procCount | Wait-Process "make"
    $installProcess = Read-Host "Kernel is now builded! Do you want to install it? [Y/n]"
    if ($installProcess -eq "Y") {
        Write-Host "Installing the kernel modules..."
        make LLVM=1 modules_install | Wait-Process "make"
        
        Write-Host "Installing the kernel..."
        make LLVM=1 install | Wait-Process "make"
        return 0
    }
    elseif ($installProcess -eq "n") {
        Write-Host "Kernel will not be installed. Exiting..."
        return 0
    }
    else { # If else statement are badly implemented in this situation
        $installProcess
    }
}

function BuildManualNoRust {
    # Build the kernel
    Write-Host "Building the kernel..."
    make -j$procCount | Wait-Process "make"
    $installProcess = Read-Host "Kernel is now builded! Do you want to install it? [Y/n]"
    if ($installProcess -eq "Y") {
        Write-Host "Installing the kernel modules..."
        make modules_install | Wait-Process "make"
        
        Write-Host "Installing the kernel..."
        make install | Wait-Process "make"
        return 0
    }
    elseif ($installProcess -eq "n") {
        Write-Host "Kernel will not be installed. Exiting..."
        return 0
    }
    else { # If else statement are badly implemented in this situation
        $installProcess
    }
}

function CheckTools {
    $tools = @("make", "gcc", "base-devel", "xmlto", "kmod", "inetutils", "bc", "libelf", "git", "cpio", "perl", "tar", "xz", "llvm")
    $tools | ForEach-Object {
        if (Get-Command $_ -ErrorAction SilentlyContinue) {
            Write-Host "Tool $_ is installed."
        } 
        else {
            Write-Error "Tool $_ is not installed."
            return 1
        }
    }
}