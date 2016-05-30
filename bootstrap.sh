#!/usr/bin/env bash

NVM_VERSION=4.4.5
PHPMYADMIN_VERSION=4.6.2

# Color helpers
export TERM=${TERM:-vt100} # avoid tput complaining when TERM is not set.
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

MYSQL_LIST=$(cat <<EOF
### THIS FILE IS AUTOMATICALLY CONFIGURED ###
# You may comment out entries below, but any other modifications may be lost.
# Use command 'dpkg-reconfigure mysql-apt-config' as root for modifications.
deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-apt-config
deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-5.7
deb-src http://repo.mysql.com/apt/ubuntu/ trusty mysql-5.7
EOF
)

XDEBUG=$(cat <<EOF
zend_extension=/usr/lib/php/20131226/xdebug.so
EOF
)

PHPMYADMIN_NAME=phpmyadmin
VHOST_PHPMYADIN=$(cat <<EOF
  <VirtualHost *:80>
        ServerAdmin webmaster@$PHPMYADMIN_NAME.mtr
        DocumentRoot /var/www/$PHPMYADMIN_NAME
        <Directory /var/www/$PHPMYADMIN_NAME/>
            Options +FollowSymLinks
            AllowOverride All
        </Directory>
        ServerName www.$PHPMYADMIN_NAME.mtr
        ErrorLog /var/log/apache2/logs/$PHPMYADMIN_NAME.www-error_log.log
        CustomLog /var/log/apache2/logs/$PHPMYADMIN_NAME.www-access_log.log common
  </VirtualHost>
EOF
)

PHPMYADMINCFG=$(cat <<'EOF'
$cfg["blowfish_secret"] = "qtdRoGmbc9{8IZr323xYcSN]0s)r$9b_JUnb{~Xz"; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */
EOF
)

all() { # Configure everything on a new machine.
    install_server_libs && \
    install_apache && \
    set_apache_rewrite_mode && \
    install_php && \
    install_mysql && \
    install_php_packages && \
 	install_xdebug && \
    install_memcached && \
    set_xdebug && \
    install_dev_tools
}

set_apache_rewrite_mode() {
	sudo service apache2 reload
	sudo a2enmod rewrite
	sudo service apache2 restart
	sudo mkdir /var/log/apache2/logs/
}

install_php() { # Install PHP 5.6
    sudo LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
    sudo apt-get update
    sudo apt-get install -y php5.6
}

install_apache() { # Install apache
    sudo apt-get install -y apache2
}

install_server_libs() { # Install server libs
    sudo apt-get update
	sudo apt-get install make
	sudo apt-get install -y libxml2
	sudo apt-get install -y libxml2-dev
	sudo apt-get install -y libssl-dev
	sudo apt-get install -y openssl
	sudo apt-get install -y git
	sudo apt-get install -y curl
	sudo apt-get install -y libsslcommon2-dev
	sudo apt-get install -y libcurl4-openssl-dev
    sudo apt-get install -y python-software-properties
    sudo apt-get install -y debconf-utils
    sudo apt-get install -y htop
    sudo apt-get install -y language-pack-en-base
    sudo apt-get update
}

install_php_packages() {
    sudo apt-get install -y php5.6-dev php5.6-xml
    sudo apt-get install -y php5.6-mbstring php5.6-curl
    sudo apt-get install -y php5.6-mysqlnd php-pear
}

install_xdebug() {
    sudo pecl install xdebug
    sudo service apache2 restart
	# Add in /etc/php/5.6/apache2/php.ini - zend_extension=/usr/lib/php5/20131226/xdebug.so (after restart server)
}

set_xdebug() { # Install Vhost
    sudo sh -c "echo '${XDEBUG}' >> /etc/php/5.6/apache2/php.ini"
    sudo service apache2 restart
}

install_dev_tools() { # Install dev tools
    # Add PHPMyadmin
    cd /var/www/ && sudo wget https://files.phpmyadmin.net/phpMyAdmin/$PHPMYADMIN_VERSION/phpMyAdmin-$PHPMYADMIN_VERSION-english.tar.gz
    cd /var/www/ && sudo tar -zxvf phpMyAdmin-$PHPMYADMIN_VERSION-english.tar.gz
    cd /var/www/ && sudo mv phpMyAdmin-$PHPMYADMIN_VERSION-english phpmyadmin
    cd /var/www/ && sudo rm phpMyAdmin-$PHPMYADMIN_VERSION-english.tar.gz

    sudo touch /etc/apache2/sites-available/$PHPMYADMIN_NAME.conf
    sudo sh -c "echo '${VHOST_PHPMYADIN}' > /etc/apache2/sites-available/$PHPMYADMIN_NAME.conf"
    sudo a2ensite $PHPMYADMIN_NAME.conf
    sudo service apache2 restart

    sudo cp /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config.inc.php
    sudo sh -c "echo '${PHPMYADMINCFG}' >> /var/www/phpmyadmin/config.inc.php"
    sudo service apache2 restart
    

    # Add Composer
    cd $HOME && curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer

    # Add NVM
    cd $HOME && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
    nvm install $NVM_VERSION
    nvm use $NVM_VERSION
    sudo sh -c "echo 'nvm use ${NVM_VERSION}' >> $HOME/.bashrc"

    # Add Bower
    npm install bower -g
}

install_mysql() { # Install mysql
    export DEBIAN_FRONTEND=noninteractive
    sudo sh -c "echo '${MYSQL_LIST}' > /etc/apt/sources.list.d/mysql.list"
    sudo apt-get update
    echo mysql-community-server mysql-community-server/re-root-pass password "parola" | sudo debconf-set-selections
    echo mysql-community-server mysql-community-server/root-pass password "parola" | sudo debconf-set-selections
	sudo -E apt-get --force-yes -y install mysql-community-server
}

install_memcached() { 
    sudo apt-get install -y php-memcache
    sudo apt-get install -y memcached
    sudo service apache2 restart
}

help() { # This help
    echo "Manage a local development server"
    echo
    echo "Usage: ${YELLOW}$0${NORMAL} <command> <arg1> ..."
    echo
	echo "Commands:"
    sed -r -n "s/([a-z_]+)\(\)+ *\{ *#(.*)$/  $BOLD\1$NORMAL:\2/gp" $0
}

cmd=$1
if [ -z "$cmd" ] ; then
    help
    exit 1
fi
shift
$cmd "$@"
