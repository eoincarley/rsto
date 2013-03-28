pro create_png,BACKG=backg

for i=1, 20 do begin

fs = '(I2.2)'
caldat,julday()-i,mon,d,y,h,min,s
today_minusi = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs)
todayhms = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs) +$
'_'+string(h, format=fs)+string(min, format=fs)+string(s, format=fs)

cd,'C:\Inetpub\wwwroot\callist\data\'+today_minusi


list = findfile('*.fit')

for j=0,n_elements(list)-1 do begin

    radio_spectro_fits_read,list[j],z,x,y
    
    
if KEYWORD_SET(backg)  then begin
    sizeData = size(z)
    meanData = fltarr(sizeData[2])

    yaxis = sizeData[2] - 1

    for k=0,yaxis do begin
    meanData(k)=avg(z(*,k))
    endfor
; plot, y(*), mean(*) i.e. frequency on x and mean y
    background = fltarr(sizeData[1],sizeData[2])

   for k =0.0, sizeData[1]-1, 1.0 do begin
     background[i,*] = meanData[*]
   endfor
     z = z - background
endif

loadct,39
!p.color=0
!p.background=255
window,1,xs=1000,ys=500

loadct,1
spectro_plot,z,x,y,/xs,/ys,ytitle='Frequency (MHz)',title='eCallisto (Birr Castle, Ireland)',charsize=1
saveimage,'BIR_'+todayhms+'.png',quality=100,/png

endfor ;end image run-through

endfor ;end folder run-through

end

