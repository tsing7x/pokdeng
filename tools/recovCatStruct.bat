@echo off
setlocal enabledelayedexpansion

set curPath=%~dp0
set outPath=%curPath%gameluaCatRestore

if not exist %outPath% (
	md %outPath%
)

rem for /f "delims=" %%i in ('%curPath%gamelua') do (
rem	echo %%~nxi
rem )

for /r %curPath%gamelua %%i in (*) do (

rem	set splitNum=0
rem	echo %%i
	echo %%~nxi
rem	:loop
rem	set strRem=nul
	call :split "%%~nxi"
	
	pause
rem	exit /b
rem	goto :end
	
	:split
	set list=%1
	
	for /f "tokens=1* delims=." %%A in (%list%) do (
		echo %%A

rem		set catPath = %outPath%
		
rem		if not exist "!catPath!/%%A" (
rem			md "!catPath!/%%A"
			
rem			set /a catPath = "!catPath!/%%A"
rem		)
		
		if not "%%B"=="lua" (
			call :split "%%B"
		)
	)
	
	rem set suffixName=
	rem set /a splitNum+=4
	rem set testStr=a.ada.wd.ad.awd.wa.dwa.dwa.wda.a
rem	for /f "delims=." %%A in ("%%i") do (
rem	echo %%A
	rem	echo %%B
	rem	echo !splitNum!
	rem set /a splitNum+=1
	rem	echo !splitNum!
rem	)
	
	rem set "str = %%i"
	rem for /f "delims=." %%b in ("%str%") do (echo %%b)
	rem echo !splitNum!
)
rem if not %%i==nul ( goto :continue )
rem :end