/*

if (isDedicated) then {

    sleep 120;

    if (isNil "INC_NewKey") then {

        _InconPersKey = (random 10000);
        ["InconPersKey",_InconPersKey] call ALiVE_fnc_setData;
        diag_log format ["Incon Persistence key saved: %1",_InconPersKey];
        missionNamespace setVariable ["INC_NewKey",_InconPersKey,true];

        waitUntil {
            sleep 2;
            (!isNil "ALiVE_sys_data_mission_data")
        };

        _oldKey = ["InconPersKey"] call ALiVE_fnc_getData;
        diag_log format ["Incon Persistence key read: %1",_oldKey];
        missionNamespace setVariable ["INC_oldKey",_oldKey,true];
    };
};
*/
