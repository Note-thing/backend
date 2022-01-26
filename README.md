# Backend
## Introduction
Cette application a été développée en [Ruby](https://www.ruby-lang.org/en/) et plus précisemment via le framework [Ruby on rails (RoR)](https://rubyonrails.org/).
Le but de cette application est de fournir une API qui s'inspire de la norme RESTful permettant à [l'application frontend de Note-thing](https://github.com/Note-thing/frontend) d'accéder aux données persistantes.

## Commencer 🏁
### Pré-requis
- [Docker engine](https://docs.docker.com/engine/install/) : *20.10.**
- [Docker compose](https://docs.docker.com/compose/install/) 
  - *NOTE: docker compose est inclus dans les installation de l'engine sur Windows et MacOS*.

### Installation
1. Cloner le repository
```bash
git clone https://github.com/Note-thing/backend && cd backend
```

2. Lancer le conteneur Docker 
```bash
docker-compose up
```
3. Créez un fichier `.env`, et mettez y la variable d'environnement `JWT_SECRET='example'`. Vous pouvez vous inspirer de `.env.example` ou le remplacer ! 
```
mv .env.example .env
```
Veillez à avoir une configuration gmail présente dans le `.env`, via les variables `EMAIl=example@gmail.com` et `EMAIL_PASSWORD=password`.  
Pour résumer, le fichier `.env` doit contenir les informations suivantes : 
```
JWT_SECRET='whateverYouWant'
EMAIL='example@gmail.com'
EMAIL_PASSWORD='password'
```

4. Allez à l'adresse [localhost:3001](http://localhost:3001/) et vous voilà prêt à contribuer 😎. 

### Se connecter au container Docker
```bash
docker exec -it backend_app_1 /bin/bash
```
Vous pouvez ensuite intéragir avec rails via le docker.

### Quelques commandes utiles
**Créer la db**
```bash
rails db:create
```

**Lancer les migrations**
```bash
rails db:migrate
```

**Lancer les [seeds](db/seeds.rb)**
```bash
rails db:seed
```

**Lancer le serveur**
```bash
rails s
```

**Afficher les routes disponible**
```bash
rake routes
```

## Considérations techniques
Vous trouverez sur notre wiki les éléments suivants : 
- [les endpoints de l'API](https://github.com/Note-thing/backend/wiki/Mod%C3%A8le-de-domaine)
- [Les routes disponibles](https://github.com/Note-thing/backend/wiki/Routes)
- [notre CI/CD](https://github.com/Note-thing/backend/wiki/CI---CD)
- [notre convention de nommage](https://github.com/Note-thing/backend/wiki/Conventions-de-nommage)

## Comment contibuer ?
Note-thing est un projet réalisé par des étudiants en ingénieurie logiciel. Nous sommes ouverts aux avis d'experts.
Vous trouverez un [guide de contribution](CONTRIBUTING.md) qui définit quelques points clefs pour contribuer au projet.

### Fondateurs
<a href="https://github.com/note-thing/backend/graphs/contributors">
<img src="https://contrib.rocks/image?repo=note-thing/backend" />
</a>

[Contactez-nous par email](note-thing@protonmail.ch)

### License
Notre projet utilise la [License apache](LICENSE).

