What this script do?

This script identifies all Active Directory groups a specific user belongs to and prompts you to save the list as a .txt file via a pop-up window.
It first validates that the username exists and then exports only the group names to your chosen location.

Usage:

1. Open powershell as a regular user
2. cd into the folder where this .ps1 file is located
3. Run the "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force"
   command in powershell, still as a regular user.
4. Type the username you want the groups for
5. The output file with AD names will be at %USERPROFILE%\Desktop\win_accs.txt

Example usages:

An old manager leaves from the company, and the new manager needs to have the same groups as the old one, but he had so many that it would be very hard to manually type into a txt.