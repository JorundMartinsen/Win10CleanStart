function Install-Tools {
    choco install brave nordpass nordvpn vscode microsoft-windows-terminal voicemeeter -y
}

function Install-WSL2 {
    choco install wsl2 --params "/Version:2 Retry:true" -y 
}

function Install-Media {
    choco install spotify discord -y
}

function Install-GameServices {
    choco install steam epicgameslauncher -y
}

Install-Tools
Install-Media
Install-GameServices
Install-WSL2