rustup-powershell
=================

A rustup equivalent for Windows using Powershell

This is an attempt to provide a `rustup.sh` equivalent for Windows. `rustup.ps1` will download the latest Windows Rust and Cargo binaries, run the Rust installer, and then places `cargo.exe` in the Rust's bin directory.

The script is designed to work on any Windows with Powershell 2.0, but is currently only confirmed on the following:
- Windows 7 64-bit.
- Windows 8.1 64-bit.

### How to Use

The one liner:

`(new-object System.Net.WebClient).Downloadfile("https://raw.githubusercontent.com/Fireforge/rustup-powershell/master/rustup.ps1", "rustup.ps1") ; .\rustup.ps1`

The script is still very fresh, please report bugs!

### If you get the message "rustup.ps1 cannot be loaded because the execution of scripts is disabled on this system."

Powershell has security restrictions on running scripts, especially scripts from the internet. So before you can run it, you might have to enter one of the following command in a Powershell with Admin privileges.

`Set-ExecutionPolicy RemoteSigned` or `Set-ExecutionPolicy Unrestricted`

**WARNING: This may introduce security risks! Use this only if you trust this script won't attack your computer.**

To keep yourself safe from accidentally running evil scripts later on, run this when you're done with `rustup.ps1`

`Set-ExecutionPolicy AllSigned`

For more on what this all means, read [here](http://technet.microsoft.com/en-us/library/hh847748.aspx)
