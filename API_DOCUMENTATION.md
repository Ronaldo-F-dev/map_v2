# 📡 Documentation API - Carte Interactive du Bénin

API REST complète pour gérer les emplacements sur la carte interactive.

## 🌐 Base URL

```
http://localhost:8000/api
```

## 📋 Endpoints

### 1. Liste des emplacements

Récupère tous les emplacements actifs.

**Endpoint:** `GET /locations`

**Paramètres de requête (optionnels):**

| Paramètre | Type   | Description                           |
|-----------|--------|---------------------------------------|
| category  | string | Filtre par catégorie                  |
| search    | string | Recherche dans nom et description     |
| lat       | float  | Latitude pour recherche de proximité  |
| lon       | float  | Longitude pour recherche de proximité |
| radius    | float  | Rayon de recherche en km (défaut: 10) |

**Exemples:**

```bash
# Tous les emplacements
curl http://localhost:8000/api/locations

# Filtrer par catégorie
curl http://localhost:8000/api/locations?category=restaurant

# Recherche textuelle
curl http://localhost:8000/api/locations?search=hotel

# Recherche de proximité (dans un rayon de 5km)
curl "http://localhost:8000/api/locations?lat=6.3703&lon=2.3912&radius=5"
```

**Réponse (200 OK):**

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

---

### 2. Détail d'un emplacement

Récupère un emplacement spécifique par son ID.

**Endpoint:** `GET /locations/{id}`

**Exemple:**

```bash
curl http://localhost:8000/api/locations/1
```

**Réponse (200 OK):**

```json
{
  "success": true,
  "data": {
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
}
```

**Réponse (404 Not Found):**

```json
{
  "success": false,
  "message": "Emplacement non trouvé"
}
```

---

### 3. Créer un emplacement

Crée un nouvel emplacement.

**Endpoint:** `POST /locations`

**Headers:**
```
Content-Type: application/json
```

**Corps de la requête:**

```json
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

**Champs requis:**
- `name` (string, 3-255 caractères)
- `latitude` (float, -90 à 90)
- `longitude` (float, -180 à 180)

**Champs optionnels:**
- `description` (text)
- `category` (string)
- `address` (string)
- `phone` (string)
- `email` (string)
- `website` (string)
- `image` (string, URL)
- `isActive` (boolean, défaut: true)
- `userId` (integer)

**Exemple:**

```bash
curl -X POST http://localhost:8000/api/locations \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Hôtel du Port",
    "description": "Hôtel 3 étoiles en centre-ville",
    "latitude": 6.3650,
    "longitude": 2.4183,
    "category": "hotel",
    "address": "Rue des Cheminots, Cotonou",
    "phone": "+229 21 31 45 67"
  }'
```

**Réponse (201 Created):**

```json
{
  "success": true,
  "message": "Emplacement créé avec succès",
  "data": {
    "id": 2,
    "name": "Hôtel du Port",
    "description": "Hôtel 3 étoiles en centre-ville",
    "latitude": 6.3650,
    "longitude": 2.4183,
    "category": "hotel",
    "address": "Rue des Cheminots, Cotonou",
    "phone": "+229 21 31 45 67",
    "email": null,
    "website": null,
    "image": null,
    "isActive": true,
    "userId": null,
    "createdAt": "2025-01-10 11:00:00",
    "updatedAt": null
  }
}
```

**Réponse (400 Bad Request):**

```json
{
  "success": false,
  "message": "Erreur de validation",
  "errors": {
    "name": ["Le nom est requis"],
    "latitude": ["La latitude doit être entre -90 et 90"]
  }
}
```

---

### 4. Mettre à jour un emplacement

Met à jour un emplacement existant.

**Endpoint:** `PUT /locations/{id}` ou `PATCH /locations/{id}`

**Headers:**
```
Content-Type: application/json
```

**Corps de la requête:**

```json
{
  "name": "Nouveau nom",
  "description": "Nouvelle description",
  "phone": "+229 21 99 88 77"
}
```

**Exemple:**

```bash
curl -X PUT http://localhost:8000/api/locations/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Restaurant Le Béninois - Nouvelle Marina",
    "address": "Nouvelle adresse"
  }'
