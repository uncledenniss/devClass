# Prompt the user to log in with admin credentials
Connect-AzureAD

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "P@ssword123"
$PasswordProfile.ForceChangePasswordNextLogin = $false

# Prompt the user for the domain suffix
$DomainSuffix = Read-Host "Enter the domain suffix for the users (e.g., johndoe.onmicrosoft.com)"

for ($i = 1; $i -le 20; $i++) {
    $DisplayName = "Test User $i"
    $UserPrincipalName = "testuser$i@$DomainSuffix"
    $MailNickname = "testuser$i"  # Unique value for each user
    $NewUser = New-AzureADUser -AccountEnabled $true -DisplayName $DisplayName -PasswordProfile $PasswordProfile -UserPrincipalName $UserPrincipalName -MailNickname $MailNickname
}

$GroupName = "Varonis Assignment Group"
$MailNickname = "varonis"  # Replace with your desired mailNickname

$NewGroup = New-AzureADGroup -DisplayName $GroupName -MailNickname $MailNickname -MailEnabled $false -SecurityEnabled $true

$GroupObjectId = $NewGroup.ObjectId

# Prompt the user for the log file path
$LogFilePath = Read-Host "Enter the log file path (e.g., C:\Users\file\log\varonis\VaronisAssignmentGroup.log)"

$LogMessageFormat = "{0} - {1} - {2}"

for ($i=1; $i -le 20; $i++) {
    $UserPrincipalName = "testuser$i@$DomainSuffix"
    $User = Get-AzureADUser -ObjectId $UserPrincipalName
    Add-AzureADGroupMember -ObjectId $GroupObjectId -RefObjectId $User.ObjectId

    # Determine the result based on whether the user was successfully added to the group
    $LogResult = if ($?) { "User added to group" } else { "Failed to add user to group" }

    $LogMessage = $LogMessageFormat -f (Get-Date), $UserPrincipalName, $LogResult
    $LogMessage | Out-File -Append -FilePath $LogFilePath
}
