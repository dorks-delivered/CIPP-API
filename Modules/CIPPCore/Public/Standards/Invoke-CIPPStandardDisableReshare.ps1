function Invoke-DisableReshare {
    <#
    .FUNCTIONALITY
    Internal
    #>
    param($Tenant, $Settings)
    If ($Settings.Remediate) {
        

        try {
            $body = '{"isResharingByExternalUsersEnabled": "False"}'
            $Request = New-GraphPostRequest -tenantid $tenant -Uri 'https://graph.microsoft.com/beta/admin/sharepoint/settings' -AsApp $true -Type patch -Body $body -ContentType 'application/json'
            Write-Host ($Request | ConvertTo-Json)
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Disabled guests from resharing files' -sev Info
        } catch {
            Write-LogMessage -API 'Standards' -tenant $tenant -message "Failed to disable guests from resharing files: $($_.exception.message)" -sev Error
        }
    }
    if ($Settings.Alert) {
        $CurrentInfo = New-GraphGetRequest -Uri 'https://graph.microsoft.com/beta/admin/sharepoint/settings' -tenantid $Tenant -AsApp $true
        if ($CurrentInfo.isResharingByExternalUsersEnabled -eq $false) {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Guests are not allowed to reshare files' -sev Info
        } else {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Guests are allowed to reshare files' -sev Alert
        }
    }
    if ($Settings.Report) {
        Add-CIPPBPAField -FieldName 'DisableReshare' -FieldValue [bool]$CurrentInfo.isResharingByExternalUsersEnabled -StoreAs bool -Tenant $tenant
    }
}
