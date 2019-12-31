function Get-OnHubDHCP{
    <#
      Usage:
        Set-ExecutionPolicy Bypass -Scope Process (optional - depends on execution policy)
        Import-Module googleonhubdhcp.ps1 -force
        Get-OnHubDHCP -OnHub <onhub>
      Example:
        Get-OnHubDHCP -OnHub 192.168.86.1
      Example Output:
        IP              Hostname
        --              --------
        192.168.86.10   Joe
        192.168.86.20   LG TV
    #>
    Param(
        [Parameter(Mandatory=$true)][String]$OnHub
    )

    #get report contents - should take ~10-15 seconds
    $report = Invoke-WebRequest -Uri "http://$onhub/api/v1/diagnostic-report" -Headers @{"Host"="onhub.here"}
    $matches = ($report.RawContent | Select-String '(?s)station_state_update {(.*?)}' -AllMatches).Matches.Value
    $res = @()

    #extract ip and hostnames
    foreach($match in $matches){
        #get hostname
        $h = ($match | Select-String 'dhcp_hostname: "(.*?)"').Matches.Value
        if (-not ([string]::IsNullOrEmpty($h))){
            $h = $h.Split('"')[1]
        }

        #get ip and populate array
        $i = ($match | Select-String 'ip_addresses: "(.*?)"').Matches.Value
        if (-not ([string]::IsNullOrEmpty($i))){
            $i = $i.Split('"')[1]
            $res += New-Object -TypeName PSObject -Property @{'IP'=$i;'Hostname'=$h}
        }
    }

    #return results
    $res
}
