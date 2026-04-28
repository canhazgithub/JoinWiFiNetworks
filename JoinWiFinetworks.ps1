# Run PowerShell as Administrator

# Define all Wi-Fi networks here
$WifiNetworks = @(
    @{ SSID = "SSID1";  Password = "Password1";  ConnectionMode = "auto"   },
    @{ SSID = "SSID2"; Password = "Password2"; ConnectionMode = "manual" },
    @{ SSID = "SSID3";  Password = "Password3";  ConnectionMode = "auto"   }
)

# Folder to store temporary XML profiles
$ProfilePath = "C:\_HarcIT"

if (-not (Test-Path $ProfilePath)) {
    New-Item -Path $ProfilePath -ItemType Directory | Out-Null
}

foreach ($Network in $WifiNetworks) {
    $SSID = $Network.SSID
    $PW   = $Network.Password
    $ConnectionMode = $Network.ConnectionMode

    $SSIDHEX = ($SSID.ToCharArray() | ForEach-Object { '{0:X2}' -f [int][char]$_ }) -join ''
    $ProfileFile = Join-Path $ProfilePath "newwifiwhodis.xml"

    $XmlFile = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>$SSID</name>
    <SSIDConfig>
        <SSID>
            <hex>$SSIDHEX</hex>
            <name>$SSID</name>
        </SSID>
    </SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>$ConnectionMode</connectionMode>
    <MSM>
        <security>
            <authEncryption>
                <authentication>WPA2PSK</authentication>
                <encryption>AES</encryption>
                <useOneX>false</useOneX>
            </authEncryption>
            <sharedKey>
                <keyType>passPhrase</keyType>
                <protected>false</protected>
                <keyMaterial>$PW</keyMaterial>
            </sharedKey>
        </security>
    </MSM>
</WLANProfile>
"@

    $XmlFile | Out-File -FilePath $ProfileFile -Encoding utf8

    netsh wlan add profile filename="$ProfileFile" user=all
    netsh wlan show profile name="$SSID" key=clear
}

# Optional: connect to one of the networks after importing
# netsh wlan connect name="First_SSID"

# Optional: delete the XML files after import
 Remove-Item "$ProfilePath\newwifiwhodis.xml" -Force
