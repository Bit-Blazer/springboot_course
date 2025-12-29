# Script to add home url metadata to all codelab markdown files

Write-Host "Adding home url metadata to all codelab files..." -ForegroundColor Green

# Find all codelab markdown files
$codelabFiles = Get-ChildItem -Path "." -Recurse -Filter "codelab-*.md" -File

foreach ($file in $codelabFiles) {
    Write-Host "Processing: $($file.FullName)" -ForegroundColor Cyan
    
    # Read file content
    $content = Get-Content -Path $file.FullName -Raw
    
    # Fix home url if it exists without leading slash
    if ($content -match "home url: springboot_course/") {
        $updatedContent = $content -replace "home url: springboot_course/", "home url: /springboot_course/"
        Set-Content -Path $file.FullName -Value $updatedContent -NoNewline
        Write-Host "  ✓ Fixed home url (added leading slash)" -ForegroundColor Green
        continue
    }
    
    # Check if correct home url already exists
    if ($content -match "home url: /springboot_course/") {
        Write-Host "  ⚠️  Home url already correct, skipping..." -ForegroundColor Yellow
        continue
    }
    
    # Add home url after status line
    $updatedContent = $content -replace "(status: Published)", "`$1`nhome url: /springboot_course/"
    
    # Write back to file
    Set-Content -Path $file.FullName -Value $updatedContent -NoNewline
    
    Write-Host "  ✓ Added home url" -ForegroundColor Green
}

Write-Host "`nComplete! Processed $($codelabFiles.Count) files." -ForegroundColor Green
