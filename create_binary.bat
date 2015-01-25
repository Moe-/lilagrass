remove lilagras.love
remove lilagras32.zip
remove lilagras64.zip
"c:\Program Files\7-Zip\7z.exe" a -tzip lilagras.love *.lua gfx/* lib/* sfx/* shader/*
copy lilagras.love win32/lilagras.love
copy lilagras.love win64/lilagras.love
cd win32
copy /b love.exe+lilagras.love lilagras32.exe
del lilagras.love
"c:\Program Files\7-Zip\7z.exe" a -tzip ../lilagras32.zip lilagras32.exe *.dll *.ico *.txt ../LICENSE ../README.md
cd ..
cd win64
copy /b love.exe+lilagras.love lilagras64.exe
del lilagras.love
"c:\Program Files\7-Zip\7z.exe" a -tzip ../lilagras64.zip lilagras64.exe *.dll *.ico *.txt ../LICENSE ../README.md
cd ..
