#!/bin/bash
#создаём временную переменную "$PASSWORD" для подставления пароля администратора
PASSWORD=$(whiptail --title "Ввод пароля пользователя" --passwordbox "Введите пароль пользователя и нажмите ОК для продолжения." 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
echo "Создание ярлыка Disk2 на рабочем столе"
sleep 3
#создаём переменную DOMAIN и присваиваем ей значение dns-имени домена
DOMAIN=$(dnsdomainname -d)
#создаём мягкую ссылку диска Disk2 на рабочем столе
ln -s /mnt/Disk2 /home/$USER@$DOMAIN/Рабочий\ стол/
echo "$PASSWORD" | sudo -S chmod 777 /home/$USER@$DOMAIN/Рабочий\ стол/
else
	echo "Вы выбрали отмену."
	exit
fi
#
#
#
echo "Добавление папки Обмен на рабочем столе"
sleep 3
#создаём на рабочем столе файл .desktop
DISKNAME=$(whiptail --title "Настройка сетевого диска" --inputbox "Введите hostname или ip-адрес сетевого диска организации (пример: srv007 или 10.10.64.3) " 10 60 10.10.64.3  3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
echo "Вы добавили следующий сетевой диск:" $DISKNAME
#создаём переменную DOMAIN и присваиваем ей значение dns-имени домена
DOMAIN=$(dnsdomainname -d)
echo -e "[Desktop Entry]\nVersion=1.0\nType=Link\nIcon=mate-disk-usage-analyzer.png\nName[ru_RU]=Obmen\nURL=$DOMAIN;smb://$USER@$DISKNAME\nName[]=Obmen" > /home/$USER@$DOMAIN/Рабочий\ стол/Obmen\ PTO.desktop
#даём файлу Obmen.desktop права на выполнение
chmod ugo+x /home/$USER@$DOMAIN/Рабочий\ стол/Obmen.desktop
#устанавливаем редактор gui-оболочки и отключаем отображение смонтированных дисков на рабочем столе
echo "$PASSWORD" | sudo -S dnf -y install dconf-editor dconf-devel
dconf write /org/mate/caja/desktop/volumes-visible false
dconf write /org/mate/marco/general/compositing-manager true
dconf write /org/mate/screensaver/idle-activation-enabled false
dconf write /org/mate/screensaver/lock-enabled false
#увеличиваем размер значков, меняем тему и фон рабочего стола
dconf write /org/mate/panel/toplevels/bottom/size 50
dconf write /org/mate/desktop/background/picture-filename "'/usr/share/backgrounds/redos/wide/desktop_1.jpg'"
dconf write /org/mate/desktop/file-views/icon-theme "'redos'"
dconf write /org/mate/desktop/file-views/icon-theme "'redos'"
dconf write /org/mate/desktop/interface/gtk-theme "'RedOS-Red'"
dconf write /org/mate/desktop/interface/icon-theme "'RedOS'"
#убираем лишние значки с панели 
dconf write /org/mate/panel/general/object-id-list "['menu-bar', 'menu-separator', 'file-browser', 'terminal', 'yandex-browser', 'search-tool', 'window-list', 'notification-area', 'volume-control', 'st-separator', 'clock', 'show-desktop']"
else
	echo "Вы выбрали отмену."
	exit
fi
#
#
#
echo "Установка программ не входящих в официальный репозиторий"
sleep 3
#скачиваем tar архив с установочными файлами из google drive
cd /mnt/Disk2
#в этой команде важен только ключ 17uKwXDsrsvGd18ktorGBmac9ImOmEPt0 именно он копируется из ссылки общего доступа, остальную конструкцию оставляем неизменной
wget --load-cookies /tmp/cookies.txt "https://drive.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://drive.google.com/uc?export=download&id=1KbJqrulNUKfQUCCZA7ZKYnFTvsFIFAP0' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1KbJqrulNUKfQUCCZA7ZKYnFTvsFIFAP0" -O repo.tar && rm -rf /tmp/cookies.txt
#распаковываем архив и заходим в директорию с установочными файлами
tar -xvf repo.tar && rm -rf repo.tar && cd /mnt/Disk2/repo/
#
#
#
echo "II. УСТАНОВКА И НАСТРОЙКА ПРОГРАММ"
sleep 3
PROGRAMMS=$(whiptail --title "Настройка доступа SSH" --checklist \
"Выберите программы, которые требуется установить" 15 60 4 \
"Spark" "внутренний чат" ON \
"VipNet" "только для Тезис" OFF \
"Kaspersky" "Агент администрирования" OFF \
"Р7-office" "офисный пакет" OFF \
"Wine" "для Windows-приложений" OFF \
"Yandex.Browser" "основной браузер" OFF \
"1С-terminal" "терминальная версия" OFF \
"1С-console" "консольная версия" OFF \
"CryptoPRO" "для использования ЭЦП" OFF \
"Browser_plugin" "для использования ЭЦП" OFF \
"DWGViewer" "для DWG-файлов" OFF \
"Krita,Gimp,Pinta" "для графики" OFF \
"VueScan" "для сканирования" OFF \
"Rainlendar" "календарь" OFF \
"HP" "Установка техники HP" OFF \
"Kyocera" "Установка техники Kyocera" OFF \
"Admin-tools" "для диагностики системы" OFF 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Вы выбрали следующие программы:" $PROGRAMMS
	sleep 10
else
    echo "Вы выбрали отмену."
fi
for prog in $PROGRAMMS
do
    if [ $prog == "\"Spark\"" ]; then
		echo "Установка чата Spark"
		sleep 3
		#запускаем установочный файл
		echo "$PASSWORD" | sudo -S dnf -y install ./spark-2.9.4.rpm
		#создаём переменную DOMAIN и присваиваем ей значение dns-имени домена
		DOMAIN=$(dnsdomainname -d)
		#создаём директорию автозагрузки и выдаём ей права
		echo "$PASSWORD" | sudo -S mkdir -p /home/$USER@$DOMAIN/.config/autostart
		echo "$PASSWORD" | sudo -S chmod 777 /home/$USER@$DOMAIN/.config/autostart
		#создаём файл автозагрузки и выдаём ему права на выполнение
		echo "$PASSWORD" | sudo -S echo -e "[Desktop Entry]\nType=Application\nExec=/bin/sh "/opt/Spark/Spark" %U\nHidden=false\nX-MATE-Autostart-enabled=true\nName=Spark\nX-MATE-Autostart-Delay=0" > /home/$USER@$DOMAIN/.config/autostart/spark.desktop
		echo "$PASSWORD" | sudo -S chmod ugo+x /home/$USER@$DOMAIN/.config/autostart/spark.desktop
		/bin/sh "/opt/Spark/Spark" %U > /dev/null 2>&1 &
		echo "Настройку учётной записи выполняете самостоятельно"
		sleep 3
	fi
    if [ $prog == "\"VipNet\"" ]; then
        echo "Установка и настройка VipNet Client"
		sleep 3
		#запускаем установочные пакеты
		cd /mnt/Disk2/repo/ViPNet/
		echo "$PASSWORD" | sudo -S dnf -y install vipnetclient-*.rpm
		echo "$PASSWORD" | sudo -S dnf -y install libxcb-devel-1.14-2.el7.i686 libxcb-doc-1.14-2.el7.noarch
		#указываем путь к .dst-файлу
		DSTFILE=$(zenity --file-selection --file-filter='DST files (dst) | *.dst' --title="Укажите ваш DST-файл")
		#создаём временную переменную "$VIPPASS" для подставления парольной фразы
		VIPPASS=$(whiptail --title "Ввод парольной фразы" --passwordbox "Введите парольную фразу от вашего DST-файла и нажмите ОК для продолжения." 10 60 3>&1 1>&2 2>&3)
		exitstatus=$?
		if [ $exitstatus = 0 ]; then
		#связываем файл с паролем - обязательно от имени текущего пользователя
		echo "Повторите ввод парольной фразы от вашего DST-файла"
		vipnetclient installkeys $DSTFILE --psw $VIPPASS
else
	echo "Вы выбрали отмену."
	exit
fi
		#выполняем настройки клиента
		#включаем проверку обновлений справочников и ключей на транспортном сервере
		vipnetclient debug --mftp-reconnect
		#ознакомиться с основными параметрами
		vipnetclient info
		sleep 5
		#проверяем доступность с координатором
		ping 11.0.0.1 -c 3
		#включаем журналирование критичных ошибок
		vipnetclient debug --loglevel 0
		#настраиваем передачу данных по протоколу TCP. Включаем автоматический режим.
		vipnetclient debug --tcp-tunnel-mode auto
		#включаем автоматическое устранение ошибок ViPNet Client
		vipnetclient debug --autostart
		#в файле vipnet.conf указываем контроллеры домена
		echo "$PASSWORD" | sudo -S sed -i '9d' /etc/vipnet.conf
		echo "$PASSWORD" | sudo -S perl -i -pe 'print "trusted=10.14.100.200,10.17.101.222\n" if $. == 9' /etc/vipnet.conf
		#включаем видимость туннелируемых узлов по реальным адресам
		echo "$PASSWORD" | sudo -S systemctl stop vipnetclient
		vipnetclient debug --tunnel-visibility 0
		echo "$PASSWORD" | sudo -S systemctl start vipnetclient
		vipnetclient-gui > /dev/null 2>&1 &
		vipnetclient dbviewer
		#создаём временную переменную "$VIPPASSORG" для подставления парольной фразы
		VIPPASSORG=$(whiptail --title "Ввод парольной фразы организации" --passwordbox "Введите парольную фразу администратора организации и нажмите ОК для продолжения." 10 60 3>&1 1>&2 2>&3)
		exitstatus=$?
		if [ $exitstatus = 0 ]; then
		#создаём журнал для ошибок 
		echo "Создадим журнал хранения ошибок"
		sleep 3
		echo "$PASSWORD" | sudo -S mkdir /var/log/vipnetlog
		echo "$PASSWORD" | sudo -S vipnetclient eventlog --psw $VIPPASSORG --output /var/log/vipnetlog/
		echo "Журнал создан, он находится здесь: /var/log/vipnetlog/"
		sleep 3
else
	echo "Вы выбрали отмену."
	exit
fi
    fi
    if [ $prog == "\"Kaspersky\"" ]; then
        echo "Установка антивируса Касперского"
		sleep 3
		#запускаем установочный пакеты агента
		cd /mnt/Disk2/repo/Kaspersky/
		echo "$PASSWORD" | sudo -S dnf -y install klnagent64-*.rpm
		cd
		#запускаем скрипт
		sleep 10
		sudo /opt/kaspersky/klnagent64/lib/bin/setup/postinstall.pl
		echo "Установка Kaspersky Endpoint Security выполняется только из Сервера администрирования Касперского!"
		sleep 10
    fi
    if [ $prog == "\"Р7-office\"" ]; then
        echo "Установка офиса Р-7"
		sleep 3
		#запускаем установочный пакет
		echo "$PASSWORD" | sudo -S dnf -y install https://download.r7-office.ru/centos/r7-office.rpm
		#устанавливаем шрифты Microsoft
		echo "$PASSWORD" | sudo -S dnf -y install libxcrypt-compat msttcore-fonts-installer
		#добавляем в программы по умолчанию
		xdg-mime default "r7-office-desktopeditors.desktop" "application/vnd.oasis.opendocument.text"
		xdg-mime default "r7-office-desktopeditors.desktop" "application/vnd.oasis.opendocument.spreadsheet"
		xdg-mime default "r7-office-desktopeditors.desktop" "application/vnd.ms-excel"
		xdg-mime default "r7-office-desktopeditors.desktop" "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
		xdg-mime default "libreoffice-draw.desktop" "application/pdf"
		#создаём переменную DOMAIN и присваиваем ей значение dns-имени домена
		DOMAIN=$(dnsdomainname -d)
		cp /mnt/Disk2/repo/r7/Документ.docx /home/$USER@$DOMAIN/Шаблоны/
		cp /mnt/Disk2/repo/r7/Презентация.pptx /home/$USER@$DOMAIN/Шаблоны/
		cp /mnt/Disk2/repo/r7/Таблица.xlsx /home/$USER@$DOMAIN/Шаблоны/
		echo "Лицензию активируете самостоятельно"
		sleep 15
    fi
	if [ $prog == "\"Wine\"" ]; then
        echo "Установка Wine"
		sleep 3
		#устанавливаем Wine
		echo "$PASSWORD" | sudo -S dnf -y update
		echo "$PASSWORD" | sudo -S dnf -y install wine winetricks
		#настраиваем winetricks от имени пользователя, для которого настраиваете wine
		#скачиваем все необходимые пакеты
		winetricks riched30 winhttp
		#обновляем до последней версии winetricks
		echo "$PASSWORD" | sudo -S winetricks --self-update
		#смотрим версию, должна не ниже, чем wine-7.16 (Staging)
		wine --version
		sleep 5
    fi
	if [ $prog == "\"Yandex.Browser\"" ]; then
        echo "Установка Яндекс.браузер"
		sleep 3
		#запуск установочных пакетов 
		echo "$PASSWORD" | sudo -S dnf -y install https://repo.yandex.ru/yandex-browser/rpm/stable/x86_64/yandex-browser-stable-22.11.3.838-1.x86_64.rpm
		#назначение браузером по умолчанию
		xdg-settings set default-web-browser yandex-browser.desktop
    fi
	if [ $prog == "\"1С-terminal\"" ]; then
        echo "Установка 1С (терминальная)"
		sleep 3
		#создаём на рабочем столе файл .desktop
		echo "$PASSWORD" | sudo -S echo -e "[Desktop Entry]\nType=Application\nExec=remmina-file-wrapper %U\nName=1C\nStartupNotify=true\nComment=1C\nIcon=/usr/share/icons/redos/48x48/status/network-idle.png" > /home/$USER@$DOMAIN/Рабочий\ стол/1C.desktop
		#создаём переменную DOMAIN и присваиваем ей значение dns-имени домена
		DOMAIN=$(dnsdomainname -d)
		#даём права на выполнение
		chmod ugo+x /home/$USER@$DOMAIN/Рабочий\ стол/1C.desktop
		echo "После запуска RDP-клиента вводим ip-адрес сервера 1С"
		sleep 3
    fi
	if [ $prog == "\"1С-console\"" ]; then
        echo "Установка 1C (консольная)"
		sleep 3
		#заходим в директорию с установочными пакетами и запускаем их
		cd /mnt/Disk2/repo/1C
		echo "$PASSWORD" | sudo -S dnf -y install webkitgtk3-*.rpm webkitgtk3-devel-*.rpm
		echo "$PASSWORD" | sudo -S dnf -y install 1c-enterprise-*-client-*.rpm 1c-enterprise-*-common-*.rpm 1c-enterprise-*-server-*.rpm 1c-enterprise-*-client-nls-*.rpm 1c-enterprise-*-ws-*.rpm 1c-enterprise-*-ws-nls-*.rpm 1c-enterprise-*-crs-*.rpm
		#копируем иконку
		echo "$PASSWORD" | sudo -S cp -r /mnt/Disk2/repo/1C/1c.ico /usr/share/icons/
		#создаём на рабочем столе файл .desktop
		echo "$PASSWORD" | sudo -S echo -e "[Desktop Entry]\nType=Application\nExec=/opt/1cv8/x86_64/8.3.18.1289/1cestart\nName[ru_RU]=1С:Предприятие\nStartupNotify=true\nComment[ru_RU]=1С:Предприятие x86_64\nIcon=/usr/share/icons/1c.ico" > /home/$USER@$DOMAIN/Рабочий\ стол/1С:Предприятие.desktop
		#создаём переменную DOMAIN и присваиваем ей значение dns-имени домена
		DOMAIN=$(dnsdomainname -d)
		#даём права на выполнение
		chmod ugo+x /home/$USER@$DOMAIN/Рабочий\ стол/1С:Предприятие.desktop
		#поднимаемся на директорию выше и обновляем значки рабочего стола
		cd /mnt/Disk2/repo/
		echo "$PASSWORD" | sudo -S gtk-update-icon-cache -f -t /usr/share/icons/hicolor
		echo "$PASSWORD" | sudo -S update-mime-database /usr/share/mime
		echo "$PASSWORD" | sudo -S update-desktop-database /usr/share/applications
		echo "После установки запустите 1С-клиент и укажите авторизационные данные сервера 1С"
		sleep 3
    fi
	if [ $prog == "\"CryptoPRO\"" ]; then
        echo "Установка КРИПТО-ПРО"
		sleep 3 
		#спускаемся в директорию, даём скрипту права на выполнение и запускаем его
		cd /mnt/Disk2/repo/CryptoPRO/
		echo "$PASSWORD" | sudo -S chmod ugo+x install_gui.sh
		echo "$PASSWORD" | sudo -S ./install_gui.sh
		#в открывшемся окне: Next -> выбираем всё -> Next -> Install -> Ok -> Enter the license now
		#вводим номер лицензии -> Enter -> Ok -> Exit ->Yes
		#устанавливаем лицензию
		/opt/cprocsp/sbin/amd64/cpconfig -license -view
		echo "Сверяйте введённый ключ"
		sleep 5
		echo "Если ошиблись, по завершении работы скрипта введите эту команду:"
		echo "/opt/cprocsp/sbin/amd64/cpconfig -license -set номер_лицензии"
		sleep 10
		#устанавливаем инструменты для подписи, хранения ключевых носителей и шифрования
		echo "$PASSWORD" | sudo -S dnf -y install ifd-rutokens token-manager ifcplugin gostcryptogui caja-gostcryptogui
		echo "$PASSWORD" | sudo -S dnf -y install cprocsp-rdr-jacarta-*.rpm
		echo "$PASSWORD" | sudo -S dnf -y install https://ds-plugin.gosuslugi.ru/plugin/upload/assets/distrib/IFCPlugin-x86_64.rpm
		cd /mnt/Disk2/repo/
    fi
	if [ $prog == "\"Browser_plugin\"" ]; then
        echo "Установка расширений для браузеров"
		echo "Плагин Госуслуги"
		sleep 3
		#ставим пакет с плагином в систему, а затем инсталируем его руками в браузер 
		#Будем делать на примере браузера Яндекс.Браузер
		python -m webbrowser "https://chrome.google.com/webstore/detail/расширение-для-плагина-го/pbefkdcndngodfeigfdgiodgnmbgcfha?hl=ru&authuser=1"
		sleep 60
		killall yandex_browser
		sleep 10
		echo "CryptoPro Browser Plug-in"
		sleep 3
		cd /mnt/Disk2/repo/plugins/
		#ставим пакет с плагином в систему, а затем инсталируем его руками в браузер 
		echo "$PASSWORD" | sudo -S dnf -y install ./cprocsp-pki*rpm
		python -m webbrowser "https://chrome.google.com/webstore/detail/cryptopro-extension-for-c/iifchhfnnmpdbibifmljnfjhpififfog?hl=ru && xdg-open https://www.cryptopro.ru/sites/default/files/products/cades/demopage/cades_bes_sample.html"
		echo "Вставьте носитель с сертификатом и проверяем подпись в появившемся диалоговом окне выбираем разрешить операцию ОК"
		sleep 60
		killall yandex_browser
		sleep 10
		echo "Контур.Плагин"
		sleep 3
		python -m webbrowser "https://chrome.google.com/webstore/detail/%D0%BA%D0%BE%D0%BD%D1%82%D1%83%D1%80%D0%BF%D0%BB%D0%B0%D0%B3%D0%B8%D0%BD/hnhppcgejeffnbnioloohhmndpmclaga"
		sleep 60
		killall yandex_browser
		sleep 10
		#ставим пакет с плагином в систему, а затем инсталируем его руками в браузер 
		cd /mnt/Disk2/repo/plugins/
		echo "$PASSWORD" | sudo -S dnf -y install kontur.plugin_amd64.rpm
		echo "$PASSWORD" | sudo -S dnf -y install kontur.plugin-4.0.6.244-1.x86_64.001499.rpm
		python -m webbrowser "https://install.kontur.ru/kekep?_ga=2.232358492.2121287449.1613045347-237475827.1613045347"
		sleep 60
		killall yandex_browser
		sleep 10
		#ставим пакет с плагином в систему, а затем инсталируем его руками в браузер 
		echo "$PASSWORD" | sudo -S dnf -y install diag.plugin*.rpm
		sleep 10
		python -m webbrowser "https://install.kontur.ru/kekep?_ga=2.232358492.2121287449.1613045347-237475827.1613045347"
		sleep 60
		killall yandex_browser
		sleep 10
    fi
	if [ $prog == "\"DWGViewer\"" ]; then
        echo "Установка DWGViewer"
		sleep 3
		#устанавливаем читалку для AutoCAD-файлов
		cd /mnt/Disk2/repo/
		echo "$PASSWORD" | sudo -S dnf -y install freeglut-devel
		echo "$PASSWORD" | sudo -S dnf -y install https://www.varicad.com/userdata/files/release/en/VariCAD_2022-en-2.05-1.x86_64.rpm
    fi
	if [ $prog == "\"Krita,Gimp,Pinta\"" ]; then
        echo "Установка графических редакторов"
		sleep 3
		#устанавливаем пакеты для сканирования и распознования текста
		echo "$PASSWORD" | sudo -S dnf -y install krita gimp pinta yagf aspell-ru aspell-en yagf-0.9.5-5.el7.i686 xsane libksane libksane-devel
		echo "$PASSWORD" | sudo -S dnf -y install  pantum-drivers-sane perl-Image-Sane sane-backends-daemon sane-backends-devel sane-frontends xsane-gimp
    fi
	if [ $prog == "\"VueScan\"" ]; then
        echo "Установка программы для сканирования VueScan"
		sleep 3
		#устанавливаем пакеты для сканирования и распознования текста
		echo "$PASSWORD" | sudo -S dnf -y install https://www.hamrick.com/files/vuex6497.rpm
		echo "Настройки программы VueScan выполняете самостоятельно"
		sleep 3
    fi
	if [ $prog == "\"Rainlendar\"" ]; then
        echo "Установка Календаря"
		sleep 3
		#распаковываем архив со скриптом и помещаем его в общую директорию 
		cd /mnt/Disk2/repo/
		tar jxvf Rainlendar*.tar.bz2
		echo "$PASSWORD" | sudo -S cp -r rainlendar2 /usr/share/
		#создаём переменную DOMAIN и присваиваем ей значение dns-имени домена
		DOMAIN=$(dnsdomainname -d)
		#добавляем файл .desktop в автозагрузку и даём ему права на выполнение 
		echo "$PASSWORD" | sudo -S echo -e "[Desktop Entry]\nType=Application\nExec=/usr/share/rainlendar2/rainlendar2\nHidden=false\nX-MATE-Autostart-enabled=true\nName=Rainlendar\nX-MATE-Autostart-Delay=0" > /home/$USER@$DOMAIN/.config/autostart/rainlendar.desktop
		echo "$PASSWORD" | sudo -S chmod ugo+x /home/$USER@$DOMAIN/.config/autostart/rainlendar.desktop
		/usr/share/rainlendar2/rainlendar2 > /dev/null 2>&1 & 
    fi
	if [ $prog == "\"HP\"" ]; then
        echo "Установка принтера\МФУ\сканера фирмы HP"
		sleep 3
		#устанавливаем драйвера и вспомогательные утилиты
		echo "$PASSWORD" | sudo -S dnf -y install manufacturer-PPDs OpenPrintingPPDs-ghostscript OpenPrintingPPDs-postscript libjpeg cups-devel net-snmp python-cups-doc PyQt4 python3-PyQt4 python-reportlab
		#выставляем python3 программой для запуска скриптов .py по умолчанию 
		echo "$PASSWORD" | sudo -S ln -fs /usr/bin/python3 /usr/bin/python
		#перезапускаем службу печати
		echo "$PASSWORD" | sudo -S systemctl enable cups
		echo "$PASSWORD" | sudo -S systemctl restart cups
		#запускаем интерактивный устаночный файл
		echo "$PASSWORD" | sudo -S hp-setup
		echo "Все настройки выполняете самостоятельно"
		sleep 3
    fi
	if [ $prog == "\"Kyocera\"" ]; then
        echo "Установка принтера\МФУ\сканера фирмы Kyocera"
		sleep 3
		#устанавливаем драйвера и вспомогательные утилиты
		echo "$PASSWORD" | sudo -S dnf -y install manufacturer-PPDs OpenPrintingPPDs-ghostscript OpenPrintingPPDs-postscript libjpeg cups-devel net-snmp python-cups-doc PyQt4 python3-PyQt4 python-reportlab
		#выставляем python3 программой для запуска скриптов .py по умолчанию 
		echo "$PASSWORD" | sudo -S ln -fs /usr/bin/python3 /usr/bin/python
		#перезапускаем службу печати
		echo "$PASSWORD" | sudo -S systemctl enable cups
		echo "$PASSWORD" | sudo -S systemctl restart cups
		#запускаем интерактивный устаночный файл
		cd /mnt/Disk2/repo/Kyocera
		echo "$PASSWORD" | sudo -S dnf -y install kyodialog*.rpm
		echo "$PASSWORD" | sudo -S dnf -y install kyocera-sane*.rpm
		#запускаем интерактивный устаночный файл
		echo "$PASSWORD" | sudo -S system-config-printer
		echo "Все кастомные настройки выполняете самостоятельно"
		sleep 3
    fi
	if [ $prog == "\"Admin-tools\"" ]; then
        echo "Установка программ для диагностики компьютера и системы"
		sleep 3
		#тут большой список инструментов, которые могут пригодиться системному администратору
		echo "$PASSWORD" | sudo -S dnf -y install gnome-disk-utility hwloc lshw htop libxslt-devel libgcrypt-devel gnutls-devel gstreamer-devel dbus-devel stress-ng nc 
		echo "$PASSWORD" | sudo -S dnf -y groupinstall "Development Tools"
		echo "Как пользоваться этими программами можно узнать в инструкции"
		sleep 3
    fi
done
#
#
#
