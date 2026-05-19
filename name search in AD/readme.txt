What this script do?

If you have Hungarian names (with á,ű,ő,ó,ü,ö, etc. in their names) in a .txt, this script collects them and then gets its usernames from Active Directory, than prints it out the names on the Powershell terminal and saves the in your Desktop under the name win_accs.txt.

Usage:

1. Open powershell as a regular user
2. cd into the folder where this .ps1 file is located
3. Run the "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force" 
   command in powershell, still as a regular user.
4. Browse for the file with the names (*.txt)
5. The output file with AD names will be at %USERPROFILE%\Desktop\win_accs.txt
