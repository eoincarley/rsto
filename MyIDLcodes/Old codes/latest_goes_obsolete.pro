function latest_goes_obsolete,tstart,tend, local=local

fs = '(I2.2)'
caldat,julday(),mon,d,y,h,min,s
today = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs)

If keyword_set(local) then begin
	file = 'Gp_xr_1m.txt'
	text = rd_tfile(file,/nocomment)
ENDIF ELSE BEGIN	
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
ENDELSE


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




rows = abs(sunriseTimePos - sunsetTimePos)+1
goes_array = dblarr(3,n_elements(high_channel))


goes_array(0,*) = time
goes_array(1,*) = low_channel
goes_array(2,*) = high_channel
stop
return,goes_array

END