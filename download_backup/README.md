## Бэкап NFS

Реализован для решения ['данной задачи'](https://openproject.rnd.lanit.ru/wp/688 "Кликни меня, если хочешь...") 

# Реализация

* В директории ***scripts*** расположен скрипт загрузки директории с готовым сжатым архивом ***/nfs*** с сервера ***88.15***
    * Реализация заключается в скачивании сжатого архива и проверкой его чек-суммы.
* В директории ***systemctl*** расположены файлы реализации скрипта как сервиса, а так же автозапуск через systemd. 
* Так же после создания нового бэкапа, скрипт удаляет старый бэкап, который был создан N дней назад.

Для унификации скриптов бэкапов я использую единый шаблон названия директорий хранения бэкапов ***backupName-$(date +"%Y-%m-%d")***.


# Как использовать?

1. Клонируем проект
2. В файле ***./systemctl/download_nfs.timer*** указываем нужное время срабатывания скрипта в строке с ***OnCalendar***
3. При необходимости в скрипте загрузки ***./scripts/download_nfs_backup.sh*** меняем переменные:
    * ***IP_ADDRESS*** - содержит IP-адрес сервера.
    * ***SSH_LOGIN*** - содержит имя пользователя для SSH-соединения
    * ***SERVER_DIR*** - содержит имя директории на сервере, откуда копируются бэкапы.
    * ***CURRENT_DATE*** - содержит текущую дату в формате "гггг-мм-дд".
    * ***BACKUP_DIR*** - содержит имя директории для хранения бэкапов.
    * ***DAYS_BEFORE_DEL*** - содержит количество дней, после которых удаляются старые бэкапы.
4. Запускаем скрипт установки ***install.sh***
5. Если скрипт ввыполнился без ошибок, проверяем состояние сервисов:
    * ***systemctl status download_nfs.service*** - должна быть строка ***TriggeredBy: ● download_nfs.timer***
    * ***systemctl status download_nfs.timer*** - должна быть строка ***Active: active (waiting)***. >Так же проверяем
      время, через которое стартует таймер.