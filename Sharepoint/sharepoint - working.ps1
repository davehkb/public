#Connect-SPOService -Url https://versaterminc-admin.sharepoint.com
clear
#purpose of this script is to use the provided list C:/temp/enabled.csv and remove the "Everyone Except External" user, while also adding another User to that site.


$owner = '<Email of SharepointAdmin>'
$csv = Import-Csv "C:\temp\enabled.csv" -Delimiter "	"

#Grab the Site URL from the csv file
$csv.SiteURL | ForEach-Object {
    Write-Output ' '
    Write-Output ' '
    Write-Output '_______________'
    Write-Output "The SiteURL name is: $_"
      
    
    $siteURL = $_
    $site = Get-SPOSite -Identity "$siteURL"
    $site = $site.Title
    Write-host "The Site name is: $site"
    
    
    Write-Output "Adding $owner as additional admin of $site"
    
    #Setting the addional admin for the site to be Owner 
    Set-SPOUser -site $siteURL -LoginName $owner -IsSiteCollectionAdmin $True
    Write-Output '----------------------------------'

    
    #check if sharepoint site has the  Everyone Except External Users 
    Write-Output Get-SPOUser -Site $siteURL | Where-Object DisplayName -Match Everyone | Where-Object Groups -Match "$site Member"
    
    $string = Get-SPOUser -Site $siteURL | Where-Object DisplayName -Match Everyone | Where-Object Groups -Match "$site Member"
    if ($string)
{
    Write-Output "$site has Everyone Except External user enabled."
    
    Write-Output '.Removed "Everyone except external Users" group from the site.'
    #removes the Everyone Except External user from that site.
    Remove-SPOUser -Site $siteURL -Group "$site Members" -LoginName 'c:0-.f|rolemanager|spo-grid-all-users/67365ef4-bb04-4874-91f8-4d360af16390'
    
    Write-Output '.Added AllEmployeesVersaterm to the Site as a Site Member'
    #Addes the group to that site
    Add-SPOUser -Site $siteURL -Group "$site Members" -LoginName '<Group you want to add to the site>'
}
else{
    
    Write-Output "$site does NOT have the Everyone user enabled."
}
    Write-Output '----------------------------------'
    
    Write-Output "Remove $owner as owner of $site"
    #removes the owner as aditional admin from that site
    Set-SPOUser -site $siteURL -LoginName $owner -IsSiteCollectionAdmin $False
    
    Write-Output '_______________'
}
exit
