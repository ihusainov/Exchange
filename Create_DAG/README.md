Разберемся, как на базе двух серверов Exchange Server 2016 создать кластерную группу DAG (Database Availability Group) для обеспечения отказоустойчивости баз данных почтовых ящиков. В этом примере для развертывания DAG будет использоваться Exchange Server 2016 Server с CU5 на Windows Server 2016. На обоих серверах базы данных почтовых ящиков хранятся на дисках E:, т.к. для работы DAG местоположение почтовых баз на всех серверах должно быть одинаковым.

**Процесс создания DAG состоит из следующих шагов:**
```bash
- Создание почтовых баз и перезапуск службы Information store service
- Создание DAG (в Exchange 2016 не нужно создавать отдельный аккаунт для кластера DAG в Active Directory и резервировать за ним IP адрес) и сервера-свидетеля (Witness Server)
- Добавление серверов в DAG
- Добавление в DAG почтовых баз (Mailbox Database)

Примечание. Касательно сети репликации DAG. В Exchange 2016 Microsoft более не рекомендует создавать выделенную сеть для репликации почтовых баз.
```
**Создадим новую базу почтовых ящиков MBX01 на сервере EX01:**
```bash
[PS] C:\>New-MailboxDatabase -Name MBX01 -Server EX01 -EdbFilePath E:\MboxDB\EX01\MBX01.edb -LogFolderPath E:\LogDB\EX01\ -Verbose
```
**После того, как база создана, нужно перезапустить службу Information Store Service командой:**
```bash
[PS] C:\>Restart-Service MSExchangeIS
```
**Теперь можно создать новый кластер DAG.**
```bash
Примечание. Для работы DAG нам потребуется третий сервер-свидетель (этот сервер может быть любым другим сервером с Exchange Server 2016, но не являться членом данного кластера DAG).

В этом примере в качестве сервера-свидетеля (Witness Server) будет выступать сервер Nano Server 2016.
[PS] C:\>New-DatabaseAvailabilityGroup -Name DAG01 -WitnessServer cas01.office.local -WitnessDirectory E:\Dag-msk  –Verbose
```
**В корне диска сервера-свидетеля будет создана новая папка с именем DAGFileShareWitnesses.**

**Теперь в группу DAG можно добавить первый почтовый сервер EX01.**
```bash
[PS] C:\>Add-DatabaseAvailabilityGroupServer -Identity DAG01 -MailboxServer EX01 -Verbose
```
**А затем и второй:**
```bash
[PS] C:\>Add-DatabaseAvailabilityGroupServer -Identity DAG01 -MailboxServer EX02 -Verbose
```
**Теперь, когда оба сервера почтовых ящиков являются членами одной группы DAG, можно добавить в группу базу данных почтовых ящиков, отказоустойчивость который вы планируете обеспечить:**
```bash
[PS] C:\>Add-MailboxDatabaseCopy -Identity MBX01 -MailboxServer EX02 -Verbose
```
**После окончания работы предыдущего командлета проверим статус DAG такой командой:**
```bash
[PS] C:\>Get-DatabaseAvailabilityGroup DAG01
```
**Для получения состояния базы в DAG, информации о ее копиях и статусе репликации между ними, выполните команду:**
```bash
[PS] C:\>Get-MailboxDatabaseCopyStatus -Db MBX01
```

Как вы видите, у нас имеется две работоспособные копии одной базы на разных серверах, одна из которых активна (mounted), а вторая – является пассивной копией.

---
```bash
New-DatabaseAvailabilityGroup -Name DAG01 -WitnessServer cas01.office.opticom.local -WitnessDirectory E:\Dag-Opti -Verbose

Add-DatabaseAvailabilityGroupServer -Identity DAG01 -MailboxServer ex01 -Verbose
Add-DatabaseAvailabilityGroupServer -Identity DAG01 -MailboxServer ex02 -Verbose
Add-MailboxDatabaseCopy -Identity MBX01 -MailboxServer ex01 -Verbose
Add-MailboxDatabaseCopy -Identity MBX01 -MailboxServer ex02 -Verbose

restart-service -name MSExchangeIS
```
