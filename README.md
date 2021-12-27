# Backend

## Commencer 🏁
### Pré-requis
- [Docker engine](https://docs.docker.com/engine/install/) : *20.10.**
- [Docker compose](https://docs.docker.com/compose/install/) 
  - *NOTE: docker compose est inclus dans les installation de l'engine sur Windows et MacOS*.

### Installation
1. Cloner le répository
```bash
git clone https://github.com/Note-thing/backend && cd backend
```

2. Lancer le conteneur Docker 
```bash
docker-compose up
```
3. Créez un fichier `.env`, et y mettre la variable d'environnement `JWT_SECRET='example''`. Vous pouvez vous inspirer de `.env.example`, ou le copier ! 
```
mv .env.example .env
```

4. Allez à l'adresse [localhost:3001](http://localhost:3001/) et vous voilà prêt à contribuer 😎. 

`

### Se connecter au container Docker
```bash
docker exec -it backend_app_1 /bin/bash
```