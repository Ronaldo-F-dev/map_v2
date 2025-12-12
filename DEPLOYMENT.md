# 🚀 Guide de déploiement en production

Ce guide explique comment déployer l'application en production avec Nginx ou Apache.

## 🔍 Problème rencontré

**Symptôme** : Les requêtes API retournent du HTML au lieu de JSON en production

**Cause** : Le serveur web ne route pas correctement les requêtes `/api/*` vers le backend Symfony

**Solution** : Configurer le serveur web pour proxy les requêtes API vers Symfony

---

## 📋 Architecture en production

```
┌─────────────────────────────────────────┐
│  Serveur Web (Nginx/Apache)             │
│  Port 80/443                             │
├──────────────────┬──────────────────────┤
│  /api/*  →       │  /*  →               │
│  Backend Symfony │  Frontend Vue.js     │
│  (port 8000)     │  (fichiers statiques)│
└──────────────────┴──────────────────────┘
```

---

## 🔧 Option 1 : Déploiement avec Nginx (Recommandé)

### Étape 1 : Build du frontend

```bash
cd frontend
npm install
npm run build

# Les fichiers de production seront dans frontend/dist/
```

### Étape 2 : Déployer les fichiers

```bash
# Copier les fichiers frontend vers le répertoire web
sudo cp -r frontend/dist/* /var/www/html/

# Vérifier que le backend Symfony est accessible
cd backend
php bin/console cache:clear --env=prod
```

### Étape 3 : Configuration Nginx

Créez un fichier de configuration :

```bash
sudo nano /etc/nginx/sites-available/votre-app
```

Copiez le contenu de `deployment/nginx/site.conf` et modifiez :
- `server_name` avec votre domaine
- `root` avec le chemin vers vos fichiers frontend
- `proxy_pass` si votre backend Symfony n'est pas sur le port 8000

```nginx
server {
    listen 80;
    server_name votre-domaine.com;
    root /var/www/html;

    # Routes API vers Symfony
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Frontend Vue.js
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### Étape 4 : Activer et redémarrer Nginx

```bash
# Activer le site
sudo ln -s /etc/nginx/sites-available/votre-app /etc/nginx/sites-enabled/

# Tester la configuration
sudo nginx -t

