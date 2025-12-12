# Backend Symfony - API Carte Interactive

API REST pour la gestion des emplacements sur la carte interactive du Bénin.

## 🚀 Installation

### 1. Installer les dépendances

```bash
composer install
```

### 2. Configurer la base de données

Modifiez le fichier `.env` :

```env
DATABASE_URL="mysql://root:password@127.0.0.1:3306/benin_map?serverVersion=8.0.32&charset=utf8mb4"
```

### 3. Créer la base de données

```bash
php bin/console doctrine:database:create
```

### 4. Exécuter les migrations

```bash
php bin/console doctrine:migrations:migrate
```

Ou créer la migration si elle n'existe pas :

```bash
php bin/console make:migration
php bin/console doctrine:migrations:migrate
```

### 5. Démarrer le serveur

```bash
# Avec Symfony CLI (recommandé)
symfony server:start

# Ou avec le serveur PHP intégré
php -S localhost:8000 -t public
```

L'API sera accessible sur `http://localhost:8000`

## 📡 Endpoints API

### Locations

- `GET /api/locations` - Liste tous les emplacements
- `GET /api/locations/{id}` - Détail d'un emplacement
- `POST /api/locations` - Créer un emplacement
- `PUT /api/locations/{id}` - Mettre à jour un emplacement
- `DELETE /api/locations/{id}` - Supprimer un emplacement

### Paramètres de recherche

- `?category=restaurant` - Filtrer par catégorie
- `?search=hotel` - Recherche textuelle
- `?lat=6.3703&lon=2.3912&radius=10` - Recherche par proximité

## 🧪 Test de l'API

```bash
# Tester que l'API fonctionne
curl http://localhost:8000/api/locations

# Créer un emplacement
curl -X POST http://localhost:8000/api/locations \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Restaurant",
    "latitude": 6.3703,
    "longitude": 2.3912,
    "category": "restaurant"
  }'
```

## 🛠️ Commandes utiles

```bash
# Vider le cache
php bin/console cache:clear

# Lister les routes
php bin/console debug:router

# Vérifier la configuration Doctrine
php bin/console doctrine:schema:validate

# Créer une nouvelle migration
php bin/console make:migration

# Exécuter les migrations
php bin/console doctrine:migrations:migrate

# Créer un nouveau controller
php bin/console make:controller

# Créer une nouvelle entity
php bin/console make:entity
```

## 📂 Structure

```
backend/
├── bin/
│   └── console          # CLI Symfony
├── config/
│   ├── packages/        # Configuration des bundles
│   ├── bundles.php      # Liste des bundles
│   ├── routes.yaml      # Configuration des routes
│   └── services.yaml    # Configuration des services
├── migrations/          # Migrations de base de données
├── public/
│   └── index.php        # Point d'entrée
├── src/
│   ├── Controller/      # Controllers API
│   ├── Entity/          # Entities Doctrine
│   ├── Repository/      # Repositories
│   └── Kernel.php       # Kernel Symfony
├── var/
│   ├── cache/           # Cache
│   └── log/             # Logs
├── vendor/              # Dépendances (créé par Composer)
├── .env                 # Configuration environnement
└── composer.json        # Dépendances PHP
```

## 🔒 Production

Pour le déploiement en production :

```bash
# Installer les dépendances de production
composer install --no-dev --optimize-autoloader

# Définir l'environnement de production
APP_ENV=prod

# Vider le cache
php bin/console cache:clear --env=prod

# Optimiser l'autoloader
composer dump-autoload --optimize --classmap-authoritative
```

## ⚙️ Variables d'environnement

- `APP_ENV` - Environnement (dev, prod)
- `APP_SECRET` - Clé secrète de l'application
- `DATABASE_URL` - URL de connexion à la base de données
- `CORS_ALLOW_ORIGIN` - Origines autorisées pour CORS

## 📝 Dépendances

- Symfony 6.4
- Doctrine ORM
- Doctrine Migrations
- NelmioCorsBundle
- Symfony Validator

## 🐛 Dépannage

### Erreur : "No such file or directory"

```bash
# Installer les dépendances
composer install
```

### Erreur : "Connection refused"

Vérifiez que la base de données est démarrée et que les informations de connexion dans `.env` sont correctes.

### Erreur CORS

Vérifiez la configuration dans `config/packages/nelmio_cors.yaml`

### Erreur 500

Vérifiez les logs :
```bash
tail -f var/log/dev.log
```
