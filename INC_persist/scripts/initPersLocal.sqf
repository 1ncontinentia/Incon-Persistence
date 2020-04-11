["saveGroup",player] call INCON_fnc_groupPersist;

[[player],"addCargoActions"] call INCON_fnc_cargoHandler;

waitUntil {
    sleep 1;
    (!isNil "INC_OldKey")
};

if (!isNil "INC_oldKey") then {
    ["loadGroup",player] call INCON_fnc_groupPersist;

	{[[_x],"loadContents"] call INCON_fnc_cargoHandler} forEach ((entities [["ReammoBox_F","LandVehicle","Ship","Air"],[],false,false]) select {(_x getVariable ["INC_persistentStorage",false])});
};
