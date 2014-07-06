@echo off

set Product=TagRenamer
set Revision=BETA1
set ReleasePath=UMOD\%Product%\%Product%%Revision%


:start

CLS
title UMOD :: UMOD%Product%
cd D:\Games\UT2004\System\

copy /Y manifest.ini manifest_%Product%.ini
copy /Y .\UMOD\%Product%\umod.ini %Product%UMOD.ini
copy /Y .\UMOD\%Product%\umod.int %Product%UMOD.int
echo.

ucc master %Product%UMOD
if errorlevel 1 goto end


title RELEASE :: UMOD%Product%

del /Q %ReleasePath%
rd %ReleasePath%
md %ReleasePath%
copy /Y UMOD\%Product%\%Product%.ut4mod %ReleasePath%\%Product%%Revision%.ut4mod
copy /Y ..\Help\%Product%.txt %ReleasePath%\%Product%.txt
xcopy /Y /I /E ..\%Product% %ReleasePath%\%Product%\

goto clean


:end
title ERROR :: UMOD%Product%
goto clean


:clean
echo.
del manifest.int
del %Product%UMOD.int
del %Product%UMOD.ini
copy /Y manifest_%Product%.ini manifest.ini
del manifest_%Product%.ini

echo.
pause

goto start