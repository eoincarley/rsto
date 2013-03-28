function latest_goes_v1,tstart,tend,ALL_DAY=ALL_DAY

;
;
; Name: latest_goes_v1
; 
; Purpose: 
;   -Retrieve the GOES light curve between the two input times. Lightcurves are from the NOAA
;    text file of 1 or 5 minute data at http://www.swpc.noaa.gov/ftpdir/lists/xray/
;
; Input parameters:
;   -tstart: Start time, in format of string 'YYYYMMDD_HHMMSS'
;   -tend: End time, in format of string 'YYYYMMDD_HHMMSS'
;
; Keywords:
;   -None
;
; Ouputs:
;   -Returns a 3 column array of times, low goes channel, high goes channel
;
;   Notes:
;   -GOES object is much better way of plotting data. Wrote this so I could have better
;    control over plot appearance.
;   
;   Last modified:
;   - 16-Nov-2011 (E.Carley) Added all_day keyword
;
;

;====Get correct time formats=========
get_utc,ut
today=time2file(ut,/date)
chosen_date = time2file( anytim(file2time(tstart),/utim),/date)

;====Define URL and path of the NOAA GOES text file======
;=======Check to see if today's GOES is needed===========
url = 'http://www.swpc.noaa.gov'
root = '/ftpdir/lists/xray/'
root = '/ftpdir/lists/xray/'
IF keyword_set(all_day) THEN BEGIN
  file=chosen_date +'_Gp_xr_1m.txt'
ENDIF ELSE BEGIN  
  IF chosen_date eq today THEN BEGIN
      file = 'Gp_xr_1m.txt'
  ENDIF ELSE BEGIN
      file = chosen_date+'_Gp_xr_1m.txt'
  ENDELSE
ENDELSE 

;======The following basically parses the text file into a data array====
;==========read_col or some other function would do the same job=========
data = sock_find(url,file,path=root)
sock_copy,data[n_elements(data)-1]
text = rd_tfile(file,/nocomment)
stop
goesDataArray = strarr(8,n_elements(text)-2)
FOR i=0,n_elements(text)-3 DO BEGIN
    split = strsplit(text[i+2],' ',/extract)
       FOR j = 0,7 DO BEGIN
         goesDataArray[j,i]=split[j,0]
       ENDFOR
ENDFOR    

;===Arse-ways of getting correct time format but it works!=====
time  = string(goesDataArray)
time = time(0,*) + time(1,*) + time(2,*) +'_'+time(3,*)


;=============Work out start and stop positions===============
      times = anytim(file2time(time,/yohkoh), /utime)
      indices = closest( times, anytim(file2time(tstart),/utime) )
      index_start = indices[0]
      start_time = file2time(time[index_start],/yohkoh)

      indices = closest( times, anytim(file2time(tend),/utime) )
      index_stop = indices[n_elements(indices)-1]
        
;===============================================================
time = anytim( file2time(time,/yohkoh), /utim)

low_channel = dblarr(n_elements(text)-3)
high_channel = dblarr(n_elements(text)-3)
low_channel = goesDataArray[7,*]
high_channel = goesDataArray[6,*]

rows = abs(index_start - index_stop)+1
goes_array = dblarr(3,rows)

goes_array[0,*] = time[index_start:index_stop]
goes_array[1,*] = low_channel[index_start:index_stop]
goes_array[2,*] = high_channel[index_start:index_stop]

return,goes_array
stop
END