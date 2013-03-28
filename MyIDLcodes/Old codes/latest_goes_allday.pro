pro latest_goes_allday,tstart,tend,goes_array,goesDataArray

get_utc,ut
today=time2file(ut,/date)

;========obselete code! Now just latest_goes_v1 used

url = 'http://www.swpc.noaa.gov'
root = '/ftpdir/lists/xray/'
file = today+'_Gp_xr_1m.txt'

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
time = anytim( file2time(time),/yohkoh,/utim)

low_channel = dblarr(n_elements(text)-3)
high_channel = dblarr(n_elements(text)-3)
low_channel = goesDataArray[7,*]
high_channel = goesDataArray[6,*]

rows = abs(sunriseTimePos - sunsetTimePos)+1
goes_array = dblarr(3,rows)

goes_array(0,*) = time[sunriseTimePos:sunsetTimePos]
goes_array(1,*) = low_channel[sunriseTimePos:sunsetTimePos]
goes_array(2,*) = high_channel[sunriseTimePos:sunsetTimePos]

END