pro callisto_goes, backg=backg

;   Name: callisto_goes
;
;   Purpose:
;   -This procedure reads in Joe's sunrise and sunset times, stitches current days spectra 
;    between those times, then finds goes data and plots latest CALLISTO and GOES together 
;    for entire day
;
;   Input parameters:
;      -None
;
;   Keyword parametrs:
;      -BACKG - set if background subtract is needed. make_daily_background.pro called on above
; 
;   Outputs:
;      -Saved PNG files of procedure plot
;      
;   Calls on:
;      -stitch_spectra_day
;      -make_daily_background   
;      -latest_goes
;       
;   Last Modified:
;      - 26-Aug-2011 (Eoin Carley) Modified background subtraction
;      - 16-Nov-2011 (Eoin Carley) Now set to call latest_goes_v1 (Used to be latest_goes_allday)
;      - 08-Jan-2013 (E.Carley) Change to realtime fts folder into which live data is written. Need change in
;                               findfile argument to take into account ALL receiver .fts are in the one folder
;	   - 29-Mar-2013 (E.Carley) - Set up version control system for all IDL scripts. all 'v1' 'v2'
;								  suffixes have been removed from codes
;
;=========Get today's date in correct format========
get_utc,ut
today = time2file(ut,/date)
todayhms = time2file(ut,/sec)
spawn,'del '+today+'_Gp_xr_1m.txt'