```

**Réponse (200 OK):**

```json
{
  "success": true,
  "message": "Emplacement mis à jour avec succès",
  "data": {
    "id": 1,
    "name": "Restaurant Le Béninois - Nouvelle Marina",
    "description": "Cuisine locale authentique",
    "latitude": 6.3703,
    "longitude": 2.3912,
    "category": "restaurant",
    "address": "Nouvelle adresse",
    "phone": "+229 21 31 23 45",
    "email": "contact@lebeninois.bj",
    "website": "https://lebeninois.bj",
    "image": null,
    "isActive": true,
    "userId": null,
    "createdAt": "2025-01-10 10:30:00",
    "updatedAt": "2025-01-10 12:00:00"
  }
}
```

---

### 5. Supprimer un emplacement

Supprime un emplacement.

**Endpoint:** `DELETE /locations/{id}`

**Exemple:**

```bash
curl -X DELETE http://localhost:8000/api/locations/1
```

**Réponse (200 OK):**

```json
{
  "success": true,
  "message": "Emplacement supprimé avec succès"
}
```

**Réponse (404 Not Found):**

```json
{
  "success": false,
  "message": "Emplacement non trouvé"
}
```

---

## 📊 Catégories disponibles

| Valeur     | Description |
|------------|-------------|
| restaurant | Restaurants |
| hotel      | Hôtels      |
| shop       | Commerces   |
| hospital   | Hôpitaux    |
| school     | Écoles      |
| other      | Autre       |

---

## 🔐 Authentification (à implémenter)

Pour sécuriser l'API, vous pouvez ajouter l'authentification JWT :

```bash
# Installation
composer require lexik/jwt-authentication-bundle

# Configuration
php bin/console lexik:jwt:generate-keypair
```

Une fois configuré, ajoutez le token dans les headers :

```bash
curl http://localhost:8000/api/locations \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 🧪 Exemples d'utilisation

### JavaScript / Axios

```javascript
import axios from 'axios';

const API_URL = 'http://localhost:8000/api';

// Récupérer tous les restaurants
const restaurants = await axios.get(`${API_URL}/locations`, {
  params: { category: 'restaurant' }
});

// Créer un nouvel emplacement
const newLocation = await axios.post(`${API_URL}/locations`, {
  name: 'Mon Hôtel',
  latitude: 6.3703,
  longitude: 2.3912,
  category: 'hotel'
});

// Mettre à jour
await axios.put(`${API_URL}/locations/1`, {
  name: 'Nouveau nom'
});

// Supprimer
await axios.delete(`${API_URL}/locations/1`);
```

### Python / Requests

```python
import requests

API_URL = 'http://localhost:8000/api'

# Récupérer tous les emplacements
response = requests.get(f'{API_URL}/locations')
locations = response.json()

# Créer un nouvel emplacement
data = {
    'name': 'Mon Restaurant',
    'latitude': 6.3703,
    'longitude': 2.3912,
    'category': 'restaurant'
}
response = requests.post(f'{API_URL}/locations', json=data)
```

### PHP / cURL

```php
<?php

$api_url = 'http://localhost:8000/api';

// Récupérer tous les emplacements
$ch = curl_init("$api_url/locations");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
$locations = json_decode($response, true);

// Créer un nouvel emplacement
$data = [
    'name' => 'Mon Restaurant',
    'latitude' => 6.3703,
    'longitude' => 2.3912,
    'category' => 'restaurant'
];

$ch = curl_init("$api_url/locations");
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
```

---

## ⚠️ Codes d'erreur

| Code | Description                    |
|------|--------------------------------|
| 200  | Succès                         |
| 201  | Créé avec succès               |
| 400  | Requête invalide / Validation  |
| 401  | Non autorisé                   |
| 404  | Ressource non trouvée          |
| 500  | Erreur serveur                 |

---

## 📝 Notes

- Toutes les coordonnées utilisent le système WGS84 (latitude/longitude)
- Les dates sont au format `Y-m-d H:i:s` (UTC)
- La recherche de proximité utilise une approximation simple. Pour une précision géographique exacte, utilisez PostgreSQL avec PostGIS

---

## 🚀 Prochaines fonctionnalités

- [ ] Authentification JWT
- [ ] Upload d'images
- [ ] Commentaires et notes
- [ ] Favoris
- [ ] Export des données (CSV, GeoJSON)
- [ ] Webhooks
