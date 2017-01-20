# INCONTINENTIA'S GROUP PERSIST (for ALiVE)

### Requires:

* ALiVE (obvs)
* iniDBI2 to be loaded on the client and server. (A workaround until there's a fix for issue #120 ).
* Mission time persistence to be set to on (so iniDBI2 can tally it's information with ALiVE's persistent data).

### Overview:

* Intended for SP / Coop TADST sessions only, where all clients exit the server at the same time.
* Saves full unit information for up to 11 AI teammates.
* No configuration required, just load the iniDBI2 mod and it will save your group state periodically (including health, loadout, skill etc.) until you save and exit the server.
* Standalone, does not require undercover or intel to be loaded (I can give instructions if anyone wants).

### Usage 

To have full persistent AI teammates you need to:
(a) save and exit the server at the end of each session 
(b) when loading the mission, make sure the mission time is the same as it was when you last saved and exited (if not, your persistent group won't load)
(c) don't play the same mission in multiplayer in the meantime if persistent data hasn't loaded (this will also overwrite your saved group data)


### How it works:

* When you save and exit the server, the most recent group information will be stored in an iniDBI2 database file. Only one group is saved per client, per mission, to prevent the database file from exploding in size.
* Upon loading the mission, the DB will wait for ALiVE persistent data before loading. Then it will check if the mission time of the last group save on the database is the same as the current mission time (after ALiVE persistence) before restoring the client's last saved group.
* To put it another way, group persistence is tied to mission date / time (+/- 10 minutes). It will only load if you have a corresponding persistent ALiVE save of the same time you last exited the mission. For instance, if you saved and exited the server when the mission time was 1500 on the 6th May, it will only load your group if, the next time you play, the mission time is within 10 minutes of 1500 on the 6th May.