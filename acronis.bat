@echo off
SETLOCAL EnableDelayedExpansion

REM :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM :: Acronis True Image Wrapper
REM :: For use with Single version Backup Scheme
REM :: Deletes oldest '.tib' first if needed and/or runs most recent '.tis'
REM :: Run without args and as Admin to start TI Backup, or see '-h' for help
REM ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

REM :: DEFAULT CONFIGURATION ::

REM :: Set backup drive letter, directory and minimal needed
REM :: free space in MB, at least '.tib' image file size (see '-s')
SET "BKP_DRIVE=F"
SET "BKP_DIR=AcronisBackup"
SET /A REQ_FREE=500000

REM :: Set to 1 to disable running user_command after backup (or use '-n')
SET /A NO_AFTER=0

REM :: END OF CONFIG :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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
  echo Acronis True Image Wrapper
  echo:
  echo USAGE: %~nx0 [-l^|-n]   l: list logs
  echo                              n: no 'after' usercmd
  echo:
  echo Run without arguments as Admin to start backup.
  echo See inside script for config and details.
  GOTO :EOF
)

IF "%1"=="/?" ( CALL :func_help & GOTO :EOF )
SET /A PARAM=0
FOR %%a in (%*) DO (
  REM :: Handle Options
  IF !PARAM! EQU 0 (
    (( echo %%a | find /I "-h" >nul 2>&1 ) || ( echo %%a | find /I "/h" >nul 2>&1 )) && (
      CALL :func_help
      GOTO :EOF
    )
    (( echo %%a | find /I "-d" >nul 2>&1 ) || ( echo %%a | find /I "/d" >nul 2>&1 )) && (
      SET /A PARAM=1
    )
    (( echo %%a | find /I "-f" >nul 2>&1 ) || ( echo %%a | find /I "/f" >nul 2>&1 )) && (
      SET /A PARAM=1
    )
    (( echo %%a | find /I "-l" >nul 2>&1 ) || ( echo %%a | find /I "/l" >nul 2>&1 )) && (
      CALL :func_viewLog
      GOTO :EOF
    )
    (( echo %%a | find /I "-n" >nul 2>&1 ) || ( echo %%a | find /I "/n" >nul 2>&1 )) && (
      SET /A NO_AFTER=1
    )
    (( echo %%a | find /I "-o" >nul 2>&1 ) || ( echo %%a | find /I "/o" >nul 2>&1 )) && (
      CALL :func_delOldest
      GOTO :EOF
    )
    (( echo %%a | find /I "-s" >nul 2>&1 ) || ( echo %%a | find /I "/s" >nul 2>&1 )) && (
      CALL :func_showBkp
      GOTO :EOF
    )
  REM :: Handle Parameters
  ) ELSE (
    (( echo !l! | find /I "-d" >nul 2>&1 ) || ( echo !l! | find /I "/d" >nul 2>&1 )) && (
      SET "BKP_PATH=%%a"
      FOR %%j in (!BKP_PATH!) DO (
        SET "LETTER=%%~dj"
        SET "BKP_DRIVE=!LETTER:~-0,1!"
        SET "BKP_DIR=%%~nj"
      )
    )
    (( echo !l! | find /I "-f" >nul 2>&1 ) || ( echo !l! | find /I "/f" >nul 2>&1 )) && (
      SET /A REQ_FREE=%%a
    )
    SET /A PARAM=0
  )
  SET "l=%%a"
)

IF NOT DEFINED REQ_FREE SET /A REQ_FREE=0

whoami /groups | find "S-1-16-12288" >nul 2>&1 || (
  echo Please run this command as Administrator (required to exec TI script^)
  echo For help run "%~nx0 -h"
  GOTO :EOF
)

REM :: Check driveletter change
IF NOT EXIST %BKP_PATH% (
  FOR %%l IN (F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) DO (
    IF EXIST "%%l:\%BKP_DIR%" (
      SET "BKP_PATH=%%l:\%BKP_DIR%"
      echo %CDATE% Backup path found at "%%l:\%BKP_DIR%", seems drive letter was changed
    )
  ) ELSE (
    echo %CDATE% Not deleting any backups, there's enough free disk space
  )
)

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
