pro copy_index
cd,'C:\Inetpub\wwwroot\callisto\data\realtime\png\high_freq'

for i=2,8 do begin

fs = '(I2.2)'
caldat,julday()-i,mon,d,y,h,min,s
today_minus = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs)


spawn,'copy index.php C:\Inetpub\wwwroot\callisto\data\'+today_minus+'\png\high_freq'
spawn,'copy index.php C:\Inetpub\wwwroot\callisto\data\'+today_minus+'\png\low_freq'

endfor
end