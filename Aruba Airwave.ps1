#
# Aruba Airwave.ps1 - Aruba Airwave
#

Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$Log_MaskableKeys = @(
    "password",    
    "proxy_password"
)

$Properties = @{
    ApList = @(
                @{ name = 'id';           										options = @('default','key')} 
                @{ name = 'controller_id';           									options = @('default')}    
                @{ name = 'device_category';           									options = @('default')}    
                @{ name = 'firmware';           									options = @('default')}
                @{ name = 'folder_id';           								options = @('default')}
                @{ name = 'folder_text';           								options = @('default')}
                @{ name = 'group_id';           							    options = @('default')}
                @{ name = 'group_text';           							    options = @('default')}
                @{ name = 'is_remote_ap';           						        options = @('default')}
                @{ name = 'is_up';           						    options = @('default')}
                @{ name = 'lan_ip';           						    options = @('default')}
                @{ name = 'lan_mac';           							options = @('default')}
                @{ name = 'last_contacted';           						    options = @('default')}
                @{ name = 'last_reboot';           						    options = @('default')}
                @{ name = 'mesh_mode';           						    options = @('default')}
                @{ name = 'mfgr';           						    options = @('default')}
                @{ name = 'model_id';           						    options = @('default')}
                @{ name = 'model_text';           						    options = @('default')}
                @{ name = 'monitor_only';           						    options = @('default')}
                @{ name = 'name';           						    options = @('default')}
                @{ name = 'notes';           						    options = @('default')}
                @{ name = 'operating_mode';           						    options = @('default')}
                @{ name = 'planned_maintenance_mode';           						    options = @('default')}
                @{ name = 'radio';           						    options = @('default')}
                @{ name = 'reboot_count';           						    options = @('default')}
                @{ name = 'serial_number';           						    options = @('default')}
                @{ name = 'snmp_uptiime';           						    options = @('default')}
                @{ name = 'ssid';           						    options = @('default')}
                @{ name = 'syscontact';           						    options = @('default')}
                @{ name = 'syslocation';           						    options = @('default')}
                @{ name = 'upstream_device_id';           						    options = @('default')}
                @{ name = 'upstream_port_index';           						    options = @('default')}
            )
}

#
# System functions
#
function Idm-SystemInfo {
    param (
        # Operations
        [switch] $Connection,
        [switch] $TestConnection,
        [switch] $Configuration,
        # Parameters
        [string] $ConnectionParams
    )

    Log info "-Connection=$Connection -TestConnection=$TestConnection -Configuration=$Configuration -ConnectionParams='$ConnectionParams'"

    if ($Connection) {
        @(
            @{
                name = 'connection_header'
                type = 'text'
                text = 'Connection'
				tooltip = 'Connection information for the database'
            }    
            @{
                name = 'hostname'
                type = 'textbox'
                label = 'Hostname'
                description = 'IP or Hostname of server. e.g. airwave.domain.com'
                value = 'airwave.domain.com'
            }
            @{
                name = 'username'
                type = 'textbox'
                label = 'Username'
                description = 'User account name to access server'
            }
            @{
                name = 'password'
                type = 'textbox'
                password = $true
                label = 'Password'
                description = 'User account password to access server'
            }
            @{
                name = 'use_proxy'
                type = 'checkbox'
                label = 'Use Proxy'
                description = 'Use Proxy server for requets'
                value = $false                  # Default value of checkbox item
            }
            @{
                name = 'proxy_address'
                type = 'textbox'
                label = 'Proxy Address'
                description = 'Address of the proxy server'
                value = 'http://127.0.0.1:8888'
                disabled = '!use_proxy'
                hidden = '!use_proxy'
            }
            @{
                name = 'use_proxy_credentials'
                type = 'checkbox'
                label = 'Use Proxy Credentials'
                description = 'Use credentials for proxy'
                value = $false
                disabled = '!use_proxy'
                hidden = '!use_proxy'
            }
            @{
                name = 'proxy_username'
                type = 'textbox'
                label = 'Proxy Username'
                label_indent = $true
                description = 'Username account'
                value = ''
                disabled = '!use_proxy_credentials'
                hidden = '!use_proxy_credentials'
            }
            @{
                name = 'proxy_password'
                type = 'textbox'
                password = $true
                label = 'Proxy Password'
                label_indent = $true
                description = 'User account password'
                value = ''
                disabled = '!use_proxy_credentials'
                hidden = '!use_proxy_credentials'
            }
            @{
                name = 'connection_timeout'
                type = 'textbox'
                label = 'Connection Timeout'
                description = 'Time it takes for the connection to timeout'
                value = '3600'
            }
            @{
                name = 'session_header'
                type = 'text'
                text = 'Session Options'
				tooltip = 'Options for system session'
            }
			@{
                name = 'nr_of_sessions'
                type = 'textbox'
                label = 'Max. number of simultaneous sessions'
                tooltip = ''
                value = 1
            }
            @{
                name = 'sessions_idle_timeout'
                type = 'textbox'
                label = 'Session cleanup idle time (minutes)'
                tooltip = ''
                value = 1
            }
        )
    }

    if ($TestConnection) {
        
    }

    if ($Configuration) {
        @()
    }

    Log info "Done"
}

function Idm-OnUnload {
}

#
# Object CRUD functions
#

