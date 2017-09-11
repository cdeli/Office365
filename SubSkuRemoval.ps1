$Password = "mysecurepasswordthatyouneedtomakeifyouwanttoautomatethis" | ConvertTo-SecureString -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential('uautomate@contoso.onmicrosoft.com', $Password)
Connect-AzureAD -Credential $Cred

$Group = Get-AzureADGroup -SearchString "GroupName"
$Members = Get-AzureADGroupMember -All $true -ObjectId $Group.ObjectId
$member = $members[0]
ForEach ($Member in $Members) { 
    Set-AzureADUser -ObjectId $Member.ObjectId -UsageLocation US
        $SkuFeaturesToEnable = @("EXCHANGE_S_ENTERPRISE","OFFICESUBSCRIPTION","SHAREPOINTENTERPRISE","MCOSTANDARD","RMS_S_ENTERPRISE","PROJECTWORKMANAGEMENT",  "STREAM_O365_E3","FORMS_PLAN_E3","SHAREPOINTWAC")
        $StandardLicense = Get-AzureADSubscribedSku | Where-Object {$_.SkuId -eq "6fd2c87f-b296-42f0-b197-1e91e994b900"}
        $SkuFeaturesToDisable = $StandardLicense.ServicePlans | ForEach-Object { $_ | Where-Object {$_.ServicePlanName -notin $SkuFeaturesToEnable }}
        $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
        $License.SkuId = $StandardLicense.SkuId
        $License.DisabledPlans = $SkuFeaturesToDisable.ServicePlanId
        $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $LicensesToAssign.AddLicenses = $License
    Set-AzureADUserLicense -ObjectId $Member.ObjectId -AssignedLicenses $LicensesToAssign
}