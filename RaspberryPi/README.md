# Raspberry Pi Notes

General notes on setting up raspberry pi's including docker, Unifi controllers, favorite apps, etc.


## Installing Docker

Docker can run on the Raspberry Pis using the ARM version of docker. Here are the steps to get docker installed.

```bash
# run updates
sudo apt-get update && sudo apt-get upgrade -y

# run raspberry pi updates
sudo rpi-update

# Reboot the pi
sudo reboot

# Download the docker install script
curl -fsSL https://get.docker.com -o get-docker.sh

# run the installer
sudo sh get-docker.sh

# add pi user to docker group
sudo usermod -aG docker pi

# pre-reqs for docker-compose
sudo apt-get install libffi-dev libssl-dev
sudo apt install python3-dev
sudo apt-get install -y python3 python3-pip

# install docker-compose
sudo pip3 install docker-compose

# check install
sudo systemctl status docker
```

## Unifi Controller Setup

Here are some instructions to get the unifi controller running on Docker

```yaml
---
version: "2.1"
services:
  unifi-controller:
    image: lscr.io/linuxserver/unifi-controller
    container_name: unifi-controller
    environment:
      - PUID=1000
      - PGID=1000
      - MEM_LIMIT=1024 #optional
      - MEM_STARTUP=1024 #optional
    volumes:
      - /home/pi/apps/config:/config
    ports:
      - 3478:3478/udp
      - 10001:10001/udp
      - 8080:8080
      - 8443:8443
      - 1900:1900/udp #optional
      - 8843:8843 #optional
      - 8880:8880 #optional
      - 6789:6789 #optional
      - 5514:5514/udp #optional
    restart: unless-stopped
```