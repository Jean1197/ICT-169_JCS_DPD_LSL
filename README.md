# ICT-169_JCS_DPD_LSL

## Présentation

Projet Docker réunissant les services **MySQL 8.0**, **WordPress**, **Nginx**, **Prometheus** et **Grafana**. Le fichier `docker-compose.yml` définit leurs configurations et leur réseau commun `app-network`.

## Prérequis

- Git
- Docker et Docker Compose (`docker compose`)

Vérification :

```bash
docker --version
docker compose version
```

## Organisation du projet

Les chemins utilisés par la configuration Docker sont notamment :

```text
.
├── docker-compose.yml
├── docker-compose.prod.yml
├── .gitignore
├── .env                 # local, ne pas versionner
├── docker/
│   ├── mysql/Dockerfile
│   └── wordpress/Dockerfile
├── config/mysql/my.cnf
├── app/
│   ├── nginx/default.conf
│   └── wordpress/wp-content/
├── prometheus/prometheus.yml
├── grafana/provisioning/
├── deploy.sh
└── init-db.sh
```

Certains chemins ne sont utiles que si les fichiers et scripts correspondants sont présents dans le dépôt.

## Configuration MySQL

Le service `mysql` est construit depuis `docker/mysql/Dockerfile`, basé sur **MySQL 8.0**. La configuration personnalisée est définie dans `config/mysql/my.cnf`.

Créer à la racine du projet un fichier `.env` **local** contenant les variables suivantes, avec des mots de passe choisis pour votre environnement :

```dotenv
MYSQL_ROOT_PASSWORD=change_me_root
MYSQL_DATABASE=wordpress
MYSQL_USER=user
MYSQL_PASSWORD=change_me_user
```

- `MYSQL_ROOT_PASSWORD` : mot de passe administrateur MySQL.
- `MYSQL_DATABASE` : base initialisée au premier démarrage (ici `wordpress`).
- `MYSQL_USER` et `MYSQL_PASSWORD` : identifiants de l'application.

**Ne pas envoyer `.env` sur GitHub.** Le fichier doit être ignoré dans `.gitignore`. Les mots de passe affichés ci-dessus sont des exemples, pas des identifiants de production.

Les données MySQL sont persistées dans le volume Docker `mysql_data`, monté sur `/var/lib/mysql`. Le service expose le port `3306` sur la machine hôte.

### Initialisation de la base

Lors du premier démarrage avec un volume vide, `MYSQL_DATABASE=wordpress` permet à MySQL de créer la base. Si le script `init-db.sh` est présent et adapté à votre environnement, il peut également servir à l'initialisation manuelle.

### Configuration `my.cnf`

Le projet utilise une configuration personnalisée MySQL indiquant notamment :

```ini
[mysqld]
bind-address=0.0.0.0
max_connections=100
default_authentication_plugin=mysql_native_password
```

Cette configuration est liée à la version MySQL utilisée ; vérifier sa compatibilité avant de changer de version.

## WordPress

Le service `wordpress` est construit depuis `docker/wordpress/Dockerfile` et utilise les fichiers du répertoire `app/wordpress/wp-content/` pour le contenu personnalisé, notamment le thème `mon-theme`.

La connexion à MySQL est configurée dans Docker Compose :

- Hôte : `mysql` (nom du service Docker)
- Utilisateur : `${MYSQL_USER}`
- Mot de passe : `${MYSQL_PASSWORD}`
- Base : `${MYSQL_DATABASE}`

WordPress dépend de MySQL et est exposé sur **http://localhost:8080**.

Pour vérifier le thème, ouvrir l'administration WordPress puis **Apparence → Thèmes**.

## Nginx, Prometheus et Grafana

### Nginx

Le service `nginx` utilise `nginx:alpine`, expose le port `80` et charge la configuration `./app/nginx/default.conf`. Dans la configuration documentée du projet, Nginx sert de reverse proxy vers `http://grafana:3000`.

Le dossier `docker/nginx/` peut contenir un Dockerfile personnalisé, mais le fichier Compose utilise actuellement directement l'image `nginx:alpine`.

### Prometheus

Le service `prometheus` utilise `prom/prometheus:latest`, expose le port `9090` et charge `./prometheus/prometheus.yml`. La configuration initiale collecte les métriques de Prometheus, avec un intervalle documenté de 15 secondes.

### Grafana

Le service `grafana` utilise `grafana/grafana:latest`, expose le port `3000` et dépend de Prometheus. Le dossier `./grafana/provisioning` est monté dans `/etc/grafana/provisioning`.

**À vérifier :** si la source de données est uniquement stockée dans `grafana/datasources/prometheus.yml`, elle ne sera pas automatiquement chargée par le montage de `grafana/provisioning` sans organisation adaptée. Un dashboard vide ne fournit pas de tableau de bord exploitable.

## Démarrage et vérifications

À la racine du dépôt :

```bash
# Vérifier la configuration Docker Compose
docker compose config --quiet

# Construire et démarrer les services
docker compose up -d --build

# Vérifier les conteneurs
docker compose ps
```

Adresses locales :

| Service | Adresse |
| --- | --- |
| Nginx | http://localhost |
| WordPress | http://localhost:8080 |
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |
| MySQL | localhost:3306 (connexion SQL) |

Afficher les journaux :

```bash
docker compose logs -f mysql
docker compose logs -f wordpress
docker compose logs -f nginx
docker compose logs -f prometheus
docker compose logs -f grafana
```

Arrêter les conteneurs sans supprimer les données :

```bash
docker compose down
```

**Attention :** `docker compose down -v` supprime aussi les volumes, dont les données MySQL.

## Environnement de production

Le fichier `docker-compose.prod.yml` ajoute la politique de redémarrage `restart: always` au service MySQL. Pour combiner les deux fichiers :

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

## Dépannage et sécurité

- **Port 3306 déjà utilisé :** rechercher un autre serveur MySQL ou adapter le mappage, par exemple `3307:3306`.
- **Identifiants modifiés mais non appliqués :** les variables d'initialisation MySQL ne reconfigurent pas automatiquement une base déjà présente dans un volume.
- **WordPress inaccessible :** vérifier `docker compose ps`, les logs WordPress et MySQL et l'existence des fichiers référencés par les Dockerfiles.
- **Secrets :** ne pas versionner `.env`, éviter les mots de passe en dur dans les scripts et employer des secrets adaptés en production.
- **Port MySQL :** si la connexion depuis l'hôte n'est pas nécessaire, limiter ou supprimer son exposition.

## Tests à réaliser

1. `docker compose config --quiet` sans erreur.
2. `docker compose up -d --build` et `docker compose ps` pour confirmer le démarrage.
3. Ouvrir WordPress et vérifier son thème personnalisé.
4. Ouvrir Grafana et Prometheus ; vérifier les sources de données et les métriques effectivement collectées.
5. Vérifier que `.env` est ignoré : `git check-ignore -v .env`.

Ces tests doivent être effectués localement : la présence des fichiers dans le dépôt ne garantit pas à elle seule le bon fonctionnement des conteneurs.
