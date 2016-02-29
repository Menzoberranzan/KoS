@LAZYGLOBAL OFF. RUN Library.
	
FUNCTION Time_warp_alt { 
	IF alt:Radar > 250000 SET warp to 5.
	ELSE IF alt:Radar > 120000 SET warp to 4.
	ELSE IF alt:Radar > 100000 SET warp to 3.
	ELSE IF alt:Radar > 80000 SET warp to 2.
	ELSE IF alt:Radar > 75000 SET warp to 1.
	ELSE SET warp to 0.}
	
LOCAL Burn_vector is Retrograde:vector. LOCAL Variable_Thrust is 0. LOCAL Mode is "Lower Periapsis".
LOCK steering TO lookdirup(Burn_vector,ship:facing:topvector). LOCK throttle to Variable_Thrust.

UNTIL MODE = "Landed" { Printer(). PRINT ("Mode Set:  " + Mode) at(2,1).
	IF Mode = "Lower Periapsis" { SET Burn_vector to Retrograde:vector. WAIT 5. SET Variable_Thrust to .5.
		WHEN alt:Periapsis < 30000 Then { SET Variable_Thrust to 0. SET MODE to "Re-entry". }}
	IF Mode = "Re-entry" { Time_warp_alt(). SET Burn_vector to Retrograde:vector.
		WHEN alt:Radar < 65000 Then { Event_allparts("ModuleDecouple","decouple"). SET MODE to "Descent". }}
	IF Mode = "Descent" { WHEN alt:Radar < 10000 Then {Action_allparts("RealChuteModule","arm parachute",true). 
		SET Mode to "Landing".}}
	IF Mode = "Landing" { WHEN alt:Radar < 10 Then SET MODE to "Landed".}
	WAIT .1.}