<?php

namespace App\Repository;

use App\Entity\Location;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Location>
 */
class LocationRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Location::class);
    }

    /**
     * Trouver les emplacements actifs
     */
    public function findActive(): array
    {
        return $this->createQueryBuilder('l')
            ->andWhere('l.isActive = :active')
            ->setParameter('active', true)
            ->orderBy('l.createdAt', 'DESC')
            ->getQuery()
            ->getResult();
    }

    /**
     * Trouver les emplacements par catégorie
     */
    public function findByCategory(string $category): array
    {
        return $this->createQueryBuilder('l')
            ->andWhere('l.category = :category')
            ->andWhere('l.isActive = :active')
            ->setParameter('category', $category)
            ->setParameter('active', true)
            ->orderBy('l.createdAt', 'DESC')
            ->getQuery()
            ->getResult();
    }

    /**
     * Rechercher les emplacements par nom ou description
     */
    public function search(string $query): array
    {
        return $this->createQueryBuilder('l')
            ->andWhere('l.name LIKE :query OR l.description LIKE :query')
            ->andWhere('l.isActive = :active')
            ->setParameter('query', '%' . $query . '%')
            ->setParameter('active', true)
            ->orderBy('l.createdAt', 'DESC')
            ->getQuery()
            ->getResult();
    }

    /**
     * Trouver les emplacements dans un rayon (en km)
     * Note: Pour une recherche plus précise, utilisez PostGIS
     */
    public function findNearby(float $latitude, float $longitude, float $radius = 10): array
    {
        // Approximation simple (pour une recherche précise, utiliser PostGIS)
        $latDelta = $radius / 111; // 1 degré de latitude ≈ 111 km
        $lonDelta = $radius / (111 * cos(deg2rad($latitude)));

        return $this->createQueryBuilder('l')
            ->andWhere('l.latitude BETWEEN :minLat AND :maxLat')
            ->andWhere('l.longitude BETWEEN :minLon AND :maxLon')
            ->andWhere('l.isActive = :active')
            ->setParameter('minLat', $latitude - $latDelta)
            ->setParameter('maxLat', $latitude + $latDelta)
            ->setParameter('minLon', $longitude - $lonDelta)
            ->setParameter('maxLon', $longitude + $lonDelta)
            ->setParameter('active', true)
            ->getQuery()
            ->getResult();
    }
}
