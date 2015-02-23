#!/bin/bash
MYSQL_ADMIN_PASSWORD="1234.passw0rd"

echo "Provisioning virtual machine..."
# this is to suppress the 'dpkg-reconfigure: unable to re-open stdin: No file or directory'
#   messages, which seem to be harmless and meaningless
export DEBIAN_FRONTEND="noninteractive"
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

echo "Installing Vim, Midnight Commander, Ntp, Bzip2"
apt-get install vim mc ntp bzip2 -y > /dev/null
PREPEND_TO_VIMRC="syntax on
set background=dark"
exec 3<> /etc/vim/vimrc && awk -v TEXT="$PREPEND_TO_VIMRC" 'BEGIN {print TEXT}{print}' /etc/vim/vimrc >&3

# echo "Installing Nodejs"
# apt-get install npm nodejs nodejs-legacy -y > /dev/null

# echo "Installing TLDR (use instead of `man`)"
# npm install -g tldr > /dev/null

echo "Installing Git"
apt-get install git -y > /dev/null

echo "Installing Nginx"
apt-get install nginx -y > /dev/null

echo "Installing PHP"
apt-get install php5-common php5-dev php5-cli php5-fpm -y > /dev/null

echo "Installing PHP extensions"
apt-get install curl php5-curl php5-gd php5-mcrypt php5-mysql -y > /dev/null

echo "Preparing MySQL"
apt-get install debconf-utils -y > /dev/null
debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ADMIN_PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ADMIN_PASSWORD"

echo "Installing MySQL"
apt-get install mysql-server -y > /dev/null

echo "Configuring Nginx"
ln -s /var/www/provision/config/nginx_vhost /etc/nginx/sites-enabled/
rm -rf /etc/nginx/sites-enabled/default
service nginx restart > /dev/null

echo "Installing Composer globally"
curl -sS https://getcomposer.org/installer | php > /dev/null
mv composer.phar /usr/local/bin/composer
#echo "
#PATH=\$PATH:~/.composer/vendor/bin" >> /home/vagrant/.bashrc

echo "Add Composer to PATH, also set up a nice bash prompt"
su -c 'ln -s /var/www/provision/.bash_aliases /home/vagrant/.bash_aliases' - vagrant

echo "Installing PHP Code Sniffer globally"
su -c '/usr/local/bin/composer global require "squizlabs/php_codesniffer=*" > /dev/null' - vagrant

echo "Finished provisioning."
