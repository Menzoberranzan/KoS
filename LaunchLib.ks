CLEARSCREEN. PARAMETER Park_orb,Inc. SET Data to Launch_azimuth_init(Park_orb,Inc). SET ship:control:pilotmainthrottle to 0.
SAS on. SET Azimuth to Launch_azimuth_calc(data). SET Variable_Thrust to 0. SET PitchAxis to 90.
LOCK TWR to ship:maxthrust/((body:mu / ((ship:altitude + body:radius)^2))*ship:mass).
LOCK Velocity_target to sqrt( body:mu / ( ship:altitude + body:radius)). LOCK Velocity_burn to Velocity_target - ship:Velocity:orbit:mag.
LOCK throttle to Variable_Thrust. LOCK steering TO R(0,0,-90) + HEADING(Azimuth,PitchAxis).
lock avail_twr to ship:maxthrust / (g * ship:mass).

FUNCTION Launch_azimuth_init { PARAMETER Park_orb,Inc.
    LOCAL Launch_latitude to SHIP:LATITUDE. LOCAL data to LIST(). LOCAL Launch_node to "Ascending".
    IF Inc < 0 { SET Launch_node to "Descending". SET Inc to ABS(Inc).}
    LOCAL Velocity_equatorial to (2 * CONSTANT():Pi * BODY:RADIUS) / BODY:ROTATIONPERIOD.
	LOCAL Velocity_parking_orb to SQRT(BODY:MU/(BODY:RADIUS + Park_orb)).
    data:ADD(Inc). data:ADD(Launch_latitude). data:ADD(Velocity_equatorial). 
	data:ADD(Velocity_parking_orb). data:ADD(Launch_node). RETURN data.}

FUNCTION Launch_azimuth_calc { PARAMETER data.
    LOCAL Azimuth_inertial to ARCSIN(MAX(MIN(COS(data[0]) / COS(SHIP:LATITUDE), 1), -1)).
    LOCAL VXRot to data[3] * SIN(Azimuth_inertial) - data[2] * COS(data[1]).
    LOCAL VYRot to data[3] * COS(Azimuth_inertial). 
	LOCAL Azimuth to MOD(ARCTAN2(VXRot, VYRot) + 360, 360).
    IF data[4] = "Ascending" { RETURN Azimuth. } ELSE IF data[4] = "Descending" {
        IF Azimuth <= 90 { RETURN 180 - Azimuth.} ELSE IF Azimuth >= 270 { RETURN 540 - Azimuth.}}}

FUNCTION Printer { PARAMETER Mode,Azimuth,PitchAxis,data. 
	CLEARSCREEN.// SET TERMINAL:HEIGHT to 12. SET TERMINAL:WIDTH to 30.
	PRINT ("Mode Set:  " + Mode) at(2,1).
	PRINT ("Azimuth:   " + ROUND(Azimuth,1) + "         ") at(2,2).
	PRINT ("Pitch:     " + ROUND(PitchAxis,1) + "         ") at(2,3).
	PRINT ("TWR:       " + ROUND(TWR,1) + "         ") at(2,4).
	PRINT ("Radar:     " + ROUND(alt:Radar/1000,1) + "         ") at(2,5).
	PRINT ("Apoapsis:  " + ROUND(alt:Apoapsis/1000,1) + "         ") at(2,6).
	PRINT ("Periapsis: " + ROUND(alt:Periapsis/1000,1) + "         ") at(2,7).
	PRINT ("ETA to Ap: " + ROUND(ETA:Apoapsis,1) + "         ") at(2,8).
	PRINT ("oVelocity: " + ROUND(ship:Velocity:orbit:mag,1) + "         ") at(2,10).
	PRINT ("tVelocity: " + ROUND(data[3],1) + "         ") at(2,11).}

FUNCTION Fairings { LIST PARTS in lp. FOR p in lp {
	IF p:modules:contains("ProceduralFairingDecoupler") {
	SET m to p:getmodule("ProceduralFairingDecoupler"). m:doevent("jettison"). }}}

STAGE. SET Mode to "LiftOff". WHEN maxthrust = 0 Then {STAGE. Preserve.} WHEN alt:Radar > 30000 Then {Fairings().}

UNTIL Velocity_burn < 0.5 { Printer(Mode,Azimuth,PitchAxis,data). SET Azimuth to Launch_azimuth_calc(data).
	IF Mode = "LiftOff" { SET Variable_Thrust to 1. WHEN alt:Radar > 500 Then { SET Mode to "Turn". }}
	IF Mode = "Turn" { SET Variable_Thrust to min(1,(2/TWR)).
		IF alt:Radar <= 50000 SET PitchAxis to (90 - 0.38*SQRT(alt:Radar - 300 )). Else SET PitchAxis to 5.
		WHEN alt:Apoapsis > Park_orb Then { SET Variable_Thrust to 0. SET Mode to "Coast".}}
	IF Mode = "Coast" {
		IF ship:altitude > 72000 and ETA:Apoapsis > 60 SET warp to 3. ELSE IF ship:altitude > 72000 and ETA:Apoapsis > 40 SET warp to 2.
		WHEN ETA:Apoapsis < 30 Then { SET Warp to 0. PANELS on. LIGHTS on. SET Mode to "Insertion". }}
	IF Mode = "Insertion" {
		IF ETA:Apoapsis < 20 { SET Variable_Thrust to 5/(ETA:Apoapsis). SET PitchAxis to -1*ETA:Apoapsis/5. }
		Else IF ETA:Apoapsis > ETA:Periapsis { SET Variable_Thrust to min(1,Velocity_burn/50). SET PitchAxis to (ship:orbit:period-ETA:Apoapsis)/5. }
		Else {SET Variable_Thrust to 0.} }
	WAIT 0.1. }