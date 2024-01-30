# Project description

Application to view websites in text-only mode

## Mix commands

Start Phoenix dev server on port 4000. Database service required.

```
mix phx.server
```

## Docker commands

**With Docker and Docker-compose installed you can run these commands**

Start container with Phoenix dev server on port 4000

```
docker-compose up
```

Run the database service in the background

```
docker-compose up -d database
```

Run commands manually inside throwaway container

```
docker-compose run --rm -p 4000:4000 elixir bash
```

## Deployment instructions for Render.com

See build.sh for build steps

**Environment Variables**

Generate secret

```
mix phx.gen.secret
```

Add secret to environment variables

SECRET_KEY_BASE: 'generated secret'