# Run in the VM as admin: authorizes the host's abeldent_vm SSH key.
$f = 'C:\ProgramData\ssh\administrators_authorized_keys'
Get-Content '\\host.lan\Data\.ssh\abeldent_vm.pub' | Add-Content $f
# sshd ignores this file for admins unless only Administrators/SYSTEM can access it
icacls $f /inheritance:r /grant Administrators:F /grant SYSTEM:F
