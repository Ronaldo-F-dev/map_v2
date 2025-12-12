import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Intercepteur pour ajouter le token d'authentification si disponible
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Intercepteur pour gérer les erreurs
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Déconnexion automatique si non autorisé
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const locationAPI = {
  /**
   * Récupère tous les emplacements
   * @param {Object} params - Paramètres de filtrage (category, search, lat, lon, radius)
   */
  getAll(params = {}) {
    return apiClient.get('/locations', { params });
  },

  /**
   * Récupère un emplacement par son ID
   * @param {number} id
   */
  getById(id) {
    return apiClient.get(`/locations/${id}`);
  },

  /**
   * Crée un nouvel emplacement
   * @param {Object} data
   */
  create(data) {
    return apiClient.post('/locations', data);
  },

  /**
   * Met à jour un emplacement
   * @param {number} id
   * @param {Object} data
   */
  update(id, data) {
    return apiClient.put(`/locations/${id}`, data);
  },

  /**
   * Supprime un emplacement
   * @param {number} id
   */
  delete(id) {
    return apiClient.delete(`/locations/${id}`);
  },

  /**
   * Recherche des emplacements
   * @param {string} query
   */
  search(query) {
    return apiClient.get('/locations', { params: { search: query } });
  },

  /**
   * Récupère les emplacements par catégorie
   * @param {string} category
   */
  getByCategory(category) {
    return apiClient.get('/locations', { params: { category } });
  },

  /**
   * Récupère les emplacements à proximité
   * @param {number} lat - Latitude
   * @param {number} lon - Longitude
   * @param {number} radius - Rayon en km
   */
  getNearby(lat, lon, radius = 10) {
    return apiClient.get('/locations', { params: { lat, lon, radius } });
  },
};

export default apiClient;
