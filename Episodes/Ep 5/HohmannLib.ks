@LAZYGLOBAL OFF. PARAMETER Target_ap,Target_pe.

FUNCTION Printer_hohmann {PARAMETER Mode. Printer().
	PRINT ("Mode Set:  " + Mode) at(2,1).
	PRINT ("ETA to Ap: " + ROUND(ETA:Apoapsis,1) + "         ") at(2,2).
	PRINT ("Circ dV:   " + ROUND(Circ_Delta_v(),1) + "         ") at(2,8).}
	
LOCAL Mode is "Hohmann Xfer". LOCAL Burn_vector is Prograde:vector. LOCAL Variable_Thrust is 0.
LOCK steering TO lookdirup(Burn_vector,ship:facing:topvector). LOCK throttle to Variable_Thrust.
WHEN maxthrust = 0 Then {Stage. Preserve.}

UNTIL MODE = "Orbit Complete" { Printer_hohmann(Mode).
	IF Mode = "Hohmann Xfer" { SET Burn_vector to Prograde:vector.
		Burn(Burn_vector,1,Target_ap*.9985-alt:Apoapsis,20000).
		WHEN alt:Apoapsis > (Target_ap*.9985) Then {SET Variable_Thrust to 0. SET MODE to "Transfer". }}
	IF Mode = "Transfer" { Time_warp_eta(eta:Apoapsis). SET Burn_vector to Prograde:vector. 
		WHEN eta:Apoapsis < 15 Then { SET MODE to "Circulation". }}
	IF Mode = "Circulation" { SET Burn_vector to Prograde:vector. Burn(Burn_vector,1,Circ_Delta_v(),50).
		WHEN alt:Periapsis > Target_pe*1.0015 Then { SET Variable_Thrust to 0. SET MODE to "Lower Apoapsis". }}
	IF MODE = "Lower Apoapsis" { IF Target_ap > alt:Apoapsis SET MODE to "Raise Periapsis".
		ELSE {Time_warp_eta(eta:Periapsis). SET Burn_vector to Retrograde:vector. WHEN eta:Periapsis < 15 Then SET MODE to "Lowering Apoapsis".}}
	IF MODE = "Lowering Apoapsis" { Burn(Burn_vector,.2,Circ_Delta_v(),50).
		WHEN Target_ap*.9985 > alt:Apoapsis Then { SET Variable_Thrust to 0. SET MODE to "Raise Periapsis". }}
	IF MODE = "Raise Periapsis" {
		IF alt:Apoapsis > Target_ap SET MODE to "Lower Apoapsis".
		ELSE IF Target_pe > alt:Periapsis { Time_warp_eta(eta:Apoapsis). SET Burn_vector to Prograde:vector. 
			WHEN eta:Apoapsis < 15 Then SET MODE to "Raising Periapsis".}
		ELSE SET MODE to "Orbit Complete".}
	IF MODE = "Raising Periapsis" { Burn(Burn_vector,.2,Circ_Delta_v(),50).
		WHEN alt:Periapsis > Target_pe*1.0015 Then { SET Variable_Thrust to 0. SET MODE to "Lower Apoapsis". }}
	WAIT .1.}