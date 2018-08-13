
apt update -y
apt upgrade -y
apt install sudo -y

sudo apt-get install software-properties-common -y
sudo LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
sudo apt-get update

sudo apt-get install wget -y

### RabitMQ

wget -O - 'https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc' | sudo apt-key add -

echo "deb https://dl.bintray.com/rabbitmq/debian trusty main" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list

cd /usr/lib/apt/methods
ln -s http https

sudo apt-get update
sudo apt-get upgrade

sudo apt-get intall erlang-nox -y

wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb

sudo apt-get update
sudo apt-get install esl-base-hipe erlang -y
sudo apt-get install esl-erlang -y

sudo apt-get update
sudo apt-get install erlang -y

sudo apt-get install rabbitmq-server -y

sudo apt install python-pip -y
pip install pika

service rabbitmq-server start

### Git

sudo apt-get install git