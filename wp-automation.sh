#!/bin/bash -e

clear

# Remove/Uninstall process
if [[ $1 == "remove" ]]; then

	# Grab the project name
	if [[ -z $2 ]]; then
		echo "WP Project to remove: "
		read -e projectname
	else
		projectname=$2
	fi

	projectDirectory="/home/vagrant/www/$projectname"

	if [[ ! -d $projectDirectory ]]; then
		echo "$projectDirectory directory not exists"
		exit
	fi

	wp db drop --yes --path=$projectDirectory

	rm -rf $projectDirectory

	echo "$projectname removed completely"

	exit
fi

echo "================================================================="
echo "WordPress Installer!!"
echo "================================================================="

if [ -z "$1" ]; then
	# accept user input for the databse name
	echo "Project Name(no space): "
	read -e projectname
else
	projectname=$1
fi

mkdir -p "/home/vagrant/www/$projectname"
cd "/home/vagrant/www/$projectname"

# download the WordPress core files
wp core download

# create the wp-config file with our standard setup
wp core config --dbname=$projectname --dbuser=root --dbpass=ediamin --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'SCRIPT_DEBUG', true );
PHP

# create database, and install WordPress
wp db create
wp core install --url="http://localhost/$projectname" --title="WordPress Localhost Site" --admin_user="admin" --admin_password="ediamin" --admin_email="to.ediamin@gmail.com"

# discourage search engines
wp option update blog_public 0

# this is required for the .htaccess
touch wp-cli.local.yml
echo "apache_modules:
  -mod_rewrite
" > wp-cli.local.yml

# set pretty urls
wp rewrite structure '/%postname%/' --hard
wp rewrite flush --hard

rm wp-cli.local.yml

# delete akismet and hello dolly
wp plugin delete akismet
wp plugin delete hello

# install starter theme
if [ ! -z "$2" ]; then
	wp theme install ~/epsilon.zip --activate
fi

echo "================================================================="
echo "Installation is complete. open browse http://localhost/$projectname/wp-admin/"
echo "Admin User: admin"
echo "Admin Pass: ediamin"
echo "================================================================="
