A venir : complétion, plus d'exemples et des schémas

Il y à quelques mois maintenant, j'ai hérité de l'hébergement OVH que mon grand-père utilisait pour maintenir un site de promotion de son chalet à la montagne.
Le site sentant bon l'amateurisme en webdesign des années 2000, il est devenu complètement obsolète par manque d'entretien et l'arrivée d'airBNB.
Désormais sa seule valeur est sentimentale et c'est dans une optique de conservation et d'apprentissage que j'ai fait un conteneur docker sur la base d'une image nginx qui a le site pour contenu.

La suite de cette page servira en même temps de petit tutoriel pour utiliser docker et de référence pour que je puisse y revenir au besoin.

Ecoutez, je fais ce que je peux.
# 1. Prérequis
Pour créer ce conteneur nous allons avoir besoin du contenu du site, d'une machine pouvant faire tourner docker et d'une image nginx.
## 1.1 Récupération du contenu du site
La méthode d'hébergement du site est à l'image son âge : papy utilisait un CMS en local puis téléversait son site dans le FTP du serveur OVH. Ce n'est donc qu'une question de récupérer le répertoire **www** et de le renseigner comme volume du conteneur.
## 1.2 Machine et installation
Je l'ai initialement fait chez moi sur une raspberry qui héberge mes services mais pour plus de facilité, je vais partager une procédure refaite sur Debian.
### 1.2.1 Installation de Docker
Il suffit de suivre la procédure d'installation du site officiel :
https://docs.docker.com/engine/install/debian/

### 1.2.2 Test du premier conteneur
à la fin de l'installation, l'installation, nous sommes amenés à tester ``sudo docker run hello-world``
Cette commande vas télécharger l'image "hello-world" et la lancer sous forme de conteneur et elle est parfaite pour comprendre le fonctionnement de la récupération et du lancement d'images.

````bash
user@machine$ sudo docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
17eec7bbc9d7: Pull complete
Digest: sha256:a0dfb02aac212703bfcb339d77d47ec32c8706ff250850ecc0e19c8737b18567
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub. (amd64)
 3. The Docker daemon created a new container from that image which runs the executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

````
Cette commande vas :
- Vérifier le fonctionnement du client Docker et du deamon
- Chercher l'image en local
- Télécharger l'image depuis la bibliothèque docker
- Créer un conteneur sur la base de l'image qu'il viens de télécharger et l'éxecuer
- Afficher l'output du client sur le terminal pour que nous puissions le lire

La commande proposée ensuite ``docker run -it ubuntu bash``, téléchargera et exécutera un conteneur ubuntu, nous permettant de travailler dans le conteneur.

### 1.2.3 Mettre l'utilisateur dans le groupe docker
Cela nous permettra d'utiliser les commandes docker sans être super user ou taper sudo avant chaque commande.
````bash
user@machine$ sudo usermod -aG docker user
````

# 2. Le conteneur du site
## 2.1 Récupération et test de l'image nginx
### 2.1.1 Recherche d'une image
Pour trouver l'image qui nous intéresse, la méthode la plus facile est de se rendre sur le sir hub de docker et de l'y rechercher : https://hub.docker.com/_/nginx
Il est aussi possible de chercher un image avec la commande ``docker search`` et la la télécharger en local sans passer par la commande run
````bash
user@machine$ docker search nginx

NAME                                     DESCRIPTION                                     STARS     OFFICIAL
nginx                                    Official build of Nginx.                        20967     [OK]
nginx/nginx-ingress                      NGINX and  NGINX Plus Ingress Controllers fo…   110
nginx/nginx-prometheus-exporter          NGINX Prometheus Exporter for NGINX and NGIN…   50
nginx/unit                               This repository is retired, use the Docker o…   66
nginx/nginx-ingress-operator             NGINX Ingress Operator for NGINX and NGINX P…   2
nginx/docker-extension                                                                   0
nginx/nginx-quic-qns                     NGINX QUIC interop                              1
````
De là, nous pouvons voir le noms des images, leur descriptions, leur nombre de recommandations et si l'image est officielle ou non.

### 2.1.2 Téléchargement de l'image
Une fois l'image trouvée, nous pouvons la télécharger avec la commande ``docker pull nginx``

## 2.2 Lancement du conteneur
Le conteneur peux être lancé avec la commande suivante, que nous allons décortiquer :
```bash
user@machine$ docker run -itd -p 8080:80 --name chalet -v ./www:/usr/share/nginx/html --restart always nginx
```

