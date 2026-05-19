# 1. Set Execution Policy for this session only
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force

# 2. Fix Hungarian character rendering
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 3. GUI File Browser for Input
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter = "Text files (*.txt)|*.txt|CSV files (*.csv)|*.csv|All files (*.*)|*.*"
    Title = "Select your name list file"
}

if ($FileBrowser.ShowDialog() -ne "OK") { exit }
$InputPath = $FileBrowser.FileName

# 4. Define Output Path
$DesktopPath = [Environment]::GetFolderPath('Desktop')
$OutputFile = Join-Path -Path $DesktopPath -ChildPath "win_accs.txt"

if (Test-Path $OutputFile) { Remove-Item $OutputFile -Force }

# 5. Normalization Function (Fixed for Hungarian Firstname.Lastname format)
function Get-ADUsername {
    param([string]$FullName)
    
    # Split name and remove extra spaces
    $Parts = $FullName.Trim().Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
    
    if ($Parts.Count -lt 2) { return $FullName.ToLower() }
    
    # Hungarian logic: Parts[0] is Family Name, Parts[1] is First Name
    # Resulting format: Hegedus.Bela
    $Target = "$($Parts[0]).$($Parts[1])"
    
    # Strip accents (Normalization)
    $Normalized = $Target.Normalize([System.Text.NormalizationForm]::FormD)
    $SB = New-Object System.Text.StringBuilder
    foreach ($char in $Normalized.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($char) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$SB.Append($char)
        }
    }
    
    # Clean up and force lowercase
    $Clean = $SB.ToString().ToLower()
    return $Clean -replace '[^a-z.]', ''
}

# 6. Process and Save
Write-Host "`nProcessing names..." -ForegroundColor Cyan
Write-Host "Output: $OutputFile`n" -ForegroundColor Yellow

Get-Content $InputPath -Encoding UTF8 | ForEach-Object {
    $Original = $_.Trim()
    if ($Original) {
        $ADName = Get-ADUsername $Original
        
        try {
            # Attempt to find the user in AD
            $UserAccount = Get-ADUser -Filter "SamAccountName -eq '$ADName'" -ErrorAction SilentlyContinue

            if ($UserAccount) {
                Write-Host "Original: $Original -> AD: $ADName " -NoNewline
                Write-Host "[Found]" -ForegroundColor Green
                $ADName | Out-File -FilePath $OutputFile -Append -Encoding UTF8
            } else {
                Write-Host "Original: $Original -> AD: $ADName " -NoNewline
                Write-Host "[Not Found]" -ForegroundColor DarkRed
            }
        } catch {
            Write-Host "Error: Active Directory module missing or connection failed." -ForegroundColor Red
            break
        }
    }
}

Write-Host "`nDone! Check your desktop for win_accs.txt" -ForegroundColor Cyan
