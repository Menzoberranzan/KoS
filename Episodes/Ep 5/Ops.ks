CLEARSCREEN. SET ship:control:pilotmainthrottle to 0.

SET Park_orb to 90.
SET Inc to 0.
SET Target_pe to 50.
SET Mission to Mun.

COPY Library from 0.
COPY LaunchLib from 0.
RUN Library.
RUN LaunchLib(Park_orb*1000,Inc).
DELETE LaunchLib. 
COPY MoonXferLib from 0.
RUN MoonXferLib(Mission,Target_pe*1000).
DELETE MoonXferLib.