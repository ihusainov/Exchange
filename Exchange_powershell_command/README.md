**Подготовка к установке**
```bash
Подготовить SSL сертификат с почтовым доменным именем.
Внести в ДНС провайдера записи:
Службы автообнаружения: autodiscover.contoso.com
HTTP подключения: mail.opti-com.ru
IMAP подключения: imap.opti-com.ru
SMTP подключения: smtp.opti-com.ru
Создать в оснастке «Пользователи и компьютеры» OU подразделения Exch_srv, Exch_Dep, Exch_Rul
Добавляем пользователя который будет заниматься установкой серверов в группы "Администраторы схемы" и "Администраторы предприятия".
Устанавливаем сервера для почты exchange
Задаём имена серверов  ex01  ex02
Подключаем к домену AD
На диске Е создаем папку  MboxDB  - будет храниться база почтовых ящиков
На диске F создаём папку LogDB – будут храниться логи писем которые ещё не попали в почтовую базу
Внутри папок MboxDB и LogDB создаём папки ex01 и ex02
Устанавливаем все обновления для ОС 2019
Включить подключение на удалённый рабочий стол
Отключить Антивирус на DC и серверах установки Exchange
```


**Установка Exchange**
```bash
Все скрипты и программы находятся по пути: X:\Папки Департаментов\ДИТ\IT\Software\Exchange
Установить на DC сервера  (DC сервер с ролью глобального каталога)
VC++ 2013 Redistributable
VisualCppRedist_AIO.exe
https://dotnet.microsoft.com/download/dotnet-framework/thank-you/net48-rus
ndp48-x86-x64-allos-rus.exe
Vmware tools
Запустить на DC cmd.exe от администратора:
Далее скрипт D:\Setup.exe /IAcceptExchangeServerLicenseTerms /PrepareSchema
Перезагрузка DC сервера
D:\Setup.exe /IAcceptExchangeServerLicenseTerms /PrepareAD /OrganizationName:"Center"
D:\Setup.exe /IAcceptExchangeServerLicenseTerms /PrepareAllDomains
```

**Установить на exchange сервера**
```bash
VC++ 2013 Redistributable
VisualCppRedist_AIO.exe
https://dotnet.microsoft.com/download/dotnet-framework/thank-you/net48-rus
ndp48-x86-x64-allos-rus.exe
https://www.microsoft.com/ru-ru/download/details.aspx?id=34992
UcmaRuntimeSetup.exe
Vmware tools

После установки Exchange перезагрузить сервера
```
---

**Download**
```bash
Exchange Server 2019 Cumulative Update 4 (x64) - DVD (Multiple Languages)
https://cloud.mail.ru/public/2kk7/2Ao43pdqV/

https://support.microsoft.com/en-in/help/4522149/cumulative-update-4-for-exchange-server-2019
https://docs.microsoft.com/en-us/exchange/new-features/build-numbers-and-release-dates?view=exchserver-2019

License keys

Exchange Server Enterprise 2019 - YCQY7-BNTF6-R337H-69FGX-P39TY
Exchange Server Standard 2019 - G3FMN-FGW6B-MQ9VW-YVFV8-292KP 

Exchange Server Enterprise 2016 - 7WJV6-H9RMH-F4267-3R2KG-F6PBY
Exchange Server Standard 2016 - QXYKC-7H87P-YKC2Q-XRVQ7-GTJP2 

Exchange Server Standard 2013 - CPJFG-C9D94-J7F4K-T9Q48-FWKP7
Exchange Server Enterprise 2013 - MV2FQ-2MVJD-WK2VK-CB8XP-3Q2D9
```


**Расположение журналов Exchange 2016 - 2019**
```bash
Путь к журналу отслеживания сообщений:
C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\MessageTracking

Путь к журналу подключений:
C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\Connectivity

Путь к журналу протокола отправки:
C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpSend

Путь к журналу протокола приема:
C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive
```

---

**Смена имени и размещения почтовой базы**
```bash
[PS] C:\>Get-MailboxDatabase
Name                                           Server          Recovery        ReplicationType
----                                               ------          --------        ---------------
Mailbox Database 1323162870    EX01            False           None

Отключаем почтовую базу
[PS] C:\>Dismount-Database -Identity "Mailbox Database 1323162870"

Меняем имя базы данных на читаемое и удобное
[PS] C:\>Get-MailboxDatabase "Mailbox Database 1323162870" | Set-MailboxDatabase -Name MBX01

Перемещаем почтовую базу и почтовые логи в заранее созданное расположение
[PS] C:\>Move-DatabasePath -Identity MBX01 -EdbFilePath 'E:\MboxDB\ex01\MBX01.edb' -LogFolderPath 'E:\LogDB\ex01\'

Подключаем базу почтовых ящиков
[PS] C:\>Mount-Database -Identity "MBX01"

Далее перезапускаем службу баз данных exchange
[PS] C:\>restart-service -name MSExchangeIS

 [PS] C:\>Get-MailboxDatabase

Name                           Server          Recovery        ReplicationType
----                               ------          --------            ---------------
MBX01                          EX01            False               None

---
```

