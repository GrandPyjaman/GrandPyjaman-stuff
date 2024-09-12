# Installation du serveur sur un LAMP
Commencez par `apt update && sudo apt upgrade -y` pour s'assurer que la machine soit à jour.
Pour installer le service GLPI, nous allons d'abord devoir installer quelques dépendances :
- Apache2
- PHP
- MariaDB pour mysql

## Installation des dépendances
**Apache2**

`apt install apache2 `

---

**PHP 8.2** (La version maximum compatible avec GLPI version 10.0.X)

`apt install ca-certificates apt-transport-https software-properties-common wget curl lsb-release -y`

Importation de la clé et du référentiel GPG

`curl -sSL https://packages.sury.org/php/README.txt | bash -x`

PHP 8.2 en module Apache

`apt install php8.2 libapache2-mod-php8.2`

Les modules PHP suivant sont aussi nécessaire au fonctionnement de glpi

`apt install php8.2-curl php8.2-gd php8.2-mbstring php8.2-zip php8.2-xml php8.2-ldap php8.2-intl php8.2-mysql php8.2-dom php8.2-simplexml php-json php8.2-phpdbg php8.2-cgi`

redémarrez ensuite le serveur apache

`sudo systemctl restart apache2`

---
**MariaDB**

`apt install mariadb-server`

Nous allons ensuite sécuriser la base de données avec

`mysql_secure_installation`

Vous pouvez suivre les conseils lors de l'installation, par exemple 

`You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n]`

Vous pouvez mettre "n" si vous avez déjà un accès root protégé

Par sécurité, désactivez l'accès root à distance ainsi que l'utilisateur anonyme et la base de donnée test.
Acceptez le rechargement des privilèges.

---

Pensez à refaire update et upgrade à cet instant pour s'assurer de la mise à jour des dépendances et prévenir des problèmes de compatibilité et d'interaction.


Le server LAMP est prêt, pensez à faire un snapshot ou un clone si vous êtes sur une VM, c'est toujours utile !
# Installation du serveur GLPI
## Création et paramétrage de la base de donnée
Commencez par créer la base de donnée qui sera utilisée par GLPI. Sur votre shell du serveur :

`mysql -u root -p`

Le mot de passe demandé sera celui que vous avez entrés lors de la sécurisation.

Créez ensuite la base de donnée

`create database glpi_DB;`

Ensuite créez un utilisateur et augmentez les droits de l'utilisateur

`create user 'glpi_user'@'localhost' identified by 'glpi_user_password';`

`grant all privileges on glpi_db.* to 'glpi_user'@'localhost' with grant option;`

`flush privileges;`

Cette dernière ligne vas mettre à jour les modifications apportées
Enfin, quittez mysql avec `exit;`

## Installation du serveur GLPI
### Téléchargement et décompression de l'archive GLPI
L'archive est disponible sur le github de glpi-project

`wget https://github.com/glpi-project/glpi/releases/download/10.0.9/glpi-10.0.9.tgz`

Décompressez l'archive

`tar xvf glpi-10.0.9.tgz`

(vous remarquerez alors le dossier « glpi » là où vous l'avez décompressé)

Déplacez le dossier glpi dans "/var/www/html/glpi" dans l'arborescence du serveur web apache2

`mv glpi /var/www/html/glpi`
### Instalation de GLPI
Commencez par donner à l'administrateur d'apache la propriété sur le dossier glpi

`chown -R www-data:www-data /var/www/html/glpi/`

`chmod -R 755 /var/www/html/glpi/`

Et redémarrez le serveur apache2

`systemctl restart apache2`

Pour accéder à l'interface web, entrez dans votre navigateur http://ip-du-serveur/glpi
Choisissez la langue et cliquez sur "ok"
Continuez après la licence et sélectionnez "installer"
Dans l'écran suivant, vérifiez bien que tout les éléments requis sont installés et cliquez sur "continuer" si c'est le cas
Lors de la configuration de la connexion à la base de donnée, entrez les coordonnées du serveur SQL, de l'utilisateur SQL et le mot de passe qui lui est associé (ici localhost, glpi_user et glpi_user_password)

Dans l'écran d'après, choisissez la base de données que nous avons construit plus tôt (glpi_DB) et continuez

Vous devrez recevoir un message "OK - La base a bien été initialisée", continuez jusqu'à la fin de l'installation et sélectionnez "Utilisez GLPI"

Enfin, connectez vous au compte pertinent pour vous et vous serez sur l'interface de GLPI

Une fois sur l'interface web, si vous souhaitez utiliser l'inventorisation, pensez bien à l'activer :
- "Administration" sur le bandeau de gauche
- "Inventaire"
- Et cochez "Activer l'inventaire"
![Activation de l'inventaire](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Activation_inventaire_glpi.png)
# Installation de l'agent
## Sur Windows
Télécharger la dernière version de l'agent à https://github.com/glpi-project/glpi-agent/releases
Le fichier d'installation Windows est un .msi
Exécutez le 

Accédez à l'interface web de l'agent en tapant `127.0.0.1:62354` dans votre navigateur. Vous devriez tomber sur cette page : ![Interface web de glpi-agent](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/gpli-agent_web_interface.png)
Le bouton "Force an Inventory" forcera la remonter des informations de l'agent vers le server
Si le serveur est configuré correctement, le bouton "server0" vous redirigera vers l'interface web du serveur GLPI

## Sur Linux
Sur le client linux, téléchargez la dernière version de l'agent (ici 1.7)

`wget https://github.com/glpi-project/glpi-agent/releases/download/1.7/glpi-agent-1.7-linux-installer.pl`

Puis lancez l'installation avec perl

`perl glpi-agent-1.7-linux-installer.pl`

Lors de l'installation, le programme vous demande de renseigner l'adresse de votre server glpi (rajoutez bien "/glpi" à la fin de l'adresse)
Puis redémarrez le service de l'agent

`systemctl restart glpi-agent.service`

Au besoin, vous pouvez éditer l'adresse dans le fichier de configuration se trouvant à `/etc/glpi-agent/conf.d/00-install.cfg`

Pour forcer l'inventorisation vous pouvez lancer l'agent en tant que commande `glpi-agent`
