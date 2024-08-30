# Remove old public dir
if (Test-Path -Path $PSScriptRoot\public) { Remove-Item -Path $PSScriptRoot\public -Recurse -Force -Confirm:$false }

# Build hugo site
hugo --minify
