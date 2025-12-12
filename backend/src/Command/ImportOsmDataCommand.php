<?php

namespace App\Command;

use App\Entity\Location;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

#[AsCommand(
    name: 'app:import-osm-data',
    description: 'Importe les données OSM dans la base de données',
)]
class ImportOsmDataCommand extends Command
{
    private EntityManagerInterface $entityManager;

    public function __construct(EntityManagerInterface $entityManager)
    {
        parent::__construct();
        $this->entityManager = $entityManager;
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new SymfonyStyle($input, $output);

        $io->title('Import des données OSM du Bénin');

        // Chemin vers le fichier OSM
        $osmFile = dirname(__DIR__, 3) . '/benin.osm.pbf';

        if (!file_exists($osmFile)) {
            $io->error("Fichier OSM non trouvé: $osmFile");
            return Command::FAILURE;
        }

        $io->info("Fichier OSM trouvé: $osmFile");
        $io->info("Extraction des POIs (Points d'Intérêt)...");

        // Extraire les POIs en JSON avec osmium
        $tempJson = sys_get_temp_dir() . '/benin_pois.json';

        // Commande osmium pour extraire les nodes avec des tags intéressants
        $cmd = sprintf(
            'osmium tags-filter %s nwr/amenity nwr/tourism nwr/shop nwr/leisure nwr/healthcare -o %s -f osm',
            escapeshellarg($osmFile),
            escapeshellarg($tempJson . '.osm')
        );

        exec($cmd, $cmdOutput, $returnCode);

        if ($returnCode !== 0) {
            $io->warning("Osmium filter a retourné le code: $returnCode");
        }

        // Convertir en JSON
        $cmd2 = sprintf(
            'osmium export %s -o %s -f geojson',
            escapeshellarg($tempJson . '.osm'),
            escapeshellarg($tempJson)
        );

        exec($cmd2, $cmdOutput2, $returnCode2);

        if ($returnCode2 !== 0) {
            $io->error("Erreur lors de l'export GeoJSON");
            return Command::FAILURE;
        }

        if (!file_exists($tempJson)) {
            $io->error("Fichier JSON temporaire non créé");
            return Command::FAILURE;
        }

        // Lire le GeoJSON
        $geoJson = json_decode(file_get_contents($tempJson), true);

        if (!$geoJson || !isset($geoJson['features'])) {
            $io->error("Format GeoJSON invalide");
            return Command::FAILURE;
        }

        $io->info(sprintf("Trouvé %d POIs", count($geoJson['features'])));

        // Nettoyer la table avant import
        $io->info("Nettoyage de la table locations...");
        $this->entityManager->createQuery('DELETE FROM App\Entity\Location')->execute();

        $imported = 0;
        $batchSize = 100;

        $io->progressStart(count($geoJson['features']));

        foreach ($geoJson['features'] as $feature) {
            $properties = $feature['properties'] ?? [];
            $geometry = $feature['geometry'] ?? null;

            if (!$geometry || $geometry['type'] !== 'Point') {
                continue;
            }

            $coords = $geometry['coordinates'];
            $lon = $coords[0];
            $lat = $coords[1];

            // Créer la location
            $location = new Location();

            // Nom
            $name = $properties['name'] ?? $properties['name:fr'] ?? $properties['name:en'] ?? null;
            if (!$name) {
                $name = $this->generateNameFromTags($properties);
            }

            if (!$name) {
                continue; // Skip si pas de nom
            }

            $location->setName($name);
            $location->setLatitude((string)$lat);
            $location->setLongitude((string)$lon);

            // Catégorie
            $category = $this->determineCategory($properties);
            $location->setCategory($category);

            // Description
            $description = $this->generateDescription($properties);
            $location->setDescription($description);

            // Autres champs
            $location->setAddress($properties['addr:street'] ?? null);
            $location->setPhone($properties['phone'] ?? $properties['contact:phone'] ?? null);
            $location->setWebsite($properties['website'] ?? $properties['contact:website'] ?? null);
            $location->setIsActive(true);
            $location->setUserId(1); // Système

            $this->entityManager->persist($location);

            $imported++;

            if ($imported % $batchSize === 0) {
                $this->entityManager->flush();
                $this->entityManager->clear();
            }

            $io->progressAdvance();
        }

        // Flush final
        $this->entityManager->flush();
        $io->progressFinish();

        // Nettoyage
        @unlink($tempJson);
        @unlink($tempJson . '.osm');

        $io->success(sprintf('Import terminé ! %d locations importées.', $imported));

        return Command::SUCCESS;
    }

    private function generateNameFromTags(array $properties): ?string
    {
        $amenity = $properties['amenity'] ?? null;
        $tourism = $properties['tourism'] ?? null;
        $shop = $properties['shop'] ?? null;

        if ($amenity) return ucfirst(str_replace('_', ' ', $amenity));
        if ($tourism) return ucfirst(str_replace('_', ' ', $tourism));
        if ($shop) return ucfirst(str_replace('_', ' ', $shop)) . ' shop';

        return null;
    }

    private function determineCategory(array $properties): string
    {
        if (isset($properties['amenity'])) {
            $amenity = $properties['amenity'];
            if (in_array($amenity, ['restaurant', 'cafe', 'fast_food', 'bar', 'pub'])) {
                return 'restaurant';
            }
            if (in_array($amenity, ['hotel', 'hostel', 'guest_house'])) {
                return 'hotel';
            }
            if (in_array($amenity, ['hospital', 'clinic', 'doctors', 'pharmacy'])) {
                return 'health';
            }
            if (in_array($amenity, ['school', 'university', 'college', 'library'])) {
                return 'education';
            }
            if (in_array($amenity, ['bank', 'atm', 'bureau_de_change'])) {
                return 'finance';
            }
            if (in_array($amenity, ['fuel', 'charging_station'])) {
                return 'fuel';
            }
            if (in_array($amenity, ['parking', 'parking_space'])) {
                return 'parking';
            }
        }

        if (isset($properties['tourism'])) {
            return 'tourism';
        }

        if (isset($properties['shop'])) {
            return 'shop';
        }

        if (isset($properties['leisure'])) {
            return 'leisure';
        }

        return 'other';
    }

    private function generateDescription(array $properties): ?string
    {
        $parts = [];

        if (isset($properties['amenity'])) {
            $parts[] = 'Type: ' . ucfirst(str_replace('_', ' ', $properties['amenity']));
        }

        if (isset($properties['tourism'])) {
            $parts[] = 'Tourisme: ' . ucfirst(str_replace('_', ' ', $properties['tourism']));
        }

        if (isset($properties['opening_hours'])) {
            $parts[] = 'Horaires: ' . $properties['opening_hours'];
        }

        if (isset($properties['cuisine'])) {
            $parts[] = 'Cuisine: ' . $properties['cuisine'];
        }

        return empty($parts) ? null : implode(' | ', $parts);
    }
}