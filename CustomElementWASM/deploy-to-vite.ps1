# Deploy Blazor Custom Element to Vite
# This script does a clean publish and copies files to Vite

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Blazor Custom Element Deployment" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean everything
Write-Host "Step 1: Cleaning previous builds..." -ForegroundColor Yellow
dotnet clean CustomElementWASM.csproj

# Also clean any stray generated files that might cause duplicate attribute errors
$objPath = "obj"
if (Test-Path $objPath) {
    Remove-Item $objPath -Recurse -Force
    Write-Host "  ? Removed obj folder" -ForegroundColor Green
}

$binPath = "bin"
if (Test-Path $binPath) {
    Remove-Item $binPath -Recurse -Force
    Write-Host "  ? Removed bin folder" -ForegroundColor Green
}

# Step 2: Publish (will output to .artifacts due to Directory.Build.props)
Write-Host ""
Write-Host "Step 2: Publishing CustomElementWASM (Release)..." -ForegroundColor Yellow
dotnet publish CustomElementWASM.csproj -c Release

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ? Publish failed!" -ForegroundColor Red
    exit 1
}
Write-Host "  ? Publish completed" -ForegroundColor Green

# Find the publish output (check multiple possible locations)
$publishPath = ""
$possiblePaths = @(
    "..\.artifacts\publish\CustomElementWASM\release",  # Artifacts path from Directory.Build.props
    "bin\Release\net10.0\browser-wasm\publish",         # Traditional publish path
    "bin\Release\net10.0\publish"                        # Alternative publish path
)

foreach ($path in $possiblePaths) {
    if (Test-Path "$path\wwwroot") {
        $publishPath = $path
        Write-Host "  ? Found publish output at: $publishPath" -ForegroundColor Green
        break
    }
}

if ($publishPath -eq "") {
    Write-Host "  ? Publish output not found in any expected location!" -ForegroundColor Red
    Write-Host "  Checked:" -ForegroundColor Yellow
    foreach ($path in $possiblePaths) {
        Write-Host "    - $path" -ForegroundColor White
    }
    exit 1
}

# Step 3: Verify dotnet.js was created
Write-Host ""
Write-Host "Step 3: Verifying dotnet.js workaround..." -ForegroundColor Yellow
if (Test-Path "$publishPath\wwwroot\_framework\dotnet.js") {
    Write-Host "  ? dotnet.js found" -ForegroundColor Green
} else {
    Write-Host "  ? dotnet.js not found - MSBuild target may have failed" -ForegroundColor Red
    Write-Host "  Creating dotnet.js manually..." -ForegroundColor Yellow
    
    $dotnetFile = Get-ChildItem "$publishPath\wwwroot\_framework" -Filter "dotnet.*.js" | 
                  Where-Object { $_.Name -match '^dotnet\.[a-z0-9]+\.js$' -and $_.Name -notmatch 'native|runtime' } | 
                  Select-Object -First 1
    
    if ($dotnetFile) {
        Copy-Item $dotnetFile.FullName "$publishPath\wwwroot\_framework\dotnet.js"
        Write-Host "  ? Created dotnet.js from $($dotnetFile.Name)" -ForegroundColor Green
    } else {
        Write-Host "  ? Could not find source dotnet file!" -ForegroundColor Red
        exit 1
    }
}

# Step 4: Verify all required files exist
Write-Host ""
Write-Host "Step 4: Verifying published files..." -ForegroundColor Yellow

$frameworkPath = "$publishPath\wwwroot\_framework"
$contentPath = "$publishPath\wwwroot\_content"

if (!(Test-Path $frameworkPath)) {
    Write-Host "  ? _framework folder not found!" -ForegroundColor Red
    exit 1
}
Write-Host "  ? _framework folder exists" -ForegroundColor Green

if (!(Test-Path $contentPath)) {
    Write-Host "  ? _content folder not found!" -ForegroundColor Red
    exit 1
}
Write-Host "  ? _content folder exists" -ForegroundColor Green

# List the dotnet files and their hashes
Write-Host ""
Write-Host "  Dotnet files in _framework:" -ForegroundColor Cyan
Get-ChildItem $frameworkPath -Filter "dotnet*.js" | ForEach-Object {
    Write-Host "    - $($_.Name)" -ForegroundColor White
}

# Step 5: Clean Vite public folders
Write-Host ""
Write-Host "Step 5: Cleaning Vite public folders..." -ForegroundColor Yellow

$viteFramework = "..\Docsite.Vite\public\_framework"
$viteContent = "..\Docsite.Vite\public\_content"

if (Test-Path $viteFramework) {
    Remove-Item $viteFramework -Recurse -Force
    Write-Host "  ? Removed old _framework from Vite" -ForegroundColor Green
}

if (Test-Path $viteContent) {
    Remove-Item $viteContent -Recurse -Force
    Write-Host "  ? Removed old _content from Vite" -ForegroundColor Green
}

# Step 6: Copy to Vite
Write-Host ""
Write-Host "Step 6: Copying to Vite public folder..." -ForegroundColor Yellow

Copy-Item -Path $frameworkPath -Destination $viteFramework -Recurse -Force
Write-Host "  ? Copied _framework to Vite" -ForegroundColor Green

Copy-Item -Path $contentPath -Destination $viteContent -Recurse -Force
Write-Host "  ? Copied _content to Vite" -ForegroundColor Green

# Step 7: Verify Vite deployment
Write-Host ""
Write-Host "Step 7: Verifying Vite deployment..." -ForegroundColor Yellow

if (!(Test-Path "$viteFramework\dotnet.js")) {
    Write-Host "  ? dotnet.js not found in Vite!" -ForegroundColor Red
    exit 1
}
Write-Host "  ? dotnet.js exists in Vite" -ForegroundColor Green

if (!(Test-Path "$viteFramework\blazor.webassembly.0o6sltz4v8.js")) {
    Write-Host "  ? blazor.webassembly.*.js not found in Vite!" -ForegroundColor Red
    exit 1
}
Write-Host "  ? blazor.webassembly.js exists in Vite" -ForegroundColor Green

$customElementsLib = Get-ChildItem "$viteContent\Microsoft.AspNetCore.Components.CustomElements" -ErrorAction SilentlyContinue
if (!$customElementsLib) {
    Write-Host "  ? Custom Elements library not found in Vite!" -ForegroundColor Red
    exit 1
}
Write-Host "  ? Custom Elements library exists in Vite" -ForegroundColor Green

# Success!
Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "? Deployment completed successfully!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Start your Vite dev server (if not already running)" -ForegroundColor White
Write-Host "  2. Navigate to http://localhost:7304" -ForegroundColor White
Write-Host "  3. Hard refresh your browser (Ctrl+Shift+R)" -ForegroundColor White
Write-Host ""
