@echo off
set Product=TagRenamer


title UCC :: %Product%
echo.
echo *
echo * Compiling %Product%.u
echo *
echo.

:: Prepare compiler config
copy /Y res\compile.ini ..\System\%Product%UCC.ini
echo %Product%>>..\System\%Product%UCC.ini

:: Compile package
del /F ..\System\%Product%.u
..\System\ucc make -ini=%Product%UCC.ini
if errorlevel 1 goto UCC_FAIL

:: copy resources
copy /Y res\config.ini ..\System\%Product%.ini
copy /Y res\icon.bmp ..\System\editorres\%Product%.bmp


title SETUP :: %Product%
echo.
echo *
echo * Adding %Product%.u to EditPackages
echo *
echo.

..\System\ucc %Product%.%Product%Setup AddPackage="%Product%"
if errorlevel 1 goto SETUP_FAIL


title OK :: %Product%
echo.
echo *
echo * Done. 
echo *
echo.
goto CLEANUP


:SETUP_FAIL
title WARNING :: %Product%
echo.
echo *
echo * Done. 
echo * Setup failed, Add %Product% to your EditPackages manually.
eche * Instructions: http://wiki.beyondunreal.com/wiki/Add_EditPackage
echo *
echo.
goto CLEANUP


:UCC_FAIL
title UCC ERROR :: %Product%
echo.
echo *
echo * Error!
echo *
echo.
goto CLEANUP


:CLEANUP
del /F ..\System\%Product%UCC.ini
goto DISPLAY


:DISPLAY
pause