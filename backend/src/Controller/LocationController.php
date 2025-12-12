<?php

namespace App\Controller;

use App\Entity\Location;
use App\Repository\LocationRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;

#[Route('/api/locations', name: 'api_location_')]
class LocationController extends AbstractController
{
    private $entityManager;
    private $locationRepository;
    private $validator;

    public function __construct(
        EntityManagerInterface $entityManager,
        LocationRepository $locationRepository,
        ValidatorInterface $validator
    ) {
        $this->validator = $validator;
        $this->locationRepository = $locationRepository;
        $this->entityManager = $entityManager;
    }

    /**
     * Liste tous les emplacements
     */
    #[Route('', name: 'list', methods: ['GET'])]
    public function index(Request $request): JsonResponse
    {
        $category = $request->query->get('category');
        $search = $request->query->get('search');
        $lat = $request->query->get('lat');
        $lon = $request->query->get('lon');
        $radius = $request->query->get('radius', 10);

        if ($lat && $lon) {
            $locations = $this->locationRepository->findNearby(
                (float) $lat,
                (float) $lon,
                (float) $radius
            );
        } elseif ($category) {
            $locations = $this->locationRepository->findByCategory($category);
        } elseif ($search) {
            $locations = $this->locationRepository->search($search);
        } else {
            $locations = $this->locationRepository->findActive();
        }

        $data = array_map(fn($location) => $location->toArray(), $locations);

        return $this->json([
            'success' => true,
            'data' => $data,
            'total' => count($data)
        ]);
    }

    /**
     * Affiche un emplacement spécifique
     */
    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(int $id): JsonResponse
    {
        $location = $this->locationRepository->find($id);

        if (!$location) {
            return $this->json([
                'success' => false,
                'message' => 'Emplacement non trouvé'
            ], Response::HTTP_NOT_FOUND);
        }

        return $this->json([
            'success' => true,
            'data' => $location->toArray()
        ]);
    }

    /**
     * Crée un nouvel emplacement
     */
    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        $location = new Location();
        $this->hydrate($location, $data);

        $errors = $this->validator->validate($location);
        if (count($errors) > 0) {
            return $this->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $this->formatErrors($errors)
            ], Response::HTTP_BAD_REQUEST);
        }

        $this->entityManager->persist($location);
        $this->entityManager->flush();

        return $this->json([
            'success' => true,
            'message' => 'Emplacement créé avec succès',
            'data' => $location->toArray()
        ], Response::HTTP_CREATED);
    }

    /**
     * Met à jour un emplacement
     */
    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(int $id, Request $request): JsonResponse
    {
        $location = $this->locationRepository->find($id);

        if (!$location) {
            return $this->json([
                'success' => false,
                'message' => 'Emplacement non trouvé'
            ], Response::HTTP_NOT_FOUND);
        }

        $data = json_decode($request->getContent(), true);
        $this->hydrate($location, $data);

        $errors = $this->validator->validate($location);
        if (count($errors) > 0) {
            return $this->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $this->formatErrors($errors)
            ], Response::HTTP_BAD_REQUEST);
        }

        $this->entityManager->flush();

        return $this->json([
            'success' => true,
            'message' => 'Emplacement mis à jour avec succès',
            'data' => $location->toArray()
        ]);
    }

    /**
     * Supprime un emplacement
     */
    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(int $id): JsonResponse
    {
        $location = $this->locationRepository->find($id);

        if (!$location) {
            return $this->json([
                'success' => false,
                'message' => 'Emplacement non trouvé'
            ], Response::HTTP_NOT_FOUND);
        }

        $this->entityManager->remove($location);
        $this->entityManager->flush();

        return $this->json([
            'success' => true,
            'message' => 'Emplacement supprimé avec succès'
        ]);
    }

    /**
     * Hydrate l'entité avec les données
     */
    private function hydrate(Location $location, array $data): void
    {
        if (isset($data['name'])) {
            $location->setName($data['name']);
        }
        if (isset($data['description'])) {
            $location->setDescription($data['description']);
        }
        if (isset($data['latitude'])) {
            $location->setLatitude((string) $data['latitude']);
        }
        if (isset($data['longitude'])) {
            $location->setLongitude((string) $data['longitude']);
        }
        if (isset($data['category'])) {
            $location->setCategory($data['category']);
        }
        if (isset($data['address'])) {
            $location->setAddress($data['address']);
        }
        if (isset($data['phone'])) {
            $location->setPhone($data['phone']);
        }
        if (isset($data['email'])) {
            $location->setEmail($data['email']);
        }
        if (isset($data['website'])) {
            $location->setWebsite($data['website']);
        }
        if (isset($data['image'])) {
            $location->setImage($data['image']);
        }
        if (isset($data['isActive'])) {
            $location->setIsActive((bool) $data['isActive']);
        }
        if (isset($data['userId'])) {
            $location->setUserId((int) $data['userId']);
        }
    }

    /**
     * Formate les erreurs de validation
     */
    private function formatErrors($errors): array
    {
        $formatted = [];
        foreach ($errors as $error) {
            $formatted[$error->getPropertyPath()][] = $error->getMessage();
        }
        return $formatted;
    }
}
