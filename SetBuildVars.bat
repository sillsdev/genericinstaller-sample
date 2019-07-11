@echo off

REM The installer for the WiX toolset sets WIX=<the WiX install dir>, but doesn't add it to the path
REM REVIEW (Hasso) 2018.01: is this really this script's responsibility, or somebody else's?
set PATH=%PATH%;%WIX%\bin

REM the following lines query the registry for the VisualStudio 2015 install directory and run its vcvarsall.bat

Set RegQry=HKLM\Hardware\Description\System\CentralProcessor\0

REG.exe Query %RegQry% > checkOS.txt

Find /i "x86" < CheckOS.txt > StringCheck.txt

If %ERRORLEVEL% == 0 (
	set KEY_NAME=HKLM\SOFTWARE\Microsoft\VisualStudio\14.0
) ELSE (
	set KEY_NAME=HKLM\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\14.0
)
set KEY_NAME=%KEY_NAME%\Setup\VS

del CheckOS.txt
del StringCheck.txt

set VALUE_NAME=ProductDir

REM Check for presence of key first.
(
	reg query %KEY_NAME% /v %VALUE_NAME% 2>nul
) || (
	REM TODO (Hasso) 2019.07: more robust way of loading VS 2017 vars
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat" && goto :EOF
) || (
	echo Build requires Visual Studio 2015 or 2017! & exit /b 1
)

REM query the value. pipe it through findstr in order to find the matching line that has the value. only grab token 3 and the remainder of the line. %%b is what we are interested in here.
set INSTALL_DIR=
for /f "tokens=2,*" %%a in ('reg query %KEY_NAME% /v %VALUE_NAME% ^| findstr %VALUE_NAME%') do (
	set PRODUCT_DIR=%%b
)
if "%arch%" == "" set arch=x86
call "%PRODUCT_DIR%\VC\vcvarsall.bat" %arch% 8.1