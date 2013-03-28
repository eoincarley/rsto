C:

cd C:\Inetpub\wwwroot\data
mkdir %Date:~-4,4%
cd %Date:~-4,4%
mkdir %Date:~-7,2%
cd %Date:~-7,2%
mkdir %Date:~-10,2%
cd %Date:~-10,2%

mkdir callisto

mkdir magnetometer\txt
mkdir magnetometer\png

move /y "M:\dailyMAG\*.txt" "C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\magnetometer\txt"
move /y "M:\dailyMAG\*.png" "C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\magnetometer\png"

mkdir SID\txt
mkdir SID\png

move /y "S:\dailySID\*.png" "C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\SID\png"
move /y "S:\dailySID\*.txt" "C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\SID\txt"

cd callisto
mkdir fts
mkdir png

cd C:\Inetpub\wwwroot\data\realtime\callisto\fts\
move /y *%Date:~-4,4%%Date:~-7,2%%Date:~-10,2%* C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\callisto\fts


cd C:\Inetpub\wwwroot\data\realtime\callisto\png\
move /y *%Date:~-4,4%%Date:~-7,2%%Date:~-10,2%* C:\Inetpub\wwwroot\data\%Date:~-4,4%\%Date:~-7,2%\%Date:~-10,2%\callisto\png


