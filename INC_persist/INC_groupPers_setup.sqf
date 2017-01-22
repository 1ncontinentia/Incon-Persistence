/*

Setup options for persistent group script by Incontinentia.

Bear in mind that the default settings are the only ones tested and working at present.

*/


//Persistent player group settings (EXPERIMENTAL)
_database = "hybrid";    //Either "iniDBI2" or "hybrid"  - iniDBI2 mod must be loaded on player system. Only use "iniDBI2" in this setting if persistence isn't reliable
_saveType = "loop";       //Can be "loop" or "onExit" - loop will save the player's group data every 60 seconds throughout the mission, "onExit" will save the player's group on player disconnect (untested)
