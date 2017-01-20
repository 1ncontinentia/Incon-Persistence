/*
Group Persistence Main

Author: Incontinentia

*/


params [["_operation","loadGroup"],["_unit",objNull]];

#include "..\INC_groupPers_setup.sqf"

switch (_database) do {

    case "alive" : {
        if !(isClass(configFile >> "CfgPatches" >> "ALiVE_main")) exitWith {};

		//Locality: client, as anything that needs to be remotely executed is done from here
		if (isDedicated) exitWith {};

		switch (_operation) do {
			case "loadGroup" : {

				[_unit] spawn {
					params ["_unit"];
					private ["_groupData","_dataKey"];

					waitUntil {
						sleep 3;

						(_unit getvariable ["alive_sys_player_playerloaded",false])
					};

					_dataKey = format ["INC_persGroupData%1%2",_unit,(getPlayerUID _unit)];

					_groupData = [_dataKey,"loadAliveData"] remoteExecCall ["INCON_fnc_persHandler",2];

					sleep 0.2;

					if (count _groupData != 0) then {

						{if ((_x != leader group _x) || {_x in playableUnits}) then {deleteVehicle _x}} forEach units group _unit;

						[_groupData,"loadGroup",_unit] call INCON_fnc_persHandler;

					};
				};
			};

            case "saveGroup" : {
        		switch (_saveType) do {

        			case "loop": {
						[_unit] spawn {
							params ["_unit"];
							private ["_groupData","_dataKey"];

							sleep 60;

							_dataKey = format ["INC_persGroupData%1%2",_unit,(getPlayerUID _unit)];

							waitUntil {

								sleep 59;

								_groupData = [_unit,"saveGroup"] call INCON_fnc_persHandler;

								sleep 1;

								[[_dataKey,_groupData],"saveAliveData"] remoteExecCall ["INCON_fnc_persHandler",2];

								!(isPlayer _unit)

							};
						};
					};

        			case "onExit": {
						[_unit] spawn {
							params ["_unit"];
							private ["_groupData","_dataKey"];

							sleep 60;

			                _dataKey = format ["INC_persGroupData%1%2",_unit,(getPlayerUID _unit)];

							waitUntil {

								sleep 3;

								!(isPlayer _unit)

							};

							_groupData = [_unit,"saveGroup"] call INCON_fnc_persHandler;

							sleep 1;

							[[_dataKey,_groupData],"saveAliveData"] remoteExecCall ["INCON_fnc_persHandler",2];
						};
        			};
        		};
        	};
        };
    };

    case "iniDBI2" : {

		//Locality, either but ideally server as otherwise "onExit" doesn't work.
        if !(isClass(configFile >> "CfgPatches" >> "inidbi2")) exitWith {};
        if !(isClass(configFile >> "CfgPatches" >> "ALiVE_main")) exitWith {};

		inidbi = ["new", "INC_groupPersDB"] call OO_INIDBI;

		switch (_operation) do {

			case "loadGroup" : {
                [_unit] spawn {
                    params ["_unit"];
                    private ["_read","_read2","_read3","_groupData","_dataKey","_dataKey2","_dataKey3","_index"];

                    waitUntil {
                        sleep 3;

                        (_unit getvariable ["alive_sys_player_playerloaded",false])
                    };

                    _dataKey = format ["INC_persGroupData%1%2",_unit,(getPlayerUID _unit)];
                    _read = ["read", [(str missionName), _dataKey,[]]] call inidbi;

					_dataKey2 = format ["INC_persGroupData2%1%2",_unit,(getPlayerUID _unit)];
					_read2 = ["read", [(str missionName), _dataKey2,[]]] call inidbi;

					_dataKey3 = format ["INC_persGroupData3%1%2",_unit,(getPlayerUID _unit)];
					_read3 = ["read", [(str missionName), _dataKey3,[]]] call inidbi;

                    if (_read isEqualTo []) exitWith {};

					sleep 1;

					_index = (_read select 0);

                    _index params ["_float","_groupSize","_rating"];

					_floatCompare = dateToNumber date;

                    if ((typeName _float == "SCALAR") && {_float > (_floatCompare - 0.000032)} && {_float < (_floatCompare + 0.000032)}) then {

                        {if ((_x != leader group _x) && {!(_x in playableUnits)}) then {deleteVehicle _x}} forEach units group _unit;

                        _unit addRating (0 - (rating _unit));

                        _unit addRating _rating;

                        [_read,"loadGroupINIDB",_unit,inidbi] call INCON_fnc_persHandler;

                        if (_groupSize >= 5) then {

                            sleep 0.1;

                            [_read2,"loadLargeGroupINIDB",_unit,inidbi] call INCON_fnc_persHandler;

                            if (_groupSize >= 9) then {

                                sleep 0.1;

                                [_read3,"loadLargeGroupINIDB",_unit,inidbi] call INCON_fnc_persHandler;
                            };
                        };
                    };
                };
			};

        	case "saveGroup" : {

        		switch (_saveType) do {

        			case "loop": {
        				[_unit] spawn {
        					params ["_unit"];
        					private ["_groupData","_dataKey","_encodedData","_secondIteration"];

        					sleep 180;

        					waitUntil {

        						sleep 57;

        	                    _encodedData = [[_unit],"saveGroupINIDB",_unit,inidbi] call INCON_fnc_persHandler;

								sleep 1;

            	                _dataKey = format ["INC_persGroupData%1%2",_unit,(getPlayerUID _unit)];

        	                    ["write", [(str missionName), _dataKey, _encodedData]] call inidbi;

                                sleep 1;

                                if (count units group _unit >= 6) then {
                                    private ["_encodedData2"];
            	                    _encodedData2 = [[_unit,"second"],"saveGroupINIDB",_unit,inidbi] call INCON_fnc_persHandler;
                	                _dataKey2 = format ["INC_persGroupData2%1%2",_unit,(getPlayerUID _unit)];
            	                    ["write", [(str missionName), _dataKey2, _encodedData2]] call inidbi;
                                };

                                if (count units group _unit >= 11) then {
                                    private ["_encodedData3"];
            	                    _encodedData3 = [[_unit,"third"],"saveGroupINIDB",_unit,inidbi] call INCON_fnc_persHandler;
                	                _dataKey3 = format ["INC_persGroupData3%1%2",_unit,(getPlayerUID _unit)];
            	                    ["write", [(str missionName), _dataKey3, _encodedData3]] call inidbi;
                                };

        						!(isPlayer _unit)

        					};
        				};
        			};

        			case "onExit": {
        				[_unit] spawn {
        					params ["_unit"];
        					private ["_groupData","_dataKey"];

        					sleep 60;

        	                _dataKey = format ["INC_persGroupData%1%2",_unit,(getPlayerUID _unit)];

							waitUntil {

								sleep 5;

								!(isPlayer _unit)

							};

    	                    _encodedData = [_unit,"saveGroupINIDB",_unit,inidbi] call INCON_fnc_persHandler;
    	                    ["write", [(str missionName), _dataKey, _encodedData]] call inidbi;

        				};
                    };
        		};
            };
        };
	};
};
