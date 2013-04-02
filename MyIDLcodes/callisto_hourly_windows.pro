pro callisto_hourly_windows, spectra, backg=backg


;  Name: callisto_hourly_windows
;
;  Purpose: This is a routine that finds the latest dynamic spectra and plots the past hour's worth.
;            A png is then created for online display

;
;  Input parameters:
;           -none
;
;  Keyword parametrs:
;           -BACKG - (OLD/OBSELETE!)set if background subtract is needed. Background is created within this code
;
;  Outputs:
;           -Spectra - Dynamic spectra of last hour (a png of this is also saved)
;           
;  Calls on:
;           -make_daily_background.pro --->calls on running_mean_background.pro
;           -latest_goes.pro         
;
;  Last modified:
;          
;           - 06-Mar-2012 (E.Carley) - The high receiver started to look like it was clipped to harshly on the
;                                      high end. High end clipping now at an extra standard deviation.
;           - 26-Aug-2011 (E.Carley) - Changing background subtraction to average backgound of entire day
;           - 23-May-2011 (E.Carley)
;           - 08-Jan-2013 (E.Carley) - v3 written. Change to directory into which realtime data is dumped -> Change directory
;                                      in which this code searches for realtime data to plot
;			- 29-Mar-2013 (E.Carley) - Set up version control system for all IDL scripts. all 'v1' 'v2'
;									   suffixes have been removed from codes
;
;
; Call above function to get high, mid and low spectra

;Stitch spectra at end of this script
stitch_spectra, '03', data_high, times_high, freq_high 
stitch_spectra, '02', data_mid, times_mid, freq_mid
stitch_spectra, '01', data_low, times_low, freq_low
    
;--------------- Get all necessary time formats --------------
get_utc, current_time
time_minus = anytim(current_time,/utime) - 3600.0 
time_minus = anytim(time_minus,/ext)
time_minus[1] = 00
tstart = time2file(time_minus) ;**string: If current time is 1542 start rounds to 1500

tend = anytim(current_time,/ext)
tend[1]=0
tend = time2file(tend)         ;**string

xstart = anytim(file2time(tstart),/utime)  
xend = anytim(file2time(tend),/utime)      
start_time = anytim(file2time(tstart),/yohkoh,/truncate) ;only for display on x-axis

;---------------- Set window size, colour and plot format ---------------------

cd,'C:\Inetpub\wwwroot\data\realtime\callisto\fts\'
set_plot,'ps'
device,filename = 'callisto_goes_hourly.ps', /color, /inches, /landscape, /encapsulate, $
yoffset=12,ysize=10,xsize=12  
!x.margin=[0,0]
!y.margin=[0,0]
loadct,39
!p.color=0
!p.background=255
!p.multi = [0,1,2]
!p.charsize=1.2 


;--------------- Plot GOES lightcurve and dynamic spectra ----------------------- 

goes = latest_goes(tstart,tend)

set_line_color
utplot, goes[0,*], goes[1,*], xr=[xstart,xend], /xs, $
thick=1, yrange=[1e-9,1e-3], /ylog, title='1-minute GOES-15 Solar X-ray Flux', psym=3,$
position=[0.055,0.69,0.98,0.94],/normal,/noerase, xtitle='Start Time: '+start_time+' (UT)'
oplot, goes[0,*], goes[1,*], color=3, thick=2

xyouts, 0.015, 0.78, 'Watts m!U-2!N', /normal, orientation=90

axis,yaxis=1,ytickname=[' ','A','B','C','M','X',' ']
axis,yaxis=0,yrange=[1e-9,1e-3]


plots, goes[0,*], 1e-8, color=0
plots, goes[0,*], 1e-7, color=0
plots, goes[0,*], 1e-6, color=0
plots, goes[0,*], 1e-5, color=0
plots, goes[0,*], 1e-4, color=0
oplot, goes[0,*], goes[1,*], color=3, thick=1.7
oplot, goes[0,*], goes[2,*], color=5, thick=1.7 

legend, ['GOES15 0.1-0.8nm','GOES15 0.05-0.4nm'],$
linestyle=[0,0], color=[3, 5], box=0,pos=[0.05,0.935], /normal


loadct,5
lower_scale = mean(data_high) - 1.5*stdev(data_high)
upper_scale = mean(data_high) + 14.0*stdev(data_high)
spectro_plot,bytscl(data_high, lower_scale, upper_scale ), times_high, freq_high, /xs, /ys, $
xrange=[xstart,xend], yr=[400,200], $
xtitle='Start Time: '+start_time+' (UT)', $
position=[0.055,0.06,0.98,0.33], /normal, /noerase

