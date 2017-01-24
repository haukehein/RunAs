@echo off

:: Source: http://www.itninja.com/blog/view/batch-run-as-administrator-automatically-with-highest-privileges-by-tools-batch-admin
:: I edited and renamed the "Admin_Batch.bat" to "admindo.cmd". (jr-2016/05/18)
::
:: Usage:
::   net session >NUL 2>NUL&if errorlevel 1  ADMINDO "%~0" %*
::   net session >NUL 2>NUL&if errorlevel 1  ADMINDO "notepad.exe


(if '%1'=='' SET $Help$=Yes)&(if '%1'=='?' SET $Help$=Yes)&(if '%1'=='/?' SET $Help$=Yes)&(if /I '%1'=='/HELP' SET $Help$=Yes)&(if /I '%1'=='-HELP' SET $Help$=Yes)&(if /I '%1'=='/INFO' SET $Help$=Yes)
if '%$Help$%'=='Yes' if exist admindo.cmd  (SET $Help_BAT$=admindo.cmd) else (FOR /F %%I IN ("admindo.cmd") DO (SET $Help_BAT$=%%~$PATH:I))
if '%$Help$%'=='Yes' (SET $Help$=&cls&MORE /C /E +85 "%$Help_BAT$%"&SET $Help_BAT$=&pause&goto:eof)

::  A D M I N I S T R A T O R   - Automatically get admin rights for script batch. Paste this on top:    net session >NUL 2>NUL&if errorlevel 1  ADMINDO "%~0" %*
::                                Also keep Batch directory localisation and then set variable:   PATH_BAT
::                                if earlier variable "ShowAdminInfo" is empty (not defined) then no info, else showing info with number of seconds
::
::                                Elaboration:  Artur Zgadzaj        Status:  Free for use and distribute
setlocal
setlocal EnableExtensions
setlocal DisableDelayedExpansion

  MD %TEMP% 2>NUL
  SET /A $Session=%RANDOM% * 100 / 32768 + 1
  SET > "%TEMP%\$ADMINDO_%$Session%__Set.txt"

  SET "PATH_BAT=%~dp1"&if not exist "%~1" if not exist "%~1.*" SET "PATH_BAT="

  SET $Parameters=%*
setlocal EnableDelayedExpansion
  SET $Parameters=!$Parameters:%%=%%%%!
setlocal DisableDelayedExpansion

  net session >NUL 2>NUL&if not errorlevel 1  goto Administrator_OK

  SET "$Script=%PATH_BAT%%~nx1"
  SET "$Script=%$Script:(=^(%"
  SET "$Script=%$Script:)=^)%"

  if defined ShowAdminInfo   (
     echo.
     echo Script = %$Script%
     echo.
     echo ******************************************************************************
     echo ***   R U N N I N G    A S    A D M I N I S T R A T O R    F O R   Y O U   ***
     echo ******************************************************************************
     echo.
     echo Call up just as the Administrator. You can make a shortcut to the script and set
     echo.
     echo          shortcut ^> Advanced ^> Running as Administrator
     echo.
     echo     Alternatively run once "As Administrator"
     echo     or in the Schedule tasks with highest privileges
     echo.
     echo Cancel Ctrl-C or wait for launch  %ShowAdminInfo%  seconds ...
     TIMEOUT /T %ShowAdminInfo% >NUL
     )

  SET "BatchFullName_EXE=%~1"&SET "EXT=%~x1"&SET "Start_EXE="
  if /I not '%EXT%'=='.EXE'   SET "BatchFullName_EXE=%BatchFullName_EXE%.EXE"
  if not defined $Admin_EXE  if exist "%BatchFullName_EXE%"  (SET Start_EXE=START "" /B) else (FOR /F %%I IN ("%BatchFullName_EXE%") DO (if not '%%~$PATH:I'==''  SET Start_EXE=START "" /B))

  SET "Admin_Name=$ADMINDO_%$Session%"
  SET "Inverted_Commas="
  del "%TEMP%\%Admin_Name%_start.bat" 2>NUL
  echo %$Parameters% > "%TEMP%\%Admin_Name%_start.bat"
  if not exist "%TEMP%\%Admin_Name%_start.bat"  SET Inverted_Commas=^"

  echo @echo off > "%TEMP%\%Admin_Name%_start.bat"
  ::
  :: sometimes needed, if running form a VirtualBox shared drive
  for /f "tokens=1-2" %%A in ('net use 2^>nul ^| find ^"\\^" ^| find /i "%~d0"') do if not [%%A]==[] (echo net use %%A %%B ^>nul 2^>nul >> "%TEMP%\%Admin_Name%_start.bat")
  ::
  echo setlocal DisableDelayedExpansion >> "%TEMP%\%Admin_Name%_start.bat"
  if not defined $Admin_Temp  echo SET TEMP^>^>"%TEMP%\%Admin_Name%__Set.txt">> "%TEMP%\%Admin_Name%_start.bat"
  if not defined $Admin_SET   echo FOR /F ^"delims=^" %%%%A IN ^(%TEMP%\%Admin_Name%__Set.txt^) DO SET %%%%A>> "%TEMP%\%Admin_Name%_start.bat"
  echo SET TMP=%%TEMP%%^&SET $Session=^&SET "PATH_BAT=%PATH_BAT%">> "%TEMP%\%Admin_Name%_start.bat"
  echo del "%TEMP%\%Admin_Name%__*.*" 2^>NUL >> "%TEMP%\%Admin_Name%_start.bat"
  echo CD /D "%CD%" >> "%TEMP%\%Admin_Name%_start.bat"
  echo %Start_EXE% %$Parameters% %Inverted_Commas% >> "%TEMP%\%Admin_Name%_start.bat"

  echo SET UAC = CreateObject^("Shell.Application"^)                         > "%TEMP%\%Admin_Name%__getPrivileges.vbs"
  echo UAC.ShellExecute "%TEMP%\%Admin_Name%_start.bat", "", "", "runas", 1 >> "%TEMP%\%Admin_Name%__getPrivileges.vbs"
  "%TEMP%\%Admin_Name%__getPrivileges.vbs"
endlocal
  exit /B

:Administrator_OK
  %$Parameters%
endlocal
  goto:eof
  REM *** A D M I N I S T R A T O R  - Automatically get admin rights  (The End)  ***