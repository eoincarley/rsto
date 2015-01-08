;
; Name: latest_goes
; 
; Purpose: 
;   -Retrieve the GOES light curve between the two input times. Lightcurves are from the NOAA
;    text file of 1 or 5 minute data at http://www.swpc.noaa.gov/ftpdir/lists/xray/
;
; Input parameters:
;   -tstart: Start time, in format of string 'YYYYMMDD_HHMMSS'
;   -tend: End time, in format of string 'YYYYMMDD_HHMMSS'
;
; Keywords:
;   -None
;
; Ouputs:
;   -Returns a 3 column array of times, low goes channel, high goes channel
;
;   Notes:
;   -GOES object is much better way of plotting data. Wrote this so I could have better
;    control over plot appearance.
;   
;   Last modified:
;   - 16-Nov-2011 (E.Carley) Added all_day keyword
;   - 28-Mar-2013 (E. carley) Cleaned up time formatting and added readcol
; 	- 29-Mar-2013 (E.Carley) - Set up version control system for all IDL scripts. all 'v1' 'v2'
;							   suffixes have been removed from codes
;
;
;
function latest_goes, tstart, tend, ALL_DAY=ALL_DAY, REMOTE = REMOTE

;-------- Define URL and path of the NOAA GOES text file ----------
;url = 'http://services.swpc.noaa.gov'
;root = 'text/'   ; location of GOES text file on SWPC server.
;http://satdat.ngdc.noaa.gov/sem/goes/data/  ;location of all day file on SWPC server.

url = 'ftp://ftp.sec.noaa.gov/pub/lists/xray/'

;--------------- Get correct time formats --------------------
get_utc, ut
date_today = time2file(ut, /date)
date_chosen = time2file( anytim(file2time(tstart),/utim), /date)


;--------- Check to see if today's GOES is needed ----------------
IF keyword_set(all_day) THEN BEGIN
  file=date_chosen +'_Gp_xr_1m.txt'
  file_latest = 'Gp_xr_1m.txt'
ENDIF ELSE BEGIN  
  IF date_chosen eq date_today THEN BEGIN
      file = 'Gp_xr_1m.txt'
  ENDIF ELSE BEGIN
      file = date_chosen+'_Gp_xr_1m.txt'
  ENDELSE
ENDELSE 

; 'file' should be copied over from the AWESOME machine. In the event that the copy
; is unsuccesful, download directly to CALLISTO machine.
IF file_test(file) eq 0 then sock_copy, url+file, /clobber


IF file_test(file) THEN BEGIN
  readcol, file, y, m, d, hhmm, mjd, sod, short_channel, long_channel
  ;The following could be cleaned up.
  IF keyword_set(all_day) THEN BEGIN
      readcol, file_latest, yl, ml, dl, hhmml, mjdl, sodl, short_channell, long_channell
      latest_goes_index = where(hhmml eq hhmm[n_elements(hhmm)-1])
      goes_index_stop = n_elements(yl)-1
      y = [y, yl[latest_goes_index+1:goes_index_stop]]
      m = [m, ml[latest_goes_index+1:goes_index_stop]]
      d = [d, dl[latest_goes_index+1:goes_index_stop]]
      hhmm = [hhmm, hhmml[latest_goes_index+1:goes_index_stop]]
      mjd = [mjd, mjdl[latest_goes_index+1:goes_index_stop]]
      sod = [sod, sodl[latest_goes_index+1:goes_index_stop]]
      short_channel = [short_channel, short_channell[latest_goes_index+1:goes_index_stop]]
      long_channel = [long_channel, long_channell[latest_goes_index+1:goes_index_stop]]
  ENDIF     

  ;-------- Time in correct format --------
  time  = strarr(n_elements(y))
  time[*] = string(y[*], format='(I04)') + string(m[*], format='(I02)') $
  		  + string(d[*], format='(I02)') + '_' + string(hhmm[*], format='(I04)')


  ;-------- Get start and stop indices -----
  time = anytim(file2time(time,/yohkoh), /utime)
  indices = closest( time, anytim(file2time(tstart), /utime) )
  index_start = indices[0]
  indices = closest( time, anytim(file2time(tend),/utime) )
  index_stop = indices[n_elements(indices)-1]


  ;------- Build data array --------------
  rows = abs(index_start - index_stop) + 1
  goes_array = dblarr(3,rows)
  goes_array[0,*] = time[index_start:index_stop]
  goes_array[1,*] = long_channel[index_start:index_stop]
  goes_array[2,*] = short_channel[index_start:index_stop]
  
ENDIF ELSE BEGIN
  print, 'Unsuccesful GOES data read. Returning empty GOES data array.'
  goes_array = dblarr(3,1)
ENDELSE

return, goes_array

END