lower_scale = mean(data_mid) - 1.5*stdev(data_mid)
upper_scale = mean(data_mid) + 12.0*stdev(data_mid)
spectro_plot,bytscl(data_mid, lower_scale, upper_scale), times_mid, freq_mid, /xs, /ys, $
xrange=[xstart,xend],yr=[200,100],ytickinterval=50,ytickname=[' ','150','100'],$
xticks=2,xtickname=[' ',' ',' ',' ',' ',' ',' '],xtitle=' ',$
position=[0.055,0.33,0.98,0.46],/normal,/noerase

lower_scale = mean(data_low) - 1.5*stdev(data_low)
upper_scale = mean(data_low) + 12.0*stdev(data_low)
spectro_plot, bytscl(data_low, lower_scale, upper_scale), times_low, freq_low, /xs, /ys, $
xrange=[xstart,xend], yr=[100,10], ytickv=[50,10], yticks=1, $
xticks=2, xtickname=[' ',' ',' ',' ',' ',' ',' '], xtitle=' ', $
position=[0.055,0.46,0.98,0.59],/normal,/noerase,title='eCallisto (RSTO, Birr, Ireland)'

xyouts, 0.015, 0.255, 'Frequency (MHz)', /normal, orientation=90

device,/close
set_plot,'win'
cd,'C:\Inetpub\wwwroot\data\realtime\callisto\fts\'
spawn,'del Gp_xr_1m.txt'
spawn,'convert -rotate "-90" callisto_goes_hourly.ps callisto_hourly1.png'
date_time =time2file(start_time)+'00'
spawn,'convert -rotate "-90" callisto_goes_hourly.ps CAL1_'+date_time+'_hourly.png'

get_utc,ut
fin_time = anytim(ut,/yoh,/trun)
print,''
print,'File created: CAL1_'+date_time+'_hourly.png in folder: C:\Inetpub\wwwroot\data\realtime\callisto\fts\'
print,'create_hourly_windows_v3 finsihed at '+fin_time
print,''


END

;------------------------------------------------------;
;       STITCH_SPECTRA
;------------------------------------------------------;
; Name: sitch_spectra
;
;   Purpose:
;   -To stitch together latest spectra in input folder into hour long spectra
;
; Input parameters:
;   -receiver (string): The receiver for which .fts files are to be searched
;               01: low receiver 10-100 MHz
;               02: mif receiver 100-200 MHz
;               03: high receiver 200-400 MHz
;
; Keywords:
;   -None
;
; Outputs:
;   -z (float array): The dynamic spectra between desired times
;   -x (float_array): The time array of desired times
;   -y (float_array): The frequency array of sitched spectra
;
;   Calling sequence example:
;   -stitch_spectra_day, '01', z, x, y  ;for low frequency receiver
; 
;   Last modified:
;   -10-Nov-2011 (E.Carley) Just a clean up....
;   -08-Jan-2013 (E.Carley) See comment on same date below.
;                           New directory structure puts ALL fits in same fts folder -> Need an extra criterion
;                           in findfile argument.
pro stitch_spectra, receiver, z, x, y
cd,'C:\Inetpub\wwwroot\data\realtime\callisto\fts\'

get_utc,ut
today=time2file(ut,/date)
list = findfile('BIR*'+receiver+'.fit')
file_times = anytim(file2time(list),/utime)

IF n_elements(list) gt 0 THEN BEGIN

  index_stop = n_elements(list)-1
  latest_time = file_times[n_elements(file_times)-1] + 900.0
  start_spectra_time = latest_time - 4500.0
  
  index_start = closest(file_times, start_spectra_time)
 
  radio_spectro_fits_read, list[index_start], z, x, y
  ;z is a 2D data array, x is 1D array of time values, y is 1D array of frequency values

  backg = make_daily_background(receiver)
  z = temporary(z) - backg 
  ;----------- Loop to 'stitch together' all spectra from last hour -----------
    FOR i = index_start+1, index_stop, 1 DO BEGIN

        filename = list[i]
        radio_spectro_fits_read, filename, runningZ, runningX, runningy
       
        runningZ = temporary(runningZ) - backg      
        z = [z,runningZ]
        x = [x,runningX]
     ENDFOR
ENDIF ELSE BEGIN
print,' Did not detect any fits files for today'
ENDELSE

END