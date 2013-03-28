
:: Name: latestSIDMG.bat
::
:: Author: Diana Morosan (TCD)
::
:: Purpose: Move the magnetometer and SID data from the shared folder of the AWESOME machine
::			to the data directory of the Callisto machine
::
:: Last edit: 2013-Mar-28 (Eoin Carley) -Clean up

copy /y "S:\latestSID\*latestSID*.png" "C:\Inetpub\wwwroot\data\realtime\SID"

copy /y "M:\latestMAG\*latestMAG_BxByBz*.png" "C:\Inetpub\wwwroot\data\realtime\magnetometer"

copy /y "M:\latestMAG\*latestMAG_DHZ*.png" "C:\Inetpub\wwwroot\data\realtime\magnetometer"