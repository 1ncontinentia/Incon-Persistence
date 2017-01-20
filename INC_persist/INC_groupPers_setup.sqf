/*

Setup options for persistent group script by Incontinentia.

Bear in mind that the default settings are the only ones tested and working at present. 

*/


//Persistent player group settings (EXPERIMENTAL)
_database = "iniDBI2";    //Either "iniDBI2" or "alive" - if using iniDBI2, iniDBI2 mod must be loaded on both server and player system (will still only load if ALiVE player data present, may not match your ALiVE session), "alive" means using ALiVE custom data to save the group (currently unreliable)
_saveType = "loop";       //Can be "loop" or "onExit" - loop will save the player's group data every 60 seconds throughout the mission, "onExit" will save the player's group on player disconnect (untested)
