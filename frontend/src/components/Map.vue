<template>
  <div class="map-container">
    <div id="map" ref="mapContainer"></div>

    <!-- Panneau de contrôle -->
    <div class="map-controls">
      <button @click="toggleAddMode" :class="{ active: isAddMode }" class="control-btn">
        {{ isAddMode ? '✕ Annuler' : '📍 Ajouter un lieu' }}
      </button>

      <div class="search-box">
        <input
          v-model="searchQuery"
          @input="onSearch"
          type="text"
          placeholder="Rechercher un lieu..."
          class="search-input"
        />
      </div>

      <select v-model="selectedCategory" @change="filterByCategory" class="category-select">
        <option value="">Toutes les catégories</option>
        <option value="restaurant">Restaurant</option>
        <option value="hotel">Hôtel</option>
        <option value="shop">Commerce</option>
        <option value="hospital">Hôpital</option>
        <option value="school">École</option>
        <option value="other">Autre</option>
      </select>
    </div>

    <!-- Modal pour ajouter/modifier un lieu -->
    <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
      <div class="modal-content">
        <h2>{{ editingLocation ? 'Modifier' : 'Ajouter' }} un lieu</h2>

        <form @submit.prevent="saveLocation">
          <div class="form-group">
            <label>Nom *</label>
            <input v-model="formData.name" type="text" required class="form-control" />
          </div>

          <div class="form-group">
            <label>Description</label>
            <textarea v-model="formData.description" rows="3" class="form-control"></textarea>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Latitude *</label>
              <input v-model="formData.latitude" type="number" step="any" required class="form-control" />
            </div>
            <div class="form-group">
              <label>Longitude *</label>
              <input v-model="formData.longitude" type="number" step="any" required class="form-control" />
            </div>
          </div>

          <div class="form-group">
            <label>Catégorie</label>
            <select v-model="formData.category" class="form-control">
              <option value="">Sélectionner une catégorie</option>
              <option value="restaurant">Restaurant</option>
              <option value="hotel">Hôtel</option>
              <option value="shop">Commerce</option>
              <option value="hospital">Hôpital</option>
              <option value="school">École</option>
              <option value="other">Autre</option>
            </select>
          </div>

          <div class="form-group">
            <label>Adresse</label>
            <input v-model="formData.address" type="text" class="form-control" />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Téléphone</label>
              <input v-model="formData.phone" type="tel" class="form-control" />
            </div>
            <div class="form-group">
              <label>Email</label>
              <input v-model="formData.email" type="email" class="form-control" />
            </div>
          </div>

          <div class="form-group">
            <label>Site web</label>
            <input v-model="formData.website" type="url" class="form-control" />
          </div>

          <div class="form-actions">
            <button type="button" @click="closeModal" class="btn btn-secondary">Annuler</button>
            <button type="submit" class="btn btn-primary" :disabled="loading">
              {{ loading ? 'Enregistrement...' : 'Enregistrer' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { locationAPI } from '../services/api';

// Fix pour les icônes Leaflet avec Vite
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

export default {
  name: 'MapComponent',

  data() {
    return {
      map: null,
      markers: [],
      locations: [],
      isAddMode: false,
      showModal: false,
      editingLocation: null,
      tempMarker: null,
      searchQuery: '',
      selectedCategory: '',
      loading: false,
      formData: {
        name: '',
        description: '',
        latitude: '',
        longitude: '',
        category: '',
        address: '',
        phone: '',
        email: '',
        website: '',
      },
    };
  },

  mounted() {
    this.initMap();
    this.loadLocations();
  },

  beforeUnmount() {
    if (this.map) {
      this.map.remove();
    }
  },

  methods: {
    /**
     * Initialise la carte Leaflet
     */
    initMap() {
      // Centrer sur le Bénin
      this.map = L.map(this.$refs.mapContainer).setView([9.30769, 2.315834], 7);

      // Ajouter la couche OpenStreetMap
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        maxZoom: 19,
      }).addTo(this.map);

      // Écouter les clics sur la carte en mode ajout
      this.map.on('click', this.onMapClick);
    },

    /**
     * Gère les clics sur la carte
     */
    onMapClick(e) {
      if (!this.isAddMode) return;

      const { lat, lng } = e.latlng;

      // Supprimer le marker temporaire précédent
      if (this.tempMarker) {
        this.map.removeLayer(this.tempMarker);
      }

      // Ajouter un marker temporaire
      this.tempMarker = L.marker([lat, lng], {
        icon: this.getCustomIcon('temp'),
      }).addTo(this.map);

      // Pré-remplir le formulaire avec les coordonnées
      this.formData.latitude = lat.toFixed(6);
      this.formData.longitude = lng.toFixed(6);

      // Ouvrir le modal
      this.showModal = true;
    },

    /**
     * Charge tous les emplacements
     */
    async loadLocations(params = {}) {
      try {
        const response = await locationAPI.getAll(params);
        if (response.data.success) {
          this.locations = response.data.data;
          this.displayMarkers();
        }
      } catch (error) {
        console.error('Erreur lors du chargement des emplacements:', error);
        alert('Erreur lors du chargement des emplacements');
      }
    },

    /**
     * Affiche les markers sur la carte
     */
    displayMarkers() {
      // Supprimer les markers existants
      this.markers.forEach(marker => this.map.removeLayer(marker));
      this.markers = [];

      // Ajouter les nouveaux markers
      this.locations.forEach(location => {
        const marker = L.marker([location.latitude, location.longitude], {
          icon: this.getCustomIcon(location.category),
        }).addTo(this.map);

        // Popup avec les informations
        const popupContent = this.createPopupContent(location);
        marker.bindPopup(popupContent);

        this.markers.push(marker);
      });
    },

    /**
     * Crée le contenu du popup
     */
    createPopupContent(location) {
      return `
        <div class="location-popup">
          <h3>${location.name}</h3>
          ${location.description ? `<p>${location.description}</p>` : ''}
          ${location.address ? `<p><strong>📍</strong> ${location.address}</p>` : ''}
          ${location.phone ? `<p><strong>📞</strong> ${location.phone}</p>` : ''}
          ${location.email ? `<p><strong>✉️</strong> ${location.email}</p>` : ''}
          ${location.website ? `<p><a href="${location.website}" target="_blank">🌐 Site web</a></p>` : ''}
          <div class="popup-actions">
            <button onclick="window.editLocation(${location.id})" class="btn-edit">✏️ Modifier</button>
            <button onclick="window.deleteLocation(${location.id})" class="btn-delete">🗑️ Supprimer</button>
          </div>
        </div>
      `;
    },

    /**
     * Retourne une icône personnalisée selon la catégorie
     */
    getCustomIcon(category) {
      const colors = {
        restaurant: 'red',
        hotel: 'blue',
        shop: 'green',
        hospital: 'orange',
        school: 'purple',
        temp: 'gray',
      };

      const color = colors[category] || 'blue';

      return L.icon({
        iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
        iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34],
        shadowSize: [41, 41],
      });
    },

    /**
     * Active/désactive le mode ajout
     */
    toggleAddMode() {
      this.isAddMode = !this.isAddMode;

      if (!this.isAddMode && this.tempMarker) {
        this.map.removeLayer(this.tempMarker);
        this.tempMarker = null;
      }
    },

    /**
     * Sauvegarde un emplacement (création ou modification)
     */
    async saveLocation() {
      this.loading = true;

      try {
        let response;

        if (this.editingLocation) {
          response = await locationAPI.update(this.editingLocation.id, this.formData);
        } else {
          response = await locationAPI.create(this.formData);
        }

        if (response.data.success) {
          alert(response.data.message);
          this.closeModal();
          this.loadLocations();
        }
      } catch (error) {
        console.error('Erreur lors de la sauvegarde:', error);
        alert('Erreur lors de la sauvegarde de l\'emplacement');
      } finally {
        this.loading = false;
      }
    },

    /**
     * Ferme le modal
     */
    closeModal() {
      this.showModal = false;
      this.editingLocation = null;
      this.isAddMode = false;

      if (this.tempMarker) {
        this.map.removeLayer(this.tempMarker);
        this.tempMarker = null;
      }

      this.resetForm();
    },

    /**
     * Réinitialise le formulaire
     */
    resetForm() {
      this.formData = {
        name: '',
        description: '',
        latitude: '',
        longitude: '',
        category: '',
        address: '',
        phone: '',
        email: '',
        website: '',
      };
    },

    /**
     * Recherche d'emplacements
     */
    onSearch() {
      if (this.searchQuery.length >= 3) {
        this.loadLocations({ search: this.searchQuery });
      } else if (this.searchQuery.length === 0) {
        this.loadLocations();
      }
    },

    /**
     * Filtre par catégorie
     */
    filterByCategory() {
      if (this.selectedCategory) {
        this.loadLocations({ category: this.selectedCategory });
      } else {
        this.loadLocations();
      }
    },
  },
};