**DAG  (Группа обеспечения доступности баз данных)**
```bash
Выбрать рядовой сервер, включенный в домен с ролью файловый сервер.
Добавить на сервере в локальную группу администраторы пользователя Exchange subsystem
Далее:  
[PS] C:\>Add-DatabaseAvailabilityGroupServer -Identity DAG01 -MailboxServer ex01 -Verbose

[PS] C:\>Add-DatabaseAvailabilityGroupServer -Identity DAG01 -MailboxServer ex01 -Verbose
[PS] C:\>Add-DatabaseAvailabilityGroupServer -Identity DAG01 -MailboxServer ex02 -Verbose
[PS] C:\>Add-MailboxDatabaseCopy -Identity MBX01 -MailboxServer ex01 -Verbose
[PS] C:\>Add-MailboxDatabaseCopy -Identity MBX01 -MailboxServer ex02 -Verbose

Перезапустим службу баз данных на каждом сервере:
[PS] C:\>Restart-Service -name MSExchangeIS

[PS] C:\>Get-DatabaseAvailabilityGroup DAG01
```
---

**Настройка сервисов на автоматическое обнаружение Exchange для локальных и внешних клиентских подключений**
```bash
Autodiscovery

Microsoft Remote Connectivity Analyzer
https://testconnectivity.microsoft.com

https://docs.microsoft.com/en-us/exchange/client-developer/exchange-web-services/autodiscover-for-exchange
https://docs.microsoft.com/en-us/Exchange/architecture/client-access/autodiscover?view=exchserver-2019
https://support.microsoft.com/en-us/help/3211279/outlook-2016-implementation-of-autodiscover
https://www.howto-outlook.com/howto/autodiscoverconfiguration.htm


[PS] C:\>Set-ClientAccessService -Identity ex01 -AutoDiscoverServiceInternalUri 'https://ex.opti-com.ru/Autodiscover/Autodiscover.xml'
[PS] C:\>Set-ClientAccessService -Identity ex02 -AutoDiscoverServiceInternalUri 'https://ex.opti-com.ru/Autodiscover/Autodiscover.xml'

[PS] C:\>Get-OutlookAnywhere | Set-OutlookAnywhere -ExternalHostname 'ex.opti-com.ru' -ExternalClientsRequireSsl $true -ExternalClientAuthenticationMethod Negotiate -InternalHostname 'ex.opti-com.ru' -InternalClientsRequireSsl $false


Offline Address Book (OAB)
[PS] C:\>Get-OabVirtualDirectory | Set-OabVirtualDirectory –ExternalURL https://ex.opti-com.ru/oab

Exchange Web Services (EWS)
[PS] C:\>Get-WebServicesVirtualDirectory | Set-WebServicesVirtualDirectory –ExternalURL https://ex.opti-com.ru/ews/exchange.asmx

Outlook Anywhere (RPC over HTTP)
[PS] C:\>Get-OutlookAnywhere | Set-OutlookAnywhere –ExternalHostname ex.opti-com.ru –ExternalClientsRequireSsl $true

MAPI over HTTP (Exchange 2013 SP1 or later)
[PS] C:\>Get-MapiVirtualDirectory | Set-MapiVirtualDirectory –ExternalURL https://ex.opti-com.ru/mapi
[PS] C:\>Set-OrganizationConfig -MapiHttpEnabled $true
```
---

