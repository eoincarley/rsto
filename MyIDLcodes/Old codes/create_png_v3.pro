pro create_png_v3

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

  ;IF latest_fits_time gt latest_png_time THEN BEGIN
      starting_point = where(fits_times gt png_times[n_elements(png_times)-1])
  ;ENDIF  

    cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts\'+folder
    
    ;thisDevice = !D.Name
    ;set_plot,'z',/copy
    ;device,filename = 'single_png.ps',/color,/inches,/landscape,/encapsulate,$
    ;yoffset=8,ysize=6,xsize=8
    
    
  If starting_point[0] ne -1 THEN BEGIN
     starting_point = starting_point[0]
     list = list_fits
     backg = make_daily_background()
     
    
      FOR j=starting_point ,n_elements(list)-1 DO BEGIN
       
        ;device,filename = 'single_png.ps',/color,/inches,/landscape,/encapsulate,$
        ;yoffset=8,ysize=6,xsize=8
        
        thisDevice = !D.Name
        set_plot,'z',/copy
        Device, Set_Resolution=[550,500],z_buffer=0
        erase
         loadct,39
        !p.color=0
        !p.background=255
        radio_spectro_fits_read,list[j],z,x,y
        z = z - backg
        
        newName = strjoin( strsplit(list[j],'fit', /regex,/extract,/preserve_null),'png')
        start_time = anytim(x[0],/yoh,/trun)
        loadct,5
        IF q eq 0 THEN BEGIN
        spectro_plot,bytscl(z,mean(z)-1.5*stdev(z),mean(z)+6.0*stdev(z)),x,y,/xs,/ys,ytitle='Frequency (MHz)',$
        title='eCallisto (Birr Castle, Ireland)',xtitle='Start Time ('+$
        start_time+' UT)', position=[0.1,0.11,0.9,0.9],/normal,$
        yr=[400,200],ytickv=[400,350,300,250,200],yticks=4,yminor=4
        ENDIF
        IF q eq 1 THEN BEGIN
        spectro_plot,bytscl(z,mean(z)-1.5*stdev(z),mean(z)+6.0*stdev(z)),x,y,/xs,/ys,ytitle='Frequency (MHz)',$
        title='eCallisto (Birr Castle, Ireland)',xtitle='Start Time ('+$
        start_time+' UT)', position=[0.1,0.11,0.9,0.9],/normal,$
        yr=[100,10],ytickv=[100,80,60,40,20,10],yticks=5,yminor=4
        
        ENDIF
        IF q eq 2 THEN BEGIN
        spectro_plot,bytscl(z,mean(z)-1.5*stdev(z),mean(z)+6.0*stdev(z)),x,y,/xs,/ys,ytitle='Frequency (MHz)',$
        title='eCallisto (Birr Castle, Ireland)',xtitle='Start Time ('+$
        start_time+' UT)', position=[0.1,0.11,0.9,0.9],/normal,$
        yr=[200,100],ytickv=[200,180,160,140,120,100],yticks=5,yminor=4
        ENDIF
        
        snapshot = TVRD()
        TVLCT, r, g, b, /Get
        Device, Z_Buffer=1
        Set_Plot, thisDevice

        image24 = BytArr(3, 550, 500)
        image24[0,*,*] = r[snapshot]
        image24[1,*,*] = g[snapshot]
        image24[2,*,*] = b[snapshot]

        write_png, newName, image24,r,g,b
  
      ENDFOR
      
  ENDIF
ENDFOR

cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts\mid_freq'
spawn,'del C:\Inetpub\wwwroot\callisto\data\realtime\fts\mid_freq\single_png.ps /q'
cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts\low_freq'
spawn,'del C:\Inetpub\wwwroot\callisto\data\realtime\fts\low_freq\single_png.ps /q'
;device,/close
set_plot,'win'

END