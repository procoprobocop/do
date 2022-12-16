_#Скрипт для автоматической установки и настройки Linux_

_#для Департамента образования ЯНАО"
__________________________________________________________________________________

_#Подготовка к запуску скриптов_

1. В контроллере домена, в папке Computers удалите настраиваемый компьютер если он там есть (иначе будут проблемы с добавлением в домен).

2. Если будет ставиться **VipNet** заранее скиньте на флешку **dst-файл** и секретный ключ.

4. Откройте терминал и введите:

**git clone https://github.com/procoprobocop/do.git**

**cd do/** 

**chmod ugo+x** ***.sh**

_#Вы скачали скрипт и дали ему права на выполнение. Теперь можно переходить к их запуску_

___________________________________________________________________________________

#Запуск скрипта

5. Введите в терминале:

**./doscript_1.sh**

_#Будет выполнен запуск скрипта, после чего произойдёт перезагрузка_

6. Откройте терминал и введите:

**git clone https://github.com/procoprobocop/do.git**

**cd do/** 

**chmod ugo+x** ***.sh**

**./doscript_2.sh**

_#Некоторые настройки, например пользователя в Spark или 1C придётся донастраивать самостоятельно._
_____________________________________________________________________________________

_#P.S: Запускать один скрипт дважды может только Чак Норрис!))_

