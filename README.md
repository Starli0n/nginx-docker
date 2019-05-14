# nginx-registry

## Install

Prerequisite: Install the [reverse proxy](https://github.com/Starli0n/nginx-proxy)

```sh
> git clone https://github.com/Starli0n/nginx-registry
> cd nginx-registry
> make env
> make init
```

## Configure

- Customize the `.env` file

## Usage

### Development

- Start the server
```
# Shortcut for docker-compose -f docker-compose.yml -f docker-compose.override.yml up
> docker-compose up
```
- Stop the server
```
# Shortcut for docker-compose -f docker-compose.yml -f docker-compose.override.yml down
> docker-compose down
```

### Production

In production, the reverse proxy should be started as well.

- Start the server
```
# docker-compose -f docker-compose.yml -f up -d
> make up
```
- Stop the server
```
# docker-compose -f docker-compose.yml -f down
> make down
```

- `https://registry.example.com` should respond

## Debug

- Explore the `registry` container
```
# docker exec -it nginx-registry /bin/bash
make shell
```
