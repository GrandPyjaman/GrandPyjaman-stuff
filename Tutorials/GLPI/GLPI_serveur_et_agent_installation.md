# GLPI c'est quoi ?
GLPI (Gestionnaire Libre de Parc Informatique) est un logiciel open source de gestion de services informatiques (ITSM) qui permet de gérer efficacement un parc informatique et de suivre les demandes d'assistance technique. Il permet plusieurs choses comme l'inventaire des équipements (que nous verrons ici aussi), la gestion des tickets d'incidents, des projets, des contrats et des licences, ainsi qu'une base de connaissances. GLPI est très utilisé en entreprises pour centraliser la gestion des actifs et le support technique.

Il s'installe sur un serveur (ici une pile LAMP) et est accessible via son interface web.

Cette procédure ce fait sur une VM Debian 12.5, pensez à adapter les commandes en fonction de la distribution que vous utilisez. Utilisez les droits sudo lorsque cela est nécéssaire.

# Installation du serveur sur un LAMP
## Qu'est-ce qu'un LAMP ?

Une pile LAMP est un ensemble de logiciels open source utilisés pour héberger des applications web. **LAMP** est l'acronyme de :

- **L**inux : Le système d'exploitation (OS) sur lequel l'ensemble repose.
- **A**pache : Le serveur web qui gère et sert les pages web.
- **M**ySQL (ou MariaDB) : Le système de gestion de base de données utilisé pour stocker les informations de l'application.
- **P**HP : Le langage de programmation côté serveur utilisé pour générer des pages web dynamiques.

Ensemble, ces composants permettent d'héberger et d'exécuter des applications web comme GLPI, offrant ainsi un environnement stable et performant pour la gestion des services informatiques.

Commencez par acceder à votre machine Debian et faites `apt update && sudo apt upgrade -y` pour s'assurer que la machine soit à jour.

Pour installer le service GLPI, nous allons donc devoir installer quelques dépendances :
- Apache2
- PHP
- MariaDB pour mysql

## Installation des dépendances
### Apache2
```bash
apt install apache2 -y
```
### PHP
Importation des certificats
```bash
apt install ca-certificates apt-transport-https software-properties-common wget curl lsb-release -y
```
Importation de la clé et du référentiel GPG
```bash
curl -sSL https://packages.sury.org/php/README.txt | bash -x
```
Installation de PHP
```bash
apt install php -y
```
Les modules PHP suivant sont aussi nécessaire au fonctionnement de glpi. Vous pouvez voir la liste des modules ici : https://glpi-install.readthedocs.io/en/latest/prerequisites.html#mandatory-extensions
```bash
apt install php-mysqli php-dom php-curl php-gd php-intl -y
```
Certains modules auront déjà été installés avec PHP directement, vous pouvez voir la liste des modules installés avec : `php -m`

Vous pouvez aussi installer d'autres modules optionnels en fonction de votre besoin comme le LDAP

redémarrez ensuite le serveur apache
```bash
systemctl restart apache2
```
### MariaDB
```bash
apt install mariadb-server -y
```
Nous allons ensuite sécuriser la base de données avec
```bash
mysql_secure_installation
```
Vous pouvez suivre les conseils lors de l'installation, par exemple :
```bash
You already have your root account protected, so you can safely answer 'n'.
Switch to unix_socket authentication [Y/n]
```
Vous pouvez mettre "n" si vous avez déjà un accès root protégé

Par sécurité, désactivez l'accès root à distance ainsi que l'utilisateur anonyme et la base de donnée test.
Acceptez le rechargement des privilèges.

---

Pensez à refaire update et upgrade à cet instant pour s'assurer de la mise à jour des dépendances et prévenir des problèmes de compatibilité et d'interaction.


Le server LAMP est prêt, pensez à faire un snapshot ou un clone si vous êtes sur une VM, c'est toujours utile !
# Installation du serveur GLPI
## Création et paramétrage de la base de donnée
Commencez par créer la base de donnée qui sera utilisée par GLPI. Sur votre shell du serveur :
```bash
mysql -u root -p
```
Le mot de passe demandé sera celui que vous avez entrés lors de la sécurisation.

