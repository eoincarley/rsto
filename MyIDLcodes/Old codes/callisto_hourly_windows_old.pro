pro callisto_hourly_windows,spectra,backg=backg


;  Name: callisto_hourly_windows
;
;  Purpose: This is a routine that finds the latest dynamic spectra and plots the past hour's worth.
;            A png is then created for online display
;
;           It also has a small routine that checks if there's been new spectra created in the past 
;           hour. If not it sets the observation status to 'off'
;
;  Input parameters:
;           -none
;
;  Keyword parametrs:
;           -BACKG - set if background subtract is needed. Background is created within this code
;
;  Outputs:
;         -Spectra - Dynamic spectra of last hour (a png of this is also saved)
;         -This routine also edits the file in C:\logs\system_status.txt
;          which is used for online purposes.
;


;=========Go to current day fits folder==========
;set_plot,'z'
cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts\high_freq'

get_utc,ut
today=time2file(ut,/date)

list = findfile('*.fit')
 
IF n_elements(list) gt 0 THEN BEGIN

  index_stop = n_elements(list)-1
  index_start = index_stop - 7 

  radio_spectro_fits_read,list[index_start],z,x,y
  ;z is a 2D data array, x is ID array time values, y is 1D array of frequency values

  sizeData = size(z)
  meanData = fltarr(sizeData[2])

  yaxis = sizeData[2] - 1
          for i=0,yaxis do begin
           meanData(i)=avg(z(*,i))
          endfor
     background = fltarr(sizeData[1],sizeData[2])

          for i =0.0, sizeData[1]-1, 1.0 do begin
             background[i,*] = meanData[*]
          endfor
     z = z - background

  ;==Loop to 'string together' all spectra from last hour==================
       for i = index_start+1, index_stop, 1 do begin 

              filename = list[i]
              radio_spectro_fits_read,filename,runningZ,runningX,runningy
              ;runningZ = callisto_spg_recalibrate(runningZ,y,/sfu) 
              sizeData = size(runningZ)
  meanData = fltarr(sizeData[2])

  yaxis = sizeData[2] - 1
          for q=0,yaxis do begin
           meanData(q)=avg(runningZ(*,q))
          endfor
     background = fltarr(sizeData[1],sizeData[2])

          for k =0.0, sizeData[1]-1, 1.0 do begin
             background[k,*] = meanData[*]
          endfor
     runningZ = runningZ - background
              
              
              z = [z,runningZ]
              x = [x,runningX]
              
    
       endfor
;The following method was replaced by the above background subtract BEFORE the
;the spectra are stiched togeter.
  ;============Create and Subtract background if required =================
 ; if KEYWORD_SET(backg)  then begin
  ;sizeData = size(z)
 ; meanData = fltarr(sizeData[2])

  ;yaxis = sizeData[2] - 1
         ; for i=0,yaxis do begin
          ; meanData(i)=avg(z(*,i))
          ;endfor
    ; background = fltarr(sizeData[1],sizeData[2])

         ; for i =0.0, sizeData[1]-1, 1.0 do begin
          ;   background[i,*] = meanData[*]
        ;  endfor
    ; z = z - background
 ; endif






;==============Latest goes data==================================
get_utc,current_time
time_minus = anytim(current_time,/utime)-3600 
time_minus = anytim(time_minus,/ext)
time_minus[1] = 00
tstart = time2file(time_minus)

tend = anytim(current_time,/ext)
tend[1]=0
tend = time2file(tend)

goes = latest_goes(tstart,tend)

xstart = anytim(file2time(tstart),/utime)

window,1,xs=1000,ys=600 ;******remove if z buffer being used

xend = anytim(file2time(tend),/utime)
loadct,39
  !p.color=0
  !p.background=255

  ;===============Plot Spectra postscript & png==================
  !p.multi = [0,1,2]
  date_label = LABEL_DATE(DATE_FORMAT = ['%H:%I'])
  start_time = anytim(file2time(tstart),/yohkoh,/truncate)
plot,goes(0,*),goes(1,*),$
XTICKFORMAT = 'LABEL_DATE',XTICKUNITS = 'minutes',$
xtickinterval=10,/xs,charsize=1.5,ytitle='Watts !1 m!E-2',$
xtitle='!1 Start time: '+'('+start_time+') UT',$
thick=1,yrange=[1e-9,1e-3],/ylog,title='1-minute GOES-15 Solar X-ray Flux',psym=3

