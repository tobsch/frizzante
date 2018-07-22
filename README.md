# Frizzante - the Fritzbox - Plex DVR server

Are you annoyed by having too much systems to take care of?
You just want to watch TV using your Plex / Fritzbox cable setup?

Try this experimental server instead of using the TVHeadend / TVHProxy combination.

Cudos to TVHProxy folks, as this is heavily inspired by them.

## How to set up?
This is a simple Sinatra server that just needs ruby and ffmpeg as prerequisites.
Please check the Dockerfile for further explanation on how to handle.
Has been tested on my synology.

### Sample setup for Ubuntu:
- Install docker-ce
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get install docker-ce
```
 
- Install ffmpeg and git
```
apt-get install ffmpeg git
```

- Checkout git repo
```
git clone https://github.com/tobsch/frizzante.git
```


- Build docker image
```
cd frizzante
docker build .
```

- Create and start container
```
docker run -d -e FRITZBOX_HOST="fritz.box" -p=4567:4567 [docker-image-id]
```

- Supported parameters:
```
PROXY_URL - The public URL the server is supposed to react on (Default is "http://localhost:4567")
PORT - The port the server is supposed to run on (Default is 4567)
FRITZBOX_HOST - The IP address of your fritzbox (Default is "fritz.box"
```

## Things on the todo list
- [] Allow multiple streams at once
