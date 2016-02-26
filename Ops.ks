CLEARSCREEN. SET ship:control:pilotmainthrottle to 0.

SET Park_orb to 100.
SET Inc to 0.
SET Target_ap to 505.
SET Target_pe to 500.

COPY LaunchLib from 0.
RUN LaunchLib(Park_orb*1000,Inc).
DELETE LaunchLib. 
COPY HohmannLib from 0.
RUN HohmannLib(Target_ap*1000,Target_pe*1000).
DELETE HohmannLib. 