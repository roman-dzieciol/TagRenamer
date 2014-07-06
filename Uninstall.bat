@echo off
set Product=TagRenamer

..\System\ucc.exe %Product%.%Product%Setup RemovePackage="%Product%"

del /F ..\Help\%Product%.txt

del /F ..\System\%Product%.u
del /F ..\System\editorres\%Product%.bmp

del /F ..\%Product%\Classes\%Product%.uc
del /F ..\%Product%\Classes\%Product%Setup.uc

del /F ..\%Product%\res\compile.ini
del /F ..\%Product%\res\config.ini
del /F ..\%Product%\res\icon.bmp

del /F ..\%Product%\Install.bat

rd Classes
rd res

del /F ..\%Product%\Uninstall.bat