["saveGroup",player] call INCON_fnc_groupPersist;

waitUntil {
    sleep 1;
    (!isNil "INC_OldKey")
};

["loadGroup",player] call INCON_fnc_groupPersist;
