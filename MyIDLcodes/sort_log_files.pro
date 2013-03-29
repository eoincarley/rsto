pro sort_log_files_v1, create_dirs = create_dirs

cd,'C:\Inetpub\wwwroot\callisto\log'
get_utc, propgram_start
sec_in_day = 24.0*60.0*60.0
files = findfile('*.prn')
file_times = anytim(file2time(files), /utim)
index_sorted = sort(file_times)
file_times = file_times[index_sorted]



tstart = anytim(file_times[0], /utim, /date_only)
tend = anytim(file_times[ n_elements(file_times)-1],/utim, /date_only)
no_of_days = (tend - tstart)/sec_in_day
date_split_array = strarr(3,no_of_days)

IF keyword_set(create_dirs) THEN BEGIN
FOR i = 0, no_of_days-1 DO BEGIN  
  t = tstart + i*sec_in_day
  print,anytim(t, /yoh)
  date_split = anytim(t, /ex)
  year = string(date_split[6], format='(I4)')
  month = string(date_split[5], format='(I02)')
  day = string(date_split[4], format='(I02)')
  
  date_split_array[0,i] = year
  date_split_array[1,i] = month
  date_split_array[2,i] = day
ENDFOR

FOR i=0, no_of_days-1 DO BEGIN  
  year = date_split_array[0,i]
  year_new = date_split_array[0,i]
  spawn,'mkdir '+year
  cd,year
  WHILE year eq year_new DO BEGIN
    month = date_split_array[1,i]
    month_new = date_split_array[1,i]
    spawn,'mkdir '+month
    cd,month
    WHILE month eq month_new DO BEGIN
      day = date_split_array[2,i]
      spawn,'mkdir '+day
      i=i+1
      month_new = date_split_array[1,i]
    ENDWHILE
    cd,'..'
    year_new = date_split_array[0,i]
  ENDWHILE
  cd,'..'
ENDFOR

ENDIF

FOR i=0, n_elements(files)-1 DO BEGIN
  log = files[i]
  t_ex = anytim(file2time(log), /ex)
  year = string(t_ex[6], format='(I4)')
  month = string(t_ex[5], format='(I02)')
  day = string(t_ex[4], format='(I02)')
  
  spawn,'move '+log+' '+year+'\'+month+'\'+day+'\'
 
ENDFOR


END