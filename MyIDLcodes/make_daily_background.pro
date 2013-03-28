
; Name: make_daily_background.pro
; 
; Purpose: 
;   -Create a background of entire day average of all fts folders in current directory
;    Save current background and restore next time program is run
;
; Input parameters:
;   -None
;
; Keywords:
;   -None
;
; Ouputs:
;   -Background of daily average of all fits files in present folder
;   
; Calling sequence:
;   - result = make_daily_background()
;
; Sub-routines:
;   - running_mean_background.pro
;
;   Last modified:
;   - 10-Nov-2011 (E.Carley) Just a clean up....
;   - 09-Jan-2013 (E.Carley) Since ALL fits files are in the one folder now, need to distinguish which receiver
;                            to search for in the findfile argument.
;
;===========================================================================
function make_daily_background, receiver

get_utc,ut
today = time2file(ut,/date)
today = today+'_000000'
day_begin = anytim(file2time(today),/utim)

files = findfile('*'+receiver+'.fit')
dates = anytim(file2time(files),/utim)
date_times = anytim(file2time(files),/ex)
file_day = string(date_times[6],format='(I4.2)')+$
           string(date_times[5],format='(I2.2)')+$
           string(date_times[4],format='(I2.2)')
                      
latest_file_time = dates[n_elements(dates)-1]
IF file_test('spectra'+receiver+'.sav') eq 1 THEN BEGIN
  restore,'spectra'+receiver+'.sav',/verb
  restore,'times.sav',/verb
  ;restore,'freq.sav',/verb
  
  q = where(x gt day_begin)
  IF q[0] eq -1 THEN BEGIN
    radio_spectro_fits_read,files[0],z,x,y
    FOR i=1,n_elements(files)-1 DO BEGIN
      radio_spectro_fits_read,files[i],z_current,x_current,y_cuurent
      z = [z, z_current]
      x = [x, x_current]
    ENDFOR
    save,z,filename='spectra'+receiver+'.sav'
    save,x,filename='times.sav'
   ENDIF ELSE BEGIN 
  
    x = x[q]
    z = z[q,0:199]
  
    latest_time = x[n_elements(x)-10]
    indices = where(dates gt latest_time)
    IF indices[0] ne -1 THEN BEGIN
      FOR i=indices[0],n_elements(files)-1 DO BEGIN
        radio_spectro_fits_read,files[i],z_current,x_current,y_cuurent
        z = [z, z_current]
        x = [x, x_current]
      ENDFOR
  
      save,z,filename='spectra'+receiver+'.sav'
      save,x,filename='times.sav'
    ENDIF;save,y_current
  ENDELSE
ENDIF ELSE BEGIN             
  radio_spectro_fits_read,files[0],z,x,y
  FOR i=1,n_elements(files)-1 DO BEGIN
      radio_spectro_fits_read,files[i],z_current,x_current,y_cuurent
      z = [z, z_current]
      x = [x, x_current]
  ENDFOR
  save,z,filename='spectra'+receiver+'.sav'
  save,x,filename='times.sav'

ENDELSE

running_mean_background,z,zback
daily_background = dblarr(3600,200)
;daily_background[0:3599,0:199] = zback[0:3599,0:199]
FOR i=0,3599 DO BEGIN
daily_background[i,0:199] = zback
ENDFOR

save,daily_background,filename='daily_backg_'+file_day+'_'+receiver
return,daily_background
END