<<<<<<< HEAD
# 🐳 MySQL Docker Infrastructure

Infrastructure Docker simple permettant de lancer une instance **MySQL 8.0** persistante, configurable avec des variables d'environnement et utilisable notamment comme base de données pour **WordPress**.

## 📋 Sommaire

- [Présentation](#-présentation)
- [Architecture du projet](#-architecture-du-projet)
- [Prérequis](#-prérequis)
- [Configuration](#-configuration)
- [Installation et démarrage](#-installation-et-démarrage)
- [Environnement de production](#-environnement-de-production)
- [Initialisation de la base](#-initialisation-de-la-base)
- [Configuration MySQL](#-configuration-mysql)
- [Volumes et persistance](#-volumes-et-persistance)
- [Commandes utiles](#-commandes-utiles)
- [Sécurité](#-sécurité)
- [Dépannage](#-dépannage)

## 🚀 Présentation

Ce projet utilise **Docker Compose** pour construire et exécuter un conteneur MySQL.

La configuration actuelle :

- utilise **MySQL 8.0** ;
- construit une image MySQL personnalisée ;
- expose MySQL sur le port `3306` ;
- charge les identifiants depuis un fichier `.env` ;
- conserve les données dans un volume Docker nommé `mysql_data` ;
- applique une configuration MySQL personnalisée via `my.cnf` ;
- fournit un script de déploiement ;
- fournit un script permettant de créer la base `wordpress` si nécessaire.

## 📁 Architecture du projet

La configuration Docker actuelle suppose une structure similaire à celle-ci :

```text
.
├── .env
├── .gitignore
├── docker-compose.yml
├── docker-compose.prod.yml
├── deploy.sh
├── init-db.sh
├── docker/
│   └── mysql/
│       └── Dockerfile
└── config/
    └── mysql/
        └── my.cnf
```

> **Important :** `docker-compose.yml` référence `docker/mysql/Dockerfile`, et le Dockerfile copie `config/mysql/my.cnf`. Les fichiers doivent donc être placés dans ces dossiers, ou les chemins doivent être adaptés.

## ✅ Prérequis

Avant de lancer le projet, installer :

- Docker ;
- Docker Compose (`docker compose`).
=======
# ICT-169_JCS_DPD_LSL

# WordPress Docker

## Installation

### Prérequis

Avant de commencer, il faut avoir installé :

* Docker Desktop
* Git
* Docker Compose

### Récupérer le projet

Cloner le projet :

```bash
git clone <URL_DU_REPOSITORY>
cd Wordpress
```

Se placer sur la branche WordPress :

```bash
git checkout feature/wordpress
```

### Configurer les variables

Créer un fichier `.env` à la racine du projet :

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=wordpress
MYSQL_ROOT_PASSWORD=root
```

 Le fichier `.env` contient des informations sensibles. Il ne doit pas être envoyé sur GitHub.

Le fichier `.gitignore` contient :

```text
.env
```

Cela permet d'empêcher Git d'envoyer le fichier `.env` sur le dépôt.

---

## Construire l'image WordPress

Construire l'image personnalisée :

```bash
docker compose build wordpress
```

Cette commande utilise le fichier :

```text
docker/wordpress/Dockerfile
```

Le Dockerfile utilise l'image officielle WordPress et copie le contenu personnalisé de `wp-content`.

---

## Démarrer WordPress

Démarrer les services :

```bash
docker compose up -d
```

Vérifier l'état des conteneurs :

```bash
docker compose ps
```

Le service WordPress doit avoir le statut :

```text
Up
```

WordPress est normalement accessible avec :

```text
http://localhost:8080
```

 WordPress nécessite que le service MySQL soit également disponible.

---

## Tests à effectuer

### Test 1 — Vérifier la configuration Docker Compose

```bash
docker compose config
```

Cette commande permet de vérifier que le fichier `docker-compose.yml` ne contient pas d'erreur de syntaxe.

### Test 2 — Vérifier l'image WordPress

```bash
docker images
```

L'image personnalisée doit apparaître, par exemple :

```text
wordpress-wordpress
```

### Test 3 — Vérifier le thème personnalisé

```bash
docker run --rm wordpress-wordpress:latest ls /var/www/html/wp-content/themes
```

Le résultat doit contenir :

```text
mon-theme
```

### Test 4 — Vérifier le fichier du thème

```bash
docker run --rm wordpress-wordpress:latest cat /var/www/html/wp-content/themes/mon-theme/style.css
```

Le fichier doit contenir les informations du thème :

```text
Theme Name: Mon Theme WordPress
Author: Lucas
Version: 1.0
```

### Test 5 — Tester WordPress

Ouvrir :

```text
http://localhost:8080
```

Puis vérifier que :

* WordPress est accessible ;
* la connexion fonctionne ;
* le thème `Mon Theme WordPress` apparaît dans **Apparence → Thèmes** ;
* le thème peut être activé.

---

## Gestion des mots de passe et secrets

Les mots de passe de la base de données ne sont pas écrits directement dans le code WordPress.

Ils sont stockés dans le fichier :

```text
.env
```

Exemple :

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=wordpress
MYSQL_ROOT_PASSWORD=root
```

Le fichier `.env` est protégé par `.gitignore` :

```text
.env
```

Ainsi, il n'est pas envoyé sur GitHub.

### Vérifier que `.env` est ignoré

Utiliser :

```bash
git status
```

Le fichier `.env` ne doit pas apparaître dans les fichiers non suivis.

On peut également vérifier avec :

```bash
git check-ignore -v .env
```

Git doit indiquer que `.env` est ignoré par `.gitignore`.

 Dans un environnement de production, il est recommandé d'utiliser des secrets plus sécurisés et de ne pas utiliser de mots de passe simples comme `root`.

---

## Dockerfile WordPress

Le Dockerfile utilisé est :

```dockerfile
FROM wordpress:latest

COPY app/wordpress/wp-content/ /var/www/html/wp-content/

RUN chown -R www-data:www-data /var/www/html/wp-content
```

Il permet de :

1. partir de l'image officielle WordPress ;
2. copier le contenu personnalisé de WordPress ;
3. appliquer les permissions nécessaires.

---

## Structure de la partie WordPress

```text
app/
└── wordpress/
    └── wp-content/
        ├── themes/
        │   └── mon-theme/
        │       ├── style.css
        │       └── index.php
        └── plugins/

docker/
└── wordpress/
    └── Dockerfile

.env
.gitignore
docker-compose.yml
README.md
```

## Résultat attendu

À la fin des tests :

* Docker Compose fonctionne ;
* l'image WordPress est construite ;
* le thème personnalisé est présent dans l'image ;
* WordPress est accessible ;
* les informations sensibles restent dans `.env` ;
* `.env` n'est pas envoyé sur GitHub.
=======
# Infrastructure Nginx, Prometheus & Grafana

Ce projet met en place une petite infrastructure de conteneurs Docker composée de **Nginx**, **Prometheus** et **Grafana**.

L'objectif est de disposer d'un reverse proxy Nginx et d'une base de monitoring avec Prometheus et Grafana, tous reliés au même réseau Docker.

## Architecture

```text
Utilisateur
    |
    | HTTP :80
    v
  Nginx
    |
    | proxy_pass
    v
 Grafana :3000
    |
    v
Prometheus :9090
```

Dans la configuration actuelle, Nginx écoute sur le port `80` et transmet les requêtes vers Grafana sur le port `3000`.

Prometheus collecte actuellement ses propres métriques toutes les 15 secondes. Grafana utilise Prometheus comme source de données par défaut.

## Technologies

- Docker
- Docker Compose
- Nginx Alpine
- Prometheus
- Grafana

## Structure du projet

```text
Project-root/
├── app/
│   └── nginx/
│       └── default.conf
├── docker/
│   └── nginx/
│       └── Dockerfile
├── grafana/
│   ├── dashboards/
│   │   └── wordpress-dashboard.json
│   ├── datasources/
│   │   └── prometheus.yml
│   └── provisioning/
├── prometheus/
│   └── prometheus.yml
└── docker-compose.yml
```

> Le dossier `.git/` présent dans l'archive n'est pas détaillé ici : il contient les données internes de Git et ne fait pas partie de l'architecture applicative.

## Services Docker

### Nginx

Le service `nginx` utilise l'image `nginx:alpine`.

Il :

- écoute sur le port `80` de la machine ;
- monte `./app/nginx/default.conf` dans `/etc/nginx/conf.d/default.conf` ;
- appartient au réseau Docker `app-network`.

La configuration actuelle utilise Nginx comme reverse proxy vers :

```text
http://grafana:3000
```

Les en-têtes `Host`, `X-Real-IP`, `X-Forwarded-For` et `X-Forwarded-Proto` sont également transmis.

### Prometheus

Le service `prometheus` utilise l'image :

```text
prom/prometheus:latest
```

Le port `9090` est exposé sur la machine hôte.

Le fichier :

```text
./prometheus/prometheus.yml
```

est monté dans :

```text
/etc/prometheus/prometheus.yml
```

La configuration définit un intervalle de collecte de **15 secondes** et surveille actuellement Prometheus lui-même sur `localhost:9090`.

Une configuration Nginx est laissée en commentaire afin de pouvoir ajouter sa surveillance ultérieurement.

### Grafana

Le service `grafana` utilise l'image :

```text
grafana/grafana:latest
```

Il expose le port `3000` et dépend du service Prometheus.

Le dossier :

```text
./grafana/provisioning
```

est monté dans :

```text
/etc/grafana/provisioning
```

Le fichier `grafana/datasources/prometheus.yml` présent dans le projet définit Prometheus comme source de données Grafana avec l'adresse :

```text
http://prometheus:9090
```

## Réseau Docker

Les trois services utilisent le réseau :

```text
app-network
```

Il utilise le driver Docker `bridge`.

Cela permet aux conteneurs de communiquer entre eux en utilisant leurs noms de services, par exemple :

```text
grafana:3000
prometheus:9090
```

## Prérequis

Avant de démarrer le projet, installer :

- Docker
- Docker Compose
>>>>>>> origin/main

Vérification :

```bash
docker --version
docker compose version
```

<<<<<<< HEAD
## ⚙️ Configuration

Les variables MySQL sont chargées depuis le fichier `.env` :

```env
MYSQL_ROOT_PASSWORD=change_me
MYSQL_DATABASE=wordpress
MYSQL_USER=user
MYSQL_PASSWORD=change_me
```

### Variables disponibles

| Variable | Description |
| --- | --- |
| `MYSQL_ROOT_PASSWORD` | Mot de passe du compte administrateur `root` |
| `MYSQL_DATABASE` | Base créée automatiquement au premier démarrage |
| `MYSQL_USER` | Utilisateur MySQL applicatif |
| `MYSQL_PASSWORD` | Mot de passe de l'utilisateur applicatif |

## 🐳 Installation et démarrage

### 1. Cloner le dépôt

```bash
git clone <URL_DU_REPOSITORY>
cd <NOM_DU_REPOSITORY>
```

### 2. Créer le fichier `.env`

Pour des raisons de sécurité, il est recommandé de ne **pas versionner le vrai `.env`**.

Créer votre fichier local :

```bash
cp .env.example .env
```

Puis renseigner des mots de passe sécurisés.

### 3. Démarrer MySQL
=======
## Démarrage

Depuis la racine du projet :

```bash
docker compose up -d
```

Pour reconstruire si nécessaire :
>>>>>>> origin/main

```bash
docker compose up -d --build
```

<<<<<<< HEAD
Le script `deploy.sh` effectue la même opération :

```bash
chmod +x deploy.sh
./deploy.sh
```

### 4. Vérifier le conteneur
=======
Vérifier les conteneurs :
>>>>>>> origin/main

```bash
docker compose ps
```

<<<<<<< HEAD
ou :

```bash
docker ps
```

Le conteneur doit apparaître sous le nom :

```text
mysql
```

## 🌐 Environnement de production

Le fichier `docker-compose.prod.yml` surcharge actuellement la configuration du service MySQL afin de garantir :

```yaml
restart: always
```

Pour combiner la configuration principale avec celle de production :

```bash
docker compose   -f docker-compose.yml   -f docker-compose.prod.yml   up -d --build
```

## 🗄️ Initialisation de la base

Le script `init-db.sh` exécute une commande SQL dans le conteneur `mysql` :

```sql
CREATE DATABASE IF NOT EXISTS wordpress;
```

Il peut être lancé avec :

```bash
chmod +x init-db.sh
./init-db.sh
```

Cependant, la variable `MYSQL_DATABASE=wordpress` permet déjà à l'image officielle MySQL de créer cette base lors de la première initialisation du volume.

### Attention au mot de passe

Le script fourni contient actuellement un mot de passe directement dans la commande :

```bash
docker exec mysql mysql -u root -p... 
```

Il est préférable d'éviter tout mot de passe codé en dur et d'utiliser la configuration d'environnement ou une autre méthode de gestion des secrets.

## 🔧 Configuration MySQL

L'image personnalisée repose sur :

```dockerfile
FROM mysql:8.0
```

Le fichier `my.cnf` est copié dans :

```text
/etc/mysql/conf.d/my.cnf
```

La configuration fournie contient notamment :

```ini
[mysqld]

bind-address=0.0.0.0
max_connections=100
default_authentication_plugin=mysql_native_password
```

### Signification

- `bind-address=0.0.0.0` : MySQL écoute sur toutes les interfaces réseau du conteneur.
- `max_connections=100` : limite le serveur à 100 connexions simultanées.
- `default_authentication_plugin=mysql_native_password` : configure le mécanisme d'authentification par défaut prévu par ce projet.

## 💾 Volumes et persistance

Les données MySQL sont enregistrées dans le volume Docker :

```text
mysql_data
```

Monté dans le conteneur sur :

```text
/var/lib/mysql
```

Ainsi, les données persistent même si le conteneur est arrêté ou recréé.

Afficher les volumes :

```bash
docker volume ls
```

Arrêter les conteneurs sans supprimer les données :
=======
## Accès aux services

Après le démarrage :

| Service | Adresse |
|---|---|
| Nginx / reverse proxy Grafana | `http://localhost` |
| Grafana directement | `http://localhost:3000` |
| Prometheus | `http://localhost:9090` |

## Arrêter le projet
>>>>>>> origin/main

```bash
docker compose down
```

<<<<<<< HEAD
Supprimer également le volume et **toutes les données MySQL** :

```bash
docker compose down -v
```

> ⚠️ Cette dernière commande supprime les données de la base.

## 🛠️ Commandes utiles

Afficher les logs :

```bash
docker compose logs -f mysql
```

Redémarrer MySQL :

```bash
docker compose restart mysql
```

Ouvrir un shell dans le conteneur :

```bash
docker exec -it mysql bash
```

Ouvrir le client MySQL :

```bash
docker exec -it mysql mysql -u root -p
```

Reconstruire l'image :

```bash
docker compose up -d --build
```

Arrêter le projet :

```bash
docker compose down
```

## 🔐 Sécurité

Avant de publier ce projet sur GitHub :

1. **Ne publiez pas le fichier `.env` contenant les vrais mots de passe.**
2. Ajoutez `.env` au `.gitignore`.
3. Fournissez plutôt un `.env.example` sans secret.
4. Utilisez des mots de passe forts et différents pour `root` et l'utilisateur applicatif.
5. Évitez de coder un mot de passe directement dans `init-db.sh`.
6. Si MySQL n'a pas besoin d'être accessible depuis l'extérieur de Docker, évitez d'exposer publiquement le port `3306`.
=======
Pour consulter les logs :

```bash
docker compose logs -f
```

Pour un service particulier :

```bash
docker compose logs -f nginx
docker compose logs -f prometheus
docker compose logs -f grafana
```

## Dockerfile Nginx

Le projet contient également `docker/nginx/Dockerfile`.

Il est basé sur `nginx:alpine`, copie le dossier `./app` vers `/usr/share/nginx/html` et expose le port `80`.

**À noter :** le `docker-compose.yml` actuel utilise directement `image: nginx:alpine` et ne construit donc pas ce Dockerfile. Pour utiliser cette image personnalisée, il faudrait modifier la configuration Compose avec une section `build`.

## Points à vérifier / améliorations possibles

### Provisioning Grafana

Le fichier de datasource Prometheus se trouve actuellement dans :

```text
grafana/datasources/prometheus.yml
```

alors que le volume Docker monte :

```text
./grafana/provisioning:/etc/grafana/provisioning
```

Il faut donc vérifier que la structure de provisioning voulue par Grafana correspond bien à cette organisation. Dans l'état actuel des fichiers, `grafana/datasources/` n'est pas monté directement dans le conteneur.

### Dashboard

Le fichier suivant existe :

```text
grafana/dashboards/wordpress-dashboard.json
```

mais il est vide dans l'archive analysée. Il ne fournit donc actuellement aucun dashboard utilisable.

### Monitoring Nginx

Prometheus ne collecte pas encore de métriques Nginx. La section correspondante dans `prometheus.yml` est uniquement présente sous forme de commentaire.

### Commentaire Nginx

Dans `default.conf`, la directive est :

```nginx
proxy_pass http://grafana:3000;
```

La configuration actuelle redirige donc vers **Grafana**.

## Sécurité et publication GitHub

L'archive fournie contient le dossier `.git/`.

Lorsque vous partagez une copie ou une archive du projet, il est généralement préférable de ne pas inclure `.git/`, car il contient l'historique et les métadonnées du dépôt.

Aucun fichier `.env` n'apparaît dans cette archive. Si des mots de passe, tokens ou autres secrets sont ajoutés plus tard, utilisez un fichier `.env` ignoré par Git et fournissez seulement un `.env.example` sans secrets.
>>>>>>> origin/main

Exemple de `.gitignore` :

```gitignore
.env
*.log
.DS_Store
```

<<<<<<< HEAD
Exemple de `.env.example` :

```env
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=user
MYSQL_PASSWORD=your_user_password
```

## 🧰 Dépannage

### Le conteneur ne démarre pas

Consulter les logs :

```bash
docker compose logs mysql
```

### Le port 3306 est déjà utilisé

Vérifier qu'aucun autre serveur MySQL/MariaDB ou conteneur n'utilise le port, ou modifier le mapping dans `docker-compose.yml`.

Par exemple :

```yaml
ports:
  - "3307:3306"
```

### Les changements de mot de passe ne sont pas appliqués

Les variables d'initialisation de l'image MySQL s'appliquent principalement lors de la création initiale de la base de données.

Pour repartir de zéro en développement :

```bash
docker compose down -v
docker compose up -d --build
```

> ⚠️ Cela supprime les données existantes.

## 📄 Fichiers du projet

| Fichier | Rôle |
| --- | --- |
| `.env` | Variables d'environnement et identifiants MySQL |
| `docker-compose.yml` | Configuration principale du service MySQL |
| `docker-compose.prod.yml` | Surcharge destinée à la production |
| `Dockerfile` | Construction de l'image personnalisée basée sur MySQL 8.0 |
| `my.cnf` | Configuration personnalisée du serveur MySQL |
| `deploy.sh` | Construction et lancement des conteneurs |
| `init-db.sh` | Création manuelle de la base `wordpress` si elle n'existe pas |

## 📜 Licence

Ajoutez ici la licence souhaitée pour le projet, par exemple MIT.
=======
## Résumé

Cette infrastructure fournit :

- un reverse proxy **Nginx** ;
- un serveur de métriques **Prometheus** ;
- une interface de visualisation **Grafana** ;
- un réseau Docker commun pour la communication entre les services.

Elle constitue une base simple pour mettre en place une infrastructure de monitoring et peut ensuite être étendue avec la collecte de métriques Nginx, des dashboards Grafana et d'autres services.
=======
# ICT-169_JCS_DPD_LSL





## Technologies utilisées
- Docker
- Docker Compose
- MySQL 8.0
-  Bash


## Configuration
Les variables d'environnement sont définies dans le fichier `.env` :
- MYSQL_ROOT_PASSWORD
- MYSQL_DATABASE
- MYSQL_USER
- MYSQL_PASSWORD

## Déploiement
Lancer le projet : ```bash docker compose up -d --build

## Vérifier que le conteneur fonctionne : docker ps

>>>>>>> origin/main
