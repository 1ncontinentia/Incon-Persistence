waitUntil {
    sleep 1;
    (hasInterface)
};


["loadGroup",player] call INCON_fnc_groupPersist;
["saveGroup",player] call INCON_fnc_groupPersist;

/*
if (isNil "INC_NewKey") then {

    _InconPersKey = (random 10000);
    [["InconPersKey",_InconPersKey],"saveAliveData"] remoteExecCall ["INCON_fnc_persHandler",2];
    diag_log format ["Incon Persistence key saved: %1",_InconPersKey];
    missionNamespace setVariable ["INC_NewKey",_InconPersKey,true];
};

waituntil {sleep 1; (player getvariable ["alive_sys_player_playerloaded",false])};

_oldKey = ["InconPersKey","loadAliveData"] remoteExecCall ["INCON_fnc_persHandler",2];
missionNamespace setVariable ["INC_oldKey",_oldKey,true];
*/
