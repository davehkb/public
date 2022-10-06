#THis script only identifies the sharepoint sites that have the Everyone Except Extended user.
#run the #sharepoint-working.ps1 to run against 

#Connect-SPOService -Url https://<site>.sharepoint.com
clear

$owner = '<Email of SharepointAdmin>'
$csv = Import-Csv "C:\temp\sites.csv" -Delimiter "	"
Add-Content C:/temp/enabled.txt "SiteURL"
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
    
    #Setting the addional admin for the site to be VTMMigration 
    Set-SPOUser -site $siteURL -LoginName $owner -IsSiteCollectionAdmin $True


    
    Write-Output '----------------------------------'
    
    
    #check if sharepoint site has the  Everyone Except External Users 
    Write-Output Get-SPOUser -Site $siteURL | Where-Object DisplayName -Match Everyone | Where-Object Groups -Match "$site Member"
    
    $string = Get-SPOUser -Site $siteURL | Where-Object DisplayName -Match Everyone | Where-Object Groups -Match "$site Member"
    if ($string)
{
    Add-Content C:/temp/enabled.txt "$siteURL"
    
    
}
else{
    
}
    Write-Output '----------------------------------'
    
    Write-Output "Remove $owner as owner of $site"
    #removes the owner as aditional admin from that site
    Set-SPOUser -site $siteURL -LoginName $owner -IsSiteCollectionAdmin $False
    
    Write-Output '_______________'
}
#Removes old file
Remove-Item -Path "C:/Temp/enabled.csv"
#converts to csv file for processing later.
Move-Item -Path "C:/Temp/enabled.txt" -Destination "C:/Temp/enabled.csv"
exit
