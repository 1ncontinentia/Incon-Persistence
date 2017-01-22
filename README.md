# INCONTINENTIA'S GROUP PERSIST (for ALiVE)

### Requires:

* ALiVE (obvs)
* iniDBI2 to be loaded on the client.

### Overview:

* Saves full unit information for up to 11 AI teammates.
* No configuration required, just load the iniDBI2 mod and it will save your group state periodically (including health, loadout, skill etc.) until you save and exit the server.

### Usage

To have full persistent AI teammates you need to:
(a) place all files into your mission root. If you already have a description.ext or initPlayerLocal.sqf, add in the code from Incon-Persistence to your original files.
(b) save and exit the server at the end of each session
(c) not be a numpty


### How it works:

* When you save and exit the server, the most recent group information will be stored in an iniDBI2 database file. Only one group is saved per client, per mission, to prevent the database file from exploding in size.
* Upon loading the mission, the DB will wait for ALiVE persistent data before loading. Then it will check if the there are corresponding keys stored in ALiVE data and iniDBI2 (a new key is generated and for each session so no session's data is overwritten).
