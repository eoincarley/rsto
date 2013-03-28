pro archive_mid

cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts\mid_freq'

files = findfile('BIR*02.fit')
yyyymmdd = strarr(n_elements(files))
dates=[' ']
j=0

FOR i=0,n_elements(files)-1 DO BEGIN
    
  date_times = anytim(file2time(files[i]),/ex)
  yyyymmdd = string(date_times[6],format='(I4.2)')+$
  string(date_times[5],format='(I2.2)')+$
  string(date_times[4],format='(I2.2)')
  
  IF dates[j] ne yyyymmdd THEN BEGIN
     dates = [dates,yyyymmdd]
     j=j+1
  ENDIF   
  
  
ENDFOR  
  
  
FOR i=3,n_elements(dates)-2 DO BEGIN  
  cd,'C:\Inetpub\wwwroot\callisto\data\'+dates[i]+'\fts\'
  IF file_test('mid_freq') eq 1 THEN BEGIN
      cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts\mid_freq\'
      spawn,'move *'+dates[i]+'*.fit C:\Inetpub\wwwroot\callisto\data\'+dates[i]+'\fts\mid_freq\'
  ENDIF ELSE BEGIN
      spawn,'mkdir mid_freq'
      cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts\mid_freq\'
      spawn,'move *'+dates[i]+'* C:\Inetpub\wwwroot\callisto\data\'+dates[i]+'\fts\mid_freq\'
  ENDELSE       
  
ENDFOR  
END