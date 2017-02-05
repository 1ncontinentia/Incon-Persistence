/*

Group Persistence Handler

Author: Incontinentia

(With thanks to hoverguy on the BI forums for the getConfig / mass related code!)

*/

params [["_input",objNull],["_operation","copy"],["_leader",objNull],["_dataBase",objNull]];

private ["_return"];

_return = false;

switch (_operation) do {

	case "getConfig": {

	    _input params["_item"];
		_return = "";
	    switch true do
	    {
	        case (isClass(configFile >> "CfgWeapons" >> _item)): {_return = "CfgWeapons"};
	        case (isClass(configFile >> "CfgMagazines" >> _item)): {_return = "CfgMagazines"};
	        case (isClass(configFile >> "CfgVehicles" >> _item)): {_return = "CfgVehicles"};
	    };
	};

	case "copyCargo": {
		_input params ["_origin",["_transfer",false],["_destination",objNull]];

		private ["_movedItems","_wpnItmsCrgo"];
		_movedItems = [];
		{
			private ["_weapons"];
			private _wpnItmsCrgo = weaponsItemsCargo (_x select 1);
			{for "_i" from 1 to ((count _x - 1)) do {
				private _item = _x select _i;
				if (_item isEqualType "" && {_item != ""}) then {
					if (_i > 0) then {_movedItems pushBack _item};
				} else {
					if (_i == 4 && {!(_item isEqualTo [])}) then {_movedItems pushBack (_item select 0)};
				};
			}} forEach _wpnItmsCrgo;
			{_movedItems pushBack _x} forEach ((itemCargo (_x select 1)) + (magazineCargo (_x select 1)) + (backPackCargo (_x select 1)));
			{_movedItems pushBack ([_x] call BIS_fnc_baseWeapon)} forEach (weaponCargo (_x select 1));
			true
		} count (everyContainer _origin);

		_wpnItmsCrgo = (weaponsItemsCargo _origin);
		{for "_i" from 0 to ((count _x - 1)) do {
			private _item = _x select _i;
			if (_item isEqualType "" && {_item != ""}) then {
				if (_i > 0) then {_movedItems pushBack _item};
			} else {
				if (_i == 4 && {!(_item isEqualTo [])}) then {_movedItems pushBack (_item select 0)};
			};
		}} forEach _wpnItmsCrgo;
		{_movedItems pushBack _x} forEach ((itemCargo _origin) + (magazineCargo _origin) + (backPackCargo _origin));
		{_movedItems pushBack ([_x] call BIS_fnc_baseWeapon)} forEach (weaponCargo _origin);

		_return = _movedItems;

		if (_transfer) then {

			_destCargo = [];

			{
				private ["_weapons"];
				private _wpnItmsCrgo = weaponsItemsCargo (_x select 1);
				{for "_i" from 1 to ((count _x - 1)) do {
					private _item = _x select _i;
					if (_item isEqualType "" && {_item != ""}) then {
						if (_i > 0) then {_destCargo pushBack _item};
					} else {
						if (_i == 4 && {!(_item isEqualTo [])}) then {_destCargo pushBack (_item select 0)};
					};
				}} forEach _wpnItmsCrgo;
				{_destCargo pushBack _x} forEach ((itemCargo (_x select 1)) + (magazineCargo (_x select 1)) + (backPackCargo (_x select 1)));
				{_movedItems pushBack ([_x] call BIS_fnc_baseWeapon)} forEach (weaponCargo (_x select 1));
				true
			} count (everyContainer _destination);

			_wpnItmsCrgo = (weaponsItemsCargo _destination);
			{for "_i" from 1 to ((count _x - 1)) do {
				private _item = _x select _i;
				if (_item isEqualType "" && {_item != ""}) then {
					if (_i > 0) then {_destCargo pushBack _item};
				} else {
					if (_i == 4 && {!(_item isEqualTo [])}) then {_destCargo pushBack (_item select 0)};
				};
			}} forEach _wpnItmsCrgo;
			{_destCargo pushBack _x} forEach ((itemCargo _destination) + (magazineCargo _destination) + (backPackCargo _destination));
			{_movedItems pushBack ([_x] call BIS_fnc_baseWeapon)} forEach (weaponCargo _destination);

			_totalCargo = _movedItems + _destCargo;

			_destCapacity = getNumber(configFile >> "CfgVehicles" >> (typeOf _destination) >> "maximumLoad");

		    _totalMass = 0;
		    _return = false;

			diag_log _movedItems;

		    {
		        _itemClass = [[_x],"getConfig"] call INCON_fnc_cargoHandler;
		        _mass = getNumber(configFile >> _itemClass >> _x >> "mass");
		        _totalMass = _mass + _totalMass;
		    } forEach _movedItems;

		    if (_totalMass > _destCapacity) exitWith {_return = false};

			_return = true;

			clearItemCargoGlobal _origin;
			clearWeaponCargoGlobal _origin;
			clearMagazineCargoGlobal _origin;
			clearBackpackCargoGlobal _origin;

			clearItemCargoGlobal _destination;
			clearWeaponCargoGlobal _destination;
			clearMagazineCargoGlobal _destination;
			clearBackpackCargoGlobal _destination;
			{_destination addItemCargoGlobal [_x, 1]} forEach (_totalCargo select {!(_x isKindOf "Bag_Base")});
			{_destination addBackpackCargoGlobal [(_x call BIS_fnc_basicBackpack),1]} forEach (_totalCargo select {_x isKindOf "Bag_Base"});
		};
	};

	case "saveContents": {

		_input params [["_unit",player],["_radius",3]];

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

		if (isNil "INC_OldKey") exitWith {_return = false};

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
			_return = [[_activeContainer,true,(_persistentStorageArray select 0)],"copyCargo"] call INCON_fnc_cargoHandler;

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
					//hint "Cargo transferred to nearest persistent container.";
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
