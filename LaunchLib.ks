@LAZYGLOBAL OFF. PARAMETER Park_orb,Inc. 

FUNCTION Printer_launch { PARAMETER Mode,Azimuth,PitchAxis. Printer(). 
	PRINT ("Mode Set:  " + Mode) at(2,1).
	PRINT ("Azimuth:   " + ROUND(Azimuth,1) + "         ") at(2,2).
	PRINT ("Pitch:     " + ROUND(PitchAxis,1) + "         ") at(2,3).
	PRINT ("TWR:       " + ROUND(TWR(),1) + "         ") at(2,8).
	PRINT ("ETA to Ap: " + ROUND(ETA:Apoapsis,1) + "         ") at(2,9).}

FUNCTION Launch_azimuth_init { PARAMETER Park_orb,Inc.
    LOCAL Launch_latitude is ship:latitude. LOCAL data is LIST(). LOCAL Launch_node is "Ascending".
    IF Inc < 0 { SET Launch_node to "Descending". SET Inc to ABS(Inc).}
    LOCAL Velocity_equatorial is (2 * constant():Pi * body:radius) / body:rotationperiod.
	LOCAL Velocity_parking_orb is sqrt(body:mu/(body:radius + Park_orb)).
    data:ADD(Inc). data:ADD(Launch_latitude). data:ADD(Velocity_equatorial). 
	data:ADD(Velocity_parking_orb). data:ADD(Launch_node). RETURN data.}

FUNCTION Launch_azimuth_calc { PARAMETER data.
    LOCAL Azimuth_inertial is arcsin(max(min(cos(data[0]) / cos(ship:latitude), 1), -1)).
    LOCAL VXRot is data[3] * sin(Azimuth_inertial) - data[2] * COS(data[1]).
    LOCAL VYRot is data[3] * cos(Azimuth_inertial). 
	LOCAL Azimuth is mod(arctan2(VXRot, VYRot) + 360, 360).
    IF data[4] = "Ascending" { return Azimuth. } ELSE IF data[4] = "Descending" {
	IF Azimuth <= 90 { return 180 - Azimuth.} ELSE IF Azimuth >= 270 { return 540 - Azimuth.}}}

LOCAL Data is Launch_azimuth_init(Park_orb,Inc). LOCAL Mode is "LiftOff".
LOCAL Azimuth is 90. LOCAL Variable_Thrust is 0. LOCAL PitchAxis is 90.
LOCK throttle to Variable_Thrust. LOCK steering to R(0,0,-90) + HEADING(Azimuth,PitchAxis).

SAS on. STAGE. SET Variable_Thrust to min(1,(3/TWR())). WHEN maxthrust = 0 Then {STAGE. Preserve.}
WHEN alt:Radar > 30000 Then {Event_allparts("ProceduralFairingDecoupler","jettison"). SET Variable_Thrust to min(1,(3/TWR())).}

UNTIL Circ_Delta_v() < 0.5 { Printer_launch(Mode,Azimuth,PitchAxis). 
	SET Azimuth to Launch_azimuth_calc(data).
	
	IF Mode = "LiftOff" { SET Variable_Thrust to 1. WHEN alt:Radar > 500 Then { SET Mode to "Turn". }}
	IF Mode = "Turn" { SET Variable_Thrust to min(1,(2/TWR())).
		IF alt:Radar <= 50000 SET PitchAxis to (90 - 0.38*SQRT(alt:Radar - 300 )). Else SET PitchAxis to 5.
		WHEN alt:Apoapsis > Park_orb Then { SET Variable_Thrust to 0. SET Mode to "Coast".}}
	IF Mode = "Coast" {
		IF ship:altitude > 70500 and ETA:Apoapsis > 60 SET warp to 3. ELSE IF ship:altitude > 70500 and ETA:Apoapsis > 40 SET warp to 2.
		WHEN ETA:Apoapsis < 30 Then { SET Warp to 0. PANELS on. LIGHTS on. SET Mode to "Insertion". }}
	IF Mode = "Insertion" {
		IF ETA:Apoapsis < 20 { SET Variable_Thrust to 5/(ETA:Apoapsis). SET PitchAxis to -1*ETA:Apoapsis/5. }
		Else IF ETA:Apoapsis > ETA:Periapsis { SET Variable_Thrust to min(1,Circ_Delta_v()/50). SET PitchAxis to (ship:orbit:period-ETA:Apoapsis)/5. }
		Else {SET Variable_Thrust to 0.} }
	WAIT 0.1. }