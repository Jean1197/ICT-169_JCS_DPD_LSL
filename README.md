#  MySQL Docker Infrastructure

Infrastructure Docker simple permettant de lancer une instance **MySQL 8.0** persistante, configurable avec des variables d'environnement et utilisable notamment comme base de données pour **WordPress**.

##  Sommaire

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

##  Présentation

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

## Architecture du projet

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

##  Prérequis

Avant de lancer le projet, installer :

- Docker ;
- Docker Compose (`docker compose`).

Vérification :

```bash
docker --version
docker compose version
```

##  Configuration

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

##  Installation et démarrage

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

```bash
docker compose up -d --build
```

Le script `deploy.sh` effectue la même opération :

```bash
chmod +x deploy.sh
./deploy.sh
```

### 4. Vérifier le conteneur

```bash
docker compose ps
```

ou :

```bash
docker ps
```

Le conteneur doit apparaître sous le nom :

```text
mysql
```

##  Environnement de production

Le fichier `docker-compose.prod.yml` surcharge actuellement la configuration du service MySQL afin de garantir :

```yaml
restart: always
```

Pour combiner la configuration principale avec celle de production :

```bash
docker compose   -f docker-compose.yml   -f docker-compose.prod.yml   up -d --build
```

##  Initialisation de la base

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

##  Configuration MySQL

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

##  Volumes et persistance

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

```bash
docker compose down
```

Supprimer également le volume et **toutes les données MySQL** :

```bash
docker compose down -v
```

>  Cette dernière commande supprime les données de la base.

##  Commandes utiles

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

##  Sécurité

Avant de publier ce projet sur GitHub :

1. **Ne publiez pas le fichier `.env` contenant les vrais mots de passe.**
2. Ajoutez `.env` au `.gitignore`.
3. Fournissez plutôt un `.env.example` sans secret.
4. Utilisez des mots de passe forts et différents pour `root` et l'utilisateur applicatif.
5. Évitez de coder un mot de passe directement dans `init-db.sh`.
6. Si MySQL n'a pas besoin d'être accessible depuis l'extérieur de Docker, évitez d'exposer publiquement le port `3306`.

Exemple de `.gitignore` :

```gitignore
.env
*.log
.DS_Store
```

Exemple de `.env.example` :

```env
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=user
MYSQL_PASSWORD=your_user_password
```

##  Dépannage

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

>  Cela supprime les données existantes.

##  Fichiers du projet

| Fichier | Rôle |
| --- | --- |
| `.env` | Variables d'environnement et identifiants MySQL |
| `docker-compose.yml` | Configuration principale du service MySQL |
| `docker-compose.prod.yml` | Surcharge destinée à la production |
| `Dockerfile` | Construction de l'image personnalisée basée sur MySQL 8.0 |
| `my.cnf` | Configuration personnalisée du serveur MySQL |
| `deploy.sh` | Construction et lancement des conteneurs |
| `init-db.sh` | Création manuelle de la base `wordpress` si elle n'existe pas |


