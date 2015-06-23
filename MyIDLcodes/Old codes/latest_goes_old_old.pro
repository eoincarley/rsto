function latest_goes,tstart,tend

fs = '(I2.2)'
caldat,julday(),mon,d,y,h,min,s
today = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs)


url = 'http://www.swpc.noaa.gov'
root = '/ftpdir/lists/xray/'
;file = today+'_Gp_xr_1m.txt'
file = 'Gp_xr_1m.txt'

data = sock_find(url,file,path=root)
;print,data
;print,data[n_elements(data)-1]
sock_copy,data[n_elements(data)-1]
text = rd_tfile(file,/nocomment)
;print,text


goesDataArray = strarr(8,n_elements(text)-2)
FOR i=0,n_elements(text)-3 DO BEGIN
    split = strsplit(text[i+2],' ',/extract)
       for j = 0,7 do begin
         goesDataArray[j,i]=split[j,0]
       endfor
ENDFOR    

;Arse-ways of getting correct time format but it works!
time  = string(goesDataArray)
time = time(0,*) + time(1,*) + time(2,*) +'_'+time(3,*)


;=============Work out sunset sunrise position===============
      times = anytim(file2time(time,/yohkoh), /utime)
      index_sunrise = closest( times, anytim(file2time(tstart),/utime) )
      sunriseTimePos = index_sunrise[0]
      start_time = file2time(time[sunriseTimePos],/yohkoh)

      index_sunset = closest( times, anytim(file2time(tend),/utime) )
      sunsetTimePos = index_sunset[n_elements(index_sunset)-1]
      ;print,sunriseTimePos,sunsetTimePos      

;===============================================================
time = anytim( file2time(time,/yohkoh), /ex)
time = julday(time[5,*],time[4,*],time[6,*],time[0,*],time[1,*],time[2,*])


date_label = LABEL_DATE(DATE_FORMAT = ['%H:%I'])


low_channel = dblarr(n_elements(text)-3)
high_channel = dblarr(n_elements(text)-3)
low_channel = goesDataArray[7,*]
high_channel = goesDataArray[6,*]

help,low_channel


;stop
;window,0,xs=900,ys=400
;loadct,39
;!p.background=255
;!p.color=0


;plot,time[sunriseTimePos:sunsetTimePos],low_channel[sunriseTimePos:sunsetTimePos],$
;XTICKFORMAT = 'LABEL_DATE',XTICKUNITS = 'minutes',$
;xtickinterval=10,/xs,charsize=1.7,ytitle='Watts !5m!E2',$
;xtitle='!5Start time: '+'('+start_time+')',$
;thick=1,yrange=[1e-9,1e-3],/ylog,title='Flux GOES15 0.1-0.8nm, 5 min time resolution',psym=3

;oplot,time[sunriseTimePos:sunsetTimePos],low_channel[sunriseTimePos:sunsetTimePos],color=240,thick=2


;axis,yaxis=1,ytickname=[' ','A','B','C','M','X',' '],charsize=2
;axis,yaxis=0,yrange=[1e-9,1e-3],ytitle='Watts !5m!E2',charsize=1.7
;axis,xaxis=0,XTICKFORMAT = 'LABEL_DATE',XTICKUNITS = 'minutes',$
;xtickinterval=10,/xs,charsize=1.7,xtitle='!5Start time: '+'('+start_time+')'
;axis,xaxis=1,xtickname=[' ',' ',' ',' ',' ',' ',' '],xtitle='Flux GOES15 0.1-0.8nm, 5 min time resolution',charsize=2


;plots,time[sunriseTimePos:sunsetTimePos],1e-8
;plots,time[sunriseTimePos:sunsetTimePos],1e-7
;plots,time[sunriseTimePos:sunsetTimePos],1e-6
;plots,time[sunriseTimePos:sunsetTimePos],1e-5
;plots,time[sunriseTimePos:sunsetTimePos],1e-4
;oplot,time[sunriseTimePos:sunsetTimePos],low_channel[sunriseTimePos:sunsetTimePos],color=230,thick=1.7



rows = abs(sunriseTimePos - sunsetTimePos)+1
goes_array = dblarr(3,rows)


goes_array(0,*) = time[sunriseTimePos:sunsetTimePos]
goes_array(1,*) = low_channel[sunriseTimePos:sunsetTimePos]
goes_array(2,*) = high_channel[sunriseTimePos:sunsetTimePos]

return,goes_array

END