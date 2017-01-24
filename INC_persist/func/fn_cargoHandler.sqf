/*

Group Persistence Handler

Author: Incontinentia

*/

params [["_input",objNull],["_operation","copy"],["_leader",objNull],["_dataBase",objNull]];

private ["_return"];

_return = false;

switch (_operation) do {

	case "copyCargo": {
		_input params ["_origin","_destination",["_moveCargo",true]];

		private ["_movedCargo"];

		_movedCargo = [];

		for "_i" from 0 to ((count (everyContainer _origin))-1) do {
			private ["_container","_contents"];
			_container = ((everyContainer _origin) select _i);
			_contents = (itemcargo (_container select 1)) + (magazinecargo (_container select 1)) + (weaponcargo (_container select 1));
			{_movedCargo pushBack _x} forEach _contents;
			_movedCargo pushBack (_container select 0);
		};

		if (_moveCargo) then {
			clearItemCargoGlobal _origin;
			{_destination addItemCargoGlobal [_x,1]} forEach (_movedCargo);
		};

		_return = _movedCargo;

	};

	case "findNearCrate": {

		_input params ["_unit",["_transfer",false],["_attempt",1],["_autoReAttempt",true],["_radius",5]];

		private ["_activeContainer","_containerArray","_contents"];

		_persistentStorageArray = (nearestObjects [_unit, ["ReammoBox_F"],(_radius * 4)]) select {(_x getVariable ["INC_persistentStorage",false])};

		if (count _persistentStorageArray == 0) then {_persistentStorageArray = (_unit nearEntities [["LandVehicle","Ship","Air"],(_radius * 4)]) select {(_x getVariable ["INC_persistentStorage",false])}};

		if (count _persistentStorageArray == 0) exitWith {_return = false};

		_containerArray = [];

		if (_attempt <= 1) then {_containerArray = (nearestObjects [_unit, ["GroundWeaponHolder"],_radius])};

		if ((count _containerArray == 0) && {_attempt <= 2}) then {_attempt = 2; _containerArray = (_unit nearEntities [["LandVehicle","Ship","Air"],_radius]) select {!(_x getVariable ["INC_persistentStorage",false])}};

		if ((count _containerArray == 0) && {_attempt <= 3}) then {_attempt = 3; _containerArray =  (nearestObjects [_unit, ["ReammoBox_F"],_radius])} select {!(_x getVariable ["INC_persistentStorage",false])}};

		if (count _containerArray == 0) exitWith {_return = false};

		_activeContainer = (_containerArray select 0);

		_contents = (itemCargo _activeContainer) + (magazineCargo _activeContainer) + (weaponCargo _activeContainer) + (everyContainer _activeContainer);

		if (count _contents == 0) exitWith {
			_return = false;
			if (_autoReAttempt && {_attempt <= 2}) then {
				_return = [[_unit,_transfer,(_attempt + 1)],"findNearCrate"] call INCON_fnc_cargoHandler;
			};
		};

		_return = true;

		if (_transfer) then {
			[[_activeContainer,(_persistentStorageArray select 0),true],"copyCargo"] call INCON_fnc_cargoHandler;
		};
	};

	case "cargoAction": {

		_input params ["_unit",["_temporary",true],["_duration",5]];

		if (_unit getVariable ["INC_cargoActionsActive",false]) exitWith {_return = false};

		_unit setVariable ["INC_cargoActionsActive",true];

		INC_transferCargoAction = _unit addAction [
			"<t color='#33FF42'>Transfer cargo to persistent container</t>", {
				params ["_unit"];

				private ["_success"];

				_success = [[_unit,true],"findNearCrate"] call INCON_fnc_cargoHandler;

				if (_success) then {
					hint "Cargo transferred.";
				} else {
					hint "Transfer failed.";
				};

			},[],1,false,true,"","(_this == _target)"
		];

		if (_temporary) then {

			[_unit,_duration] spawn {

				params ["_unit",["_timer",12]];

				waitUntil {
					sleep 3;
					_timer = _timer - 3;

					(!([[_unit],"findNearCrate"] call INCON_fnc_gearHandler) || {_timer <= 0})
				};

				_unit removeAction INC_transferCargoAction;

				_unit setVariable ["INC_cargoActionsActive",false];
			};
		};

		_return = true;
	};

	case "addCargoActions": {

		params ["_unit"];

		_unit addEventHandler ["InventoryClosed", {

			params ["_unit"];
			if ([[_unit],"findNearCrate"] call INCON_fnc_gearHandler) then {
				[[_unit,true,4],"cargoAction"] call INCON_fnc_cargoHandler;
			};
		}];
	};
};

_return;
