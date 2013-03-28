pro move_files

for i=3, 35 do begin

fs = '(I2.2)'
caldat,julday()-i,mon,d,y,h,min,s
today_minusi = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs)
todayhms = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs) +$
'_'+string(h, format=fs)+string(min, format=fs)+string(s, format=fs)

cd,'C:\Inetpub\wwwroot\callisto\data\'+today_minusi

$mkdir fts
$move *.fit* fts
$mkdir png
$move *.png* png

endfor 

end

