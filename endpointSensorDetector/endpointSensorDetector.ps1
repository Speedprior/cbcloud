# Store your API key here
$ApiKey = "API secret key / API ID, with Device Read permissions"
$OrgKey = "Org Key"



# Retrieve the hostname and IP address of the host
$HostName = [System.Net.Dns]::GetHostName()
$IPAddresses = [System.Net.Dns]::GetHostAddresses($HostName) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -ExpandProperty IPAddressToString

# Function to check for the presence of the Carbon Black Cloud sensor MSI installation log
function CheckMSILog {
    $LogFile = "C:\Windows\Temp\CBDefenseInstaller.log"

    if (Test-Path $LogFile) {
        $Content = Get-Content $LogFile
        if ($Content -match "Installation success") {
            return $true
        }
    }

    return $false
}

# Function to verify the sensor status using the repcli command
function CheckRepCliStatus {
    $RepCliStatus = & 'C:\Program Files\Confer\repcli.exe' status

    if ($RepCliStatus -match "Sensor operational") {
        return $true
    }

    return $false
}

# Function to query the Carbon Black Cloud Platform API for the device
function CheckDeviceInCBC {
    param (
        $ApiKey,
        $HostName,
        $IPAddresses
    )
 
    # Set API URL, headers, and parameters
    $ApiUrl = 'https://defense-prod05.conferdeploy.net/appservices/v6/orgs/' + $OrgKey + '/devices/_search'
    $Headers = @{
        "X-Auth-Token" = $ApiKey
        "Content-Type" = "application/json"
    } 

    # Generate query string for hostname and IP addresses
    $IPQuery = ($IPAddresses | ForEach-Object {  $_ }) -join " OR "
    $Query = "($IPQuery) AND name:$HostName"

    $Body = @{
        query = $Query
        rows = 10
        start = 0
    } | ConvertTo-Json


    # Invoke the API request
    $Response = Invoke-RestMethod -Method Post -Uri $ApiUrl -Headers $Headers -Body $Body

    # Check if the device is present and connected
    if ($Response.num_found -gt 0) {
        foreach ($Device in $Response.results) {
            if ($Device.name -eq $HostName -and $Device.status -eq "REGISTERED") {
                return $true
            }
        }
    }
 
    return $false
}
# Check MSI log, repcli status, and query Carbon Black Cloud Platform API
$MSILogResult = CheckMSILog
$RepCliResult = CheckRepCliStatus
$CBCResult = CheckDeviceInCBC $ApiKey $HostName $IPAddresses

Write-host "MSI Log: " $MSILogResult "RepCli: " $RepCliResult "Back-end: " $CBCResult
