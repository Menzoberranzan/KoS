CLEARSCREEN. PARAMETER Target_ap,Target_pe. SET ship:control:pilotmainthrottle to 0. SET Variable_Thrust to 0.
LOCK throttle to Variable_Thrust. LOCK steering TO Burn_vector. SET Mode to "Hohmann Xfer".
Set Target_Orb to ((Target_ap+Target_pe)/2). SET Vt to SQRT(BODY:MU/(BODY:RADIUS + Target_Orb)).
lock Velocity_target to sqrt( body:mu / ( ship:altitude + body:radius)). LOCK Burn_velocity to Velocity_target - ship:Velocity:orbit:mag. 
WHEN maxthrust = 0 Then {Stage. Preserve.}

FUNCTION Printer2 {PARAMETER Mode,Burn_velocity.	CLEARSCREEN.
	PRINT ("Mode Set:  " + Mode) at(2,1). //SET TERMINAL:WIDTH to 30. SET TERMINAL:HEIGHT to 12.
	PRINT ("Radar:     " + ROUND(alt:Radar/1000,1) + "         ") at(2,2).
	PRINT ("Apoapsis:  " + ROUND(alt:Apoapsis/1000,1) + "         ") at(2,3).
	PRINT ("Periapsis: " + ROUND(alt:Periapsis/1000,1) + "         ") at(2,4).
	PRINT ("ETA to Ap: " + ROUND(ETA:Apoapsis,1) + "         ") at(2,5).
	PRINT ("oVelocity: " + ROUND(ship:Velocity:orbit:mag,1) + "         ") at(2,7).
	PRINT ("BVelocity: " + ROUND(Burn_velocity,1) + "         ") at(2,9).}
	
FUNCTION Time_warp { PARAMETER eta_to.
	IF alt:Radar > 250000 and eta_to > 2000 SET warp to 5.
	ELSE IF alt:Radar > 120000 and eta_to > 1000 SET warp to 4.
	ELSE IF eta_to > 150 SET warp to 3.
	ELSE IF eta_to > 50 SET warp to 2.
	ELSE IF eta_to > 25 SET warp to 1.
	ELSE SET warp to 0. }
	
FUNCTION Burn { PARAMETER Vector_p,min_number,x,y. SET Burn_vector to Vector_p.
	WAIT UNTIL vang(ship:Facing:vector, Vector_p) < 2.
	SET Variable_Thrust to min(min_number,(x/y)).}

UNTIL MODE = "Lower Apoapsis" { Printer2(Mode,Burn_velocity).
	IF Mode = "Hohmann Xfer" { UNTIL alt:Apoapsis > (Target_ap*.9985) {
			Printer2(Mode,Burn_velocity). Burn(Prograde:vector,1,Target_ap*.9985-alt:Apoapsis,20000). Wait .1.}
		SET Variable_Thrust to 0. SET MODE to "Transfer". }
	IF Mode = "Transfer" { Time_warp(eta:Apoapsis). SET Burn_vector to Prograde.
		WHEN eta:Apoapsis < 15 Then { SET MODE to "Circulation". }}
	IF Mode = "Circulation" { UNTIL alt:Periapsis > Target_pe*1.0015 {
			Printer2(Mode,Burn_velocity). Burn(Prograde:vector,1,Burn_velocity,50). Wait .1.}
		SET Variable_Thrust to 0. SET MODE to "Lower Apoapsis". }
	WAIT .1.}	
	
UNTIL MODE = "Orbit Complete" { Printer2(Mode,Burn_velocity).
	IF MODE = "Lower Apoapsis" { IF Target_ap > alt:Apoapsis SET MODE to "Raise Periapsis".
		ELSE {Time_warp(eta:Periapsis). SET Burn_vector to Retrograde:vector. WHEN eta:Periapsis < 15 Then SET MODE to "Lowering Apoapsis".}}
	IF MODE = "Lowering Apoapsis" { UNTIL Target_ap*.9985 > alt:Apoapsis { Printer2(Mode,Burn_velocity).
		Burn(Burn_vector,.2,Burn_velocity,50). Wait .1.} SET Variable_Thrust to 0. SET MODE to "Raise Periapsis". }
	IF MODE = "Raise Periapsis" {
		IF alt:Apoapsis > Target_ap SET MODE to "Lower Apoapsis".
		ELSE IF Target_pe > alt:Periapsis { Time_warp(eta:Apoapsis). SET Burn_vector to Prograde:vector. 
			WHEN eta:Apoapsis < 15 Then SET MODE to "Raising Periapsis".}
		ELSE SET MODE to "Orbit Complete".}
	IF MODE = "Raising Periapsis" { UNTIL alt:Periapsis > Target_pe*1.0015 { Printer2(Mode,Burn_velocity).
		Burn(Burn_vector,.2,Burn_velocity,50). Wait .1.} SET Variable_Thrust to 0. SET MODE to "Lower Apoapsis". }
	WAIT .1.}