**Востановление данных из резервной копии почтовой базы**
```bash
Скопируйте восстановленную базу данных edb и ее файлы журнала в расположение, которое будет использоваться для базы данных восстановления.
  
Необходимо прочитать базу на состояние чистого отключения:
C:\Users\username>eseutil /mh .\ex01.edb

State: Dirty Shutdown

С помощью программы Eseutil переведите эту базу данных в состояние чистого отключения. В следующем примере EXX это префикс создания журнала для базы данных (например, E00, E01, E02 и т. д.):
C:\Users\username>eseutil /r E00 /l E:\Recovery\LogDB\ex01\ /d E:\Recovery\MboxDB\ex01\

Необходимо прочитать базу на состояние чистого отключения:
C:\Users\username>eseutil /mh .\ex01.edb

State: Clean Shutdown

[PS] C:\>New-MailboxDatabase -Recovery -Name RecoveryMBX01 -Server ex01 -EdbFilePath "E:\Recovery\MboxDB\ex01\MBX01.edb" -logfolderpath "E:\Recovery\LogDB\ex01"

[PS] C:\>Restart-Service MSExchangeIS

[PS] C:\>Mount-Database RecoveryMBX01

Убедитесь, что подключенная база данных содержит почтовые ящики, которые вы хотите восстановить:
[PS] C:\>Get-MailboxStatistics -Database RecoveryMBX01 | Format-Table DisplayName, Name, MailboxGUID -AutoSize

С помощью командлета New-MailboxRestoreRequest восстановите почтовый ящик или элементы из базы данных восстановления в производственный почтовый ящик. В следующем примере показано восстановление исходного почтового ящика с идентификатором MailboxGUID 1d20855f-fd54-4681-98e6-e249f7326ddd из базы данных MBX01 в целевом почтовом ящике с псевдонимом Morris:
[PS] C:\>New-MailboxRestoreRequest -SourceDatabase RecoveryMBX01 -SourceStoreMailbox f0ab62f3-07d1-403d-b004-8037a0cfd463 -TargetRootFolder "Recovery Mail" -TargetMailbox "p.pet" -AllowLegacyDNMismatch

В следующем примере показано восстановление содержимого исходного ящика с отображаемым именем "Иван Иванов" из базы данных MBX01 в архивном почтовом ящике для i.iva@contoso.com.
[PS] C:\>New-MaiboxRestoreRequest -SourceDatabase MBX01 -SourceStoreMailbox "Иван Иванов" -TargetMailbox i.iva@contoso.com -TargetIsArchive

Проверка состояние запроса восстановления почтового ящика с помощью командлета
[PS] C:\>Get-MailboxRestoreRequest

Когда состояние восстановления изменится на "Завершено", уделите запрос, используя командлет MailboxRestoreRequest
[PS] C:\>Get-MailboxRestoreRequest -Status Completed | Remove-MailboxRestoreRequest

```
---

**Trobleshooting**
```bash
Очистка очереди

[PS] C:\>net pause MsExchangeTransport

# Далее получаем список элементов в очереди нужного нам сервера и удаляем их
# в качестве фильтра можно использовать и другое условие, или не использовать фильтр вовсе.

[PS] C:\>Get-TransportServer ex01 | Get-Queue | Get-Message -ResultSize unlimited | Where {$_.Subject -eq "Surprise Party"} | Remove-Message -WithNDR $False

В случае с большим количеством элементов в очереди, вы получите ошибку вида:

The query produced too many results. To reduce the number of results, use a more restrictive filter.
   + CategoryInfo : InvalidOperation: (:) [Get-Message], LocalizedException
   + FullyQualifiedErrorId : 88B8D789,Microsoft.Exchange.Management.QueueViewerTasks.GetMessageInfo

Чтобы обойти эту ошибку, необходимо использовать следующую конструкцию:

[PS] C:\>Get-Message -filter {Subject -eq "…"} -resultsize 1000 | remove-Message -withNDR $False

[PS] C:\>net start MsExchangeTransport
```
---

**Просмотр логов хождения почты**

```bash
[PS] C:\>Get-MessageTrackingLog -Start (Get-Date).AddHours(-12) -ResultSize unlimited | where {[string]$_.recipients -like "*@gmail.com"}

[PS] C:\>Get-MessageTrackingLog -ResultSize unlimited –Sender "khusyainov@opti.dit" –Server EX01 -Start "01/14/2020 08:00:00" -End "01/14/2020 12:00:00" | select-object Timestamp, Sender, Recipients, MessageSubject, EventId | ft

[PS] C:\>Get-MessageTrackingLog -ResultSize 20 -Server EX01 -Start "02/27/2020 17:00:00" -End "02/27/2020 18:00:00" | select-object Timestamp, Sender, Recipients, MessageSubject, EventId | ft
```
---
```bash
Add-MailboxDatabaseCopy -Identity DB01 -MailboxServer EX01 -ReplayLagTime 00:10:00 -TruncationLagTime 00:15:00 -ActivationPreference 2
```
---
```bash
Update-MailboxDatabaseCopy -Identity "EXHDB09\AUH2MBX01" -SourceServer AUH2MBX02 -DeleteExistingFiles:$true
```
