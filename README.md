[![Docker Repository on Quay.io](https://quay.io/repository/sameersbn/akaunting/status "Docker Repository on Quay.io")](https://quay.io/repository/sameersbn/akaunting)

# sameersbn/akaunting:1.2.10

- [Introduction](#introduction)
  - [Contributing](#contributing)
  - [Issues](#issues)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Persistence](#persistence)
- [Maintenance](#maintenance)
  - [Creating backups](#creating-backups)
  - [Restoring backups](#restoring-backups)
  - [Upgrading](#upgrading)
  - [Shell Access](#shell-access)

# Introduction

`Dockerfile` to create a [Docker](https://www.docker.com/) container image for [Akaunting](https://akaunting.com/).

Akaunting is a self-hosted open source accounting software.

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your awesome features and bug fixes
- Help users resolve their [issues](../../issues?q=is%3Aopen+is%3Aissue).
- Support the development of this image with a [donation](http://www.damagehead.com/donate/)

## Issues

Before reporting your issue please try updating Docker to the latest version and check if it resolves the issue. Refer to the Docker [installation guide](https://docs.docker.com/installation) for instructions.

SELinux users should try disabling SELinux using the command `setenforce 0` to see if it resolves the issue.

If the above recommendations do not help then [report your issue](../../issues/new) along with the following information:

- Output of the `docker version` and `docker info` commands
- The `docker run` command or `docker-compose.yml` used to start the image. Mask out the sensitive bits.
- Please state if you are using [Boot2Docker](http://www.boot2docker.io), [VirtualBox](https://www.virtualbox.org), etc.

# Getting started

## Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/sameersbn/akaunting) and is the recommended method of installation.

> **Note**: Builds are also available on [Quay.io](https://quay.io/repository/sameersbn/akaunting)

```bash
docker pull sameersbn/akaunting:1.2.10
```

Alternatively you can build the image yourself.

```bash
docker build -t sameersbn/akaunting github.com/sameersbn/docker-akaunting
```

## Quickstart

The quickest way to start using this image is with [docker-compose](https://docs.docker.com/compose/).

```bash
wget https://raw.githubusercontent.com/sameersbn/docker-akaunting/master/docker-compose.yml
```

Update the `AKAUNTING_URL` environment variable in the `docker-compose.yml` file with the url from which Akaunting will be externally accessible.

```bash
docker-compose up
```

Alternatively, you can start Akaunting manually using the Docker command line.

Step 1. Launch a MySQL container

```bash
docker run --name akaunting-mysql -itd --restart=always \
  --env 'DB_NAME=akaunting_db' \
  --env 'DB_USER=akaunting' --env 'DB_PASS=password' \
  --volume /srv/docker/akaunting/mysql:/var/lib/mysql \
  sameersbn/mysql:latest
```

Step 2. Launch the Akaunting php-fpm container

```bash
docker run --name akaunting -itd --restart=always \
  --env AKAUNTING_URL=http://akaunting.example.com:10080 \
  --link akaunting-mysql:mysql \
  --volume /srv/docker/akaunting/akaunting:/var/lib/akaunting \
  sameersbn/akaunting:1.2.10 app:akaunting
```

Step 3. Launch a NGINX frontend container

```bash
docker run --name akaunting-nginx -itd --restart=always \
  --link akaunting:php-fpm \
  --publish 10080:80 \
  sameersbn/akaunting:1.2.10 app:nginx
```

Point your browser to `http://akaunting.example.com:10080` and login using the default username and password:

* username: **admin@example.com**
* password: **password**

> **Note**
>
> Use the `AKAUNTING_ADMIN_EMAIL` and `AKAUNTING_ADMIN_PASSWORD` variables to create a custom admin user and password on the firstrun instead of the default credentials.

## Persistence

For Akaunting to preserve its state across container shutdown and startup you should mount a volume at `/var/lib/akaunting`.

> *The [Quickstart](#quickstart) command already mounts a volume for persistence.*

SELinux users should update the security context of the host mountpoint so that it plays nicely with Docker:

```bash
mkdir -p /srv/docker/akaunting
chcon -Rt svirt_sandbox_file_t /srv/docker/akaunting
```

# Maintenance

## Creating backups

The image allows users to create backups of the Akaunting installation using the `app:backup:create` command or the `akaunting-backup-create` helper script. The generated backup consists of configuration files, uploaded files and the sql database.

Before generating a backup — stop and remove the running instance.

```bash
docker stop akaunting && docker rm akaunting
```

Relaunch the container with the `app:backup:create` argument.

```bash
docker run --name akaunting -it --rm [OPTIONS] \
  sameersbn/akaunting:1.2.10 app:backup:create
```

The backup will be created in the `backups/` folder of the [Persistent](#persistence) volume. You can change the location using the `AKAUNTING_BACKUPS_DIR` configuration parameter.

> **NOTE**
>
> Backups can also be generated on a running instance using:
>
>  ```bash
>  docker exec -it akaunting akaunting-backup-create
>  ```

By default backups are held indefinitely. Using the `AKAUNTING_BACKUPS_EXPIRY` parameter you can configure how long (in seconds) you wish to keep the backups. For example, setting `AKAUNTING_BACKUPS_EXPIRY=604800` will remove backups that are older than 7 days. Old backups are only removed when creating a new backup, never automatically.

## Restoring Backups

Backups created using instructions from the [Creating backups](#creating-backups) section can be restored using the `app:backup:restore` argument.

Before restoring a backup — stop and remove the running instance.

```bash
docker stop akaunting && docker rm akaunting
```

Relaunch the container with the `app:backup:restore` argument. Ensure you launch the container in the interactive mode `-it`.

```bash
docker run --name akaunting -it --rm [OPTIONS] \
  sameersbn/akaunting:1.2.10 app:backup:restore
```

A list of existing backups will be displayed. Select a backup you wish to restore.

To avoid this interaction you can specify the backup filename using the `BACKUP` argument to `app:backup:restore`, eg.

```bash
docker run --name akaunting -it --rm [OPTIONS] \
  sameersbn/akaunting:1.2.10 app:backup:restore BACKUP=1417624827_akaunting_backup.tar
```

## Upgrading

To upgrade to newer releases:

  1. Download the updated Docker image:

  ```bash
  docker pull sameersbn/akaunting:1.2.10
  ```

  2. Stop the currently running image:

  ```bash
  docker stop akaunting
  ```

  3. Remove the stopped container

  ```bash
  docker rm -v akaunting
  ```

  4. Start the updated image

  ```bash
  docker run -name akaunting -itd \
    [OPTIONS] \
    sameersbn/akaunting:1.2.10
  ```

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker exec -it akaunting bash
```