;=======Get solar ephemeris from suntimes.txt (ouput from Joe's program)=======
  cd,'c:\logs'
  openr,100,'suntimes.txt'
  suntimes = strarr(3)
  readf,100,suntimes
  close,100
  suntimes[0] = today+'_'+StrMid(suntimes[0],10)
  suntimes[1] = today+'_'+StrMid(suntimes[1],9)

  sunrise = suntimes[0]
  sunset = suntimes[1]

;===========Get the GOES data============

goes = latest_goes(sunrise,sunset,/all_day)

;=====Define plotting parameters=======
cd,'C:\Inetpub\wwwroot\data\realtime\callisto\fts\'
set_plot,'ps'
device,filename = 'callisto_goes_all_day.ps',/color,/inches,/landscape,/encapsulate,$
yoffset=12,ysize=10,xsize=12  

loadct,39
!p.color=0
!p.background=255
!p.charsize=1.2

start_time = anytim(file2time(sunrise),/yohkoh,/truncate) ;string for plotting
xstart = anytim( file2time(sunrise), /utim)
xend = anytim( file2time(sunset), /utim)



;=========Plot the goes data==================
utplot,goes[0,*],goes[1,*],thick=1,psym=3,title='1-minute GOES-15 Solar X-ray Flux',$
xtitle='!1 Start time: '+start_time+' (UT)',xrange=[xstart,xend],/xs,$
yrange=[1e-9,1e-3],/ylog,$
position=[0.055,0.69,0.98,0.94],/normal,/noerase

xyouts,0.015, 0.78, 'Watts m!U-2!N',/normal,orientation=90
oplot,goes[0,*],goes[1,*],color=240,thick=2 ;for some reason utplot won't color the line

axis,yaxis=1,ytickname=[' ','A','B','C','M','X',' ']
axis,yaxis=0,yrange=[1e-9,1e-3]

plots,goes[0,*],1e-8
plots,goes[0,*],1e-7
plots,goes[0,*],1e-6
plots,goes[0,*],1e-5
plots,goes[0,*],1e-4
oplot,goes[0,*],goes[1,*],color=230,thick=1.5
oplot,goes[0,*],goes[2,*],color=80,thick=1.5

legend, ['GOES15 0.1-0.8nm','GOES15 0.05-0.4nm'],$
linestyle=[0,0], color=[220,80], box=0,pos=[0.05,0.935],/normal

;============End of goes plot============


;a = '!1 Plot time between sunrise ('+anytim(file2time(sunrise),/yohkoh, /time_only, /truncate)+$
;' UT) and sunset ('+anytim(file2time(sunset),/yohkoh, /time_only, /truncate)+' UT)'
;xyouts,0.5,0.01,a,/normal


;=====Plot dynamic spectra between appropriate times======
loadct,5

;=======The 200-400 MHz data=========
  stitch_spectra_day,'03',sunrise,sunset,z_high,x_high,y_high

  spectro_plot,bytscl(z_high,mean(z_high)-1.5*stdev(z_high),mean(z_high)+8.0*stdev(z_high)),x_high,y_high,/xs,/ys,$
  xrange=[xstart,xend],yr=[400,200],$
  xtitle='Start Time: '+start_time+' (UT)',$
  position=[0.055,0.06,0.98,0.33],/normal,/noerase
  z_high=[0] ;Dump the data otherwise the machine runs out of RAM!


;=======The 100-200 MHz data=========
  stitch_spectra_day,'02',sunrise,sunset,z_mid,x_mid,y_mid

  spectro_plot,bytscl(z_mid,mean(z_mid)-1.5*stdev(z_mid),mean(z_mid)+8.0*stdev(z_mid)),x_mid,y_mid,/xs,/ys,$
  xrange=[xstart,xend],yr=[200,100],ytickinterval=50,ytickname=[' ','150','100'],$
  xticks=2,xtickname=[' ',' ',' ',' ',' ',' ',' '],xtitle=' ',$
  position=[0.055,0.33,0.98,0.46],/normal,/noerase
  z_mid=[0]

;=======The 10-100 MHz data=========
  stitch_spectra_day,'01',sunrise,sunset,z_low,x_low,y_low

  spectro_plot,bytscl(z_low,mean(z_low)-1.5*stdev(z_low),mean(z_low)+8.0*stdev(z_low)),x_low,y_low,/xs,/ys,$
  xrange=[xstart,xend],yr=[100,10],ytickv=[50,10],yticks=1,$
  xticks=2,xtickname=[' ',' ',' ',' ',' ',' ',' '],xtitle=' ',$
  position=[0.055,0.46,0.98,0.59],/normal,/noerase,title='eCallisto (RSTO, Birr, Ireland)'

  y_low=[0]

set_line_color
xyouts,0.015, 0.255, 'Frequency (MHz)',/normal,orientation=90
xyouts, 0.97, 0.56, 'Sunrise: '+anytim(file2time(sunrise),/yohkoh,/truncate), $
/normal, alignment = 1.0, charthick=7.0, color=1
xyouts, 0.97, 0.56, 'Sunrise: '+anytim(file2time(sunrise),/yohkoh,/truncate), $
/normal, alignment = 1.0, charthick=2.0, color=0


xyouts, 0.97, 0.54, 'Sunset: '+anytim(file2time(sunset),/yohkoh,/truncate), $
/normal, alignment = 1.0, charthick=7.0, color=1, charsize=1.5
xyouts, 0.97, 0.54, 'Sunset: '+anytim(file2time(sunset),/yohkoh,/truncate), $
/normal, alignment = 1.0, charthick=2.0, color=0, charsize=1.5

device,/close
set_plot,'win'


cd,'C:\Inetpub\wwwroot\data\realtime\callisto\fts\'
spawn,'del Gp_xr_1m.txt'
spawn,'convert -rotate "-90" callisto_goes_all_day.ps callisto_goes.png'
date_time =time2file(start_time)+'00'
spawn,'convert -rotate "-90" callisto_goes_all_day.ps callisto_goes'+today+'.png'

get_utc,ut
fin_time = anytim(ut,/yoh,/trun)
print,''
print,'File written: callisto_goes'+today+'.png'
print,'callisto_goes_v3 finsihed at '+fin_time
print,''
wait,10
END

pro stitch_spectra_day, receiver, sunrise, sunset, z, x, y
 
; Name: sitch_spectra_day
;
;   Purpose:
;   -To stitch together all spectra in input folder and between the input times given. 
;
; Input parameters:
;   -receiver (string): The receiver for which .fts files are to be searched
;   -sunrise (string): The start time of the stitch. Format: YYYYMMDD_HHMMSS
;   -sunset (string): The end time of the stitch. Format: YYYYMMDD_HHMMSS
;
; Keywords:
;   -None
;
; Outputs:
;   -z (float array): The dynamic spectra between desired times
;   -x (float array): The time array of desired times
;   -y (float_array): The frequency array of stitched spectra
;
;   Calling sequence example:
;   -stitch_spectra_day,'01','20110101_081000','20110101_191000',z,x,y
;
;   Last modified:
;   -10-Nov-2011 (E.Carley) Just a clean up....
;   -08-Jan-2013 (E.Carley) v3 implemented Change to realtime fts folder into which live data is written. Need change in
;                           findfile argument to take into account ALL receiver .fts are in the one folder
cd,'C:\Inetpub\wwwroot\data\realtime\callisto\fts\';+folder


  times = anytim(file2time(findfile('BIR*'+receiver+'.fit')),/utime)

  ;sunrise must be in the format YYYYMMDD_HHMMSS
  index_sunrise = where(times gt anytim(file2time(sunrise),/utime))
  sunriseFilePos = index_sunrise[0]

  ;sunset must be in the format YYYYMMDD_HHMMSS
  index_sunset = where(times lt anytim(file2time(sunset),/utime))
  sunsetFilePos = index_sunset[n_elements(index_sunset)-1]

;=======Dynamic Spectra of entire day===========================
list = findfile('BIR*'+receiver+'.fit')

  radio_spectro_fits_read,list[sunriseFilePos],z,x,y ;start value for z ad x
    ;z is a 2D data array, x is ID array time values, y is 1D array of frequency values
    
     backg=make_daily_background(receiver)
     z = temporary(z) - backg
   
    ;for loop to create dynamic spectra of entire day
    FOR i = sunriseFilePos+ 1, sunsetFilePos, 1 DO BEGIN 
        filename = list[i]
        radio_spectro_fits_read,filename,runningZ,runningX,y
      
        runningZ = temporary(runningZ) - backg
        z = [z,runningZ]
        x = [x,runningX]       
    ENDFOR

END

