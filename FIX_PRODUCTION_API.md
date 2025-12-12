# 🔧 Solution au problème API en production

## ❌ Problème actuel

**Symptôme** :
- En local: `/api/login` retourne du JSON ✅
- En production: `/api/login` retourne du HTML (index.html) ❌

**Réponse en production** :
```html
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8" />
    <title>Smart Stock - Gestion de Stock</title>
    <script type="module" crossorigin src="/assets/index-BCKJjv3M.js"></script>
    <link rel="stylesheet" crossorigin href="/assets/index-BdfkkVsh.css">
</head>
<body>
    <div id="app"></div>
</body>
</html>
```

## 🔍 Cause

Le serveur web (Nginx/Apache) en production **ne route PAS** les requêtes `/api/*` vers le backend Symfony. À la place, il sert le fichier `index.html` du frontend Vue.js.

---

## ✅ SOLUTION RAPIDE (Nginx)

### Option 1 : Si vous utilisez Nginx

1. **Modifiez votre configuration Nginx** :

```bash
sudo nano /etc/nginx/sites-available/votre-site
```

2. **Ajoutez cette section AVANT** la configuration du frontend :

```nginx
server {
    listen 80;
    server_name votre-domaine.com;

    # ⭐ AJOUTER CETTE SECTION EN PREMIER
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # CORS
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Requested-With' always;

        if ($request_method = 'OPTIONS') {
            return 204;
        }
    }

    # Frontend Vue.js (APRÈS la section API)
    location / {
        root /var/www/html;
        try_files $uri $uri/ /index.html;
    }
}
```

3. **Testez et redémarrez** :

```bash
# Tester la config
sudo nginx -t

# Redémarrer
sudo systemctl restart nginx
```

4. **Assurez-vous que le backend Symfony tourne** :

```bash
# Vérifier
curl http://localhost:8000/api/login

# Si ça ne fonctionne pas, démarrer Symfony
cd backend
symfony server:start --port=8000 --daemon
```

---

## ✅ SOLUTION RAPIDE (Apache)

### Option 2 : Si vous utilisez Apache

1. **Créez/modifiez le fichier `.htaccess`** dans le dossier racine :

```bash
sudo nano /var/www/html/.htaccess
```

2. **Ajoutez ce contenu** :

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On

    # ⭐ Proxy les requêtes /api/* vers Symfony
    RewriteCond %{REQUEST_URI} ^/api/
    RewriteRule ^api/(.*)$ http://localhost:8000/api/$1 [P,L]

    # Frontend Vue.js - tout le reste
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ /index.html [L]
</IfModule>

# CORS
<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With"
</IfModule>
```

3. **Activez les modules nécessaires** :

```bash
sudo a2enmod rewrite
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod headers
sudo systemctl restart apache2
```

4. **Vérifiez que mod_proxy est activé** :

```bash
apache2ctl -M | grep proxy
```

---

## 🧪 TESTS

### 1. Tester directement le backend

```bash
# Doit retourner du JSON
curl http://localhost:8000/api/login

# Si erreur, le backend ne tourne pas
cd backend
symfony server:start --port=8000 --daemon
```

### 2. Tester via le domaine

```bash
# Doit retourner du JSON, PAS du HTML
curl https://votre-domaine.com/api/login

# Avec headers pour debug
curl -v https://votre-domaine.com/api/login
```

### 3. Test depuis le navigateur

Ouvrez la console développeur (F12) et testez :

```javascript
fetch('/api/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username: 'test', password: 'test' })
})
.then(r => r.json())
.then(data => console.log(data))
```

✅ **Résultat attendu** : Objet JSON avec les données utilisateur
❌ **Résultat actuel** : HTML de la page index.html

---

## 🔍 DIAGNOSTIC

Si ça ne fonctionne toujours pas :

### 1. Vérifier les logs Nginx

```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### 2. Vérifier les logs Apache

```bash
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/log/apache2/access.log
```

### 3. Vérifier que le backend tourne

```bash
# Processus Symfony
ps aux | grep symfony

# Port 8000 en écoute
sudo netstat -tlnp | grep 8000

# Ou avec ss
sudo ss -tlnp | grep 8000
```

### 4. Tester le proxy

```bash
# Doit montrer que la requête passe par le proxy
curl -v http://localhost/api/login 2>&1 | grep -i proxy
```

---

## 📝 CHECKLIST

- [ ] Configuration serveur web modifiée (Nginx ou Apache)
- [ ] Module proxy activé (Apache uniquement)
- [ ] Backend Symfony tourne sur port 8000
- [ ] `curl http://localhost:8000/api/login` retourne du JSON
- [ ] `curl http://votre-domaine.com/api/login` retourne du JSON
- [ ] Serveur web redémarré
- [ ] CORS configuré
- [ ] Logs vérifiés (pas d'erreur)

---

## 🆘 SI ÇA NE FONCTIONNE TOUJOURS PAS

### Solution alternative : Servir Symfony et Vue.js séparément

Au lieu de proxy, servez le backend sur un sous-domaine :

1. **Backend** : `api.votre-domaine.com` → Pointe vers Symfony
2. **Frontend** : `votre-domaine.com` → Pointe vers Vue.js

Modifiez le fichier `.env` du frontend :

```bash
# frontend/.env
VITE_API_URL=https://api.votre-domaine.com/api
```

Configuration Nginx pour le backend :

```nginx
server {
    listen 80;
    server_name api.votre-domaine.com;
    root /var/www/backend/public;

    location / {
        try_files $uri /index.php$is_args$args;
    }

    location ~ ^/index\.php(/|$) {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    }
}
```

---

## 📞 Contact

Si le problème persiste, envoyez-moi :
1. Votre configuration serveur web actuelle
2. Les logs d'erreur
3. Le résultat de `curl -v http://localhost:8000/api/login`
4. Le résultat de `curl -v https://votre-domaine.com/api/login`
