["saveGroup",player] call INCON_fnc_groupPersist;

//[[player],"addCargoActions"] call INCON_fnc_cargoHandler; 

waitUntil {
    sleep 1;
    (!isNil "INC_OldKey")
};

["loadGroup",player] call INCON_fnc_groupPersist;
