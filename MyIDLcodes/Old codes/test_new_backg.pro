pro test_new_backg

cd,'C:\Inetpub\wwwroot\callisto\data\20110823\fts\low_freq'

backg = make_daily_background()

radio_spectro_fits_read,'BIR_20110823_121459_01.fit',z,x,y
z = z - backg
loadct,39
!p.color=0
!p.background=255
window,0,xs=900,ys=500

loadct,5
spectro_plot,bytscl(z,0,20),x,y,/xs,/ys,ytitle='Frequency (MHz)',title=$
'eCallisto (Birr Castle, Ireland)',charsize=1

newName = strjoin( strsplit('BIR_20110823_121459_01.fit','fit', /regex,/extract,/preserve_null),'png')
x2png,newName

END