#Setting the path for hash database and target folder
$HashDatabase = "C:\Users\Administrator\database\database.xml"
$Target = "C:\Users\Administrator\Zip\"

# Preparing 7z for zipping
$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"

if (-not (Test-Path -Path $7zipPath -PathType Leaf)) {
    throw "7 zip file '$7zipPath' not found"
}

Set-Alias 7zip $7zipPath

# Zipping individual files
dir | ForEach-Object { 
& 7zip a -tzip ($Target+$_.Name+".zip") $_.Name 
}

# Calculating the MD5 hash of the zipped files and storing in xml databse
c:\fciv -add $Target -xml $HashDatabase

#Loopthrough all the files in zip folder
Get-ChildItem $Target -Filter *.zip | 
Foreach-Object {
    $dest = $_.FullName
    $object = $_.Name
    Write-Host $dest
    Write-Host $object

#Getting the MD5 base64 encoded hash value from the database
[XML]$Details = Get-Content $HashDatabase
 
foreach($Detail in $Details.FCIV.FILE_ENTRY){
    if($Dest -eq $Detail.name){
 
        $hashvalue = $Detail.MD5
        Write-Host $hashvalue
    }
 }

# Uploading the file to s3 if the MD5 hash matches the database
aws s3api put-object --bucket hbc-sec-test --key $object --body $dest --content-md5 $hashvalue
}
Read-Host -Prompt "Press Enter to exit" 
