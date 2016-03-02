#!/usr/bin/env bash

# Color helpers
export TERM=${TERM:-vt100} # avoid tput complaining when TERM is not set.
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

all() { # Configure everything on a new machine.
    install_server_libs && \
    install_apache && \
    set_apache_rewrite_mode && \
    install_php && \
    install_mysql && \
 	install_xdebug && \
    install_memcached
}

set_apache_rewrite_mode() {
	sudo service apache2 reload
	sudo a2enmod rewrite
	sudo service apache2 restart
	sudo mkdir /var/log/apache2/logs/
}

install_php() { # Download the PHP sources
    sudo add-apt-repository -y ppa:ondrej/php5-5.6
    sudo apt-get update
    sudo apt-get install -y php5
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
	sudo apt-get install -y pkg-config
    sudo apt-get install -y python-software-properties
    sudo apt-get update
}

install_xdebug() {
	sudo apt-get install -y php5-dev php-pear
    sudo pecl install xdebug
    sudo service apache2 restart
	# Add in /etc/php5/apache2/php.ini - zend_extension=/usr/lib/php5/20121212/xdebug.so (after restart server)
}

install_mysql() { # Install mysql
    cd $HOME && sudo wget https://dev.mysql.com/get/mysql-apt-config_0.6.0-1_all.deb
    cd $HOME && sudo dpkg -i mysql-apt-config_0.6.0-1_all.deb
    sudo apt-get update
	sudo apt-get install -y mysql-server
}

install_memcached() {
    sudo apt-get install -y php5-mysql 
    sudo apt-get install -y php5
    sudo apt-get install -y php5-memcache
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

