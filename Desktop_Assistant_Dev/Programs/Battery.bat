@echo off
TITLE Battary Status Check Program
powercfg.exe /batteryreport
echo Battary Status Check Successfully. Please check C:\WINDOWS\system32\energy-report.html for show results.
pause