pro callisto_hourly_windows_test,spectra,BACKG = backg

cd,'C:\Inetpub\wwwroot\callisto\data\realtime\'
fs = '(I2.2)'
caldat,julday(),mon,d,y,h,min,s
today = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs)
todayhms = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs) +$
'_'+string(h, format=fs)+string(min, format=fs)+string(s, format=fs)


;============
list = findfile('*.fit')
 
IF n_elements(list) gt 0 then begin

index_stop = n_elements(list)-1
index_start = index_stop - 3

radio_spectro_fits_read,list[index_start],z,x,y

for i = index_start+1, index_stop, 1 do begin 

    filename = list[i]
    radio_spectro_fits_read,filename,runningZ,runningX,runningy
    ;runningZ = callisto_spg_recalibrate(runningZ,y,/sfu) 
    z = [z,runningZ]
    x = [x,runningX]
    y = [y,runningY]
    
endfor

;============Create and Subtract background  if required =================
if KEYWORD_SET(backg)  then begin
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
endif

array_size = size(z)

summed_freq=fltarr(array_size[1])

FOR i=0., array_size[1]-1,1 DO BEGIN
     summed_freq[i] = total(z(i,*))
ENDFOR
!p.multi = [0,1,1]
window,0,xs=1000,ys=500

normal = summed_freq/max(summed_freq)
;normal = summed_freq
times = x
date_label = LABEL_DATE(DATE_FORMAT = ['%H%I'])
start_time = anytim(x[0],/yohkoh)
set_plot,'win'
loadct=39
!p.color=0
!p.background=255
plot,times,normal,psym=3,XTICKFORMAT = 'LABEL_DATE',XTICKUNITS = 'Minutes',xtickinterval=15,/ynozero,/xs,$
xtitle = 'Start time ('+start_time+')', ytitle = 'Normalised intensity units',charsize=1,min_value=0.8,$
title='Total Normalised Power vs. Time Over 5 Days'
cd,'C:\'
saveimage,'radio_lightcurve.png',quality=100,/png



;===============Plot Spectra==================
!p.multi = [0,1,1]
set_plot,'ps'
device,filename='callisto_hourly.ps',/landscape,/INCHES,YSIZE=10.0,xsize=20,SCALE_FACTOR=0.5,/color
loadct,5
;!p.color=0
spectro_plot,smooth(z,1),x,y,/xs,/ys,ytitle='Frequency (MHz)',title='eCallisto (Birr Castle, Ireland)',charsize=2
device,/close
set_plot,'win'

loadct,39
!p.color=0
!p.background=255
window,1,xs=1000,ys=500

loadct,1
spectro_plot,z,x,y,/xs,/ys,ytitle='Frequency (MHz)',title='eCallisto (Birr Castle, Ireland)',charsize=1
saveimage,'callisto_hourly.png',quality=100,/png
;$convert -format jpeg -quality 100 callisto_hourly.ps test.jpg  

;

ENDIF

IF n_elements(list) eq 0 then print,'No realtime spectra available'

;===========Pietro's system status ===============
file_times = file2time(list)
current_time = file2time(todayhms)
file_times = anytim(file_times,/utime)
current_time = anytim(current_time,/utime)


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
;================================================================= 

cd,'c:\logs'
openr,100,'suntimes.txt'
suntimes = strarr(3)
readf,100,suntimes
close,100
suntimes[0] = today+'_'+StrMid(suntimes[0],10)
suntimes[1] = today +'_'+StrMid(suntimes[1],9)
suntimes[2] = today +'_'+StrMid(suntimes[2],10)
times4php = strarr(3)
times4php[0] = 'Sunrise: ' +anytim(  file2time(suntimes[0]),/yohkoh)+' <br>'
times4php[1] = 'Sunset:   ' +anytim(  file2time(suntimes[1]),/yohkoh)+' <br>'
times4php[2]= 'Transit time: ' +anytim(  file2time(suntimes[2]),/yohkoh)
times4php =transpose(times4php)

openw,100,'sitetime.txt'
printf,100,times4php
close,100


end



