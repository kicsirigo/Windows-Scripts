Add-Type -AssemblyName System.Windows.Forms

# Function for the graphical file picker dialog
function Get-TxtFileVisual {
    param ($WindowTitle)
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $FileBrowser.Title = $WindowTitle
    $FileBrowser.Filter = "Text files (*.txt)|*.txt"
    
    $ShowBrowser = $FileBrowser.ShowDialog()
    if ($ShowBrowser -eq "OK") {
        return $FileBrowser.FileName
    } else {
        return $null
    }
}

# Function for the graphical folder browser dialog
function Get-FolderVisual {
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowser.Description = "Select the folder where you want to save the report file"
    
    $ShowBrowser = $FolderBrowser.ShowDialog()
    if ($ShowBrowser -eq "OK" -or $ShowBrowser -eq "Yes") {
        return $FolderBrowser.SelectedPath
    } else {
        return $null
    }
}

# Graphical file selection
$file1 = Get-TxtFileVisual "Select the FIRST .txt file"
$file2 = Get-TxtFileVisual "Select the SECOND .txt file"

# Check if both files were selected
if ($null -ne $file1 -and $null -ne $file2) {
    
    # Get the exact, actual names of your files
    $fileName1 = Split-Path $file1 -Leaf
    $fileName2 = Split-Path $file2 -Leaf

    # Read files line by line into arrays
    $lines1 = Get-Content -Path $file1 | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    $lines2 = Get-Content -Path $file2 | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

    # Array to temporarily store ONLY the missing elements
    $mismatchLog = @()

    Write-Host "--- Starting File Content Analysis ---`n" -ForegroundColor Cyan

    # Loop through the first file exactly one time
    foreach ($line in $lines1) {
        
        # Check if the line exists in the second file
        if ($lines2 -contains $line) {
            Write-Host "$line [Match]" -ForegroundColor Green
        } else {
            # Displays the exact name of the missing target file
            $mismatchMessage = "$line [Not Match] [Not Found in: $fileName2]"
            Write-Host $mismatchMessage -ForegroundColor Red
            
            # Save ONLY this missing line to the log array
            $mismatchLog += $mismatchMessage
        }
    }

    # Print all red texts again as a final summary right before asking to save
    Write-Host "`n--- MISMATCH SUMMARY ---" -ForegroundColor Yellow
    if ($mismatchLog.Count -gt 0) {
        foreach ($mismatch in $mismatchLog) {
            Write-Host $mismatch -ForegroundColor Red
        }
    } else {
        Write-Host "No mismatches found. Perfect correlation!" -ForegroundColor Green
    }

    # Ask the user if they want to export the results
    Write-Host ""
    $response = Read-Host "Do you want to save the output to a file? (y/n)"

    if ($response.Trim().ToLower() -eq 'y') {
        
        # If there are no mismatches at all, don't generate an empty file
        if ($mismatchLog.Count -eq 0) {
            Write-Host "All items matched perfectly! No error file needed. Exiting." -ForegroundColor Green
            exit
        }

        # Get target directory graphically
        $targetFolder = Get-FolderVisual

        if ($null -ne $targetFolder) {
            $currentDate = Get-Date -Format "yyyy.MM.dd"
            
            # Drops the extension for the log name prefix (e.g., kiskutya or xbox)
            $baseMissingName = [System.IO.Path]::GetFileNameWithoutExtension($fileName2)
            $outputFileName = "notfoundin$($baseMissingName)_$currentDate.txt"
            
            $finalPath = Join-Path -Path $targetFolder -ChildPath $outputFileName

            # Export data to the text file
            $mismatchLog | Out-File -FilePath $finalPath -Encoding utf8
            Write-Host "Success: Mismatch report saved to $finalPath" -ForegroundColor Green
        } else {
            Write-Host "Operation cancelled: No folder was selected. Exiting." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Exiting script without saving." -ForegroundColor Yellow
    }

} else {
    Write-Host "Operation cancelled: You did not select both files!" -ForegroundColor Yellow
}