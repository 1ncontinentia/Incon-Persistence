params ["_plyr"];
/*
[_plyr] spawn {
    params ["_plyr"];
    private ["_oldKey","_newKey"];

    waitUntil {
        sleep 1;
        (_plyr getvariable ["alive_sys_player_playerloaded",false])
    };

    if (isNil "INC_OldKey") then {

    	_oldKey = ["InconPersKey"] call ALiVE_fnc_getData;

    	if (isNil "_oldKey") then {diag_log format ["Incon Persistence previous data not found: %1",_oldKey]} else {

    		missionNamespace setVariable ["INC_OldKey",_oldKey,true];

    		diag_log format ["Incon Persistence previous data key: %1",_oldKey];
    	};
    };
};*/

if (isNil "INC_OldKey") then {

    _oldKey = ["InconPersKey"] call ALiVE_fnc_getData;

    if (isNil "_oldKey") then {diag_log format ["Incon Persistence previous data not found: %1",_oldKey]} else {

        missionNamespace setVariable ["INC_OldKey",_oldKey,true];

        diag_log format ["Incon Persistence previous data key: %1",_oldKey];
    };
};

private ["_oldKey","_newKey"];

sleep 10;

if (isNil "INC_NewKey") then {

	_newKey = str (round (random 10000));

	["InconPersKey",_newKey] call ALiVE_fnc_setData;

	missionNamespace setVariable ["INC_NewKey",_newKey,true];

	diag_log format ["Incon Persistence new data key: %1",_newKey];
};
