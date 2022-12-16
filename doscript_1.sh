#!/bin/bash
echo "I. УСТАНОВКА И НАСТРОЙКА ОС"
sleep 3
#создаём временную переменную "$PASSWORD" для подставления пароля администратора
PASSWORD=$(whiptail --title "Ввод пароля администратора" --passwordbox "Введите пароль Локального администратора и нажмите ОК для продолжения." 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
echo "Производится обновление системы"
sleep 3
echo "$PASSWORD" | sudo -S dnf -y install kernel-lt-5.15.35-1.el7.3.x86_64 kernel-lt-tools-5.15.35-1.el7.3.x86_64 kernel-lt-devel-5.15.35-1.el7.3.x86_64 kernel-lt-headers-5.15.35-1.el7.3.x86_64
echo "$PASSWORD" | sudo -S dnf -y update && echo "$PASSWORD" | sudo -S dnf -y upgrade && echo "$PASSWORD" | sudo -S dnf -y autoremove && uname -r
else
	echo "Вы выбрали отмену."
	exit
fi
#
#
#
echo "Производится настройка Disk2"
sleep 3
#создаём таблицу разделов в формате gpt
echo "$PASSWORD" | sudo -S parted /dev/sdb mktable gpt
#создаём раздел диска sdb, который будет называться sdb1 с файловой системой ext4 и отводим ему 100% места на диске
echo "$PASSWORD" | sudo -S parted /dev/sdb mkpart primary ext4 0% 100% 
#форматируем созданный раздел
echo "$PASSWORD" | sudo -S mkfs.ext4 /dev/sdb1
#создаём директорию Disk2, в которую смонтируем наш HDD
echo "$PASSWORD" | sudo -S mkdir /mnt/Disk2
#задаём директории Disk2 в которую примонтирован HDD доступ на чтение/запись/выполнение для всех: 
echo "$PASSWORD" | sudo -S chmod 777 /mnt/Disk2/
#создаём символическую ссылку диска на рабочем столе локального пользователя
ln -s /mnt/Disk2 /home/$USER/Рабочий\ стол/
echo "$PASSWORD" | sudo -S chmod 777 /home/$USER/Рабочий\ стол/Disk2
#редактируем файл /etc/fstab монтируя вновь созданный раздел диска /dev/sdb1 в директорию Disk2
echo "$PASSWORD" | sudo -S sh -c "echo '/dev/sdb1	/mnt/Disk2	ext4	defaults	1 2' >> /etc/fstab"
#монтируем созданный диск
echo "$PASSWORD" | sudo -S mount /mnt/Disk2
#
#
#
echo "Добавляем компьютер в домен"
sleep 3
#устанавливаем правильный часовой пояс
echo "$PASSWORD" | sudo -S timedatectl set-timezone Asia/Yekaterinburg
timedatectl | grep "Time zone"
date
chronyc tracking
#проверяем DNS и разрешение имён
nslookup 10.14.100.222
nslookup 10.17.101.222
nslookup YG.loc
#меняем локализацию на английскую. Это нужно, если у вас в пароле администратора домена присутствуют специальные символы: !@#$%^ и т.д..
#после перезагрузки локализация снова сбросится на русскую
export LANG=en_US.UTF-8
#проверяем доступность домена
realm discover YG.loc
#устанавливаем программу добавления в домен
echo "$PASSWORD" | sudo -S dnf -y install join-to-domain
#запускаем скрипт добавления в домен
sudo join-to-domain.sh
realm discover YG.loc
#проверяем доступность домена
realm list
#создаём переменную DOMAIN и присваиваем ей значение dns-имени домена
DOMAIN=$(dnsdomainname -d)
realm discover -v $DOMAIN
#проверяем новое имя компьютера
hostname
#даём группам "Администраторы домена" и "Пользователи домена" права выполнения команд от имени суперпользователя 
cd /etc/
echo "$PASSROOT" | sudo -S perl -i -pe 'print "%DO\\ Admins  ALL=(ALL)       ALL\n" if $. == 108' sudoers
echo "$PASSROOT" | sudo -S perl -i -pe 'print "%Domain\\ Users  ALL=(ALL)       ALL\n" if $. == 109' sudoers
#
#
#
#перезагружаемся, иначе магия не сработает
if (whiptail --title "Требуется перезагрузка системы" --yesno "Перезагрузить систему сейчас?" 10 60) then
	echo "$PASSWORD" | sudo -S reboot
else
	echo "Не забудьте перезагрузить систему"
	exit
fi
