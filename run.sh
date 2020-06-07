#! /usr/bin/env bash
set -euo pipefail
(( ! $# ))

if ! command -v dockerd ; then
  wget -O- https://download.docker.com/linux/static/stable/`uname -m`/docker-19.03.8.tgz |
  sudo tar xzC /usr/local/bin --strip-components=1
fi

if ! command -v docker-compose ; then
  wget "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" |
  sudo tee /usr/local/bin/docker-compose > /dev/null
  sudo chmod -v +x /usr/local/bin/docker-compose
fi

docker version ||
dockerd &

cd "`dirname "$(readlink -f "$0")"`"

touch {sources,perf}/.sentinel

# stage1

nice -n +19      -- \
docker-compose build ssc

( trap 'docker-compose down ssc ; sudo umount /sys/kernel/debug' 0
  sudo umount /sys/kernel/debug || :
  sudo mount -t debugfs nodev /sys/kernel/debug

  xhost +local:`whoami`
  sudo             -- \
  nice -n -20      -- \
  sudo -u `whoami` -- \
  docker-compose up --force-recreate ssc )

# stage 2

trap 'docker-compose down ssc-prof' 0

nice -n +19      -- \
docker-compose build ssc-prof

xhost +local:`whoami`
sudo             -- \
nice -n -20      -- \
sudo -u `whoami` -- \
docker-compose up --force-recreate ssc-prof

