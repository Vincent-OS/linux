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
    Force update the linux kernel.

    .DESCRIPTION
    This script will force update the linux kernel to the latest version.
    It is useful if Arch Build System (ABS) is not working properly with nvidia-dkms drivers.

    .NOTES
    Do not use this script if the kernel is working properly with Arch Build System (ABS).
    This script is only for rebuilding the kernel cleanly.
#>

Set-Location ../../ # Set the location to the root directory of the kernel
$kernelPath = (Get-Location).Path

# Warn the user the potential risk of using this script
Write-Warning "This script will force update the kernel to the latest version."
Write-Warning "It is recommended to use this script only if Arch Build System (ABS) is not working properly with nvidia-dkms drivers."
Write-Warning "Before proceeding, make sure you have a backup of your work."
$proceed = Read-Host "Do you want to proceed? (Y/N)"
if ($proceed -contains "Y") {
    # Create a folder in /tmp to store the backup files
    New-Item -Path "/tmp" -Name "vos-src-kernel-backup" -ItemType "directory"

    # Backup the Makefile, and .config file before updating the kernel
    Copy-Item -Path "$kernelPath/Makefile" -Destination "/tmp/vos-src-kernel-backup/Makefile"
    Copy-Item -Path "$kernelPath/.config" -Destination "/tmp/vos-src-kernel-backup/.config"

    # Create a folder in /usr/src to store the linux source code
    New-Item -Path "/usr/src" -Name "linux-src" -ItemType "directory"
    Set-Location "/usr/src/linux-src"

    # Clone the archlinux/linux repository to /usr/src/linux
    try {
        git clone "https://github.com/archlinux/linux.git"
        Set-Location "/usr/src/linux-src/linux"
    }
    catch {
        Write-Error "Failed to clone the archlinux/linux repository."
        return 1
    }

    # Copy all the files from the cloned repository to the kernel source code forcefully
    Copy-Item -Path "/usr/src/linux-src/linux/*" -Destination "$kernelPath" -Recurse -Force

    # When finished, restore the Makefile, and .config file
    Copy-Item -Path "/tmp/vos-src-kernel-backup/Makefile" -Destination "$kernelPath/Makefile" -Force
    Copy-Item -Path "/tmp/vos-src-kernel-backup/.config" -Destination "$kernelPath/.config" -Force

    # Remove the backup folder
    Remove-Item -Path "/tmp/vos-src-kernel-backup" -Recurse -Force

    Write-Host "Kernel updated successfully. Try to rebuild the kernel with ABS."
    Write-Host "If the kernel is still not working properly, please report the issue to https://github.com/Vincent-OS/issues/issues."
    return 0
}
else {
    Write-Host "No actions taken. Have a great day!"
    return 255
}