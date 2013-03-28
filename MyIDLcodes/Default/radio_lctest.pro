pro radio_lctest,normal,z

;=========Get today's date in correct format========
for j=0,1 do begin

k = 1-j
fs = '(I2.2)'
caldat,julday()-k,mon,d,y,h,min,s

today_minus2 = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs)

todayhms = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs) +$
'_'+string(h, format=fs)+string(min, format=fs)+string(s, format=fs)
cd,'c:\logs'
openr,100,'suntimes.txt'
suntimes = strarr(3)
readf,100,suntimes
close,100
suntimes[0] = today_minus2+'_'+StrMid(suntimes[0],10)
suntimes[1] = today_minus2+'_'+StrMid(suntimes[1],9)

sunrise = suntimes[0]
sunset = suntimes[1]
if k eq 1 then begin
cd,'C:\Inetpub\wwwroot\callisto\data\'+today_minus2+'\fts\'
endif
if k eq 0 then begin
cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts\'
endif
;===============Files between sunrise and sunset ==============
files = findfile('*.fit')
file_times = file2time(files)
times = anytim(file_times,/utime)

sunrise = file2time(sunrise) ; sunrise will preferably be in the format YYYYMMDD_HHMMSS
sunrise = anytim(sunrise,/utime) 
index_sunrise =where(times gt sunrise)
sunriseFilePos = index_sunrise[0]

sunset = file2time(sunset) ; sunsetwill preferably be in the format YYYYMMDD_HHMMSS
sunset = anytim(sunset,/utime)
index_sunset = where(times lt sunset)
sunsetFilePos = index_sunset[n_elements(index_sunset)-1]


;sock_copy,files[sunriseFilePos:sunsetFilePos],/verb,/loud

;=======Dynamic Spectra of entire day===========================
list = findfile('*.fit')
if k eq 1 then begin
radio_spectro_fits_read,list[0],z,x,y ;start value for z ad x
endif
;z = callisto_spg_recalibrate(z,y,/sfu) 

;for loop to create dynamic spectra of entire day
i=0
for i = 1, n_elements(list)-1, 1 do begin 

    filename = list[i]
    radio_spectro_fits_read,filename,runningZ,runningX,y
   ; runningZ = callisto_spg_recalibrate(runningZ,y,/sfu) 
    z = [z,runningZ]
    x = [x,runningX]
    
endfor

;============Create and Subtract background  if required =================
IF KEYWORD_SET(backg)  then begin
sizeData = size(z)
meanData = fltarr(sizeData[2])

yaxis = sizeData[2] - 1

for i=0,yaxis do begin
  meanData(i)=avg(z(*,i))
endfor
; plot, y(*), mean(*) i.e. frequency on x and mean y
background = fltarr(sizeData[1],sizeData[2])

for i =0.0, sizeData[1]-1, 1.0 do begin
     background[i,*] = meanData[*]
endfor
     z = z - background
ENDIF
endfor

;===========Get the goes data==================================

;tstart = file2time( list[sunriseFilePos],/yohkoh) ;yohkoh time format is the same as goes
;a = file2time( list[sunsetFilePos],/yohkoh)
;tend = anytim(a,/utime)+900 ;900 seconds
;tend = anytim(tend,/yohkoh)

;print,'tstart = '+ tstart
;print,'tend = '+ tend

;=====Plot=======

array_size = size(z)

summed_freq=fltarr(array_size[1])

FOR i=0., array_size[1]-1,1 DO BEGIN
     summed_freq[i] = total(z(i,*))
ENDFOR


time = anytim(x,/ex)
julian = julday(time[5,*],time[4,*],time[6,*],time[0,*],time[1,*],time[2,*])
date_label = LABEL_DATE(DATE_FORMAT = ['%H:%I:%S'])
start_time = anytim(x[0],/yohkoh)
print,'start time: '+start_time

normal = summed_freq/max(summed_freq)

!p.multi = [0,1,1]
window,0,xs=1000,ys=500

set_plot,'win'
loadct=39
!p.color=0
!p.background=255
plot,julian,normal,psym=3,XTICKFORMAT = 'LABEL_DATE',XTICKUNITS = 'hour',xtickinterval=12,/ynozero,/xs,$
xtitle = 'Start time ('+start_time+')', ytitle = 'Normalised intensity units',charsize=1,min_value=0.8,$
title='Total Normalised Power vs. Time Over 5 Days'
cd,'C:\'
saveimage,'radio_lightcurve.png',quality=100,/png

end


