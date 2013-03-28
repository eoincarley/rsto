pro callisto_hourly_test,spectra,backg=backg


;  Name: callisto_hourly_windows
;
;  Purpose: This is a routine that finds the latest dynamic spectra and plots the past hour's worth.
;            A png is then created for online display
;
;           It also has a small routine that checks if there's been new spectra created in the past 
;           hour. If not it sets the observation status to 'off'
;
;  Input parameters:
;           -none
;
;  Keyword parametrs:
;           -BACKG - set if background subtract is needed. Background is created within this code
;
;  Outputs:
;         -Spectra - Dynamic spectra of last hour (a png of this is also saved)
;         -This routine also edits the file in C:\logs\system_status.txt
;          which is used for online purposes.
;


;=========Go to current day fits folder==========

cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts\high_freq'

get_utc,ut
today=time2file(ut,/date)

list = findfile('*.fit')
 
IF n_elements(list) gt 0 THEN BEGIN

  index_stop = n_elements(list)-1
  index_start = index_stop - 7 

  radio_spectro_fits_read,list[index_start],z,x,y
  ;z is a 2D data array, x is ID array time values, y is 1D array of frequency values

  sizeData = size(z)
  meanData = fltarr(sizeData[2])

  yaxis = sizeData[2] - 1
          for i=0,yaxis do begin
           meanData(i)=avg(z(*,i))
          endfor
     background = fltarr(sizeData[1],sizeData[2])

          for i =0.0, sizeData[1]-1, 1.0 do begin
             background[i,*] = meanData[*]
          endfor
     z = z - background

  ;==Loop to 'string together' all spectra from last hour==================
       for i = index_start+1, index_stop, 1 do begin 

              filename = list[i]
              radio_spectro_fits_read,filename,runningZ,runningX,runningy
              ;runningZ = callisto_spg_recalibrate(runningZ,y,/sfu) 
              sizeData = size(runningZ)
  meanData = fltarr(sizeData[2])

  yaxis = sizeData[2] - 1
          for q=0,yaxis do begin
           meanData(q)=avg(runningZ(*,q))
          endfor
     background = fltarr(sizeData[1],sizeData[2])

          for k =0.0, sizeData[1]-1, 1.0 do begin
             background[k,*] = meanData[*]
          endfor
     runningZ = runningZ - background
              
              
              z = [z,runningZ]
              x = [x,runningX]
              
    
       endfor
       ;z = tracedespike(z,statistics=7)
;z = GlidBackSub(z,1000)
;z = tracedespike(z,statistics=8)
       
       stop
ENDIF
  ;============Create and Subtract background if required =================
  loadct,5
  spectro_plot,bytscl(smooth(z,3),-2,10),x,y,/xs,/ys,ytitle='Frequency (MHz)',$
  title='eCallisto (Birr Castle, Ireland)',$
  charsize=1.5
  
  end
