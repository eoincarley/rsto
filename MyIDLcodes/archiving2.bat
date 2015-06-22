:: Name: archiving2.bat
::
:: Author: Eoin Carley (TCD)
::
:: Purpose: This is file that is run at the end of every day by windows scheduler.
:: 			It moves the contents of 'realtime' into the appropriate YYYY/MM/DD folder
::
:: Last edit: 2013-Nov-8 (Diana Morosan) -adding LBA archiving back 
 
set root=C:\Inetpub\wwwroot\data
set year=%Date:~-4,4%
set month=%Date:~-7,2%
set day=%Date:~-10,2%

cd %root%
mkdir %year%
cd %year%

mkdir %month%
cd %month%

mkdir %day%
cd %day%

mkdir callisto

::-------------------------------------------------::
::
::  Move the Mag and SID data to appropriate folder (edited by Diana Morosan)
:: 
::-------------------------------------------------::

mkdir magnetometer\txt
mkdir magnetometer\png

::move /y "M:\dailyMAG\*.txt" "C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\magnetometer\txt"
::move /y "M:\dailyMAG\*.png" "C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\magnetometer\png"

move /y "C:\Inetpub\wwwroot\data\realtime\magnetometer\testmagpic\*.png" "C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\magnetometer\png"
move /y "C:\Inetpub\wwwroot\data\realtime\magnetometer\testmagpic\*.txt" "C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\magnetometer\txt"

mkdir sid\txt
mkdir sid\png

move /y "S:\dailySID\*.png" "C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\sid\png"
move /y "S:\dailySID\*.txt" "C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\sid\txt"

::-------------------------------------------------::
::
::  Move the LBA data to appropriate folder (edited by Diana Morosan)
:: 
::-------------------------------------------------::

mkdir lba\fts
mkdir lba\png

move /y "C:\Inetpub\wwwroot\data\realtime\LBA\PNG\*.png" "C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\lba\png"
move /y "C:\Inetpub\wwwroot\data\realtime\LBA\FTS\*.fit" "C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\lba\fts"

::-------------------------------------------------::
::
::   Move the Callisto data to appropriate folder
:: 
::-------------------------------------------------::

cd callisto
mkdir fts
mkdir png

cd C:\Inetpub\wwwroot\data\realtime\callisto\fts\
move /y *%year%%month%%day%* %root%\%year%\%month%\%day%\callisto\fts

cd C:\Inetpub\wwwroot\data\realtime\callisto\png\
move /y *%year%%month%%day%* %root%\%year%\%month%\%day%\callisto\png



