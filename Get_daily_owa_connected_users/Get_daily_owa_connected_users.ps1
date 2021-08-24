Get-MailboxServer  ServerNameHere | Get-LogonStatistics | ?{$_.applicationid -like "*Client=OWA*" -and $_.username -like "*UserNameHere*"}
