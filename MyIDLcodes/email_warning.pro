pro email_warning,DO_CHECK = do_check

;  Name: email_warning
;
;  Purpose: This is a routine that looks for a drop in data. If there's no new files in the
;     last hour it sends and email warning
;
;  Input parameters:
;           -none
;
;  Keyword parametrs:
;           -none
;  Outputs:
;           -Warning email
;           
;  Calls on:
;           -
;
;  Last modified:
;           - 19-Jan-2012 - Written by Eoin Carley
;
get_utc,ut

IF keyword_set(do_check) THEN print,'Performing data check for email warning system'
data_drop = strarr(3)
data_drop[*] = 'ONLINE'

cd,'C:\Inetpub\wwwroot\sunrise_sunset'

openr,1,'system_status.txt'
status = strarr(4)
readf,1,status
close,1


check_low = strsplit(status[1], 'Off', /extract, /regex)
check_mid = strsplit(status[2], 'Off', /extract, /regex)
check_high = strsplit(status[3], 'Off', /extract, /regex)

IF status[1] ne check_low[0] THEN data_drop[0] ='OFFLINE'
IF status[2] ne check_mid[0] THEN data_drop[1] ='OFFLINE'
IF status[3] ne check_high[0] THEN data_drop[2] ='OFFLINE'

;**********If a data drop is detected then begin alert***********
IF data_drop[0] eq 'OFFLINE' or data_drop[1] eq 'OFFLINE' or data_drop[2] eq 'OFFLINE' THEN BEGIN
  cd,'C:\Inetpub\wwwroot\data\realtime\callisto\fts\'
  high_files = findfile('*03.fit')
  cd,'C:\Inetpub\wwwroot\data\realtime\callisto\fts\'
  mid_files = findfile('*02.fit')
  cd,'C:\Inetpub\wwwroot\data\realtime\callisto\fts\'
  low_files = findfile('*01.fit')

  high_times = file2time(high_files)
  mid_times = file2time(mid_files)
  low_times = file2time(low_files)
  
  ;**********Alter the message*************
  cd,'C:\MyIDLcodes\Message_warning_system'
  openr,2,'message.txt'
  message_text = strarr(23)
  readf,2,message_text
  close,2
  
  get_utc,ut
  current_time = anytim(ut,/yohkoh,/trun)
  message_text[4] = 'WARNING: CALLISTO receiver malfunction detected at '+current_time
  message_text[6] = '10-100 MHz Receiver: '+data_drop[0]
  message_text[7] = '  -Latest file time: '+anytim(low_times[n_elements(low_times)-1], /yohkoh,/trun)
  
  message_text[9] = '100-200 MHz Receiver: '+data_drop[1]
  message_text[10] = '  -Latest file time: '+anytim(mid_times[n_elements(mid_times)-1], /yohkoh,/trun)
  
  message_text[12] = '200-400 MHz Receiver: '+data_drop[2]
  message_text[13] = '  -Latest file time: '+anytim(high_times[n_elements(high_times)-1], /yohkoh,/trun)
  
  message_text[20] = 'Message time: '+anytim(ut,/yoh,/trun)
  
    message_text = transpose(message_text)
    openw,3,'message.txt'
    printf,3,message_text
    close,3
  ;****************************************
 cd,'C:\MyIDLcodes\Message_warning_system'
 spawn,'email_send.vbs'
ENDIF ELSE BEGIN
print,''
print,'*************************'
print,'No malfunction detected'
ENDELSE

print,'Data check finished'
END