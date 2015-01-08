
:: Name: latestSIDMG.bat
::
:: Author: Diana Morosan (TCD)
::
:: Purpose: Move the magnetometer, SID a data from the shared folder of the AWESOME machine
::			to the data directory of the Callisto machine
::
:: Last edit: 2013-Mar-28 (Eoin Carley) -Clean up

copy /y "S:\latestSID\*latestSID*.png" "C:\Inetpub\wwwroot\data\realtime\SID"

copy /y "M:\latestMAG\*.png" "C:\Inetpub\wwwroot\data\realtime\magnetometer"

move /y "L:\latestLBA\*.png" "C:\Inetpub\wwwroot\data\realtime\LBA\PNG"

move /y "L:\latestLBA\*.fit" "C:\Inetpub\wwwroot\data\realtime\LBA\FTS"

