Import-Module ActiveDirectory

# --- Choose username ---
$userName = Read-Host -Prompt "Choose username (pl. last_name.fist_name)"

# --- Check if user exists ---
try {
    # Tries to check if AD user exists
    Get-ADUser -Identity $userName -ErrorAction Stop
    Write-Host "User ($userName) exists. Continuing..." -ForegroundColor Green
    $userExists = $true
} catch {
    # If user does NOT exists, print result with red
    Write-Host "User does not exists! (typo?)" -ForegroundColor Red
    $userExists = $false
}

# If user existing true continues
if ($userExists) {
    # --- Selecting a save location ---
    # Creates a graphic file save window
    Add-Type -AssemblyName System.Windows.Forms
    $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $SaveFileDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop') # Starting folder: Desktop
    $SaveFileDialog.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"
    $SaveFileDialog.Title = "Choose an AD username and a location to save"
    $SaveFileDialog.FileName = "$userName" + "_groups.txt" # Default name conversion

    # Shows dialog table for choosing save location (OK/Cancel)
    if ($SaveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $SaveLocation = $SaveFileDialog.FileName
        Write-Host "Save location: $SaveLocation" -ForegroundColor Green

        # --- Execution of the command ---
        try {
            (Get-ADUser -Identity $userName -Property MemberOF).MemberOF |
                Get-ADGroup |
                Select-Object -ExpandProperty Name |
                Out-File -FilePath $SaveLocation -Encoding UTF8
            Write-Host "Success!" -ForegroundColor Green
        }
        catch {
            Write-Host "Error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Stopped" -ForegroundColor Yellow
    }
}