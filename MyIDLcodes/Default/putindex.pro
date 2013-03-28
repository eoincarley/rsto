pro putindex

fs = '(I2.2)'
caldat,julday(),mon,d,y,h,min,s
today_minusi = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs)
todayhms = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs) +$
'_'+string(h, format=fs)+string(min, format=fs)+string(s, format=fs)

cd,'C:\Inetpub\wwwroot\callisto\data\realtime\png'
for i=1,60 do begin


$copy index.php c:\inetpub\wwwroot\callisto\data\fs-i\png

endfor

end