``-itd`` est en fait la contraction de 3 arguments :
- ``i`` pour Interactive, pour permet d'interagir avec le conteneur en lui envoyant des commandes grâce au **STDIN**, souvent combiné avec l'argument d'après
- ``t`` pour avoir accès à un terminal (TTY) en cas d'interaction avec le conteneur. Particulièrement efficace pour les conteneur ayant des outils comme des distribution linux
- ``d`` pour Detach, afin que l'output ne soit pas affiché sur votre terminal et que vous puissiez encore y avoir accès
``-p 8000:80`` vas exposer sur le port **8080** de l'hôte le port **80**
``--name chalet`` vas nommer le conteneur **chalet**
``-v ./www:/usr/share/nginx/html`` va monter le répertoire ./www dans le conteneur à /usr/share/nginx/html afin que le service nginx puisse lire son contenu
``--restart always`` correspond à la politique de redémarrage quand le conteneur s'arrête. Ici, le conteneur sera toujours redémarré. Sans cet argument, nous aurions pu utiliser ``--rm`` pour supprimer automatiquement le conteneur lorsque son exécution prends fin
Enfin, ``nginx`` correspond à l'image sur laquelle vas se baser le conteneur

Pour plus de commandes, vous pouvez consulter la documentation officielle à https://docs.docker.com/reference/cli/docker/container/run/

Lancer la commande vas imprimer sur le terminal l'ID du conteneur et nous pouvons vérifier son exécution en allant sur l'ip de l'hôte au port 8080 ou avec la commande
```bash
CONTAINER ID IMAGE COMMAND                  CREATED            STATUS            PORTS                                   NAMES
9050f2bbd180 nginx "/docker-entrypoint.…"   About a minute ago Up About a minute 0.0.0.0:8080->80/tcp, [::]:8080->80/tcp chalet
```

## 2.3 Interagir avec le conteneur
Grâce aux arguments ``-it``, nous pouvons directement interagir avec le conteneur et, par exemple, utiliser une shell avec ``sh``
```bash
user@machine$ docker exec -it chalet sh
#
# ls
bin  boot  dev  docker-entrypoint.d  docker-entrypoint.sh  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

Le conteneur est maintenant lancé et je peux accèder au site depuis ma rasperry à chaque fois qu'un élan de nostalgie me prends !

_______________
# 2. Networking avec Docker
7 type de réseaux différents
Lister les réseaux docker actuels :
```
docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
d3d997cc10f8   bridge    bridge    local
38f884ef31c0   host      host      local
218cfb6d295a   none      null      local
danetg@DebianGeneral:~$
```
DRIVER = type de réseau

Déployer un conteneur avec `--network host` pour déployer directement sur l'hôte, le conteneur va partager l'adresse et les ports de l'hôte, comme une application

## 2.1 Bridge
Par défaut, docker créé une **interface Ethernet** pour chaque conteneur et les connecte au bridge **docker0**
Un exemple après avoir déployé 3 conteneurs :
```
user@machine:~$ sudo bridge link
5: veth4b59cb6@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master docker0 state forwarding priority 32 cost 2
7: veth3a48798@if6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master docker0 state forwarding priority 32 cost 2
9: veth040bfe4@if8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master docker0 state forwarding priority 32 cost 2
```

`docker inspect bridge` pur voir la configuration du bridge actuel avec le réseau, la passerelle et les adresses des conteneurs dans le réseau bridge
**Ouvrir un port :**
`user@machine:~$ docker run -itd --rm -p 80:80 --name stormbreaker-nginx nginx`
l'argument -p 80:80 expose le port 80 du conteneur au port 80 de l'hôte
## 2.2 User-Defined Bridge
Pour nommer votre réseau nommé asgard : `docker network create asgard`
Le réseau sera visible avec la commande : `docker network ls`
Pour déployer un conteneur à l'intérieur de ce réseau : `docker run -itd --rm --network asgard --name loki busybox`
Ce réseau peut être inspecté avec `docker inspect asgard`

Ce réseau ne peux actuellement pas communiquer avec l'autre bridge

**Les réseaux ont leur propre DNS**, par exemple, un conteneur avec --name *loki* et un autre avec --name *odin* pourront communiquer ensemble sur la base de leurs noms respectifs plutôt que leurs adresses ip

## 2.3 MACVLAN
### 2.3.1 mode bridge
MACVLAN consiste en une simulation de réseau physique, comme pour une VM qui est en mode bridge, tout les conteneurs du MACVLAN auront leur propre adresse MAC mais partageront le même port réseau de l'hôte
Cela peux empêcher les communication réseaux si le mode promiscuité n'est pas activé
Pas de gestion DHCP non plus

Pour activer le mode promiscuité sur une interface de l'hôte (ici enp0s3)
`sudo ip link set enp0s3 promisc on`

Pour créer un MACVLAN il faut préciser le type de driver avec **-d**, le sous réseau avec **--subnet**, la passerelle et une options **-o** du parent qui correspond à l'interface de l'hôte du conteneur
`docker network create -d macvlan --subnet 192.168.1.0/24 --gateway 192.168.1.1 -o parent=enp0s3 newasgard`
Il est aussi possible d'utiliser **--ip-range** pour donner un liste d'IP disponible que docker pourra attribuer aux conteneur

Pour déployer un conteneur dans ce réseau, il faut le préciser et lui donner une adresse IP
`docker run -itd --rm --network newasgard --ip 192.168.1.29 --name thor busybox`

### 2.3.2 mode 802.q
Peux connecter les conteneur au réseau
Peux spécifier une sous-interface 

Permet la création de VLAN IP
Exemple avec un VLAN .20
`docker network create -d macvlan --subnet 192.168.20.0/24 --gateway 192.168.20.1 -o parent=enp0s3.20 macvlan20`
et
`docker network create -d macvlan --subnet 192.168.30.0/24 --gateway 192.168.30.1 -o parent=enp0s3.30 macvlan30`
pour créer 2 VLANs

(Voir trunking)

## 2.4 IPVLAN (mode Layer 2)
Partage d'adresse MAC avec l'hôte mais IP distinctes

Créer le réseau :
`docker network create -d ipvlan --subnet 192.168.1.0/24 --gateway 192.168.1.1 -o parent=enp0s3 newasgard`

## 2.5 IPVLAN (mode Layer 3)
Les conteneur se connectent à l'hôte comme s'il était un routeur, plus de broadcast
Lors de la création du réseau, il ne faut pas préciser de passerelle mais préciser le type d'IPVLAN qu'on souhaite mettre en place
`docker network create -d ipvlan --subnet 192.168.94.0/24 -o parent=enp0s3 -o ipvlan_mode=l3 --subnet 192.168.95.0/24 newasgard`
Comme 2 sous réseaux sont spécifiés, il suffit de préciser l'IP d'un conteneur lors de son déploiement pour l'y assigner

Les conteneurs pourront communiquer entre les sous réseaux mais pas avec l'extérieur sans routage !

## 2.6 Overlay network
Dans le cadre de plusieurs hôtes

# 3. Docker Compose
docker-compose (ou docker compose) est une reformulation de la commande `docker run` pour des besoins plus larges

Il faut d'abord créer le fichier de configuration par défaut : **docker-compose.yaml**
ATTENTION : l'indentation est très importante en yml
Exemple de fichier pour déployer le même serveur web nginx que nous avons vus au tout début
```yaml
name: chalet
services:
    nginx: # Le nom du service
        stdin_open: true # Permet l'input de commandes
        tty: true # Permet l'accès au terminal
        ports:
           - 8080:80 # L'ouverture de ports du conteneur sur l'hôte
        container_name: chalet # Le nom du conteneur
        volumes:
            - ./www:/usr/share/nginx/html
        image: nginx # L'image depuis laquelle sera créée le conteneur
        restart: always # Le conteneur se relance après redémarrage de la machine
