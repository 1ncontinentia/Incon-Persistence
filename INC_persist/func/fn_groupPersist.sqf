/*
Group Persistence Main

Author: Incontinentia

*/


params [["_operation","loadGroup"],["_unit",objNull]];

if !(isClass(configFile >> "CfgPatches" >> "inidbi2")) exitWith {diag_log "inidbi2 missing, group persistence exiting"};
if !(isClass(configFile >> "CfgPatches" >> "ALiVE_main")) exitWith {};

inidbi = ["new", "INC_groupPersDB"] call OO_INIDBI;

switch (_operation) do {

    case "loadGroup" : {

        [_unit] spawn {

            params ["_unit"];
            private ["_read","_read2","_read3","_groupData","_dataKey","_dataKey2","_dataKey3","_index"];

            waituntil {
            sleep 1;
            (!(isNil "INC_oldKey") && (player getvariable ["alive_sys_player_playerloaded",false]))
            };

            sleep 0.3;

            _dataKey = format ["INC_persGroupData%1%2%3",_unit,(getPlayerUID _unit),INC_oldKey];
            _read = ["read", [(str missionName), _dataKey,[]]] call inidbi;

            _dataKey2 = format ["INC_persGroupData2%1%2%3",_unit,(getPlayerUID _unit),INC_oldKey];
            _read2 = ["read", [(str missionName), _dataKey2,[]]] call inidbi;

            _dataKey3 = format ["INC_persGroupData3%1%2%3",_unit,(getPlayerUID _unit),INC_oldKey];
            _read3 = ["read", [(str missionName), _dataKey3,[]]] call inidbi;

            if (_read isEqualTo []) exitWith {};

            {if ((_x != leader group _x) && {!(_x in playableUnits)}) then {deleteVehicle _x}} forEach units group _unit;

            sleep 0.3;

            _index = (_read select 0);

            _index params ["_float","_groupSize","_rating"];

            sleep 1;

            _unit addRating (0 - (rating _unit));

            _unit addRating _rating;

            [_read,"loadGroupINIDB",_unit,inidbi] call INCON_fnc_persMain;

            if (_groupSize >= 5) then {

                sleep 0.1;

                [_read2,"loadLargeGroupINIDB",_unit,inidbi] call INCON_fnc_persMain;

                if (_groupSize >= 9) then {

                    sleep 0.1;

                    [_read3,"loadLargeGroupINIDB",_unit,inidbi] call INCON_fnc_persMain;
                };
            };

            sleep 5;

            if (!(isNil "INCON_ucr_fnc_ucrMain") && {_unit getVariable ["isSneaky",false]}) then {
                {
                    sleep 0.2;
                    [_x] execVM "INC_undercover\Scripts\initUCR.sqf";
                    sleep 0.2;
                    _x setVariable ["noChanges",true,true];
                    _x setVariable ["isUndercover", true];
                    sleep 0.2;
                    [[_x,_unit],"addConcealActions"] call INCON_ucr_fnc_ucrMain;
                } forEach ((units _unit) select {
                    !(_x getVariable ["isUndercover",false]) &&
                    {!isPlayer _x}
                });
            };
        };
    };

    case "saveGroup" : {

        [_unit] spawn {
            params ["_unit"];
            private ["_groupData","_dataKey","_encodedData","_secondIteration"];

            sleep 20;

            waituntil {
                sleep 1;
                !(isNil "INC_NewKey")
            };

            waitUntil {

                sleep 47;

                _encodedData = [[_unit],"saveGroupINIDB",_unit,inidbi] call INCON_fnc_persMain;

                sleep 1;

                _dataKey = format ["INC_persGroupData%1%2%3",_unit,(getPlayerUID _unit),INC_NewKey];

                ["write", [(str missionName), _dataKey, _encodedData]] call inidbi;

                sleep 1;

                if (count units group _unit >= 6) then {
                    private ["_encodedData2"];
                    _encodedData2 = [[_unit,"second"],"saveGroupINIDB",_unit,inidbi] call INCON_fnc_persMain;
                    _dataKey2 = format ["INC_persGroupData2%1%2%3",_unit,(getPlayerUID _unit),INC_NewKey];
                    ["write", [(str missionName), _dataKey2, _encodedData2]] call inidbi;
                };

                if (count units group _unit >= 11) then {
                    private ["_encodedData3"];
                    _encodedData3 = [[_unit,"third"],"saveGroupINIDB",_unit,inidbi] call INCON_fnc_persMain;
                    _dataKey3 = format ["INC_persGroupData3%1%2%3",_unit,(getPlayerUID _unit),INC_NewKey];
                    ["write", [(str missionName), _dataKey3, _encodedData3]] call inidbi;
                };

                !(isPlayer _unit)
            };
        };
    };
};
