# ws-bedrock-server

Start a Minecraft server (bedrock version) and access server console via websocket using a HTML page.

## Overview

This dockerfile is building a container downloading the latest Minecraft bedrock server for Linux.

Inspired by https://www.github.com/toasterlint/minecraft_bedrock

## Usage

### Install

`mkdir ~/minecraft`
`mkdir ~/minecraft/config`
`mkdir ~/minecraft/worlds`

If you want to start with a new world just skip the next section.

#### From backup

Unzip archive (e.g. world.mcworld) into a seprate directory (~/minecraft/worlds/{world}) in the worlds path. 

`unzip world.mcworld -d ~/minecraft/worlds/world`

Copy `system.properties` file into the server config path (~/minecraft/config)

`cp system.properties ~/minecraft/config/`

If available copy `permissions.json`.

`cp permissions.json ~/minecraft/config/`

If available or required because of property (`system.properties`) `white-list=true`.

`cp whitelist.json ~/minecraft/config`

#### Create docker image

`sudo docker create -ti --name=minecraft-${USER} -v "${HOME}/minecraft/config:/srv/bedrock-server/config:/srv/bedrock-server/config" -v "${HOME}/minecraft/config:/srv/bedrock-server/worlds:/srv/bedrock-server/worlds" -p 19132:19132/udp -p 80:8080  minecraft-bedrock`

### Start

`sudo docker start minecraft-${USER}`

### Stop

`sudo docker stop minecraft-${USER}`

### Websocket

`ws://{hostname}:{port}`

### Default web console

`http://{hostname}:{port}`

Click the check button to connect.

If this is the first time a websocket is created since server start. 
You should now see the typical server output.

```
onmessage NO LOG FILE! - setting up server logging... 
onmessage [2020-07-09 11:46:11 INFO] Starting Server 
onmessage [2020-07-09 11:46:11 INFO] Version 1.16.1.2 
onmessage [2020-07-09 11:46:11 INFO] Session ID XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX 
onmessage [2020-07-09 11:46:11 INFO] Level Name: world 
onmessage [2020-07-09 11:46:11 ERROR] Error opening whitelist file: whitelist.json 
onmessage [2020-07-09 11:46:11 INFO] Game mode: 0 Survival 
onmessage [2020-07-09 11:46:11 INFO] Difficulty: 2 NORMAL 
onmessage [2020-07-09 11:46:11 INFO] opening worlds/world/db 
onmessage [2020-07-09 11:46:16 INFO] IPv4 supported, port: 19132 
onmessage [2020-07-09 11:46:16 INFO] IPv6 not supported 
onmessage [2020-07-09 11:46:16 INFO] IPv4 supported, port: 42369 
onmessage [2020-07-09 11:46:16 INFO] IPv6 not supported 
onmessage [2020-07-09 11:46:17 INFO] Server started. 
```

#### Example

Type `stop` into the `send` panel.

Now the server is stopping and the container is stopped.
```
onmessage [2020-07-09 14:38:09 INFO] Server stop requested. 
onmessage [2020-07-09 14:38:09 INFO] Stopping server... 
onmessage Quit correctly  
```

## Config Examples

### server.properties

```
server-name=Dedicated Server
# Used as the server name
# Allowed values: Any string

gamemode=survival
# Sets the game mode for new players.
# Allowed values: "survival", "creative", or "adventure"

difficulty=normal
# Sets the difficulty of the world.
# Allowed values: "peaceful", "easy", "normal", or "hard"

allow-cheats=true
# If true then cheats like commands can be used.
# Allowed values: "true" or "false"

max-players=10
# The maximum number of players that can play on the server.
# Allowed values: Any positive integer

online-mode=true
# If true then all connected players must be authenticated to Xbox Live.
# Clients connecting to remote (non-LAN) servers will always require Xbox Live authentication regardless of this setting.
# If the server accepts connections from the Internet, then it's highly recommended to enable online-mode.
# Allowed values: "true" or "false"

white-list=false
# If true then all connected players must be listed in the separate whitelist.json file.
# Allowed values: "true" or "false"

server-port=19132
# Which IPv4 port the server should listen to.
# Allowed values: Integers in the range [1, 65535]

server-portv6=19133
# Which IPv6 port the server should listen to.
# Allowed values: Integers in the range [1, 65535]

view-distance=32
# The maximum allowed view distance in number of chunks.
# Allowed values: Any positive integer.

tick-distance=4
# The world will be ticked this many chunks away from any player.
# Allowed values: Integers in the range [4, 12]

player-idle-timeout=30
# After a player has idled for this many minutes they will be kicked. If set to 0 then players can idle indefinitely.
# Allowed values: Any non-negative integer.

max-threads=8
# Maximum number of threads the server will try to use. If set to 0 or removed then it will use as many as possible.
# Allowed values: Any positive integer.

level-name=world
# Allowed values: Any string

level-seed=
# Use to randomize the world
# Allowed values: Any string

default-player-permission-level=member
# Permission level for new players joining for the first time.
# Allowed values: "visitor", "member", "operator"

texturepack-required=false
# Force clients to use texture packs in the current world
# Allowed values: "true" or "false"

content-log-file-enabled=false
# Enables logging content errors to a file
# Allowed values: "true" or "false"

compression-threshold=1
# Determines the smallest size of raw network payload to compress
# Allowed values: 0-65535

server-authoritative-movement=true
# Enables server authoritative movement. If true, the server will replay local user input on
# the server and send down corrections when the client's position doesn't match the server's.
# Corrections will only happen if correct-player-movement is set to true.

player-movement-score-threshold=20
# The number of incongruent time intervals needed before abnormal behavior is reported.
# Disabled by server-authoritative-movement.

player-movement-distance-threshold=0.3
# The difference between server and client positions that needs to be exceeded before abnormal behavior is detected.
# Disabled by server-authoritative-movement.

player-movement-duration-threshold-in-ms=500
# The duration of time the server and client positions can be out of sync (as defined by player-movement-distance-threshold)
# before the abnormal movement score is incremented. This value is defined in milliseconds.
# Disabled by server-authoritative-movement.

correct-player-movement=false
# If true, the client position will get corrected to the server position if the movement score exceeds the threshold.
```