Créez ensuite la base de donnée
```sql
create database glpi_db;
```
Ensuite créez un utilisateur et augmentez les droits de l'utilisateur
```sql
create user 'glpi_user'@'localhost' identified by 'glpi_user_password';
grant all privileges on glpi_db.* to 'glpi_user'@'localhost' with grant option;
flush privileges;
```
Cette dernière ligne vas mettre à jour les modifications apportées
Enfin, quittez mysql avec `exit;`

## Installation du serveur GLPI
### Téléchargement et décompression de l'archive GLPI
L'archive est disponible sur le github de glpi-project
```bash
wget https://github.com/glpi-project/glpi/releases/download/10.0.16/glpi-10.0.16.tgz
```
Décompressez l'archive
```bash
tar xvf glpi-10.0.16.tgz
```
(vous remarquerez alors le dossier « glpi » là où vous l'avez décompressé)

Déplacez le dossier glpi dans "/var/www/html/glpi" dans l'arborescence du serveur web apache2
```bash
mv glpi /var/www/html/glpi
```
### Instalation de GLPI
Commencez par donner à l'administrateur d'apache la propriété sur le dossier glpi
```bash
chown -R www-data:www-data /var/www/html/glpi/
chmod -R 755 /var/www/html/glpi/
```
Et redémarrez le serveur apache2
```bash
systemctl restart apache2
```
### Fin de l'installation et interface web de GLPI
Pour accéder à l'interface web, entrez dans votre navigateur http://ip-du-serveur/glpi
Choisissez la langue et cliquez sur "ok"
![Choix de la langue](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Pictures/1glpi_setup_langue.png)
Continuez après la licence et sélectionnez "installer"
![Installation](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Pictures/1glpi_setup_installation.png)
Dans l'écran suivant, vérifiez bien que tout les éléments requis sont installés et cliquez sur "continuer" si c'est le cas. En cas de problèmes, vous pouvez installer les dépendances sur le serveur et cliquer sur "réesayer"
![Activation de l'inventaire](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Pictures/1glpi_setup_test.png)
Lors de la configuration de la connexion à la base de donnée, entrez les coordonnées du serveur SQL, de l'utilisateur SQL et le mot de passe qui lui est associé (ici localhost, glpi_user et glpi_user_password)
![Configuration BD](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Pictures/1glpi_setup_configuration_bd.png)
Dans l'écran d'après, choisissez la base de données que nous avons construit plus tôt (glpi_DB) et continuez
![selection bd](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Pictures/1glpi_setup_connexion_bd.png)
Après l'initialisation, vous devrez recevoir un message "OK - La base a bien été initialisée", continuez jusqu'à la fin de l'installation et sélectionnez "Utilisez GLPI"
![initialisation](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Pictures/1glpi_setup_initialisation_db.png)
![valide](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Pictures/1glpi_setup_connexion_valid%C3%A9e.png)
Vous verrez ensuite les identifiants par défauts des comptes de bases
![comptes](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Pictures/1glpi_setup_comptes.png)
Enfin, connectez vous au compte pertinent pour vous et vous serez sur l'interface de GLPI (ici avec le compte administrateur)
![interface](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Pictures/glpi_interface.png)

Une fois sur l'interface web, si vous souhaitez utiliser l'inventorisation, pensez bien à l'activer :
- "Administration" sur le bandeau de gauche
- "Inventaire"
- Cochez "Activer l'inventaire"
- Tout en bas de la page, cliquez bien sur "sauvegarder"
![Activation de l'inventaire](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Pictures/Activation_inventaire_glpi.png)
# Installation de l'agent GLPI
L'agent GLPI vas permettre d'envoyer les informations du client sur lequel il est installé vers le serveur

Sa documentation est ici : https://glpi-agent.readthedocs.io/en/latest/index.html

## Sur Windows
Télécharger la dernière version de l'agent à https://github.com/glpi-project/glpi-agent/releases
Le fichier d'installation Windows est un .msi
### En ersion graphique
- Exécutez le fichier d'installation, suivez les étapes et acceptez la licence d'utilisation
- Choisissez où installer l'agent
- Choisissez le type d'installation (dans le cadre de cet exercice, nous nous contenterons d'utilisez l'installation typique, n'hésitez pas à choisie "complete" ou "custom" selon votre besoin)
- Choisissez votre cible (distante ou locale. Ici le serveur GLPI est distant et l'hôte Windows est un client) et renseignez l'adresse en rajoutant bien "/glpi" en suffixe

![Cibles de l'agent Windows GLPI](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Pictures/glpi_agent_targets.png)
- Si vous souhaitez renseigner des certificats, proxies, mode d'éxecution ou d'autres options, décochez "quick installation". (Ce tutoriel ce voulant simple, je ne couvrirait pas cette partie ici)
- Puis cliquez sur "Install"

Vous pourrez toujours changer la configuration de l'agent en relançant le fichier .msi et en sélectionnant "change"
![changement de la configuration de l'agent](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Pictures/glpi_agent_change.png)

Accédez à l'interface web de l'agent en tapant `127.0.0.1:62354` dans un navigateur web. Vous devriez tomber sur cette page : ![Interface web de glpi-agent](https://github.com/GrandPyjaman/GrandPyjaman-stuff/blob/main/Tutorials/GLPI/Pictures/gpli-agent_web_interface.png)
Le bouton "Force an Inventory" forcera la remonter des informations de l'agent vers le server
Si le serveur est configuré correctement, le bouton "server0" vous redirigera vers l'interface web du serveur GLPI

### En ligne de commande
Pour lancer l'agent en ligne de commande, il faut bien utiliser l'invite de commande windows et non pas Powershell.

La commande utilise msiexec avec quelques arguments :
```command
msiexec /i "chemin vers le .msi" /quiet EXECMODE=1 RUNNOW=1 ADD_FIREWALL_EXCEPTION=1 SERVER="http://adresse_de_votre_server/glpi"
```
- **msiexec** est l'utilitaire  d'installation des fichiers .msi
- **/i** permet de dire qu'il s'agit d'une installation, suivie du chemin vers le fichier
- **/quiet** lance l'installation en mode silencieux
- **EXECMODE=1** permet de faire fonctionner l'agent en tant que service
- **RUNNOW=1** éxecute l'agent immédiatement après l'installation
- **ADD_FIREWALL_EXCEPTION=1** Ajoute une exception au pare feu pour l'agent GLPI
- **SERVER="http://adresse_de_votre_server/glpi"** précise à l'agent d'adresse de votre serveur pour qu'il fasse remonter les informations

Toutes les précisions sont ici : https://glpi-agent.readthedocs.io/en/latest/installation/windows-command-line.html#command-line-parameters

## Sur Linux
Sur le client linux, téléchargez la dernière version de l'agent (ici 1.7)
```bash
wget https://github.com/glpi-project/glpi-agent/releases/download/1.7/glpi-agent-1.7-linux-installer.pl
```
Puis lancez l'installation avec perl
```bash
perl glpi-agent-1.7-linux-installer.pl
```
Lors de l'installation, le programme vous demande de renseigner l'adresse de votre server glpi (rajoutez bien "/glpi" à la fin de l'adresse)

Vous n'avez pas à fournir de chemin vers l'inventaire local ou le tag s'il n'y en a pas.

Puis redémarrez le service de l'agent
```bash
systemctl restart glpi-agent.service
```
Au besoin, vous pouvez éditer l'adresse dans le fichier de configuration se trouvant à `/etc/glpi-agent/conf.d/00-install.cfg`

Pour forcer l'inventorisation vous pouvez lancer l'agent en tant que commande :
```bash
glpi-agent
```
# Gestion de l'inventaire
()
