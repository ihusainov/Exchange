**Намного быстрее и проще ту же самую процедуру выполнить при помощи следующей команды PowerShell ниже, заменив servername на имя сервера, на котором размещен виртуальный каталог OWA.**
```bash
Set-OwaVirtualDirectory -Identity "servername\owa (Default Web Site)" -ChangePasswordEnabled $false
```
**Для того, чтобы выполнить изменения на всех серверах организации Exchange, необходимо выполнить следующую команду:**
```bash
Get-OwaVirtualDirectory | Set-OwaVirtualDirectory -ChangePasswordEnabled $false
```
**Затем выполнить**
```bash
IISreset
```
Теперь пользователи не смогут менять свои пароли через веб-интерфейс OWA.
