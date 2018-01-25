@echo off

set DIR=%~dp0
set APP_DIR=%DIR%
set FileName=%date:~5,2%%date:~8,2%%time:~0,2%_%time:~3,2%

echo "ø™ º±‡“ÎLUA°≠°≠"
call "%QUICK_V3_ROOT%"\quick\bin\compile_scripts.bat -i %APP_DIR%src -o %APP_DIR%fix%FileName%.zip -e xxtea_zip -ek PokDeng655355 -es pokdeng@boyaa2015
