@echo off
SETLOCAL EnableDelayedExpansion

REM :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM :: Acronis True Image 2016 (Home) Wrapper 
REM :: Deletes oldest '.tib' first if needed, then runs most recent '.tis'
REM :: Run without arguments as Admin to start or use '-l' to view latest log
REM :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

REM :: Set minimal needed free space in MB, so at least '.tib' file size
REM :: SET /A REQ_FREE=500000
SET /A REQ_FREE=0

REM :: Set backup drive letter and directory
SET "BKP_DRIVE=F"
SET "BKP_DIR=AcronisBackup"

REM :: Set to 1 to disable running user_command after backup (or use '-n')
SET /A NO_AFTER=0

SET "TI_PROG=%CommonProgramFiles(x86)%\Acronis\TrueImageHome\TrueImageHomeNotify.exe"
SET "TI_DATA=%ALLUSERSPROFILE%\Acronis\TrueImageHome"

REM :: TODO: del oldest '.tib' using Acronis settings instead of DIR date/time

SET "CDATE=%DATE:~-4%-%DATE:~-7,2%-%DATE:~-10,2% %TIME:~0,2%:%TIME:~3,2%:%TIME:~6,2%"

SET "BKP_PATH=%BKP_DRIVE%:\%BKP_DIR%"
FOR %%L IN (G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) DO (
  IF EXIST "%%L:\%BKP_DIR%" (
    SET "BKP_PATH=%%L:\%BKP_DIR%"
  )
)

( echo %~1 | find /I "-h" >nul 2>&1 ) && (
  echo:
  echo %~nx0 [-l^|-n]   (l=list logs, n=no 'after' usercmd^)
  echo:
  echo Run without arguments as Admin to start backup.
  echo See inside script for options and details.
  GOTO :EOF
)

( echo %~1 | find /I "-l" >nul 2>&1 ) && (
  FOR /F "delims=" %%i IN ('DIR /B /OD %TI_DATA%\Logs\service_*.log') DO (
      SET "log=%%i"
  )
  echo:
  IF /I NOT "!log!"=="" (
    echo !log!
    echo:
    TYPE %TI_DATA%\Logs\!log!
  ) ELSE (
    echo %CDATE% ERROR: Log not found
  )
  GOTO :EOF
)

( echo %~1 | find /I "-n" >nul 2>&1 ) && (
  SET /A NO_AFTER=1
)

IF NOT DEFINED REQ_FREE SET /A REQ_FREE=0
IF NOT DEFINED CUR_FREE SET /A CUR_FREE=0

IF NOT EXIST %BKP_PATH% (
    echo %CDATE% ERROR: Could not find backup dir "%BKP_DIR%"
    GOTO :EOF
) ELSE (
  SET i=0
  FOR /F "tokens=3 USEBACKQ" %%F IN (`DIR /-C /W !BKP_PATH! ^| find " bytes free"`) DO (
     SET "i=%%F"
  )
  echo %CDATE% Backup drive: !i! bytes free
  IF !i! GTR 0 SET /A CUR_FREE=!i:~0,-6!
  IF "%CUR_FREE%"=="" SET /A CUR_FREE=0
  SET "S=     "
  echo %S% %S% %S%   Required MB Free = %REQ_FREE%
  echo %S% %S% %S%    Current MB Free = !CUR_FREE!
  echo:
  IF NOT DEFINED CUR_FREE (
    echo %CDATE% ERROR: Unable get free disk space, exiting...
    GOTO :EOF
  )
  IF !CUR_FREE! LSS %REQ_FREE% (
    FOR /F "delims=" %%i IN ('DIR /B /O-D %BKP_PATH%') DO @(
      @SET "tib=%%i"
    )     
    IF /I NOT "!tib!"=="" (
      IF EXIST "%BKP_PATH%\!tib!" (
        echo %CDATE% Deleting oldest TIB and showing result...
        echo:
        dir "%BKP_PATH%\!tib!" | find "!tib!"
        del "%BKP_PATH%\!tib!"
        echo:
        dir "%BKP_PATH%" | find " bytes"
        echo:
      )
    )
  ) ELSE (
    echo %CDATE% Not deleting any backups, there's enough free disk space
  )
)

whoami /groups | find "S-1-16-12288" >nul 2>&1 && (
  FOR /F "delims=" %%i IN ('DIR /B /OD %TI_DATA%\Scripts') DO (
    SET "script=%%i"
  )
  echo %CDATE% Using script: "!script!"
  IF %NO_AFTER% EQU 1 (
    echo %CDATE% Removing 'after' user command from "!script!"
    REM :: SETLOCAL EnableExtensions DisableDelayedExpansion
    del "%TEMP%\recent.tis" 2>nul
    SET "print=1"
    (
      FOR /F "usebackq delims=" %%a in (`type %TI_DATA%\Scripts\!script!`) DO (
        FOR /F "tokens=1,2 delims=/<> " %%b in ("%%a") DO (
          IF /I "%%~c"=="after" (
            IF DEFINED print (
              SET "print="
            ) ELSE (
              SET "print=1"
            )
          ) ELSE (
            IF DEFINED print (
              SET "script=%TEMP%\recent.tis"
              echo(%%a) >> "!script!"
            )
          )
        )
      )
    )
  )
  "%TI_PROG%" /script:"!script:.tib.tis=!" || (
    echo %CDATE% ERROR: Issue while running TrueImage script, exiting...
   GOTO :EOF
  )
  echo %CDATE% Done
  GOTO :EOF
) || (
  echo Please run this command as Administrator to execute TrueImage script
)
