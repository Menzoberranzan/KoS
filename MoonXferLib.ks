@LAZYGLOBAL OFF. PARAMETER Mission,Target_pariaps. CLEARSCREEN.

FUNCTION Printer_Mun_Xfer { PARAMETER Mode,M_node. CLEARSCREEN. Printer().
	PRINT ("Mode Set:  " + Mode) at(2,1).
	PRINT ("Burn Time: " + Time_ignition(M_node) + "         ") at(2,9).
	PRINT ("Burn Durat:" + (Burn_time(M_node[2])) + "         ") at(2,10).
	PRINT ("Mnvr dV:   " + (M_node[2]) + "         ") at(2,11).}
	
FUNCTION Maneuver_calc { PARAMETER Mission,Target_pariaps. LOCAL mn is list().
	LOCAL Target_orb_radius is (Mission:obt:Semimajoraxis -Mission:Radius -Target_pariaps -( Mission:SOIRadius/10 )).
	LOCAL mn_eta is (( mod( 360+(mod(360 + Mission:Longitude - ship:Longitude,360)) 
		- (180*(1-(sqrt(((ship:obt:Semimajoraxis + Target_orb_radius)/(2*Target_orb_radius))^3)))) ,360 ))/((360/ship:obt:Period)-(360/Mission:obt:Period))).
	LOCAL mn_vector is Prograde:vector.
	LOCAL mn_dV is (sqrt (body:MU/ship:obt:Semimajoraxis) * (sqrt((2* Target_orb_radius)/(ship:obt:Semimajoraxis + Target_orb_radius)) - 1)).
	mn:add(mn_eta). mn:add(mn_vector). mn:add(mn_dV). return mn.}
	
LOCAL Mode is "Mun Prep". LOCAL Variable_Thrust is 0. LOCAL Burn_vector is Prograde:vector.
LOCK steering TO lookdirup(Burn_vector,ship:facing:topvector). LOCK throttle to Variable_Thrust.
WHEN maxthrust = 0 Then {Stage. Preserve.}

UNTIL MODE = "Munar Capture Prep" { LOCAL M_node is Maneuver_calc(Mission,Target_pariaps). LOCK steering TO lookdirup(Burn_vector,ship:facing:topvector).
	Printer_Mun_Xfer(Mode,M_node). LOCAL Burn_vector is M_node[1]. LOCK dV to M_node[2].
	
	IF Mode = "Mun Prep" {  Time_warp_eta(Time_ignition(M_node)-10).
		WHEN Time_ignition(M_node) <= 0 Then SET Mode to "Xfer Burn". }
	IF Mode = "Xfer Burn" { BURN(M_node[1],1,Burn_time(dV),ship:maxthrust/ship:mass). 
		WHEN dV < .1 Then { SET Variable_Thrust to 0.  SET Mode to "Munar Xfer".}}
	IF Mode = "Munar Xfer" { Set Warp to 5. 
		WHEN Mun:distance/1000 < 5000 Then { SET Warp to 4. 
			WHEN Body = Mun Then { Set Warp to 0. SET Burn_vector to Retrograde:vector. SET Mode to "Munar Capture Prep". }}}
	Wait .05.}
	
UNTIL MODE = "Orbit Complete" { LOCAL Circularization is list().	Circularization:add(ETA:Periapsis). 
	Circularization:add(retrograde:vector). Circularization:add(-1*Circ_Delta_v()). 
	Printer_Mun_Xfer(Mode,Circularization).
	LOCK steering TO lookdirup(Burn_vector,ship:facing:topvector). LOCAL Burn_vector is Circularization[1]. LOCK dV2 to Circularization[2].
	
	IF Mode = "Munar Capture Prep" { LOCAL Burn_vector is Circularization[1].
		Time_warp_eta(Time_ignition(Circularization)-10). WHEN Time_ignition(Circularization) <= 0 Then SET Mode to "Munar Capture".}
	IF MOde = "Munar Capture" {
		BURN(Circularization[1],1,(alt:periapsis-40000),10000). 
		WHEN alt:periapsis < 40000 Then { SET Variable_Thrust to 0. SET Mode to "Munar Circularization Prep".}}
	IF Mode = "Munar Circularization Prep" { LOCAL Burn_vector is Circularization[1].
		Time_warp_eta(Time_ignition(Circularization)-10). WHEN Time_ignition(Circularization) <= 0 Then SET Mode to "Munar Circularization".}	
	IF MOde = "Munar Circularization" {
		BURN(Circularization[1],1,(Burn_time(Circularization[2])),ship:maxthrust/ship:mass). 
		WHEN dV2 < 1 Then { SET Variable_Thrust to 0. SET Mode to "Orbit Complete".}}
	WAIT .05.}