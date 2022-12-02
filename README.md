# `tabcmd` Docker Service

Tableau provides a `tabcmd` command-line utility which you can use to automate site administration tasks on your Tableau Server site. For example, creating or deleting users, projects, and groups.

# Background
This is a Docker service packages `tabcmd` as an image to be run as a container. Docker is required for this service to run.

## What is Docker?
If you don't know what Docker is read "[What is Docker?](https://www.docker.com/what-docker)".

### Get Docker

Once you have a sense of what Docker is, you can then install the software. It is free: "[Get Docker](https://www.docker.com/products/docker-desktop)". Select the Docker package that aligns with your environment (ie. OS X, Linux or Windows). If you have not used Docker before, take a look at the guides:

- [Engine: Get Started](https://docs.docker.com/engine/getstarted/)
- [Docker Mac](https://docs.docker.com/docker-for-mac/)
- [Docker Windows](https://docs.docker.com/docker-for-windows/)

If you already have a Linux instance running as a host or VM, you can install Docker command line. For example, on CentOS you would run `yum install docker -y` and then start the Docker service.

We also strongly suggest installing `docker-compose`. Compose allowws you to package runtime definitions for your container. More on this is here: https://docs.docker.com/compose/install/

# Getting Started

## Step 1: Determine Your Tableau Server Version
The first step for using `tabcmd` is getting a Docker image built. You will need to know in advance which Tableau Server version you want to connect `tabcmd` to. There is a tight coupling between the Server version and the `tabcmd` version. For example, if you are using Tableau Server version `2019-3-0` then you must use the `2019-3-0` version of `tabcmd` in your build. Note that you **can** create multiple Docker images for each version


## Step 2: Build Your `tabcmd` Docker image
 With your version number in-hand, you need to set this value as part of your Docker build command. This is done via the Docker `--build-arg` variable.

 The build statement will look like this:
```bash
docker build --build-arg "TABLEAU_SERVER_VERSION=2019-3-0" -t tabcmd:latest .
```
### Build Versions
If you want to use an different version of `tabcmd` you set the version number accordingly. For example, you need to need `tabcmd` for Tableau Server version `2019-2-0`. You would then build the image with this version of the software:
```bash
docker build --build-arg "TABLEAU_SERVER_VERSION=2019-2-0" -t tabcmd:2019-2-0 .
```
This allows you to version your image according to current and past releases for `tabcmd`. Typically, you will use `latest` in your image for the most current release:
```bash
docker build --build-arg "TABLEAU_SERVER_VERSION=2019-3-0" -t tabcmd:latest .
```

# Using Amazon ECR
Retrieve the login command to use to authenticate your Docker client to your registry.
Use the AWS CLI:
```bash
$(aws ecr get-login --no-include-email --region us-east-1)
```
Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions here . You can skip this step if your image is already built:
```bash
docker build --build-arg "TABLEAU_SERVER_VERSION=2019-3-0" -t tabcmd:latest .
```
After the build completes, tag your image so you can push the image to this repository:
```bash
docker tag tabcmd:latest xxxxxxxxxxx.dkr.ecr.us-east-1.amazonaws.com/tabcmd:latest
```
Run the following command to push this image to your newly created AWS repository:
```bash
docker push xxxxxxxxxxx.dkr.ecr.us-east-1.amazonaws.com/tabcmd:latest
```
# Example Usage

Here is an example of remotely `createsite` command for "East Coast Sales":
```bash
docker run -it ob_tabcmd tabcmd createsite "East Coast Sales" --server 3.82.223.16:80 --username admin --password admin
```
The output will show the status of the operation:
```bash
+ exec tabcmd createsite 'East Coast Sales' --server 3.82.223.16:80 --username admin --password admin
===== Creating new session
=====     Server:   http://3.82.223.16:80
=====     Username: admin
===== Connecting to the server...
===== Signing in...
===== Auto-sign in to site: Default
===== Creating new session
=====     Server:   http://3.82.223.16:80
=====     Username: admin
===== Connecting to the server...
===== Signing in...
===== Succeeded
===== Succeeded
===== Create site 'East Coast Sales' on the server...
===== Succeeded
```
Here is an example of running a remote `deletesite` command for the same site:
```bash
docker run -it ob_tabcmd tabcmd deletesite "East Coast Sales" --server 3.82.223.16:80 --username admin --password admin
```
The output of the command confirms the deletion:
```bash
+ exec tabcmd deletesite 'East Coast Sales' --server 3.82.223.16:80 --username admin --password admin
===== Creating new session
=====     Server:   http://3.82.223.16:80
=====     Username: admin
===== Connecting to the server...
===== Signing in...
===== Auto-sign in to site: Default
===== Creating new session
=====     Server:   http://3.82.223.16:80
=====     Username: admin
===== Connecting to the server...
===== Signing in...
===== Succeeded
===== Succeeded
===== Deleting site 'East Coast Sales' from the server...
===== 0% complete
===== 100% complete
===== Finished deleting site 'East Coast Sales'.
```
Here is an example of downloading a workbook from the server:
```bash
docker run -it -v /ssh:/tmp ob_tabcmd tabcmd get "/workbooks/Regional.twbx" -f "/tmp/Regional.twbx" --server 3.82.223.16:80 --username admin --password admin
```
Notice in this example we used the `-v` or volume command. Why? When the file is downloaded from the container we want to make sure it is stored on the host running the command. In this example we mount the `ssh` on the host to the `tmp` inside the container.
```bash
+ exec tabcmd get /workbooks/Regional.twbx -f /tmp/Regional.twbx --server 3.82.223.16:80 --username admin --password admin
===== Creating new session
=====     Server:   http://3.82.223.16:80
=====     Username: admin
===== Connecting to the server...
===== Signing in...
===== Auto-sign in to site: Default
===== Creating new session
=====     Server:   http://3.82.223.16:80
=====     Username: admin
===== Connecting to the server...
===== Signing in...
===== Succeeded
===== Succeeded
===== Requesting '/workbooks/Regional.twbx' from the server...
===== Saved /workbooks/Regional.twbx to '/tmp/Regional.twbx'
```

For a complete list of commands, visit: https://help.tableau.com/current/server/en-us/tabcmd_cmd.htm

**Note:** When you use the `tabcmd` login command, you cannot use SAML single sign-on (SSO), even if the server is configured to use SAML. To log in, you must pass the user name and password of a user who has been created on the server. You will have the permissions of the Tableau Server user that you're signed in as. For more information, see Set Users’ Site Roles and Permissions.

# Firewall
If you are running Tableau behind a firewall and running `tabcmd` remotely, make sure the system you are running it on has been whitelisted.

# Build Notes

Make sure you take note of the exact version number and format. Tableau may switch the format at some point from `XXXX-X-X`. They already use `XXXX.X.X` in the path to the RPM file. We convert the version `XXXX-X-X` to the version to the path `XXXX.X.X` format.

```bash
&& tabPath="$(echo $TABLEAU_SERVER_VERSION | tr '-' '.')" \
```
This line may need to be adjusted, enhanced or refactored to reflect any changes to the formatting

# References
* https://help.tableau.com/current/server-linux/en-us/tabcmd_cmd.htm
* https://help.tableau.com/current/server/en-us/tabcmd.htm
* https://www.tableau.com/support/releases/server
* https://help.tableau.com/current/server-linux/en-us/config_firewall_linux.htm
