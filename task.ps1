$curVer = [regex]::Match((Get-Content ".\src\spicetify.go"), "version = `"([\d\.]*)`"").Captures.Groups[1].Value
Write-Host "Current version: $curVer"

function BumpVersion {
    param (
        [Parameter(Mandatory=$true)][int16]$major,
        [Parameter(Mandatory=$true)][int16]$minor,
        [Parameter(Mandatory=$true)][int16]$patch
    )

    $ver = "$($major).$($minor).$($patch)"

    (Get-Content ".\src\spicetify.go") -replace "version = `"[\d\.]*`"", "version = `"$($ver)`"" |
        Set-Content ".\src\spicetify.go"
}

function Dist {
    param (
        [Parameter(Mandatory=$true)][int16]$major,
        [Parameter(Mandatory=$true)][int16]$minor,
        [Parameter(Mandatory=$true)][int16]$patch
    )

    BumpVersion $major $minor $patch

    $nameVersion="spicetify-$($major).$($minor).$($patch)"
    $env:GOARCH="amd64"

    if (Test-Path "./bin") {
        Remove-Item -Recurse "./bin"
    }

    Write-Host "Building Linux binary:"
    $env:GOOS="linux"

    go build -o "./bin/linux/spicetify" "./src/spicetify.go"

    7z a -bb0 "./bin/linux/$($nameVersion)-linux-amd64.tar" "./bin/linux/*" "./Themes" "./jsHelper" >$null 2>&1
    7z a -bb0 -sdel -mx9 "./bin/$($nameVersion)-linux-amd64.tar.gz" "./bin/linux/$($nameVersion)-linux-amd64.tar" >$null 2>&1
    Write-Host "✔" -ForegroundColor Green

    Write-Host "Building MacOS binary:"
    $env:GOOS="darwin"

    go build -o "./bin/darwin/spicetify" "./src/spicetify.go"

    7z a -bb0 "./bin/darwin/$($nameVersion)-darwin-amd64.tar" "./bin/darwin/*" "./Themes" "./jsHelper" >$null 2>&1
    7z a -bb0 -sdel -mx9 "./bin/$($nameVersion)-darwin-amd64.tar.gz" "./bin/darwin/$($nameVersion)-darwin-amd64.tar" >$null 2>&1
    Write-Host "✔" -ForegroundColor Green

    Write-Host "Building Windows binary:"
    $env:GOOS="windows"

    go build -o "./bin/windows/spicetify.exe" "./src/spicetify.go"

    7z a -bb0 -mx9 "./bin/$($nameVersion)-windows-x64.zip" "./bin/windows/*" "./Themes" "./jsHelper" >$null 2>&1
    Write-Host "✔" -ForegroundColor Green
}