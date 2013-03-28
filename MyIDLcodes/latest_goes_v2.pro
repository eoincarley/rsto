;
; Name: latest_goes_v2
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
; - 28-Mar-2013 (E. carley) Cleaned up time formatting and added readcol
;
;
function latest_goes_v2, tstart, tend, ALL_DAY=ALL_DAY

;-------- Define URL and path of the NOAA GOES text file ----------
url = 'http://www.swpc.noaa.gov'
root = '/ftpdir/lists/xray/'

;--------------- Get correct time formats --------------------
get_utc, ut
date_today = time2file(ut, /date)
date_chosen = time2file( anytim(file2time(tstart),/utim), /date)


;--------- Check to see if today's GOES is needed ----------------

IF keyword_set(all_day) THEN BEGIN
  file=date_chosen +'_Gp_xr_1m.txt'
ENDIF ELSE BEGIN  
  IF date_chosen eq date_today THEN BEGIN
      file = 'Gp_xr_1m.txt'
  ENDIF ELSE BEGIN
      file = date_chosen+'_Gp_xr_1m.txt'
  ENDELSE
ENDELSE 

;--------- Copy data from url -----------

  data = sock_find(url, file, path=root)
IF n_elements(data) gt 1 THEN BEGIN
  sock_copy, data[n_elements(data)-1]
  readcol,'GP_xr_1m.txt', y, m, d, hhmm, mjd, sod, short_channel, long_channel

  ;-------- Time in correct format --------
  time  = strarr(n_elements(y))
  time[*] = string(y[*], format='(I04)') + string(m[*], format='(I02)') + string(d[*], format='(I02)') + '_' + string(hhmm[*], format='(I04)')


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
  return,goes_array
ENDIF ELSE BEGIN
  print,' '
  print, 'Copy of '+file+' from : '+url+root+' unsuccessful' 
  print,' '
  goes_array = [0,0,0] ;dummy goes array
  return, goes_array
ENDELSE

END