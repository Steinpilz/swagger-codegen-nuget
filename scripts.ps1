param([String]$version)

If (!$version)
{
    echo "version is required"
    exit
}

echo "Version = $version"

$artifactsPath = '.artifacts'
$binPath = "$artifactsPath\bin"
$publishPath = "$artifactsPath\publish"
$paket = ".paket\paket"

Function Restore()
{
    & $paket restore
}

Function Clean()
{
    If(test-path $artifactsPath)
    {    
        Remove-Item -Path $artifactsPath -Force -Recurse 
    }
}

Function DownloadBinary($version)
{
    If(!(test-path $binPath))
    {
       New-Item -ItemType Directory -Path $binPath -Force
    }
    Invoke-WebRequest -OutFile $binPath\swagger-codegen-cli.jar http://central.maven.org/maven2/io/swagger/swagger-codegen-cli/$version/swagger-codegen-cli-$version.jar
}

Function Pack($version)
{
    echo 'Packing...'
    & $paket pack $publishPath --template paket.template --specific-version Steinpilz.SwaggerCodeGenTool $version
    echo 'Packed.'
}

Function Publish($version)
{
    echo 'Publishing...'
    & $paket push $publishPath\Steinpilz.SwaggerCodeGenTool.$version.nupkg --api-key $env:NUGET_API_KEY
    echo 'Published'
}

Clean
Restore
DownloadBinary($version)

$cmd = $args[0]
echo "Calling $cmd"

If ($cmd -eq 'pack')
{
    Pack($version)
}
if ($cmd -eq 'publish')
{
    Pack($version)
    Publish($version)
}