# Backend
## Introduction

## Considérations techniques

## Commencer 🏁
### Pré-requis
- [Docker engine](https://docs.docker.com/engine/install/) : *20.10.**
- [Docker compose](https://docs.docker.com/compose/install/) 
  - *NOTE: docker compose est inclus dans les installation de l'engine sur Windows et MacOS*.
- []()

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
Afin d'envoyer des mails de reset de mot de passe, nous utilisons `gmail`. Veillez à avoir une configuration gmail présente dans le `.env`, via les variables `EMAIl=example@gmail.com` et `EMAIL_PASSWORD=password`.

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

**Lancer les tests**
```bash
rails spec
```

## Comment contibuer ?
1. Commencez par récupérer la dernière version du code (branche main)
2. Ouvrir une issue expliquant ce que vous-voulez améliorer / fixer ou en reprendre une existante
3. Créer une nouvelle branche à partir de main
4. Faire vos changements
5. Ouvrez une pull-request afin de merge vos changement, mentionnez la / les issues concernées
6. Assurez-vous que la pull-request passe les tests automatisés et attendez que quelqu'un donne une review
7. Une fois que le point 6 est passé, vous pouvez merge votre pull-request dans main
8. Youpi vous avez fait une contribution au projet