oplot,goes(0,*),goes(1,*),color=240,thick=2


axis,yaxis=1,ytickname=[' ','A','B','C','M','X',' '],charsize=1.5
axis,yaxis=0,yrange=[1e-9,1e-3],ytitle='Watts !1 m!E-2',charsize=1.5
axis,xaxis=0,XTICKFORMAT = 'LABEL_DATE',XTICKUNITS = 'minutes',$
xtickinterval=10,/xs,charsize=1.5,xtitle='!1 Start time: '+'('+start_time+') UT'
;axis,xaxis=1,xtickname=[' ',' ',' ',' ',' ',' ',' '],xtitle='Flux GOES15 0.1-0.8nm, 5 min time resolution',charsize=2


plots,goes(0,*),1e-8
plots,goes(0,*),1e-7
plots,goes(0,*),1e-6
plots,goes(0,*),1e-5
plots,goes(0,*),1e-4
oplot,goes(0,*),goes(1,*),color=230,thick=1.7
oplot,goes(0,*),goes(2,*),color=80,thick=1.5 

legend, ['GOES15 0.1-0.8nm','GOES15 0.05-0.4nm'],$
linestyle=[0,0], color=[220,80], charsize=1.3, box=0,pos=[110,565],/device
  
xtitle = 'Start Time ('+anytim(x[0],/yoh,/truncate)+' UT)'   
  
  loadct,5
  spectro_plot,bytscl(smooth(z,3),-2,10),x,y,/xs,/ys,ytitle='Frequency (MHz)',$
  xrange=[xstart,xend],title='eCallisto (Birr Castle, Ireland)',$
  charsize=1.5,xtitle=xtitle
  
 get_utc,ut
time = anytim(file2time(time2file(ut)),/ex)
if time[1] gt 4 then begin
 time[1]=0
time = anytim(time,/utime)+4200
update_time = 'Next update time: '+string(anytim(time,/yohkoh,/time_only,/truncate))+' UT'
endif else begin
time[1]=0
time = anytim(time,/utim)+600
update_time = 'Time of next update: '+string(anytim(time,/yohkoh,/time_only,/truncate))+' UT'
endelse

xyouts,740,3,update_time,/device,charsize=1.3
  
  
 
  x2png,'callisto_hourly.png'
  
  ;!p.multi=[0,1,1]
  ;window,2,xs=1000,ys=600
  ;;plot_hist,z
;stop
ENDIF
spawn,'del Gp_xr_1m.txt'
IF n_elements(list) eq 0 THEN PRINT,'No realtime spectra available'



;===========Pietro's system status ===============
file_times = file2time(list)
get_utc,current_time
file_times = anytim(file_times,/utime)
current_time = anytim(current_time,/utime)

;   If the last file was 40 minutes ago then notify
IF file_times[n_elements(file_times)-1] lt (current_time - 2400) then begin
    cd,'C:\logs\'
      openr,1,'system_status.txt'
      status = strarr(1)
      readf,1,status
 
          status='Callisto Radio Spectrometer: Off' 
  
      openw,2,'system_status.txt'
      printf,2,status
  close,1
  close,2
ENDIF ELSE BEGIN
  cd,'C:\logs\'
      openr,1,'system_status.txt'
      status = strarr(1)
      readf,1,status
  
          status ='Callisto Radio Spectrometer: On' 
  
      openw,2,'system_status.txt'
      printf,2,status
  close,1
  close,2
ENDELSE  

;===========Put Joe's solar ephemeris in appropriate format for online display==================== 

cd,'c:\logs'
openr,100,'suntimes.txt'
suntimes = strarr(3)
readf,100,suntimes
close,100

suntimes[0] = today+'_'+StrMid(suntimes[0],10)
suntimes[1] = today+'_'+StrMid(suntimes[1],9)
suntimes[2] = today+'_'+StrMid(suntimes[2],10)
times4php = strarr(3)
times4php[0] = 'Sunrise: ' +anytim(  file2time(suntimes[0]),/yohkoh,/truncate)+' UT<br>'
times4php[1] = 'Sunset:   ' +anytim(  file2time(suntimes[1]),/yohkoh,/truncate)+' UT<br>'
times4php[2] = 'Transit time: ' +anytim(  file2time(suntimes[2]),/yohkoh,/truncate)+' UT'
times4php =transpose(times4php)

openw,100,'sitetime.txt'
printf,100,times4php
close,100
;stop
;End program
END