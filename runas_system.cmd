: # This is a special script which intermixes both Bash and CMD.EXE code. It
: # is written this way because it is used in system() shell-outs directly in 
: # otherwise portable code. See http://stackoverflow.com/questions/17510688
: # for details.
: #
: ##############################################################################
: #                                                                            #
: #  (call) runas_system <command> [<arguments>]                               #
: #  (call) runas_system <exefile> [<arguments>]                               #
: #                                                                            #
: #  Executes a <command> (or an Windows' <exefile>) along with <arguments>    #
: #  using system privileges (the user group 'SYSTEM').                        #
: #                                                                            #
: #  It requires the file PSEXEC.EXE of the Sysinternals-Suite from Microsoft  #
: #  installed in the Windwos' System32 or SysWOW64 folder.                    #
: #  (Download: https://technet.microsoft.com/en-us/sysinternals/pxexec.aspx)  #
: #                                                                            #
: ##############################################################################
: <<"::CMDLITERAL"
@echo off & goto :CMDSCRIPT
::CMDLITERAL

#BASHSCRIPT
  [[ ! "${OSTYPE}:0:6" =~ "cygwin" ]] && echo "[$( basename "$0" )]: Abort! Cygwin was not detected." >&2 && exit 1
  cmd /D/C "$( cygpath --windows --absolute "$0" )" $@
  exit


:CMDSCRIPT
  @echo off & if [%1]==[] goto:EOF
  setlocal
  if "%_bitness_%"=="" reg query "HKLM\Hardware\Description\System\CentralProcessor\0" 2>nul | findstr /i "x86" >nul 2>&1 && set "_bitness_=32" || set "_bitness_=64"
  set "SYSTEMSYSTEM=%SYSTEMROOT%\System32"
  if "%_bitness_%"=="64" set "SYSTEMSYSTEM=%SYSTEMROOT%\SysWOW64"
  set "psexec=%~dp0..\pstools\psexec%_bitness_%.exe"
  if exist "%SYSTEMSYSTEM%\psexec.exe" set "psexec=%SYSTEMSYSTEM%\psexec.exe"
  rem
  call "%~dp0runas_admin.cmd" "%psexec%" -accepteula -i -s -d %*
  rem
  endlocal
  rem
  set "_EXITBATCH=goto:EOF"
  for %%G in ( .exe .cmd .bat ) do if /i [%~x1]==[%%G] set "_EXITBATCH=rem"
  rem
  %_EXITBATCH%
  rem
  setlocal enabledelayedexpansion
  set sleep_seconds=1
:PROCESS_WAITING
  rem  Sleep some seconds.
  ( timeout /T %sleep_seconds% /NOBREAK || ping 127.0.0.1 -n %sleep_seconds% || ping ::1 -n %sleep_seconds% ) >nul 2>&1
  rem
  for /F %%x in ('tasklist /NH /FI "IMAGENAME eq %~nx1"')  do if /I "%%x"=="%~nx1" goto :PROCESS_WAITING
  rem
  endlocal
