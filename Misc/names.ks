SET p TO ship:partsdubbed("KzProcFairingSide1")[0].SET MOD TO P:GETMODULE("ProceduralFairingDecoupler").LOG ("These are all the things that I can currently USE GETFIELD AND SETFIELD ON IN " + MOD:NAME + ":") TO NAMELIST.LOG MOD:ALLFIELDS TO NAMELIST.LOG ("These are all the things that I can currently USE DOEVENT ON IN " +  MOD:NAME + ":") TO NAMELIST.LOG MOD:ALLEVENTS TO NAMELIST.LOG ("These are all the things that I can currently USE DOACTION ON IN " +  MOD:NAME + ":") TO NAMELIST.LOG MOD:ALLACTIONS TO NAMELIST.