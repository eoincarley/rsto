PRO email_warning_mag

;
;__________________________________________________________
;tests if SID data is being recording in the last hour

cd, 'S:\'

list = findfile('*.csv')  
  
file = list[ n_elements( list ) - 1 ]
print, file

flag = file_test(file)
print, 'Flag:', flag

;_______________________________________________________
;tests if computer can be accessed by the callisto machine

IF flag eq 0 THEN BEGIN

  cd, 'C:\MyIDLCodes\Email_warning_mag'
  spawn, 'email_send1.vbs'


ENDIF ELSE BEGIN
  
  txt = rd_text(file)
  line = txt[ n_elements(txt) - 1 ]
  last_recorded_time = JULDAY(strmid(line , 5, 2 ), strmid( line, 8, 2 ), strmid( line, 0, 4 ),  strmid( line, 11, 2 ), strmid( line, 14, 2 ), strmid( line, 17, 2 ) )
  current_time = SYSTIME(/Julian)
  print, last_recorded_time, current_time

  IF last_recorded_time lt current_time - 0.04 THEN BEGIN ;0.04 corresponds to 1 hour in jultime
    
    cd, 'C:\MyIDLCodes\Email_warning_mag'
    print, '0'
    spawn, 'email_send2.vbs'

 ENDIF

ENDELSE


;
;__________________________________________________________
;tests if MAG data is being recording in the last hour

cd, 'M:\'

list = findfile('*.dat')  
  
file = list[ n_elements( list ) - 1 ]
print, file

flag = file_test(file)
print, flag

;_______________________________________________________
;tests if computer can be accessed by the callisto machine

IF flag eq 0 THEN BEGIN

  cd, 'C:\MyIDLCodes\Email_warning_mag'
  spawn, 'email_send1.vbs'

;__________________________________________________________
;tests if SID data is being recording in the last hour

ENDIF ELSE BEGIN
  
  txt = rd_text(file)
  line = txt[ n_elements(txt) - 1 ]
  last_recorded_time = JULDAY(strmid(line , 3, 2 ), strmid( line, 0, 2 ), strmid( line, 6, 4 ),  strmid( line, 11, 2 ), strmid( line, 14, 2 ), strmid( line, 17, 2 ) )
  current_time = SYSTIME(/Julian)
  print, last_recorded_time, current_time

  IF last_recorded_time lt current_time - 0.04 THEN BEGIN ;0.04 corresponds to 1 hour in jultime
    
    cd, 'C:\MyIDLCodes\Email_warning_mag'
    print, '0'
    spawn, 'email_send3.vbs'

 ENDIF

ENDELSE

END
