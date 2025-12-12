<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Annotation\Route;

class ApiController extends AbstractController
{
    /**
     * Page d'accueil de l'API
     */
    #[Route('/api', name: 'api_home', methods: ['GET'])]
    public function index(): JsonResponse
    {
        return $this->json([
            'success' => true,
            'message' => 'Bienvenue sur l\'API de carte interactive du Bénin',
            'version' => '1.0.0',
            'endpoints' => [
                'locations' => [
                    'list' => 'GET /api/locations - Liste tous les emplacements',
                    'show' => 'GET /api/locations/{id} - Affiche un emplacement',
                    'create' => 'POST /api/locations - Crée un nouvel emplacement',
                    'update' => 'PUT /api/locations/{id} - Met à jour un emplacement',
                    'delete' => 'DELETE /api/locations/{id} - Supprime un emplacement'
                ]
            ],
            'query_parameters' => [
                'locations' => [
                    'category' => 'Filtrer par catégorie',
                    'search' => 'Rechercher par nom ou description',
                    'lat & lon & radius' => 'Rechercher dans un rayon (en km)'
                ]
            ]
        ]);
    }
}