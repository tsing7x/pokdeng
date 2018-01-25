@echo off
set curPath=%~dp0

set outPath=%curPath%gamelua

if not exist %outPath% (
	md %outPath%
)

for /r %curPath%game %%i in (*) do (
	echo %%i
	rem echo %%~nxi|findstr "_bak.sql">nul||echo %%i
	java -jar %curPath%unluac_2015_06_13.jar %%i > %outPath%/%%~nxi.lua
)
pause