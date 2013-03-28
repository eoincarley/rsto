pro move_low

;or i=0,0 do begin
;fs = '(I2.2)'
;caldat,julday()-i,mon,d,y,h,min,s
;today_minus = string(y, format = '(I4.2)') + string(mon, format=fs) + string(d, format=fs)

cd,'C:\Inetpub\wwwroot\callisto\data\realtime\png\'
;spawn, 'mkdir high_freq'
;spawn, 'mkdir low_freq';

spawn, 'move /y *.png C:\Inetpub\wwwroot\callisto\data\realtime\png\high_freq
spawn, 'move /y *.php C:\Inetpub\wwwroot\callisto\data\realtime\png\high_freq
;spawn, 'move /y *20.fit C:\Inetpub\wwwroot\callisto\data\realtime\fts\low_freq
;cd,'C:\Inetpub\wwwroot\callisto\data\realtime\fts
;print,today_minus
;spawn, 'mkdir high_freq'
;spawn, 'mkdir low_freq'

;spawn, 'move /y *59.fit C:\Inetpub\wwwroot\callisto\data\'+today_minus+'\fts\high_freq'

;;endfor

end