# Redémarrer Nginx
sudo systemctl restart nginx
```

### Étape 5 : Démarrer le backend Symfony

Option A - Avec Symfony CLI (développement) :
```bash
cd backend
symfony server:start --port=8000 --daemon
```

Option B - Avec PHP-FPM (production recommandé) :
```bash
# Configurer PHP-FPM dans Nginx
# Voir section "Backend avec PHP-FPM" ci-dessous
```

---

## 🔧 Option 2 : Déploiement avec Apache

### Étape 1 : Build du frontend

```bash
cd frontend
npm install
npm run build
```

### Étape 2 : Déployer les fichiers

```bash
# Copier les fichiers vers le DocumentRoot Apache
sudo cp -r frontend/dist/* /var/www/html/

# Copier le .htaccess
sudo cp deployment/apache/.htaccess /var/www/html/
```

### Étape 3 : Activer les modules Apache nécessaires

```bash
sudo a2enmod rewrite
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod headers
sudo a2enmod expires
sudo systemctl restart apache2
```

### Étape 4 : Configuration VirtualHost

Créez ou modifiez votre VirtualHost :

```bash
sudo nano /etc/apache2/sites-available/000-default.conf
```

Ajoutez :

```apache
<VirtualHost *:80>
    ServerName votre-domaine.com
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>

    # Proxy pour les requêtes API
    ProxyPass /api http://localhost:8000/api
    ProxyPassReverse /api http://localhost:8000/api

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

### Étape 5 : Redémarrer Apache

```bash
sudo systemctl restart apache2
```

---

## 🐘 Backend avec PHP-FPM (Production)

Pour production, utilisez PHP-FPM au lieu du serveur Symfony :

### Nginx + PHP-FPM

```nginx
server {
    listen 80;
    server_name votre-domaine.com;
    root /var/www/html;

    # Backend Symfony
    location /api/ {
        root /var/www/backend/public;
        try_files $uri /index.php$is_args$args;

        location ~ ^/api/index\.php(/|$) {
            fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
            fastcgi_split_path_info ^(.+\.php)(/.*)$;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
            fastcgi_param DOCUMENT_ROOT $realpath_root;
            internal;
        }
    }

    # Frontend Vue.js
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

Installation PHP-FPM :

```bash
sudo apt install php8.2-fpm php8.2-mysql php8.2-xml php8.2-curl
sudo systemctl start php8.2-fpm
```

---

## 🔐 HTTPS avec Let's Encrypt

### Installation Certbot

```bash
sudo apt install certbot python3-certbot-nginx
```

### Obtenir un certificat SSL

```bash
# Pour Nginx
sudo certbot --nginx -d votre-domaine.com

# Pour Apache
sudo certbot --apache -d votre-domaine.com
```

Certbot configurera automatiquement HTTPS et la redirection HTTP → HTTPS.

---

## 🐳 Option 3 : Déploiement avec Docker

Créez un `docker-compose.yml` :

```yaml
version: '3.8'

services:
  # Backend Symfony
  backend:
    image: php:8.2-fpm
    working_dir: /var/www/backend
    volumes:
      - ./backend:/var/www/backend
    expose:
      - "9000"

  # Nginx
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./frontend/dist:/var/www/html
      - ./backend:/var/www/backend
      - ./deployment/nginx/site.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - backend

  # Base de données
  database:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: benin_map
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
```

Démarrage :

```bash
docker-compose up -d
```

---

## 🧪 Tests après déploiement

### 1. Tester l'API

```bash
# Test endpoint API
curl https://votre-domaine.com/api/locations

# Devrait retourner du JSON, pas du HTML !
```

### 2. Tester le frontend

Ouvrez `https://votre-domaine.com` dans votre navigateur et testez :
- ✅ La carte s'affiche
- ✅ Vous pouvez ajouter un emplacement
- ✅ Les requêtes API fonctionnent

### 3. Vérifier les logs

```bash
# Nginx
sudo tail -f /var/log/nginx/error.log

# Apache
sudo tail -f /var/log/apache2/error.log

# Symfony
tail -f backend/var/log/prod.log
```

---

## ⚠️ Checklist de sécurité

- [ ] HTTPS activé (Let's Encrypt)
- [ ] Fichiers `.env` sécurisés (pas accessible via web)
- [ ] Base de données avec mot de passe fort
- [ ] `APP_ENV=prod` dans `.env` (Symfony)
- [ ] Cache Symfony vidé après déploiement
- [ ] Permissions correctes (755 pour dossiers, 644 pour fichiers)
- [ ] Firewall configuré (ports 80, 443 ouverts)
- [ ] CORS configuré correctement
- [ ] Rate limiting activé (optionnel)

---

## 🔧 Dépannage

### Problème : API retourne HTML au lieu de JSON

**Cause** : Le serveur web ne route pas `/api/*` vers Symfony

**Solution** :
1. Vérifiez la configuration Nginx/Apache
2. Vérifiez que le backend Symfony tourne (port 8000)
3. Testez directement : `curl http://localhost:8000/api/locations`

### Problème : Erreur 502 Bad Gateway

**Cause** : Le backend Symfony n'est pas accessible

**Solution** :
1. Vérifiez que Symfony tourne : `ps aux | grep php`
2. Vérifiez les logs : `tail -f backend/var/log/prod.log`
3. Redémarrez PHP-FPM : `sudo systemctl restart php8.2-fpm`

### Problème : CORS errors

**Cause** : CORS mal configuré

**Solution** :
1. Vérifiez `backend/config/packages/nelmio_cors.yaml`
2. Ajoutez les headers CORS dans Nginx/Apache
3. Videz le cache : `php bin/console cache:clear --env=prod`

---

## 📞 Support

Pour plus d'aide, consultez :
- [Documentation Nginx](https://nginx.org/en/docs/)
- [Documentation Apache](https://httpd.apache.org/docs/)
- [Documentation Symfony Deployment](https://symfony.com/doc/current/deployment.html)

---

**Note** : Ce guide suppose que vous utilisez Ubuntu/Debian. Adaptez les commandes selon votre système d'exploitation.
