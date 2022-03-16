# Docker container for the [GameArch videogame collection tool](https://github.com/Cryptec/GameArch)

## Using the container

To start the container you need to supply the necessary environment variables. `REACT_APP_SITE_URL` and `REACT_APP_API_ENDPOINT` have to match. For this example let's assume your docker host's IP is **192.168.1.10**, then your `REACT_APP_SITE_URL` would be **http://192.168.1.10:8080** and `REACT_APP_API_ENDPOINT` should be identical. This is because both services run in the same container with the same IP address.

Additionally, make sure `BACKEND_URL` and `CORS_ORIGIN` of the backend environment variables match the frontend values.

It's advised to mount a `/data/db` volume to preserve the database between container restarts. It can be a named volume, e.g. `db:` (`-v db:/data/db`).

The preferred way to start the container is with a `docker-compose.yaml` file. This has the advantage of a single `.env` file that contains all backend and frontend variables. An example `.env` file is included in the `build` directory (`.env.example`). Create some default values for `JWT_SECRET` and `SALT`, for example using a password generator. You could also use those of the example file in the [main repository](https://github.com/Cryptec/GameArch/blob/main/Backend/.env.example).

```yaml
version: "3.7"

services:
  gamearch:
    image: quay.io/ckoenig/gamearch:0.8.5
    container_name: gamearch
    restart: unless-stopped
    ports:
      - 8080:8080
    volumes:
      - db:/data/db
    env_file:
      - .env

volumes:
  db:
```

Start the container with:

```bash
docker-compose up -d
```

It's also possible to run the container without docker-compose. In this case it would be best to mount a backend `.env` file to prevent sensitive environment values like the password to show up in your shell history. You can find an example `.env.backend` file in the `build` directory.

Before you can start it you will need to pull the image from the registry:

```bash
docker pull quay.io/ckoenig/gamearch:0.8.5
```

Then start it with the following command (replacing the path to `.env.backend` and the URLs):

```bash
docker run -it -d \
    --name=gamearch \
    -e REACT_APP_SITE_URL=http://192.168.1.10:8080 \
    -e REACT_APP_API_ENDPOINT=http://192.168.1.10:8080 \
    -v /path/to/.env.backend:/data/.env \
    -v gamearch_db:/data/db \
    -p 8080:8080 \
    quay.io/ckoenig/gamearch:0.8.5
```

You can then access GameArch at **http://192.168.1.10:8080**.

## Building your own containers

To build your own container you can use the script `build.sh`. Before executing the script you should take a look at it and also rename the `.env.frontend.example` file in the `build` directory to `.env.frontend`.

Building the container is the only way to change the supported platforms at the moment since the `platform.js` file is only read once during build time. This is not strictly necessary however, since you can still enter platforms not included in the file. You just won't get suggestions.

## Security considerations

This container is intended to run in a local environment only, meaning your client, a NAS or other server in your local network. It is **not** recommended to run it directly on the internet, like a VPS. You will need to setup your own environment if you wish to do so.