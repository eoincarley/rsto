pro callisto_hourly_windows_v1,spectra,backg=backg


;  Name: callisto_hourly_windows_v1
;
;  Purpose: This is a routine that finds the latest dynamic spectra and plots the past hour's worth.
;            A png is then created for online display

;
;  Input parameters:
;           -none
;
;  Keyword parametrs:
;           -BACKG - set if background subtract is needed. Background is created within this code
;
;  Outputs:
;           -Spectra - Dynamic spectra of last hour (a png of this is also saved)
;           
;  Calls on:
;           -make_daily_background.pro --->calls on running_mean_background.pro
;           -latest_goes.pro         
;
;  Last modifies:
;           - 26-Aug-2011 - Changing background subtraction to average backgound of entire day
;           - 23-May-2011 E.Carley
;
;=========Go to current day fits folder==========

cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts\high_freq'

get_utc,ut
today=time2file(ut,/date)
list = findfile('*.fit')
file_times = anytim(file2time(list),/utime)
 
IF n_elements(list) gt 0 THEN BEGIN

  index_stop = n_elements(list)-1
  latest_time = file_times(n_elements(file_times)-1)+900 
  start_spectra_time = latest_time - 3600
  index_start = closest(file_times, start_spectra_time)-2
  ;stop
  radio_spectro_fits_read,list[index_start],z,x,y
  ;z is a 2D data array, x is ID array time values, y is 1D array of frequency values

 backg = make_daily_background()
 z = z - backg 
  ;==Loop to 'string together' all spectra from last hour==================
    FOR i = index_start+1, index_stop, 1 DO BEGIN

        filename = list[i]
        radio_spectro_fits_read,filename,runningZ,runningX,runningy
        ;runningZ = callisto_spg_recalibrate(runningZ,y,/sfu) 
       
        runningZ = runningZ - backg      
        z = [z,runningZ]
        x = [x,runningX]
     ENDFOR
    
;==============Get all necessary time formats================
get_utc,current_time
 time_minus = anytim(current_time,/utime)-3600 
 time_minus = anytim(time_minus,/ext)
 time_minus[1] = 00
tstart = time2file(time_minus) ;**string: If current time is 1542 start ends up as 1500

tend = anytim(current_time,/ext)
tend[1]=0
tend = time2file(tend)         ;**string

xstart = anytim(file2time(tstart),/utime) ;seconds since Jan-1 1979
xend = anytim(file2time(tend),/utime)   ;seconds since Jan-1 1979
start_time = anytim(file2time(tstart),/yohkoh,/truncate) ;for display on x-axis

goes = latest_goes(tstart,tend)

  ;===============Set window size, colour and plot format=====================
  window,1,xs=1000,ys=600 ;******remove if z buffer being used
  loadct,39
  !p.color=0
  !p.background=255
  !p.multi = [0,1,2]

;===============Plot GOES lightcurve and dynamic spectra====================
date_label = LABEL_DATE(DATE_FORMAT = ['%H:%I'])
plot,goes(0,*),goes(1,*),$
XTICKFORMAT = 'LABEL_DATE',XTICKUNITS = 'minutes',$
xtickinterval=10,/xs,charsize=1.5,ytitle='Watts !1 m!E-2',$
xtitle='!1 Start time: '+'('+start_time+') UT',$
thick=1,yrange=[1e-9,1e-3],/ylog,title='1-minute GOES-15 Solar X-ray Flux',psym=3

oplot,goes(0,*),goes(1,*),color=240,thick=2

axis,yaxis=1,ytickname=[' ','A','B','C','M','X',' '],charsize=1.5
axis,yaxis=0,yrange=[1e-9,1e-3],ytitle='Watts !1 m!E-2',charsize=1.5
axis,xaxis=0,XTICKFORMAT = 'LABEL_DATE',XTICKUNITS = 'minutes',$
xtickinterval=10,/xs,charsize=1.5,xtitle='!1 Start time: ('+start_time+') UT'

plots,goes(0,*),1e-8
plots,goes(0,*),1e-7
plots,goes(0,*),1e-6
plots,goes(0,*),1e-5
plots,goes(0,*),1e-4
oplot,goes(0,*),goes(1,*),color=230,thick=1.7
oplot,goes(0,*),goes(2,*),color=80,thick=1.5 

legend, ['GOES15 0.1-0.8nm','GOES15 0.05-0.4nm'],$
linestyle=[0,0], color=[220,80], charsize=1.3, box=0,pos=[110,565],/device

;Plot dynamic spectra of last hour
loadct,5
spectro_plot,bytscl(smooth(z,3),-2,10),x,y,/xs,/ys,ytitle='Frequency (MHz)',$
xrange=[xstart,xend],title='eCallisto (Birr Castle, Ireland)',$
charsize=1.5,xtitle='Start Time: ('+start_time+') UT'
  
  
  
;=======This assumes update time is always at 10 past the hour========
get_utc,ut
time = anytim(file2time(time2file(ut)),/ex)
   if time[1] ge 10 then begin
    time[1]=0
    time = anytim(time,/utime)+4200
    update_time = 'Next update time: '+string(anytim(time,/yohkoh,/time_only,/truncate))+' UT'
   endif else begin
    time[1]=0
    time = anytim(time,/utim)+600
    update_time = 'Time of next update: '+string(anytim(time,/yohkoh,/time_only,/truncate))+' UT'
   endelse
;xyouts,740,3,update_time,/device,charsize=1.3
  
x2png,'callisto_hourly1.png'

date_time =time2file(start_time)+'00'
x2png,'CAL1_'+date_time+'_hourly.png'
  
ENDIF
spawn,'del Gp_xr_1m.txt'
IF n_elements(list) eq 0 THEN PRINT,'No realtime spectra available'


END