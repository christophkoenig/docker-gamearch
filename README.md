# Docker container for the [GameArch videogame collection tool](https://github.com/Cryptec/GameArch)

## Using the container

Before doing anything else you should pull the container from the registry:

```bash
docker pull quay.io/ckoenig/gamearch:latest
```

Start by copying the `.env` file from `build` and open it with your favorite editor. 

```bash
cp build/.env.example .env
vim .env
```

You will need to change some values before you can run the container. At the very least you need to set the IP address of your docker host, i.e. `localhost` if you want to run it on your computer, or the IP address of your NAS if you want to run it on your NAS. You can keep the default values of the mail settings if you don't want to send emails.

Here's a full example. Just replace `localhost` if you intend to run it somewhere else in your network, and the port (`8099`) if it's already in use (it probably won't be).

```
REACT_APP_SITE_URL=http://localhost:8099
REACT_APP_API_ENDPOINT=http://localhost:8099
MAIL_HOST=""
MAIL_PORT=
MAIL_EMAIL=""
MAIL_PASSWORD=""
MAIL_ENCRYPTION=null
SALT=GXncYmMtRUb2N5E9
CORS_ORIGIN=http://localhost:8099
JWT_SECRET=3S2XuThMLuLnxkAV
BACKEND_URL=http://localhost:8099
ADMIN_EMAIL=admin@gamearch.local
INITIAL_ADMIN_PASSWORD=yo9wGTqK
```

Finally, start your container (and add the full path to your `.env` file if you're not in the same directory):

```bash
docker run -it -d \
    --name=gamearch \
    --env-file .env \
    -v gamearch_db:/data/db \
    -p 8099:8080 \
    quay.io/ckoenig/gamearch:latest
```

It should be available at **http://localhost:8099**.

### Updating the container

To update the container stop and remove the old container:

```bash
docker stop gamearch
docker rm gamearch
```
Then pull the latest image:

```bash
docker pull quay.io/ckoenig/gamearch:latest
```
And finally, run a new container:
```bash
docker run -it -d \
    --name=gamearch \
    --env-file .env \
    -v gamearch_db:/data/db \
    -p 8099:8080 \
    quay.io/ckoenig/gamearch:latest
```

Provided you didn't change the volume your settings and games will remain untouched.

### Docker compose

Another way to start the container is with the included `docker-compose.yaml` file. Take the same steps to create your `.env` file and start the container with:

```bash
docker-compose up -d
```


## Building your own containers

To build your own container you can use the script `build.sh`. Before executing the script you should take a look at it and also rename the `.env.frontend.example` file in the `build` directory to `.env.frontend`.

Building the container is the only way to change the supported platforms at the moment since the `platform.js` file is only read once during build time. This is not strictly necessary however, since you can still enter platforms not included in the file. You just won't get suggestions.

## Technical information

* After the first launch, changing `INITIAL_ADMIN_PASSWORD` will no longer have any effect because the database was already created with this value.

* Although the default values will work, it's better to set your own values for sensitive variables. If you want to change them but don't know how to generate the values you could use a password generator.

  * SALT
  * JWT_SECRET
  * INITIAL_ADMIN_PASSWORD

* It's advised to mount a `/data/db` volume to preserve the database between container restarts. It can be a named volume, e.g. `db:` (`-v db:/data/db`), but it can also be a path on your system. The examples use a named volume.

* The mail settings (see [Using the container](#using-the-container)) are required for the reset password feature but the application will run without them.

## Security considerations

This container is intended to run in a local environment only, meaning your client, a NAS or other server in your local network. It is **not** recommended to run it directly on the internet, like a VPS. You will need to setup your own environment if you wish to do so.