pro callisto_goes_day_plot_windows,sunrise,sunset,z,Backg = backg

;   Name: callisto_goes_day_plot_windows
;
;   Purpose:
;      This procedure first gets all files in the current day folder on the server
;      It calls on the procedure radio_spectro_fits_read and creates a day-long dynamic spectra. It
;      then produces a composite plot of GOES lightcurve and Callisto day long dynamic spectra. Only 
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
set_plot,'z'
;=========Get today's date in correct format========
fs = '(I2.2)'
caldat,julday()-2,mon,d,y,h,min,s
today_minus2 = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs)
todayhms = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs) +$
'_'+string(h, format=fs)+string(min, format=fs)+string(s, format=fs)


;=======Get solar ephemeris from suntimes.txt (ouput from Joe's program=======
  cd,'c:\logs'
  openr,100,'suntimes.txt'
  suntimes = strarr(3)
  readf,100,suntimes
  close,100
  suntimes[0] = today_minus2+'_'+StrMid(suntimes[0],10)
  suntimes[1] = today_minus2+'_'+StrMid(suntimes[1],9)

  sunrise = suntimes[0]
  sunset = suntimes[1]

;=======Go to folder from two days ago, GOES data availability is limited so 2 days old is latest===

cd,'C:\Inetpub\wwwroot\callisto\data\'+today_minus2+'\fts\high_freq'

;===============Files between sunrise and sunset ==============
  
  times = anytim(file2time(findfile('*.fit')),/utime)

    ;sunrise will preferably be in the format YYYYMMDD_HHMMSS
  index_sunrise = where(times gt anytim(file2time(sunrise),/utime))
  sunriseFilePos = index_sunrise[0]

  ;sunset will preferably be in the format YYYYMMDD_HHMMSS
  index_sunset = where(times lt anytim(file2time(sunset),/utime))
  sunsetFilePos = index_sunset[n_elements(index_sunset)-1]


;=======Dynamic Spectra of entire day===========================
list = findfile('*.fit')

  radio_spectro_fits_read,list[sunriseFilePos-1],z,x,y ;start value for z ad x
  ;z is a 2D data array, x is ID array time values, y is 1D array of frequency values

    ;for loop to create dynamic spectra of entire day
    FOR i = sunriseFilePos+ 1, sunsetFilePos, 1 DO BEGIN 

        filename = list[i]
        radio_spectro_fits_read,filename,runningZ,runningX,y
        ;runningZ = callisto_spg_recalibrate(runningZ,y,/sfu) 
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

tstart = file2time( list[sunriseFilePos],/yohkoh) ;yohkoh time format is the same as goes
a = file2time( list[sunsetFilePos],/yohkoh)
tend = anytim(a,/utime)+900 ;900 seconds because the file start time for callisto is 15mins behind its end
tend = anytim(tend,/yohkoh)

goes = obj_new('goes')
goes ->  set, tstart=tstart, tend=tend,  showclass=1,/low
;goes->help

;=====Plot=======
set_plot,'win'
loadct,39
!p.color=0
!p.background=255
window,1,xs=1000,ys=500
cd,'C:\Inetpub\wwwroot\callisto\data\realtime\png\high_freq'
loadct,5
!p.multi = [0,1,2]
goes ->plot, /xs ,charsize=1, yrange=[1e-9,1e-3],xrange=[tstart,tend]
;spectro_plot,bytscl(smooth(z,2),-2,12),x,y,/xs,/ys,ytitle='Frequency (MHz)',title='eCallisto (Birr Castle, Ireland)',charsize=1,$
;xticks=10
spectro_plot,smooth(z,2),x,y,/xs,/ys,ytitle='Frequency (MHz)',title='eCallisto (Birr Castle, Ireland)',charsize=1,$
xticks=10
;saveimage,'callisto_goes.png',quality=100,/png
;
x2png,'callisto_goes.png'
;Next line ensures each day folder has a copy of its CALLISTO-GOES plot
cd,'C:\Inetpub\wwwroot\callisto\data\'+today_minus2+'\png'
saveimage,'callisto_goes'+today_minus2+'.png',quality=100,/png


END
    