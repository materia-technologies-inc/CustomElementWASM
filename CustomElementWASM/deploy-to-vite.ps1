# Deploy Blazor Custom Element to Vite
# This script does a clean publish and copies files to Vite

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Blazor Custom Element Deployment" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean everything
Write-Host "Step 1: Cleaning previous builds..." -ForegroundColor Yellow
dotnet clean CustomElementWASM.csproj

# Clean artifacts folder
if (Test-Path "..\.artifacts") {
    Remove-Item "..\.artifacts" -Recurse -Force
    Write-Host "  Cleaned .artifacts folder" -ForegroundColor Green
}

# Clean obj and bin
if (Test-Path "obj") {
    Remove-Item "obj" -Recurse -Force
    Write-Host "  Cleaned obj folder" -ForegroundColor Green
}
if (Test-Path "bin") {
    Remove-Item "bin" -Recurse -Force
    Write-Host "  Cleaned bin folder" -ForegroundColor Green
}

# Step 2: Publish (will output to .artifacts due to Directory.Build.props)
Write-Host ""
Write-Host "Step 2: Publishing CustomElementWASM (Release)..." -ForegroundColor Yellow
dotnet publish CustomElementWASM.csproj -c Release

if ($LASTEXITCODE -ne 0) {
    Write-Host "  Publish failed!" -ForegroundColor Red
    exit 1
}
Write-Host "  Publish completed" -ForegroundColor Green

# Step 3: Find publish output
Write-Host ""
Write-Host "Step 3: Locating publish output..." -ForegroundColor Yellow
$publishBase = "..\.artifacts\publish\CustomElementWASM\release"
if (!(Test-Path $publishBase)) {
    Write-Host "  Publish output not found at: $publishBase" -ForegroundColor Red
    exit 1
}
Write-Host "  Found publish output at: $publishBase" -ForegroundColor Green

# Step 4: Copy to Vite public folder
Write-Host ""
Write-Host "Step 4: Copying to Vite public folder..." -ForegroundColor Yellow

$sourceFramework = Join-Path $publishBase "wwwroot\_framework"
$sourceContent = Join-Path $publishBase "wwwroot\_content"
$targetFramework = "..\Docsite.Vite\public\_framework"
$targetContent = "..\Docsite.Vite\public\_content"

# Clean target folders
if (Test-Path $targetFramework) {
    Remove-Item $targetFramework -Recurse -Force
    Write-Host "  Cleaned old _framework" -ForegroundColor Green
}
if (Test-Path $targetContent) {
    Remove-Item $targetContent -Recurse -Force
    Write-Host "  Cleaned old _content" -ForegroundColor Green
}

# Copy new files
if (Test-Path $sourceFramework) {
    Copy-Item -Path $sourceFramework -Destination $targetFramework -Recurse -Force
    Write-Host "  Copied _framework to Vite" -ForegroundColor Green
    
    # Create dotnet.js from versioned file (workaround for .NET 10 RC bug)
    $dotnetVersioned = Get-ChildItem -Path $targetFramework -Filter "dotnet.*.js" -File | 
                       Where-Object { $_.Name -match '^dotnet\.[a-z0-9]+\.js$' -and $_.Name -notmatch 'native|runtime' } | 
                       Select-Object -First 1
    
    if ($dotnetVersioned) {
        $dotnetTarget = Join-Path $targetFramework "dotnet.js"
        Copy-Item -Path $dotnetVersioned.FullName -Destination $dotnetTarget -Force
        Write-Host "  Created dotnet.js from $($dotnetVersioned.Name)" -ForegroundColor Green
    } else {
        Write-Host "  Warning: Could not find versioned dotnet.*.js file" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Source _framework not found!" -ForegroundColor Red
    exit 1
}

if (Test-Path $sourceContent) {
    Copy-Item -Path $sourceContent -Destination $targetContent -Recurse -Force
    Write-Host "  Copied _content to Vite" -ForegroundColor Green
} else {
    Write-Host "  Source _content not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart your Vite dev server (Ctrl+C, then npm run dev)" -ForegroundColor White
Write-Host "  2. Hard refresh your browser (Ctrl+Shift+R)" -ForegroundColor White
Write-Host ""
