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
