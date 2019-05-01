sudo apt-get upgrade
sudo apt-get update
sudo apt-get install -y bash jq curl avahi-daemon dbus network-manager apparmor-utils
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

## sanity check 
## sudo docker run hello-world
sudo -i

## curl -fsSL get.docker.com | sh

curl -sL "https://raw.githubusercontent.com/home-assistant/hassio-installer/master/hassio_install.sh" | bash -s

## add Portainer
docker pull portainer/portainer
docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer

## sanity check
docker ps

## find ip addresses 
apt-get install net-tools
ifconfig

## launch guis

## Hass io - http://xxx.xxx.xxx.xxx:8123  172.17.0.1:8123 http://192.168.5.40:8123
## Portainer - http://xxx.xxx.xxx.xxx:9000 
