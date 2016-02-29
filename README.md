This guide shows you how to set up a Docker Private Registry on a local network with full HTTPS support, which will work straight out of the box with all Docker Engines. Perfect for demos and workshops with poor internet connectivity and lots of bandwidth hungry Docker users.

Thanks to [@winggundamth](https://twitter.com/winggundamth) for the idea!

## Set up temporary server

Get a hold of a server somewhere with a public IP.

## Set DNS

Point ``registry.yourdomain.com`` to the public IP of the temporary server.

## Run letsencrypt

Run letsencrypt on the temporary server.

    git clone https://github.com/letsencrypt/letsencrypt
    cd letsencrypt
    ./letsencrypt-auto certonly

The certificate files and key (4 files total) are placed here:

    $ ls /etc/letsencrypt/live/registry.yourdomain.com/
    cert1.pem
    chain1.pem
    fullchain1.pem
    privkey1.pem

## Download certificates

Copy all certificate files and the private key to your local machine.

## Run registry

### Linux

Edit the path to the certs folder under ``volumes:`` in ``docker-compose.yml``, then do

    docker-compose up -d

### Mac

On a Mac you need to do a bit more. First, install [Docker Toolbox](https://www.docker.com/products/docker-toolbox) to get the latest versions of Docker Machine. Make sure your Docker Machine VM is up and running:

    $ docker-machine ls
    NAME     ACTIVE  DRIVER     STATE   URL                        SWARM  ERRORS
    default  -       virtualbox Running tcp://192.168.99.100:2376       

#### Put certs in place

Put the certificates in a folder somewhere under ``/Users/``, for example:

    /Users/johndoe/.ssl/registry.yourdomain.com/

Enter the path under ``volumes:`` in ``docker-compose.yml``:

    - /Users/johndoe/.ssl/registry.yourdomain.com:/certs

#### Start the registry

    docker-compose up -d

Ensure that you can reach the registry:

    $ curl https://$(docker-machine ip)/
    curl: (60) SSL certificate problem: Invalid certificate chain
    More details...

You should get a certificate error, since you're not using the right DNS name.

#### Forward port

You now want to forward a port on your machine onto the VM's port 443. The problem is that to get access to port 443 on your machine, VirtualBox needs to run as root (bad idea). A better workaround is to use SSH port forwarding.

This is what it will look like:

    443 on host --> 8080 on host --> 443 on docker-machine VM

##### Forward port in VirtualBox

Select the VM and click ``Settings -> Network ->``, add a rule to forward TCP on host port 8080 to guest port 443.

##### Disable Password authentication

Before we enable remote access, you don't want to risk people guessing your Mac password, so turn off password auth for SSH.

In ``/private/etc/ssh/sshd_config`` (edit as root), ensure this line exists:

    PasswordAuthentication no

##### Enable Remote access

Go to ``System Preferences -> Sharing`` and tick ``Remote Login``.

Add yourself to authorized keys:

    cat ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys

##### Forward port with SSH

    $ sudo su -
    # ssh -i /Users/johndoe/.ssh/id_rsa johndoe@localhost -L \*:443:8080

Try it out:

    $ curl https://localhost/
    curl: (60) SSL certificate problem: Invalid certificate chain
    More details...

## Update the DNS record

Get your current IP on the network where your users are, for example ``192.168.111.123``, and update your DNS record to point to that IP.

## Test

    $ curl https://registry.yourdomain.com/v2/
    {}%

## Push images to local registry

Pull down an image from the official hub, re-tag it to the local registry and push it up.

    docker pull redis
    docker tag redis registry.yourdomain.com/library/redis
    docker push registry.yourdomain.com/library/redis

## That's it!

Your LAN users can now use your private registry to pull the image:

    docker pull registry.yourdomain.com/library/redis

Or in a Compose file:

    redis:
      image: registry.yourdomain.com/library/redis

Or in a Dockerfile:

    FROM registry.yourdomain.com/library/redis
