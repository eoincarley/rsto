pro create_png

;
;
; Name: create_png.pro
; 
; Purpose: 
;   -Make PNGs from latest fits folders in the archive (version 2)
;
; Input parameters:
;   -None
;
; Keywords:
;   -None
;
; Ouputs:
;   -PNG files of latest fits folders saved in the fits archive. They are shifted to a fits archive by 
;    umbrella routine that runs this code e.g. callisto_hourly_batch.pro run by callisto_hourly.bat
;   
; Calling sequence:
;   - create_png_v2
;
;   Last modified:
;   - 10-Nov-2011 (E.Carley) Force correct axes display on each spectra.
;   - 08-Jan-2013 (E.Carley) v2 implements. Change to realtime fts folder into which live data is written. Need change in
;                            findfile argument to take into account ALL receiver .fts are in the one folder
;
;   Recommended Updates:
;   - Start plotting in z buffer to make things run faster (see v3 of this code; currently not working)
;   - To do list: The code is a bit of a mess of FOR and IF statements, it could do with being 
;     made more efficient
;

get_utc,YMD
YMD=time2file(YMD,/date)
today_minusi = YMD

FOR q=0,2 DO BEGIN

  IF q eq 0 THEN receiver='03'
   
  IF q eq 1 THEN receiver='01'

  IF q eq 2 THEN receiver='02'

  cd,'C:\Inetpub\wwwroot\data\realtime\callisto\fts\'
    list_fits = findfile('*'+receiver+'.fit')
    latest_fits_time = anytim(file2time(list_fits[n_elements(list_fits)-1]),/utim)
    fits_times = anytim(file2time(list_fits),/utim)
    
  cd,'C:\Inetpub\wwwroot\data\realtime\callisto\png\'
    list_pngs = findfile('*'+receiver+'.png')
    latest_png_time = anytim(file2time(list_pngs[n_elements(list_pngs)-1]),/utim)
    png_times = anytim(file2time(list_pngs),/utim)

  IF latest_fits_time gt latest_png_time THEN BEGIN
      starting_point = where(fits_times gt png_times[n_elements(png_times)-1])
  ENDIF ELSE BEGIN
      starting_point = -1.0
  ENDELSE    

  cd,'C:\Inetpub\wwwroot\data\realtime\callisto\fts\'
  set_plot,'ps'
    
    
  IF starting_point[0] ne -1 THEN BEGIN
     starting_point = starting_point[0]
     list = list_fits
     ;backg = make_daily_background(receiver)
     
    
      FOR j=starting_point ,n_elements(list)-1 DO BEGIN
       
        device,filename = 'single_png.ps', /color, /inches, /landscape, /encapsulate, $
        yoffset=8, ysize=6, xsize=8
        radio_spectro_fits_read, list[j], data, time, freq
        data = constbacksub(data, /auto);z - backg
        
        newName = strjoin( strsplit(list[j],'fit', /regex,/extract,/preserve_null),'png')
        start_time = anytim(time[0],/yoh,/trun)
        loadct,5
        IF q eq 2 THEN BEGIN
          spectro_plot, data > (-10), time, freq, $
          /xs,/ys,ytitle='Frequency (MHz)',yr=[200,100],$
          title='eCallisto (Birr Castle, Ireland)',xtitle='Start Time ('+$
          start_time+' UT)', position=[0.1,0.11,0.9,0.9],/normal
        ENDIF
        IF q eq 1 THEN BEGIN
          spectro_plot, data > (-10), time, freq, $
          /xs, /ys, ytitle='Frequency (MHz)', yr=[100,10], ytickv=[100,80,60,40,20,10], yticks=5, yminor=4, $
          title='eCallisto (Birr Castle, Ireland)',xtitle='Start Time ('+$
          start_time+' UT)', position=[0.1,0.11,0.9,0.9],/normal
        ENDIF 
        IF q eq 0 THEN BEGIN
          spectro_plot, data > (-10), time, freq, $
          /xs,/ys,ytitle='Frequency (MHz)',$
          title='eCallisto (Birr Castle, Ireland)',xtitle='Start Time ('+$
          start_time+' UT)', position=[0.1,0.11,0.9,0.9],/normal
        ENDIF
        
        spawn,'convert \c -rotate "-90" single_png.ps '+newName
        spawn,'CMDOW /MA'
        device,/close
        spawn,'del C:\Inetpub\wwwroot\data\realtime\callisto\fts\single_png.ps /q'
        ;set_plot,'win'
        
      ENDFOR
      
  ENDIF
ENDFOR


;device,/close
set_plot,'win'
get_utc,ut
fin_time = anytim(ut,/yoh,/trun)
print,''
print,'create_png finsihed at '+fin_time
print,''

END