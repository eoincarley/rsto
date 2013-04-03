pro correct_latlong

;------------- Generate paths ---------------;
cd,'C:\Inetpub\wwwroot\data'

start_date = '20100817_000000'
end_date = '20130402_000000'
start_date = anytim(file2time(start_date), /utim)
date_ex = anytim(start_date, /ex)

folders = string(date_ex[6], format='(I4)')+'\'$
    +string(date_ex[5], format='(I02)')+'\'$
    +string(date_ex[4], format='(I02)')

sid = 24.0*60*60.0    
i = 1.0
next_date = start_date
WHILE next_date lt anytim(file2time(end_date), /utim) DO BEGIN    
  
  next_date =  start_date + sid*i
  date_ex = anytim(next_date, /ex)
  next_folder = string(date_ex[6], format='(I4)')+'\'$
       +string(date_ex[5], format='(I02)')+'\'$
         +string(date_ex[4], format='(I02)')
  folders = [folders, next_folder]

  i = i + 1.0
ENDWHILE


;--------- Go to Directories -----------;
cd, folders[0]
IF file_test('callisto') eq 1 THEN cd, 'callisto'
cd,'fts'

fits_files = findfile('*.fit')
data = readfits(fits_files[0], hdr)

old_string = "OBS_LOC = 'E       '           / observatory longitude code {E,W}               "
new_string = "OBS_LOC = 'W       '           / observatory longitude code {E,W}               "
IF hdr[36] eq old_string THEN BEGIN
  hdr[36] = new_string
ENDIF

writefits, fits_files[0], data, hdr


END