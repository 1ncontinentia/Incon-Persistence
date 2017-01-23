waitUntil {
    sleep 1;
    (hasInterface)
};

[[player],"INC_persist\scripts\initPersServer.sqf"] remoteExec ["execVM",2];
[[player],"INC_persist\scripts\initPersLocal.sqf"] remoteExec ["execVM",player];
