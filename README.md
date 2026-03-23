# Server

Server for my region.  When a user arrives, it add adds to a list of current users and sends a message
to the region that the user is there (for objects that react to avatars in region).  It also rezzes a prim,
[ORAC](https://blakes7.fandom.com/wiki/Orac), which enables each avatar in the region to interact (e.g. teleporting,
animations, etc), primarily developed for Role Play in the sim. When an avatar leaves the region, the ORAC prim
dies and the user is removed from the current avatar list.

# ORAC
ORAC is a prim that is rezzed for each user in the region.  The prim follows the user around and listens
for commands from that user on channel 123.  Commands can be customized for particular ROLE PLAY.  Example
commands are TELEPORT or ANIMATE.  In the system, ORAC communicates with the server to perform actions for this
user.

# SUBSERVERS
COMING SOON
