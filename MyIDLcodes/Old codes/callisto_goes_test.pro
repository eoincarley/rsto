pro callisto_goes_test,backg=backg


;   Name: callisto_goes_day_plot_windows
;
;   Purpose:
;      This procedure first gets all files in the current day folder on the server
;      It calls on the procedure radio_spectro_fits_read and creates a dynamic spectra up to the current hour.
;      It then produces a composite plot of GOES lightcurve and CALLISTO day long dynamic spectra. Only 
;      times within sunrise & sunset are plotted, these are obtained from a txt file output by Joe's
;      solar tracking software
;
;   Input parameters:
;      -None
;
;   Keyword parametrs:
;      -BACKG - set if background subtract is needed. Background is created within this code
; 
;   Outputs:
;      -z - Dynamic spectra of entire day. Also saved is a png of CALLISTO-GOES plot
;       
;      
;
;set_plot,'z'

;=========Get today's date in correct format========
get_utc,ut
today = time2file(ut,/date)
todayhms = time2file(ut,/sec)
spawn,'del'+today+'_Gp_xr_1m.txt'

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

;===========Go to realtime folder for latest data==============

cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts\high_freq'

;==============Files between sunrise and sunset ===============
  
  times = anytim(file2time(findfile('*.fit')),/utime)

  ;sunrise must be in the format YYYYMMDD_HHMMSS
  index_sunrise = where(times gt anytim(file2time(sunrise),/utime))
  sunriseFilePos = index_sunrise[0]

  ;sunset must be in the format YYYYMMDD_HHMMSS
  index_sunset = where(times lt anytim(file2time(sunset),/utime))
  sunsetFilePos = index_sunset[n_elements(index_sunset)-1]


;=======Dynamic Spectra of entire day===========================
list = findfile('*.fit')

  radio_spectro_fits_read,list[sunriseFilePos],z,x,y ;start value for z ad x
  ;z is a 2D data array, x is ID array time values, y is 1D array of frequency values
  ;z = tracedespike(z,statistics=2)
     z=GlidBackSub(z,1000)
    ;for loop to create dynamic spectra of entire day
    FOR i = sunriseFilePos+ 1, sunsetFilePos, 1 DO BEGIN 

        filename = list[i]
        radio_spectro_fits_read,filename,runningZ,runningX,y
        ;runningZ = callisto_spg_recalibrate(runningZ,y,/sfu) 
        ;runningZ = tracedespike(runningZ,statistics=2)
        runningZ = GlidBackSub(runningZ,1000)
        z = [z,runningZ]
        x = [x,runningX]
    
    ENDFOR

;============Create and Subtract background  if required =================
IF KEYWORD_SET(backg)  THEN BEGIN
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
ENDIF


;===========Get the GOES data==================================

latest_goes_allday,sunrise,sunset,goes,goesData
;goes->help

;=====Plot=======
set_plot,'win'
loadct,39
!p.multi=[0,1,2]
!p.color=0
!p.background=255
window,1,xs=1000,ys=500 ;*****remove if z buffer used
cd,'C:\Inetpub\wwwroot\callisto\data\realtime\png\high_freq'

;======Time formatting because utplot this has more control than utplot
  date_label = LABEL_DATE(DATE_FORMAT = ['%H:%I'])
  start_time = anytim(file2time(sunrise),/yohkoh,/truncate)
  
  time = anytim( file2time(sunrise,/yohkoh), /ex)
  xstart = julday(time[5,*],time[4,*],time[6,*],time[0,*],time[1,*],time[2,*])
  
  time = anytim( file2time(sunset,/yohkoh), /ex)
  xend = julday(time[5,*],time[4,*],time[6,*],time[0,*],time[1,*],time[2,*])


;=====plot the goes data==================
plot,goes(0,*),goes(1,*),$
XTICKFORMAT = 'LABEL_DATE',XTICKUNITS = 'minutes',$
xtickinterval=120,charsize=1.3,ytitle='Watts !1 m!E-2',xtitle='!1 Start time: '+'('+start_time+') UT',/xs,$
thick=1,yrange=[1e-9,1e-3],/ylog,title='1-minute GOES-15 Solar X-ray Flux',psym=3,xrange=[xstart,xend]

oplot,goes(0,*),goes(1,*),color=240,thick=2

axis,yaxis=1,ytickname=[' ','A','B','C','M','X',' '],charsize=1.3
axis,yaxis=0,yrange=[1e-9,1e-3],ytitle='Watts !1 m!E-2',charsize=1.3

plots,goes(0,*),1e-8
plots,goes(0,*),1e-7
plots,goes(0,*),1e-6
plots,goes(0,*),1e-5
plots,goes(0,*),1e-4
oplot,goes(0,*),goes(1,*),color=230,thick=1.7
oplot,goes(0,*),goes(2,*),color=80,thick=1.5

legend, ['GOES15 0.1-0.8nm','GOES15 0.05-0.4nm'],$
linestyle=[0,0], color=[220,80], charsize=1, box=0,pos=[90,472],/device

a = '!1 Plot time between sunrise ('+anytim(file2time(sunrise),/yohkoh, /time_only, /truncate)+$
' UT) and sunset ('+anytim(file2time(sunset),/yohkoh, /time_only, /truncate)+' UT)'
xyouts,5,3,a,/device,charsize=1.1

;===========For printing next update time on plots for www.rosseobservatory.ie
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

xyouts,770,3,update_time,/device,charsize=1.1


;=====plot dynamic spectra between appropriate times======
xstart = anytim(file2time(sunrise),/utime)
xend = anytim(file2time(sunset),/utime)
a=size(goesData)
zstopt = anytim(file2time(goesData[0]+goesData[1]+goesData[2]+'_'+goesData[3,a[2]-1]),/utime)
z = tracedespike(z,statistics=6)
zstop = closest(x,zstopt)

xtitle = 'Start Time ('+anytim(x[0],/yoh,/truncate)+' UT)' 

loadct,5
spectro_plot,bytscl(smooth(z[0:zstop,*],3),-2,5),x,y,/xs,/ys,ytitle='Frequency (MHz)',$
title='eCallisto (Birr Castle, Ireland)',charsize=1.3,xticks=10,xrange=[xstart,xend],xtitle=xtitle

x2png,'callisto_goes.png'
x2png,'callisto_goes'+today+'.png


END
