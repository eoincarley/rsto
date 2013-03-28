pro create_png_v1

get_utc,YMD
YMD=time2file(YMD,/date)
today_minusi = YMD

FOR q=0,2 DO BEGIN

  IF q eq 0 THEN folder='high_freq'
  IF q eq 1 THEN folder='low_freq'
  IF q eq 2 THEN folder='mid_freq'

  cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts\'+folder
    list_fits = findfile('*.fit')
    latest_fits_time = anytim(file2time(list_fits[n_elements(list_fits)-1]),/utim)
    fits_times = anytim(file2time(list_fits),/utim)
  cd,'C:\Inetpub\wwwroot\callisto\data\realtime\png\'+folder
    list_pngs = findfile('BIR*.png')
    latest_png_time = anytim(file2time(list_pngs[n_elements(list_pngs)-1]),/utim)
    png_times = anytim(file2time(list_pngs),/utim)

  IF latest_fits_time gt latest_png_time THEN BEGIN
      starting_point = where(fits_times gt png_times[n_elements(png_times)-1])
  ENDIF  

    cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts\'+folder
  If starting_point[0] ne -1 THEN BEGIN
    starting_point = starting_point[0]
    list = list_fits
   backg = make_daily_background()
    FOR j=starting_point ,n_elements(list)-1 DO BEGIN
      radio_spectro_fits_read,list[j],z,x,y
      z = z - backg
     
      newName = strjoin( strsplit(list[j],'fit', /regex,/extract,/preserve_null),'png')

          loadct,39
        !p.multi=[0,1,1]
      !p.color=0
        !p.background=255
        window,1,xs=1000,ys=500
      loadct,5
        spectro_plot,bytscl(smooth(z,2),-2,10),x,y,/xs,/ys,ytitle='Frequency (MHz)',$
        title='eCallisto (Birr Castle, Ireland)',charsize=1
      x2png,newName


    ENDFOR
  ENDIF
ENDFOR

END