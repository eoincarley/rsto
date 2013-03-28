pro stitch_spectra, folder, receiver, z, x, y

; Name: sitch_spectra_day
;
;   Purpose:
;   -To stitch together latest spectra in input folder into hour long spectra
;
; Input parameters:
;   -folder: The folder in which to search for the .fts files
;
; Keywords:
;   -None
;
; Outputs:
;   -z: The dynamic spectra between desired times
;   -x: The time array of desired times
;   -y: The frequency array of sitched spectra
;
;   Calling sequence example:
;   -stitch_spectra_day,'high',z,x,y
;
;   Last modified:
;   -10-Nov-2011 (E.Carley) Just a clean up....
;   -08-Jan-2013 (E.Carley) See comment on same date below.
;                           New directory structure puts ALL fits in same fts folder -> Need an extra criterion
;                           in findfile argument.

cd,'C:\Inetpub\wwwroot\data\realtime\callisto\fts\';+folder

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

  backg = make_daily_background()
  z = z - backg 
  ;==Loop to 'string together' all spectra from last hour==================
    FOR i = index_start+1, index_stop, 1 DO BEGIN

        filename = list[i]
        radio_spectro_fits_read, filename, runningZ, runningX, runningy
        ;runningZ = callisto_spg_recalibrate(runningZ,y,/sfu) 
       
        runningZ = runningZ - backg      
        z = [z,runningZ]
        x = [x,runningX]
     ENDFOR
ENDIF
END

pro callisto_hourly_windows_v2, spectra, backg=backg


;  Name: callisto_hourly_windows_v2
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
;           -latest_goes_v1.pro         
;
;  Last modified:
;          
;           - 06-Mar-2012 (E.Carley) - The high receiver started to look like it was clipped to harshly on the
;                                      high end. High end clipping now at an extra standard deviation.
;           - 26-Aug-2011 (E.Carley) - Changing background subtraction to average backgound of entire day
;           - 23-May-2011 (E.Carley)
;           - 08-Jan-2013 (E.Carley) - Change to directory into which realtime data is dumped -> Change directory
;                                      in which this code searches for realtime data to plot
;
; Call above function to get high, mid and low spectra


stitch_spectra,'high_freq',z_high,x_high,y_high
stitch_spectra,'mid_freq',z_mid,x_mid,y_mid
stitch_spectra,'low_freq',z_low,x_low,y_low
    
;==============Get all necessary time formats================
get_utc,current_time
time_minus = anytim(current_time,/utime)-3600.0 
time_minus = anytim(time_minus,/ext)
time_minus[1] = 00
tstart = time2file(time_minus) ;**string: If current time is 1542 start rounds to 1500

tend = anytim(current_time,/ext)
tend[1]=0
tend = time2file(tend)         ;**string

xstart = anytim(file2time(tstart),/utime) ;seconds since Jan-1 1979
xend = anytim(file2time(tend),/utime)   ;seconds since Jan-1 1979
start_time = anytim(file2time(tstart),/yohkoh,/truncate) ;only for display on x-axis

;===============Set window size, colour and plot format=====================
;window,1,xs=1000,ys=600 ;******remove if z buffer being used
cd,'C:\Inetpub\wwwroot\data\realtime\callisto\fts\'
set_plot,'ps'
device,filename = 'callisto_goes_hourly.ps',/color,/inches,/landscape,/encapsulate,$
yoffset=12,ysize=10,xsize=12  

!x.margin=[0,0]
!y.margin=[0,0]
  
  
  loadct,39
  !p.color=0
  !p.background=255
  !p.multi = [0,1,2]
  !p.charsize=1.2 
;===============Plot GOES lightcurve and dynamic spectra====================
;date_label = LABEL_DATE(DATE_FORMAT = ['%H:%I'])
goes = latest_goes_v1(tstart,tend)

utplot,goes(0,*),goes(1,*),xr=[xstart,xend],/xs,$
thick=1,yrange=[1e-9,1e-3],/ylog,title='1-minute GOES-15 Solar X-ray Flux',psym=3,$
position=[0.055,0.69,0.98,0.94],/normal,/noerase
oplot,goes(0,*),goes(1,*),color=240,thick=2

xyouts,0.015, 0.78, 'Watts m!U-2!N',/normal,orientation=90

axis,yaxis=1,ytickname=[' ','A','B','C','M','X',' '];,charsize=1.5
axis,yaxis=0,yrange=[1e-9,1e-3];,charsize=1.5
;axis,xaxis=0,XTICKFORMAT = 'LABEL_DATE',XTICKUNITS = 'minutes',$
;xtickinterval=10,/xs,charsize=1.5,xtitle='!1 Start time: ('+start_time+') UT'

plots,goes(0,*),1e-8
plots,goes(0,*),1e-7
plots,goes(0,*),1e-6
plots,goes(0,*),1e-5
plots,goes(0,*),1e-4
oplot,goes(0,*),goes(1,*),color=230,thick=1.7
oplot,goes(0,*),goes(2,*),color=80,thick=1.7 

legend, ['GOES15 0.1-0.8nm','GOES15 0.05-0.4nm'],$
linestyle=[0,0], color=[220,80], box=0,pos=[0.05,0.935],/normal

loadct,5
;spectro_plot,bytscl(smooth(z_high,3),-1,10),x_high,y_high,/xs,/ys,$
spectro_plot,bytscl(z_high,mean(z_high)-1.5*stdev(z_high),mean(z_high)+11.0*stdev(z_high)),x_high,y_high,/xs,/ys,$
;spectro_plot,z_high,/auto),x_high,y_high,/xs,/ys,$
xrange=[xstart,xend],yr=[400,200],$
xtitle='Start Time: ('+start_time+') UT',$
position=[0.055,0.06,0.98,0.33],/normal,/noerase

;spectro_plot,bytscl(smooth(z_mid,3),-2,10),x_high,y_mid,/xs,/ys,$
spectro_plot,bytscl(z_mid,mean(z_mid)-1.5*stdev(z_mid),mean(z_mid)+7.0*stdev(z_mid)),x_mid,y_mid,/xs,/ys,$
xrange=[xstart,xend],yr=[200,100],ytickinterval=50,ytickname=[' ','150','100'],$
xticks=2,xtickname=[' ',' ',' ',' ',' ',' ',' '],xtitle=' ',$
position=[0.055,0.33,0.98,0.46],/normal,/noerase

;spectro_plot,bytscl(z_low,-10,50),x_low,y_low,/xs,/ys,$
spectro_plot,bytscl(z_low,mean(z_low)-1.5*stdev(z_low),mean(z_low)+7.0*stdev(z_low)),x_low,y_low,/xs,/ys,$
xrange=[xstart,xend],yr=[100,10],ytickv=[50,10],yticks=1,$
xticks=2,xtickname=[' ',' ',' ',' ',' ',' ',' '],xtitle=' ',$
position=[0.055,0.46,0.98,0.59],/normal,/noerase,title='eCallisto Birr Castle, Ireland'

xyouts,0.015, 0.255, 'Frequency (MHz)',/normal,orientation=90

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
print,'create_hourly_windows_v2 finsihed at '+fin_time
print,''


END