// Fonctions globales pour les actions du popup
window.editLocation = (id) => {
  // Cette fonction sera appelée depuis le popup
  console.log('Edit location:', id);
};

window.deleteLocation = async (id) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer cet emplacement ?')) {
    try {
      const response = await locationAPI.delete(id);
      if (response.data.success) {
        alert('Emplacement supprimé avec succès');
        window.location.reload();
      }
    } catch (error) {
      console.error('Erreur lors de la suppression:', error);
      alert('Erreur lors de la suppression');
    }
  }
};
</script>

<style scoped>
.map-container {
  position: relative;
  width: 100%;
  height: 100vh;
}

#map {
  width: 100%;
  height: 100%;
}

.map-controls {
  position: absolute;
  top: 10px;
  left: 10px;
  z-index: 1000;
  background: white;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.2);
  display: flex;
  flex-direction: column;
  gap: 10px;
  min-width: 250px;
}

.control-btn {
  padding: 10px 15px;
  border: none;
  border-radius: 5px;
  background: #4CAF50;
  color: white;
  cursor: pointer;
  font-weight: bold;
  transition: background 0.3s;
}

.control-btn:hover {
  background: #45a049;
}

.control-btn.active {
  background: #f44336;
}

.search-input,
.category-select {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
}

.modal-content {
  background: white;
  padding: 30px;
  border-radius: 10px;
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-content h2 {
  margin-top: 0;
  color: #333;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
  color: #555;
}

.form-control {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  box-sizing: border-box;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-weight: bold;
  transition: background 0.3s;
}

.btn-primary {
  background: #4CAF50;
  color: white;
}

.btn-primary:hover {
  background: #45a049;
}

.btn-primary:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.btn-secondary {
  background: #999;
  color: white;
}

.btn-secondary:hover {
  background: #777;
}
</style>

<style>
/* Styles globaux pour les popups Leaflet */
.location-popup {
  min-width: 200px;
}

.location-popup h3 {
  margin-top: 0;
  color: #333;
  font-size: 18px;
}

.location-popup p {
  margin: 5px 0;
  color: #666;
}

.popup-actions {
  display: flex;
  gap: 10px;
  margin-top: 10px;
}

.btn-edit,
.btn-delete {
  padding: 5px 10px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
}

.btn-edit {
  background: #2196F3;
  color: white;
}

.btn-delete {
  background: #f44336;
  color: white;
}
</style>
