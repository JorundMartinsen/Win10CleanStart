function Install-Tools {
    choco install git -y 
    choco install 7zip -y 
    choco install brave -y 
    choco install nordpass -y 
    choco install nordvpn -y 
    choco install vscode -y 
    choco install microsoft-windows-terminal -y 
    choco install nodejs -y
    choco install yarn -y
    choco install voicemeeter -y
}

function Install-WSL2 {
    choco install wsl2 --params "/Version:2 Retry:true" -y 
    
}
function Install-Ubuntu{
    choco install wsl-ubuntu-2004 -y
}
function Install-Media {
    choco install spotify -y 
    choco install discord -y 
    choco install obs-studio -y 
    choco install obs-move-transition -y
}

function Install-GameServices {
    choco install steam -y 
    choco install steamcmd -y
    choco install epicgameslauncher -y
}

Install-Tools
Install-Media
Install-GameServices
Install-WSL2