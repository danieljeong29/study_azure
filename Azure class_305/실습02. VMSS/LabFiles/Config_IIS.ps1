##변수 설정
$userName = "kormtt0404vmss"   #스토리지 계정 이름
$userPwd = "twnUUoW1vIZW8ui/DshoH5ahVhaFPAePM86VrxUOOTbpqXUXfl7euMf3lsf6GzxbjTwVBqKjq6JEhb4qou1gEA=="  #스토리지 계정 키
$adminName = "labAdmin"  #가상 머신 관리자 계정
$filesPath = "\\kormtt0404vmss.file.core.windows.net\myweb"  #File Share 경로
$poolName = "filesPool"  #생성할 IIS 응용 프로그램 풀 이름
$webSiteName = "filesWEB"  #생성할 IIS 웹 사이트 이름

##IIS 구성을 위한 로컬 사용자 생성
$localPwd = ConvertTo-SecureString -String $userPwd -AsPlainText -Force
$localUser = New-LocalUser -Name $userName -Password $localPwd -FullName $userName
Add-LocalGroupMember -Group "IIS_IUSRS" -Member $localUser

##Azure Files 연결
$adminCred = New-Object PSCredential "Azure\$userName", ($userPwd | ConvertTo-SecureString -AsPlainText -Force)
New-SmbGlobalMapping -RemotePath $filesPath -Credential $adminCred -LocalPath Y: `
  -FullAccess @("NT AUTHORITY\SYSTEM", "NT AUTHORITY\NetworkService", $userName, $adminName) -Persistent $true

##웹 사이트 생성
Import-Module WebAdministration
Remove-Website -Name "Default Web Site"
New-Item "IIS:\AppPools\$poolName" -Force
Set-ItemProperty IIS:\AppPools\$poolName -name processModel -value @{userName=$userName;password=$userPwd;identitytype=3}
$webSite = New-Website -Name $webSiteName -PhysicalPath $filesPath -ApplicationPool $poolName
$siteName = ($webSite | Select -Property "Name").name
$fullPath = "system.applicationHost/sites/site[@name='$siteName']/application[@path='/']/virtualDirectory[@path='/']"
Set-WebConfigurationProperty $fullPath -Name "username" -Value $userName
Set-WebConfigurationProperty $fullPath -Name "password" -Value $userPwd
