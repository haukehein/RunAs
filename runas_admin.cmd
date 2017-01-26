: # This is a special script which intermixes both Bash and CMD.EXE code. It
: # is written this way because it is used in system() shell-outs directly in 
: # otherwise portable code. See http://stackoverflow.com/questions/17510688
: # for details.
: #
: ##############################################################################
: #                                                                            #
: #  (call) runas_admin  <command>  [<arguments>]                              #
: #  (call) runas_admin  <exefile>  [<arguments>]                              #
: #                                                                            #
: #  Executes a <command> (or an Windows' <exefile>) along with <arguments>    #
: #  using administrator privileges (the user group 'ADMINISTRATORS').         #
: #                                                                            #
: ##############################################################################
: <<"::CMDLITERAL"
@echo off & goto :CMDSCRIPT
::CMDLITERAL

#BASHSCRIPT
  cmd /D/C "$( cygpath --windows --absolute "$0" )" $@
  exit


:CMDSCRIPT
  @echo off & if [%1]==[] goto:EOF
  net session >nul 2>&1 && ( 
    %* 
    rem
  ) || ( 
    call "%~dp0admindo.cmd" %* 
    rem
  )
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
