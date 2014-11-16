# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.

function Expand-ZIPFile($file, $destination)
{
    $shell = new-object -com shell.application
    $zip = $shell.namespace($file)
    if (-Not (Test-Path "$destination")) { New-Item $destination -ItemType Directory -Force}
    $dst = $shell.namespace($destination)
    $dst.Copyhere($zip.items())
}

function which($name)
{
    Get-Command $name | Select-Object -ExpandProperty Definition
}

Import-Module BitsTransfer

$TMP_DIR = "$env:temp\rustup-tmp-install"
New-Item $TMP_DIR -ItemType Directory -Force | Out-Null
Set-Location $TMP_DIR

# Detect 32 or 64 bit
switch ([IntPtr]::Size)
{ 
    4 {
        $arch = 32
        $rust_dl = "https://static.rust-lang.org/dist/rust-nightly-i686-pc-windows-gnu.exe"
        $cargo_dl = "https://static.rust-lang.org/cargo-dist/cargo-nightly-i686-w64-mingw32.tar.gz"
    } 
    8 {
        $arch = 64
        $rust_dl = "https://static.rust-lang.org/dist/rust-nightly-x86_64-pc-windows-gnu.exe"
        $cargo_dl = "https://static.rust-lang.org/cargo-dist/cargo-nightly-x86_64-w64-mingw32.tar.gz"
    }
    default {echo "ERROR: The processor architecture could not be determined." ; exit 1}
}

# Detect/install 7zip
$7zip_dl= "http://downloads.sourceforge.net/project/sevenzip/7-Zip/9.20/7za920.zip"
$7z_path = "$TMP_DIR\7za920.zip"
$7z = "$TMP_DIR\7za.exe"
if(Test-Path $7z) { echo "7zip found" }
else {
    Start-BitsTransfer $7zip_dl $7z_path -DisplayName "Downloading 7zip" -Description $7zip_dl
    Expand-ZIPFile -File $7z_path -Destination "$TMP_DIR"
}

# Download the latest rust and cargo binaries
$rust_installer = "$TMP_DIR\rust_install.exe"
$cargo_binary = "$TMP_DIR\cargo_install.tar.gz"

Start-BitsTransfer $rust_dl $rust_installer -DisplayName "Downloading the lastest Rust nightly - this may take a while" -Description $rust_dl 

Start-BitsTransfer $cargo_dl $cargo_binary -DisplayName "Downloading the latest Cargo nightly - this may take a while" -Description $cargo_dl

echo "Downloads complete."

# Install the rust binaries
Start-Process $rust_installer -Wait
# Looking for the dir which has rustc in it, which may fail if the user doesn't add rust\bin to
# their path or for multiple rust versions
$rust_bin = which "rustc.exe" | Split-Path
rustc -v
echo "Rust is Ready!"

# Place the cargo binaries in the rust bin folder
Start-Process .\7za.exe -ArgumentList "e $cargo_binary -y" -NoNewWindow -Wait
Start-Process .\7za.exe -ArgumentList "e .\cargo_install.tar *.exe -r -y" -NoNewWindow -Wait
Copy-Item "$TMP_DIR\cargo.exe" $rust_bin
cargo -V
echo "Cargo is Ready!"

cmd /c pause