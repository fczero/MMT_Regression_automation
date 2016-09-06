SET FOLDERNAME=test_results
SET OLD_RESULTS=old
SET DCM=%FOLDERNAME%_DCM
SET NONDCM=%FOLDERNAME%_NON_DCM
timeout 5
REM xcopy %NONDCM% %OLD_RESULTS%
REM xcopy %DCM% %OLD_RESULTS%
REM rmdir %NONDCM% /S /Q
REM rmdir %DCM% /S /Q
REM mkdir %NONDCM%
REM mkdir %DCM%
call robot -L trace -d %NONDCM% -i NONDCM .
timeout 5
call robot -L trace -d %DCM% -i DCM -v DCM:1 .
start ./%NONDCM%/report.html
start ./%DCM%/report.html
pause
