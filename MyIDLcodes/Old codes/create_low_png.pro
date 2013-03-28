pro create_low_png

for j=8,8 do begin
fs = '(I2.2)'
caldat,julday()-j,mon,d,y,h,min,s
today_minus = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs)

cd,'C:\Inetpub\wwwroot\callisto\data\'+today_minus+'\png'
spawn, 'mkdir high_freq'
spawn, 'mkdir low_freq'

cd,'C:\Inetpub\wwwroot\callisto\data\'+today_minus+'\png'
spawn,'move /y *.png high_freq'

cd,'C:\Inetpub\wwwroot\callisto\data\'+today_minus+'\fts\low_freq\'

list = findfile('*.fit')
stopping = n_elements(list)-1
    

for i=13 ,stopping do begin

  radio_spectro_fits_read,list[i],z,x,y
    
    
      
          sizeData = size(z)
          meanData = fltarr(sizeData[2])

          yaxis = sizeData[2] - 1

          for k=0,yaxis do begin
                meanData(k)=avg(z(*,k))
          endfor
; plot, y(*), mean(*) i.e. frequency on x and mean y
      background = fltarr(sizeData[1],sizeData[2])

          for k =0.0, sizeData[1]-1, 1.0 do begin
          background[k,*] = meanData[*]
          endfor
     z = z - background


newName = strjoin( strsplit(list[i],'fit', /regex,/extract,/preserve_null),'png')

set_plot,'win'
  loadct,39
  !p.color=0
  !p.background=255
  window,1,xs=1000,ys=500
  loadct,5
  spectro_plot,bytscl(smooth(z,2),-2,10),x,y,/xs,/ys,ytitle='Frequency (MHz)',title='eCallisto (Birr Castle, Ireland)',charsize=1
  x2png,newName
  
;spawn,'move /y *.png C:\Inetpub\wwwroot\callisto\data\'+today_minus+'\png\low_freq  
endfor
spawn,'move /y *.png C:\Inetpub\wwwroot\callisto\data\'+today_minus+'\png\low_freq 
endfor
end
