set projectName=MASM4
\masm32\bin\ml /c  /Zi /Fl /coff %projectName%.asm
\masm32\bin\Link /SUBSYSTEM:CONSOLE /out:%projectName%.exe %projectName%.obj String1.obj String2.obj ..\macros\convutil201604.obj ..\macros\utility201609.obj 
%projectName%.exe