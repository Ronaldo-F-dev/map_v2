#!/bin/bash

# Script de déploiement automatique
# Usage: ./deploy.sh [production|staging]

set -e

ENV=${1:-production}
echo "🚀 Déploiement en mode: $ENV"

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
FRONTEND_BUILD_DIR="frontend/dist"
BACKEND_DIR="backend"
WEB_ROOT="/var/www/html"
BACKEND_ROOT="/var/www/backend"

echo -e "${YELLOW}📦 Étape 1: Build du frontend...${NC}"
cd frontend
npm install
npm run build
echo -e "${GREEN}✅ Frontend build terminé${NC}"

echo -e "${YELLOW}📦 Étape 2: Déploiement des fichiers frontend...${NC}"
if [ -d "$WEB_ROOT" ]; then
    sudo cp -r dist/* $WEB_ROOT/
    echo -e "${GREEN}✅ Fichiers frontend déployés dans $WEB_ROOT${NC}"
else
    echo -e "${RED}❌ Erreur: $WEB_ROOT n'existe pas${NC}"
    exit 1
fi

cd ..

echo -e "${YELLOW}📦 Étape 3: Configuration du backend...${NC}"
cd backend

# Installer les dépendances
composer install --no-dev --optimize-autoloader

# Vider le cache
php bin/console cache:clear --env=prod

# Exécuter les migrations
php bin/console doctrine:migrations:migrate --no-interaction

echo -e "${GREEN}✅ Backend configuré${NC}"

cd ..

echo -e "${YELLOW}🔧 Étape 4: Configuration du serveur web...${NC}"

# Détecter le serveur web
if command -v nginx &> /dev/null; then
    echo "Nginx détecté"

    # Copier la configuration Nginx
    if [ -f "deployment/nginx/site.conf" ]; then
        sudo cp deployment/nginx/site.conf /etc/nginx/sites-available/app
        sudo ln -sf /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app

        # Tester la configuration
        sudo nginx -t

        # Redémarrer Nginx
        sudo systemctl restart nginx
        echo -e "${GREEN}✅ Nginx configuré et redémarré${NC}"
    fi

elif command -v apache2 &> /dev/null; then
    echo "Apache détecté"

    # Copier le .htaccess
    if [ -f "deployment/apache/.htaccess" ]; then
        sudo cp deployment/apache/.htaccess $WEB_ROOT/

        # Activer les modules
        sudo a2enmod rewrite proxy proxy_http headers expires

        # Redémarrer Apache
        sudo systemctl restart apache2
        echo -e "${GREEN}✅ Apache configuré et redémarré${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Aucun serveur web détecté. Configuration manuelle requise.${NC}"
fi

echo -e "${YELLOW}🔧 Étape 5: Démarrage du backend Symfony...${NC}"

# Démarrer le serveur Symfony en arrière-plan
cd backend
symfony server:start --port=8000 --daemon || php -S localhost:8000 -t public &

echo -e "${GREEN}✅ Backend Symfony démarré${NC}"

cd ..

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Déploiement terminé avec succès !${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}📋 Prochaines étapes:${NC}"
echo "1. Testez l'API: curl http://localhost/api/locations"
echo "2. Ouvrez votre navigateur: http://votre-domaine.com"
echo "3. Vérifiez les logs: sudo tail -f /var/log/nginx/error.log"
echo ""
echo -e "${YELLOW}🔐 Pour activer HTTPS:${NC}"
echo "sudo certbot --nginx -d votre-domaine.com"
