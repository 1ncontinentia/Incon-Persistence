/*

Group Persistence Handler

Author: Incontinentia

*/

params [["_input",objNull],["_operation","copy"],["_leader",objNull],["_dataBase",objNull]];

private ["_return"];

_return = false;

switch (_operation) do {

	case "copyCargo": {
		_input params ["_origin",["_transfer",false],["_destination",objNull]];

		private ["_movedCargo"];

		_movedCargo = [];

		for "_i" from 0 to ((count (everyContainer _origin))-1) do {
			private ["_container","_contents"];
			_container = ((everyContainer _origin) select _i);
			_contents = (itemcargo (_container select 1)) + (magazinecargo (_container select 1)) + (weaponcargo (_container select 1));
			{_movedCargo pushBack _x} forEach _contents;
			_movedCargo pushBack (_container select 0);
		};

		{_movedCargo pushBack _x} forEach ((itemcargo _origin) + (magazinecargo _origin) + (weaponcargo _origin));

		if (_transfer) then {
			clearItemCargoGlobal _origin;
			clearWeaponCargoGlobal _origin;
			clearMagazineCargoGlobal _origin;
			{_destination addItemCargoGlobal [_x,1]} forEach (_movedCargo);
		};

		//hint format ["Origin: %1, Destination: %2, Cargo List: %3",_origin,_destination,_movedCargo];

		_return = _movedCargo;

	};

	case "saveContents": {

		_input params [["_unit",player],["_radius",5]];

		_persistentStorageArray = (nearestObjects [_unit, ["ReammoBox_F"],(_radius * 4)]) select {(_x getVariable ["INC_persistentStorage",false])};

		if (count _persistentStorageArray == 0) then {_persistentStorageArray = (_unit nearEntities [["LandVehicle","Ship","Air"],(_radius * 4)]) select {(_x getVariable ["INC_persistentStorage",false])}};

		if (count _persistentStorageArray == 0) exitWith {_return = false};

		inidbiCargo = ["new", "INC_cargoPersDB"] call OO_INIDBI;

		if (isNil "INC_NewKey") exitWith {diag_log "Incon persistence: New key not found, unable to save cargo."; _return = false};

		{
			private ["_contentsKey","_crateKey","_crateDetails","_contents"];

			_crateKey = format ["INC_persCargoData%1%2%3Crate",_x,INC_NewKey];
			_crateDetails = [(typeOf _x),(getPosWorld _x),damage _x];

			_contentsKey = format ["INC_persCargoData%1%2%3",_x,INC_NewKey];
			_contents = [[_x,false],"copyCargo"] call INCON_fnc_cargoHandler;

			["write", [(str missionName), _crateKey, _crateDetails]] call inidbiCargo;
			["write", [(str missionName), _contentsKey, _contents]] call inidbiCargo;
		} forEach _persistentStorageArray;

		_return = true;
	};

	case "loadContents": {

		_input params ["_container"];

		inidbiCargo = ["new", "INC_cargoPersDB"] call OO_INIDBI;

		_contentsKey = format ["INC_persCargoData%1%2%3",_container,INC_OldKey];
		_crateKey = format ["INC_persCargoData%1%2%3Crate",_container,INC_OldKey];

		_crateDetails = ["read", [(str missionName), _crateKey,[]]] call inidbiCargo;

		_contents = ["read", [(str missionName), _contentsKey,[]]] call inidbiCargo;

		_crateDetails params ["_type","_pos","_damage"];

		//deleteVehicle _container;
		//_container = _type createVehicle [0,0,0];

		clearItemCargoGlobal _origin;
		clearWeaponCargoGlobal _origin;
		clearMagazineCargoGlobal _origin;

		_container setPosWorld _pos;

		_container setDamage _damage;
		{_container addItemCargoGlobal [_x, 1]} forEach _contents;

		_container setVariable ["INC_persistentStorage",true,true];

		_return = true;
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

		if ((count _containerArray == 0) && {_attempt <= 3}) then {_attempt = 3; _containerArray =  (nearestObjects [_unit, ["ReammoBox_F"],_radius]) select {!(_x getVariable ["INC_persistentStorage",false])}};

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
			[[_activeContainer,true,(_persistentStorageArray select 0)],"copyCargo"] call INCON_fnc_cargoHandler;

			[[(_persistentStorageArray select 0),10],"saveContents"] call INCON_fnc_cargoHandler;
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
					//hint "Cargo transferred.";
				} else {
					//hint "Transfer failed.";
				};

			},[],1,false,true,"","(_this == _target)"
		];

		if (_temporary) then {

			[_unit,_duration] spawn {

				params ["_unit",["_timer",12]];

				waitUntil {
					sleep 3;
					_timer = _timer - 3;

					(!([[_unit],"findNearCrate"] call INCON_fnc_cargoHandler) || {_timer <= 0})
				};

				_unit removeAction INC_transferCargoAction;

				_unit setVariable ["INC_cargoActionsActive",false];
			};
		};

		_return = true;
	};

	case "addCargoActions": {

		_input params ["_unit"];

		_unit addEventHandler ["InventoryClosed", {

			params ["_unit"];

			[[_unit,5],"saveContents"] call INCON_fnc_cargoHandler;

			if ([[_unit],"findNearCrate"] call INCON_fnc_cargoHandler) then {
				[[_unit,true,4],"cargoAction"] call INCON_fnc_cargoHandler;
			};
		}];
	};
};

_return;
