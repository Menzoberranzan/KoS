@LAZYGLOBAL OFF.

FUNCTION TWR { LOCAL ratio is ship:maxthrust/((body:mu / ((ship:altitude + body:radius)^2))*ship:mass).
	IF ratio > 0 RETURN ratio. ELSE RETURN .01.}

FUNCTION Circ_Delta_v { LOCAL Vt is sqrt( body:mu / ( ship:altitude + body:radius)).
	RETURN Vt - ship:Velocity:orbit:mag.}

FUNCTION Event_allparts { PARAMETER module,event. LOCAL Part_list is list(). LIST parts in Part_list. FOR p in Part_list {
	IF p:modules:contains(module) { LOCAL m is p:getmodule(module). m:doevent(event). }}}

FUNCTION Action_allparts { PARAMETER module,mod_action,boolan. LOCAL Part_list is list(). LIST parts in Part_list. FOR p in Part_list {
	IF p:modules:contains(module) { LOCAL m is p:getmodule(module). m:doaction(mod_action,boolan). }}}
	
FUNCTION Burn { PARAMETER Vector_p,min_number,x,y.
	WAIT UNTIL vang(ship:Facing:vector, Vector_p) < 2.
	SET Variable_Thrust to min(min_number,(x/y)).}

FUNCTION Burn_time { PARAMETER Delta_v. LOCAL en is list(). LIST engines in en.
	RETURN 9.82*(ship:Mass*1000)*en[0]:ISP *( 1-constant():E ^(-Delta_v/(9.82*en[0]:ISP))) / (en[0]:MAXTHRUST*1000).}
	
FUNCTION Time_ignition { PARAMETER Mn_node. RETURN ((time:seconds +Mn_node[0] -(Burn_time(Mn_node[2])/2))-time:seconds).}
	
FUNCTION Time_warp_eta { PARAMETER eta_to.
	IF eta_to > 1200 SET warp to 5.
	ELSE IF eta_to > 300 SET warp to 4.
	ELSE IF eta_to > 100 SET warp to 3.
	ELSE IF eta_to > 30 SET warp to 2.
	ELSE IF eta_to > 1 SET warp to 1.
	ELSE SET warp to 0. }
	
FUNCTION Printer {CLEARSCREEN. SET TERMINAL:WIDTH to 30. SET TERMINAL:HEIGHT to 13.
	PRINT ("Radar:     " + ROUND(alt:Radar/1000,1)) at(2,4).
	PRINT ("Apoapsis:  " + ROUND(alt:Apoapsis/1000,1) + "         ") at(2,5).
	PRINT ("Periapsis: " + ROUND(alt:Periapsis/1000,1) + "         ") at(2,6).
	PRINT ("oVelocity: " + ROUND(ship:Velocity:orbit:mag,1) + "         ") at(2,7).}