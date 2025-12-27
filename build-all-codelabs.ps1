# Build All Codelabs Script
# This script exports all markdown codelabs to HTML using claat

Write-Host "Starting codelab export process..." -ForegroundColor Green

# Check if claat is available
try {
    $claatVersion = claat version 2>&1
    Write-Host "Found claat: $claatVersion" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: claat not found. Please install claat first." -ForegroundColor Red
    Write-Host "Install: go install github.com/googlecodelabs/tools/claat@latest" -ForegroundColor Yellow
    exit 1
}

# Discover all section folders dynamically
$sections = Get-ChildItem -Path $PSScriptRoot -Directory | 
    Where-Object { $_.Name -match '^section-\d+' } | 
    Sort-Object Name

if ($sections.Count -eq 0) {
    Write-Host "ERROR: No section folders found (section-*)" -ForegroundColor Red
    exit 1
}

Write-Host "Found $($sections.Count) section(s): $($sections.Name -join ', ')" -ForegroundColor Cyan

$totalExported = 0
$totalErrors = 0

# Process each section
foreach ($section in $sections) {
    $sectionPath = $section.FullName
    
    Write-Host "`nProcessing $($section.Name)..." -ForegroundColor Cyan
    
    # Find all codelab markdown files
    $codelabFiles = Get-ChildItem -Path $sectionPath -Filter "codelab-*.md" -File
    
    if ($codelabFiles.Count -eq 0) {
        Write-Host "  No codelab files found in $($section.Name)" -ForegroundColor Yellow
        continue
    }
    
    # Export each codelab
    foreach ($file in $codelabFiles) {
        Write-Host "  Exporting: $($file.Name)" -ForegroundColor White
        
        try {
            Push-Location $sectionPath
            $result = claat export $file.Name 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    ✓ Success" -ForegroundColor Green
                $totalExported++
            } else {
                Write-Host "    ✗ Failed: $result" -ForegroundColor Red
                $totalErrors++
            }
        } catch {
            Write-Host "    ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
            $totalErrors++
        } finally {
            Pop-Location
        }
    }
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "  Successfully exported: $totalExported codelabs" -ForegroundColor Green
if ($totalErrors -gt 0) {
    Write-Host "  Errors: $totalErrors" -ForegroundColor Red
}
Write-Host "========================================`n" -ForegroundColor Cyan
