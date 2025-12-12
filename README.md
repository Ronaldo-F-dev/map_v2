# 🗺️ Carte Interactive du Bénin

Application web permettant aux utilisateurs d'ajouter et de gérer leurs propres emplacements sur une carte interactive basée sur OpenStreetMap.

## 📋 Fonctionnalités

- ✅ Carte interactive avec OpenStreetMap
- ✅ Ajout d'emplacements personnalisés en cliquant sur la carte
- ✅ CRUD complet (Créer, Lire, Mettre à jour, Supprimer)
- ✅ Recherche d'emplacements par nom ou description
- ✅ Filtrage par catégorie
- ✅ Recherche de proximité (emplacements à proximité)
- ✅ API REST complète pour les développeurs
- ✅ Interface responsive et moderne

## 🏗️ Architecture

```
map_v2/
├── backend/          # API Symfony
│   ├── src/
│   │   ├── Entity/           # Location entity
│   │   ├── Controller/       # LocationController (API REST)
│   │   └── Repository/       # LocationRepository
│   └── config/
└── frontend/         # Application Vue.js
    ├── src/
    │   ├── components/       # Map.vue
    │   └── services/         # api.js
    └── public/
```

## 🚀 Installation

### Prérequis

- PHP 8.2+
- Composer
- Node.js 18+
- npm ou yarn
- MySQL/PostgreSQL

### Backend (Symfony)

```bash
cd backend

# Installer les dépendances
composer install

# Configurer la base de données dans .env
# DATABASE_URL="mysql://user:password@127.0.0.1:3306/benin_map"

# Créer la base de données
php bin/console doctrine:database:create

# Créer les tables
php bin/console doctrine:migrations:migrate

# Démarrer le serveur
symfony server:start
# ou
php -S localhost:8000 -t public
```

### Frontend (Vue.js)

```bash
cd frontend

# Installer les dépendances
npm install

# Démarrer le serveur de développement
npm run dev

# Construire pour la production
npm run build
```

## 📡 API REST

### Endpoints disponibles

#### Récupérer tous les emplacements
```http
GET /api/locations
GET /api/locations?category=restaurant
GET /api/locations?search=hotel
GET /api/locations?lat=9.30769&lon=2.315834&radius=10
```

**Réponse :**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Restaurant Le Béninois",
      "description": "Cuisine locale authentique",
      "latitude": 6.3703,
      "longitude": 2.3912,
      "category": "restaurant",
      "address": "Avenue de la Marina, Cotonou",
      "phone": "+229 21 31 23 45",
      "email": "contact@lebeninois.bj",
      "website": "https://lebeninois.bj",
      "image": null,
      "isActive": true,
      "userId": null,
      "createdAt": "2025-01-10 10:30:00",
      "updatedAt": null
    }
  ],
  "total": 1
}
```

#### Récupérer un emplacement spécifique
```http
GET /api/locations/{id}
```

#### Créer un nouvel emplacement
```http
POST /api/locations
Content-Type: application/json

{
  "name": "Mon Restaurant",
  "description": "Description du restaurant",
  "latitude": 6.3703,
  "longitude": 2.3912,
  "category": "restaurant",
  "address": "Adresse complète",
  "phone": "+229 XX XX XX XX",
  "email": "contact@example.com",
  "website": "https://example.com"
}
```

#### Mettre à jour un emplacement
```http
PUT /api/locations/{id}
Content-Type: application/json

{
  "name": "Nouveau nom",
  "description": "Nouvelle description"
}
```

#### Supprimer un emplacement
```http
DELETE /api/locations/{id}
```

## 💻 Utilisation

### Frontend

1. Ouvrez l'application dans votre navigateur (http://localhost:3000)
2. Cliquez sur le bouton "📍 Ajouter un lieu"
3. Cliquez sur la carte à l'endroit désiré
4. Remplissez le formulaire avec les informations
5. Cliquez sur "Enregistrer"

### Filtres et recherche

- Utilisez la barre de recherche pour trouver un lieu par nom ou description
- Utilisez le sélecteur de catégorie pour filtrer par type de lieu
- Cliquez sur un marker pour voir les détails et les actions

### API pour développeurs

Utilisez l'API REST pour intégrer la carte dans votre propre application :

```javascript
// Exemple avec JavaScript/Axios
import axios from 'axios';

