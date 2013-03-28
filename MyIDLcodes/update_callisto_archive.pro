pro update_callisto_archive,make_archive=make_archive

cd,'C:\Inetpub\wwwroot\callisto\data'
folders = findfile('*')

cd,'C:\Documents and Settings\Joe\Desktop\Data_new_archive'
IF keyword_set(make_archive) THEN BEGIN    ;01 IF statement
  FOR i=43,n_elements(folders)-2 DO BEGIN
    cd,'C:\Documents and Settings\Joe\Desktop\Data_new_archive'
      date = strsplit(folders[i],'\',/extract)
      date_split = anytim(file2time(date),/ex)
   IF date_split[6] ne 1979 THEN BEGIN;02 IF statement
        yyyy = string(date_split[6],format = '(I4.2)')
        mm = string(date_split[5],format = '(I2.2)')
        dd = string(date_split[4],format = '(I2.2)')
        IF file_test(yyyy) ne 1 THEN spawn,'mkdir '+yyyy
          cd,yyyy
        IF file_test(mm) ne 1 THEN spawn,'mkdir '+mm
          cd,mm 
        IF file_test(dd) ne 1 THEN spawn,'mkdir '+dd
          cd,dd
        IF file_test('fts') ne 1 THEN spawn,'mkdir fts'
        IF file_test('png') ne 1 THEN spawn,'mkdir png' 
        
        ;===Move back to proper directory and check to see if there is a 'fts'====
        ;===If so then move to it and copy everything from here to new archive===
      IF keyword_set(move_fits) THEN BEGIN ;03 IF statement
          cd,'\Inetpub\wwwroot\callisto\data\'
          cd,folders[i]
          IF file_test('fts') eq 0 THEN BEGIN
              spawn,'copy * C:\Docume~1\Joe\Desktop\Data_new_archive\'+yyyy+'\'+mm+'\'+dd+'\fts\'                            
          ENDIF ELSE BEGIN ;***!!!!
                  cd,'fts'
                  IF file_test('high_freq') eq 1 THEN BEGIN
                    cd,'high_freq'
                    spawn,'copy * C:\Docume~1\Joe\Desktop\Data_new_archive\'+yyyy+'\'+mm+'\'+dd+'\fts\'
                    cd,'..'
                  ENDIF ELSE BEGIN
                    spawn,'copy * C:\Docume~1\Joe\Desktop\Data_new_archive\'+yyyy+'\'+mm+'\'+dd+'\fts\'
                  ENDELSE                   
                  IF file_test('low_freq') eq 1 THEN BEGIN
                    cd,'low_freq'
                    spawn,'copy * C:\Docume~1\Joe\Desktop\Data_new_archive\'+yyyy+'\'+mm+'\'+dd+'\fts\'
                    cd,'..'
                  ENDIF
                  IF file_test('mid_freq') eq 1 THEN BEGIN
                    cd,'mid_freq'
                    spawn,'copy * C:\Docume~1\Joe\Desktop\Data_new_archive\'+yyyy+'\'+mm+'\'+dd+'\fts\'
                    cd,'..'
                  ENDIF
              
          ENDELSE;***!!! see above                     
          cd,'C:\Documents and Settings\Joe\Desktop\Data_new_archive'   
        ENDIF;03 IF statement
        
        
        ;================Move pngs========================
        cd,'\Inetpub\wwwroot\callisto\data\'
          cd,folders[i]
          IF file_test('png') ne 0 THEN BEGIN
              ;spawn,'copy * C:\Docume~1\Joe\Desktop\Data_new_archive\'+yyyy+'\'+mm+'\'+dd+'\fts\'                            
              ;ENDIF ELSE BEGIN ;***!!!!
                  cd,'png'
                  IF file_test('high_freq') eq 1 THEN BEGIN
                    cd,'high_freq'
                    spawn,'copy * C:\Docume~1\Joe\Desktop\Data_new_archive\'+yyyy+'\'+mm+'\'+dd+'\png\'
                    cd,'..'
                  ENDIF ELSE BEGIN
                    spawn,'copy * C:\Docume~1\Joe\Desktop\Data_new_archive\'+yyyy+'\'+mm+'\'+dd+'\png\'
                  ENDELSE                   
                  IF file_test('low_freq') eq 1 THEN BEGIN
                    cd,'low_freq'
                    spawn,'copy * C:\Docume~1\Joe\Desktop\Data_new_archive\'+yyyy+'\'+mm+'\'+dd+'\png\'
                    cd,'..'
                  ENDIF
                  IF file_test('mid_freq') eq 1 THEN BEGIN
                    cd,'mid_freq'
                    spawn,'copy * C:\Docume~1\Joe\Desktop\Data_new_archive\'+yyyy+'\'+mm+'\'+dd+'\png\'
                    cd,'..'
                  ENDIF
              
         ; ENDELSE;***!!! see above 
         ENDIF                    
          cd,'C:\Documents and Settings\Joe\Desktop\Data_new_archive'   
        
     ENDIF;02 IF statement
   ENDFOR  
ENDIF ;01 IF statement
      
END 