```

Sans préciser le nom du conteneur, il aura par défaut le nom du répertoire contenant le .yaml suivi du nom du serveur et d'un numéro. Par exemple, si le fichier docker compose est dans un répertoire appelé "internet" et il n'y a pas encore de conteneur, il s'appellera donc "internet_websites_1"

Au lancement de la commande `user@machine:~/internet$ docker-compose up -d`

```bash
Creating network "chalet" with the default driver
Creating chalet ... done
```

On peux ne voir que les conteneurs lancés avec docker-compose avec la commande `docker-compose ps`

Pour créer un réseau avec `docker-compose` :
```bash
networks:
  network1: # Nom du réseau
    ipam: # IP Address Management
      driver: default # Driver utilisé (default=bridge)
      config:
        - subnet: "192.168.2.0/26" # Sous-réseau
```
Le réseau sera nommé selon la même nomenclature que les conteneurs
Pour mettre un conteneur dans ce réseau avec `docker-compose` :
```yaml
  website2:
    image: nginx
    ports:
      - "8082:80"
    restart: always
    networks:
      network1:
        ipv4_address: 192.168.2.3 # Addresse attribuée au conteneur
```

Une fois le **docker-compose.yaml** terminé, on peux vérifier sa validité avec la commande `docker-compose -f docker-compose.yaml config`
Enfin, on peux l'exécuter avec la commande `docker-compose up -d` le **-d** va servir à lancer l'exécution en arrière plan

Exemple de déploiement d'un service wordpress avec un base de données mysql
```yaml
services:
  wordpress:
    image: wordpress
    ports:
      - "8089:80"
    depends_on:
      - mysql
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: root
      WORDPRESS_DB_PASSWORD: "password"
      WORDPRESS_DB_NAME: wordpress_db
    restart: always
    networks:
        wordpress:
          ipv4_address: "192.168.2.4"

  mysql:
    image: "mysql:5.7"
    environment:
      MYSQL_DATABASE: wordpress_db
      MYSQL_ROOT_PASSWORD: "password"
    volumes:
      - ./mysql:/var/lib/mysql
    restart: always
    networks:
      wordpress:
        ipv4_address: "192.168.2.3"

networks:
  wordpress:
    ipam:
      driver: default
      config:
        - subnet: "192.168.2.0/28"

```