const API_URL = 'http://localhost:8000/api';

// Récupérer tous les emplacements
const locations = await axios.get(`${API_URL}/locations`);

// Créer un nouvel emplacement
const newLocation = await axios.post(`${API_URL}/locations`, {
  name: 'Mon lieu',
  latitude: 6.3703,
  longitude: 2.3912,
  category: 'restaurant'
});

// Rechercher à proximité
const nearby = await axios.get(`${API_URL}/locations?lat=6.3703&lon=2.3912&radius=5`);
```

## 🎨 Catégories disponibles

- `restaurant` - Restaurants
- `hotel` - Hôtels
- `shop` - Commerces
- `hospital` - Hôpitaux
- `school` - Écoles
- `other` - Autre

## 🔒 Sécurité

- Validation des données côté serveur avec Symfony Validator
- CORS configuré pour autoriser les requêtes cross-origin
- Support pour l'authentification JWT (à implémenter selon vos besoins)

## 📝 Base de données

### Structure de la table `locations`

| Colonne      | Type         | Description                    |
|--------------|--------------|--------------------------------|
| id           | INT          | Identifiant unique             |
| name         | VARCHAR(255) | Nom de l'emplacement          |
| description  | TEXT         | Description                    |
| latitude     | DECIMAL      | Latitude (WGS84)              |
| longitude    | DECIMAL      | Longitude (WGS84)             |
| category     | VARCHAR(100) | Catégorie                     |
| address      | VARCHAR(255) | Adresse                       |
| phone        | VARCHAR(20)  | Téléphone                     |
| email        | VARCHAR(255) | Email                         |
| website      | VARCHAR(255) | Site web                      |
| image        | VARCHAR(255) | URL de l'image                |
| isActive     | BOOLEAN      | Statut actif/inactif          |
| userId       | INT          | ID de l'utilisateur créateur  |
| createdAt    | DATETIME     | Date de création              |
| updatedAt    | DATETIME     | Date de modification          |

## 🛠️ Technologies utilisées

### Backend
- **Symfony 6/7** - Framework PHP
- **Doctrine ORM** - Object-Relational Mapping
- **MySQL/PostgreSQL** - Base de données
- **NelmioCorsBundle** - Gestion CORS

### Frontend
- **Vue.js 3** - Framework JavaScript
- **Vite** - Build tool
- **Leaflet.js** - Bibliothèque de cartographie
- **Axios** - Client HTTP
- **OpenStreetMap** - Tiles de carte

## 📦 Déploiement

### Backend (Symfony)

```bash
# Build pour production
composer install --no-dev --optimize-autoloader

# Clear cache
php bin/console cache:clear --env=prod

# Optimiser l'autoloader
composer dump-autoload --optimize --classmap-authoritative
```

### Frontend (Vue.js)

```bash
# Build pour production
npm run build

# Les fichiers seront dans le dossier dist/
# Déployez sur un serveur web (Nginx, Apache, etc.)
```

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

## 📄 Licence

Ce projet est sous licence MIT.

## 👨‍💻 Auteur

Votre nom - [Votre GitHub](https://github.com/votre-username)

## 🙏 Remerciements

- OpenStreetMap pour les tiles de carte
- Leaflet.js pour la bibliothèque de cartographie
- La communauté Symfony et Vue.js

---

**Note importante :** Pour une recherche géographique plus précise (rayon, distance exacte), il est recommandé d'utiliser PostgreSQL avec l'extension PostGIS.
