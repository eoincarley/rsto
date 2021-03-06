:: Name: callisto_hourly.bat
::
:: Author: Eoin Carley (TCD)
::
:: Purpose: startup script to define paths an environment variables before IDL is run
::
:: Last edit: 2013-Apr--03 (Eoin Carley) -Added copy command from S:\
 

:: 		Copy the GOES text sheet from the S:\\ folder
:: %_y_%%_m_%%_d_%_Gp_xr_1m.txt
set _y_=%Date:~-4,4%
::year
set _m_=%Date:~-7,2%
::month
set _d_=%Date:~-10,2%
::day

S:
copy /y Gp_xr_1m.txt C:\Inetpub\wwwroot\data\realtime\callisto\fts
copy /y %_y_%%_m_%%_d_%_Gp_xr_1m.txt C:\Inetpub\wwwroot\data\realtime\callisto\fts
C:

echo SolarSoft setup/startup file Revision 1.0
echo Generated by WWW/ssw_install at: Thu Nov 25 08:11:22 2010
echo .

::------------------------------------------::

::		Define Environment Variables		::

::------------------------------------------::

set HOST=lmsal.com
rem Define the location of SolarSoft, SSWDB and the Windows startup
set SSW=C:\ssw
set SSWDB=C:\sswdb
set IDL_STARTUP=C:\ssw\gen\idl\ssw_system\idl_startup_windows.pro
;PREF_SET, 'IDL_PATH', 'C:\MyIDLcodes;<IDL_DEFAULT>', $ /COMMIT 
;PREF_SET, 'IDL_PATH', 'C:\MyIDLcodes\', $ /COMMIT
rem A personal startup can be defined by editing the following statement
set SSW_PERSONAL_STARTUP=c:\MyIDLcodes\idl_startup.pro

rem   A default set of instruments be defined by editing the following
set SSW_INSTR=ethz norp nrh ovsa sxig12 sxig13

rem Optional Instrument specific setup/startup

rem   If you are not using the default version of IDL, add a path below
CMDOW /MA


::------------------------------------------::

::		Run IDL with Appropriate script		::
::			(callisto_hourly_batch)			::

::------------------------------------------::

cd C:\Program Files\ITT\IDL71\idlde
start /min idl C:\MyIDLcodes\callisto_hourly_batch &

cd C:\Inetpub\wwwroot\callisto\data\realtime\fts\
copy /y '.' C:\Inetpub\wwwroot\callisto\data\Copy_of_realtime

CMDOW /UW
