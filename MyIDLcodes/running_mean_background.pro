pro running_mean_background,data,background

;
;
; Name: running_mean_background
; 
; Purpose: 
;   -Create background of average in each frequency channel in 'data'
;
; Input parameters:
;   -data: A dynamic spectra 
;
; Keywords:
;   -None
;
; Ouputs:
;   -background: Background genereated from average values of freq channels through time in data
;   
;   Last modified:
;   - 10-Nov-2011 (E.Carley) Just a clean up....
;
;

sizeData = size(data)
meanData = fltarr(sizeData[2])

yaxis = sizeData[2] - 1

FOR i=0,yaxis DO BEGIN
  meanData(i)=avg(data(*,i))
ENDFOR
background=meanData

END