function Idm-ApListRead {
    param (
        # Mode
        [switch] $GetMeta,    
        # Parameters
        [string] $SystemParams,
        [string] $FunctionParams

    )
        $Class = "ApList"
        $system_params   = ConvertFrom-Json2 $SystemParams
        $function_params = ConvertFrom-Json2 $FunctionParams

        if ($GetMeta) {
            Get-ClassMetaData -SystemParams $SystemParams -Class $Class
            
        } else {
            Open-AirwaveConnection -system_params $System_params
            $response = Get-AirwaveRequest -Method "GET" -Uri "$($system_params.hostname)/ap_list.xml" -System_params $system_params

            $properties = ($Global:Properties.$Class).name
            $hash_table = [ordered]@{}

            foreach ($prop in $properties.GetEnumerator()) {
                $hash_table[$prop] = ""
            }
            
            foreach($rowItem in $response.amp_ap_list.ap.GetEnumerator()) {
                
                $row = New-Object -TypeName PSObject -Property $hash_table

                foreach($prop in $rowItem.PSObject.properties) {
                    if($prop.Name -eq 'folder') {
                        $row.folder_id = $prop.Value.id
                        $row.folder_text = $prop.Value.'#text'
                        continue
                    }

                    if($prop.Name -eq 'group') {
                        $row.group_id = $prop.Value.id
                        $row.group_text = $prop.Value.'#text'
                        continue
                    }
                    
                    if($prop.Name -eq 'model') {
                        $row.model_id = $prop.Value.id
                        $row.model_text = $prop.Value.'#text'
                        continue
                    }
                    
                    if(!$properties.contains($prop.Name)) { 
                        log warn "$($prop.Name) not configured, skipping"
                        continue
                    }

                    if($prop.Name -eq 'Date') {
                        $row.($prop.Name) = try { ([datetime]::ParseExact($prop.Value, "MMM d, yyyy h:mmtt", $null)).ToString("yyyy-MM-dd HH:mm") } catch{}
                    } else {
                        $row.($prop.Name) = $prop.Value
                    }
                    
                    
                    }

                $row
            } 
        }
}

function Get-AirwaveRequest {
    param (
        [string] $Uri,
        [string] $Method,
        [hashtable] $System_params
    )
    
    $splat = @{
               Method = $method
               Uri = "https://$($uri)"

    }
    
    try {
        Log verbose "Retrieving [$($splat.Uri)]"

        if($system_params.use_proxy) {
                    
            $splat["Proxy"] = $system_params.proxy_address

            if($system_params.use_proxy_credentials)
            {
                $splat["proxyCredential"] = New-Object System.Management.Automation.PSCredential ($system_params.proxy_username, (ConvertTo-SecureString $system_params.proxy_password -AsPlainText -Force) )
            }
        }

        [xml](Invoke-WebRequest @splat -WebSession $Global:Session -UseBasicParsing -ErrorAction Stop)
    }
    catch [System.Net.WebException] {
        Log error "Error : $($_)"
        throw $_
    }
    catch {
        Log error "Error : $($_)"
        throw $_
    }
}

function Open-AirwaveConnection {
    param (
        [hashtable] $System_params
    )
    try {
        $splat = @{
            Method = "GET"
            Uri = "https://$($System_params.hostname)/LOGIN"
            Body = @{
                "destination"  = "/api"
                "credential_0" = $System_params.username
                "credential_1" = $System_params.password
                "login"        = "Log In"
            }
            Headers = $headers
        }

        if ($System_params.use_proxy) {
            $splat["Proxy"] = $System_params.proxy_address
            if ($System_params.use_proxy_credentials) {
                $splat["ProxyCredential"] = New-Object System.Management.Automation.PSCredential (
                    $System_params.proxy_username,
                    (ConvertTo-SecureString $System_params.proxy_password -AsPlainText -Force)
                )
            }
        }

        $Global:Session = $null
        Invoke-WebRequest @splat -SessionVariable Session -UseBasicParsing -ErrorAction Stop | Out-Null
        $Global:Session = $Session
    }
    catch {
        Log error "Error : $($_)"
        throw
    }
}


function Close-AirwaveConnection {
    param (
        [hashtable] $SystemParams
    )
    
   
}

function Get-ClassMetaData {
    param (
        [string] $SystemParams,
        [string] $Class
    )

    @(
        @{
            name = 'properties'
            type = 'grid'
            label = 'Properties'
            table = @{
                rows = @( $Global:Properties.$Class | ForEach-Object {
                    @{
                        name = $_.name
                        usage_hint = @( @(
                            foreach ($opt in $_.options) {
                                if ($opt -notin @('default', 'idm', 'key')) { continue }

                                if ($opt -eq 'idm') {
                                    $opt.Toupper()
                                }
                                else {
                                    $opt.Substring(0,1).Toupper() + $opt.Substring(1)
                                }
                            }
                        ) | Sort-Object) -join ' | '
                    }
                })
                settings_grid = @{
                    selection = 'multiple'
                    key_column = 'name'
                    checkbox = $true
                    filter = $true
                    columns = @(
                        @{
                            name = 'name'
                            display_name = 'Name'
                        }
                        @{
                            name = 'usage_hint'
                            display_name = 'Usage hint'
                        }
                    )
                }
            }
            value = ($Global:Properties.$Class | Where-Object { $_.options.Contains('default') }).name
        }
    )
}
