::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::: 공통 부분 시작:::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off

setlocal
set infosec=C:\infosec
set john=%infosec%\john
set script=%infosec%\script

rem 스크립트 실행 시 항목 카운트 보여주기 위한 변수df
set item_count=0

TITLE Windosws Security Check

::실제 버전 확인 시작
ver > ver.txt
for /f "delims=[ tokens=2" %%i in (ver.txt) do set MV=%%i
del ver.txt 2> nul

if exist %windir%\SysWOW64 (
	set WinBit=64
) else (
	set WinBit=32
)

:: windows 2000
if "%MV:~8,3%"=="5.0" (
	set WinVer=1
	set WinVer_name=2000
	echo Windows 2000 %WinBit%bit                                                            > %infosec%\real_ver.txt
)

:: windows 2003
if "%MV:~8,3%"=="5.2" (
	set WinVer=2
	set WinVer_name=2003
	echo Windows 2003 %WinBit%bit                                                            > %infosec%\real_ver.txt
)

:: windows 2008
if "%MV:~8,3%"=="6.0" (
	set WinVer=3
	set WinVer_name=2008
	echo Windows 2008 %WinBit%bit                                                            > %infosec%\real_ver.txt
)

:: windows 2008 r2
if "%MV:~8,3%"=="6.1" (
	set WinVer=4
	set WinVer_name=2008_R2
	echo Windows 2008 R2 %WinBit%bit                                                         > %infosec%\real_ver.txt
)

:: windows 2012
if "%MV:~8,3%"=="6.2" (
	set WinVer=5
	set WinVer_name=2012
	echo Windows 2012 %WinBit%bit                                                            > %infosec%\real_ver.txt
)

:: windows 2012 r2
if "%MV:~8,3%"=="6.3" (
	set WinVer=6
	set WinVer_name=2012_R2
	echo Windows 2012 R2 %WinBit%bit                                                         > %infosec%\real_ver.txt
)

:: windows 2016
if "%MV:~8,4%"=="10.0" (
	set WinVer=7
	set WinVer_name=2016
	echo Windows 2016 %WinBit%bit                                                         > %infosec%\real_ver.txt
)

type real_ver.txt > %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

:: windows 2008 이상버전은 icacls
if %WinVer% geq 3 (
	doskey cacls=icacls $*
)
::실제 버전 확인 끝




set SCRIPT_LAST_UPDATE=2018.02.28
echo ======================================================================================= >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■■■■■■■■■■■■■■■■■■■      Windows %WinVer_name% Security Check      ■■■■■■■■■■■■■■■■■■■■ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■■■■■■■■■■■■■■■■■■■      Copyright ⓒ 2018, SK Infosec Co. Ltd.    ■■■■■■■■■■■■■■■■■■■■ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ======================================================================================= >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo LAST_UPDATE %SCRIPT_LAST_UPDATE%                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  Start Time  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
date /t                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
time /t                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt     
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

::sysinfo 한글(chcp 437이후 한글 ??로 깨짐 현상 방지)
echo [+] Gathering systeminfo...
systeminfo																					 > %infosec%\systeminfo_ko.txt 2>nul

::영문으로 변경
chcp 437

::공통 설정파일 추출
secedit /EXPORT /CFG Local_Security_Policy.txt >nul
net accounts > %infosec%\net-accounts.txt 


::FTP 사용확인
net start | find /i "ftp" > nul
if not errorlevel 1 (
	echo FTP Enable                                                                         > ftp-enable.txt
) else (
goto FTP-Disable
)

:: FTP Version 구별하기
net start | find /i "FTP Publishing Service" > nul
if not errorlevel 1 (
	set iis_ftp_ver_major=6
) else (
	net start | find /i "Microsoft FTP Service" > nul
	if not errorlevel 1 (
		set iis_ftp_ver_major=7
	) else (
		set iis_ftp_ver_major=0
	)
)

:: FTP Site List 구하기 ( ftpsite-list.txt )
:: iis ver >= 7
if %iis_ftp_ver_major% geq 7 (
	%systemroot%\System32\inetsrv\appcmd list site | find /i "ftp"                           > %infosec%\ftpsite-list.txt
)
:: iis ver <= 6
if %iis_ftp_ver_major% leq 6 (
	cscript %script%\adsutil.vbs enum MSFTPSVC | find /i "MSFTPSVC" | findstr /i /v "FILTERS APPPOOLS INFO" > ftpsite-list.txt
)

:: FTP Site Name 구하기 ( ftpsite-name.txt )
:: iis ver >= 7
if %iis_ftp_ver_major% geq 7 (
	for /f "tokens=1 delims=(" %%a in (ftpsite-list.txt) do (
		for /f "tokens=2-11 delims= " %%b in ("%%a") do (
			echo %%b %%c %%d %%e %%f %%g %%h %%i %%j %%k                                   >> %infosec%\ftpsite-name.txt
		)
	)
)
:: iis ver <= 6
if %iis_ftp_ver_major% leq 6 (
	for /f "tokens=1 delims=[]" %%i in (ftpsite-list.txt) do (
		cscript %script%\adsutil.vbs enum %%i | findstr /i "ServerComment ServerState"     >> %infosec%\ftpsite-name.txt
		echo -----------------------------------------------------------------------	   >> %infosec%\ftpsite-name.txt
	)
)

:: FTP Site physicalpath 구하기 ( ftpsite-physicalpath.txt )
:: iis ver >= 7
if %iis_ftp_ver_major% geq 7 (
	%systemroot%\System32\inetsrv\appcmd list config -section:system.applicationHost/sites | find /i "physicalpath" > %infosec%\ftpsite-physicalpath-temp.txt
	for /f "tokens=3 delims= " %%a in (ftpsite-physicalpath-temp.txt) do (
		for /f "tokens=2 delims==" %%b in ("%%a") do echo %%~b >> ftpsite-physicalpath.txt
	)
	del ftpsite-physicalpath-temp.txt 2> nul
)
:: iis ver <= 6
if %iis_ftp_ver_major% leq 6 (
	for /f "tokens=1 delims=[]" %%i in (ftpsite-list.txt) do (
		cscript %script%\adsutil.vbs enum %%i/root | find /i "path" | find /i /v "AspEnableParentPaths" >> %infosec%\ftpsite-physicalpath-temp.txt
	)
	for /f "tokens=4-8 delims= " %%i in (ftpsite-physicalpath-temp.txt) do (
		echo %%i %%j %%k %%l %%m                                                              >> %infosec%\ftpsite-physicalpath.txt
	)
	del ftpsite-physicalpath-temp.txt 2> nul
)
:FTP-Disable

::IIS 사용확인
net start | find /i "world wide web publishing service" > nul
if not errorlevel 1 (
	echo IIS Enable                                                                           > iis-enable.txt
) else (
 goto IIS-Disable
 )

:: IIS Version 구하기
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters" | find /i "version" > iis-version.txt
type iis-version.txt | find /i "major"                                                        > iis-version-major.txt
for /f "tokens=3" %%a in (iis-version-major.txt) do set iis_ver_major=%%a
del iis-version-major.txt 2> nul

:: WebSite List 구하기 ( website-list.txt )
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	%systemroot%\System32\inetsrv\appcmd list site | find /i "http"                             > website-list.txt
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	cscript %script%\adsutil.vbs enum W3SVC | find /i "W3SVC" | findstr /i /v "FILTERS APPPOOLS INFO" > website-list.txt
)

:: WebSite Name 구하기 ( website-name.txt )
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	for /f "tokens=1 delims=(" %%a in (website-list.txt) do (
		for /f "tokens=2-11 delims= " %%b in ("%%a") do (
			echo %%b %%c %%d %%e %%f %%g %%h %%i %%j %%k                                         >> website-name.txt
		)
	)
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	for /f "tokens=1 delims=[]" %%i in (website-list.txt) do (
		cscript %script%\adsutil.vbs enum %%i | findstr /i "ServerComment ServerAutoStart"       >> website-name.txt
		cscript %script%\adsutil.vbs enum %%i/ROOT | find "AppRoot"                              >> website-name.txt
		echo -----------------------------------------------------------------------			 >> website-name.txt
	)
)

:: Web Site physicalpath 구하기 ( website-physicalpath.txt )
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	%systemroot%\System32\inetsrv\appcmd list config -section:system.applicationHost/sites | find /i "physicalpath" > website-physicalpath-temp.txt
	for /f "tokens=3 delims= " %%a in (website-physicalpath-temp.txt) do (
		for /f "tokens=2 delims==" %%b in ("%%a") do echo %%~b >> website-physicalpath.txt
	)
	del website-physicalpath-temp.txt 2> nul
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	for /f "tokens=1 delims=[]" %%i in (website-list.txt) do (
		cscript %script%\adsutil.vbs enum %%i/root | find /i "path" | find /i /v "AspEnableParentPaths" >> website-physicalpath-temp.txt
	)
	for /f "tokens=4-8 delims= " %%i in (website-physicalpath-temp.txt) do (
		echo %%i %%j %%k %%l %%m                                                              >> website-physicalpath.txt
	)
	del website-physicalpath-temp.txt 2> nul
)
:IIS-Disable


::sysinfo 영문
systeminfo																					 > %infosec%\systeminfo.txt 2>nul

::Process List
:: winver = 2000
if %WinVer% equ 1 (
	%script%\pslist                                                                          > tasklist.txt
)
:: winver >= 2003
if %WinVer% geq 2 (
	tasklist																				 > %infosec%\tasklist.txt 2>nul
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::: 공통 부분 끝:::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##########################        1. 사용자 인증       ################################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0101 START                                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##################          1.01 불필요한 계정 제거              ###################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 불필요한 계정이 존재하지 않을 경우 양호                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 불필요한 계정에 대해 인터뷰 필요                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ****************************  User Accounts List  *****************************         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net user | find /V "successfully" | findstr .                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo *****************************  Account Information  ***************************         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        > %infosec%\account.txt 2>nul
FOR /F "tokens=1,2,3 skip=4" %%i IN ('net user') DO (
echo -------------------------------------------------------------------------------         >> %infosec%\account.txt 2>nul
net user %%i >> account.txt 2>nul
echo -------------------------------------------------------------------------------         >> %infosec%\account.txt 2>nul
net user %%j >> account.txt 2>nul
echo -------------------------------------------------------------------------------         >> %infosec%\account.txt 2>nul
net user %%k >> account.txt 2>nul
)
findstr "User active Comment Last --" account.txt                                            > %infosec%\account_temp1.txt
findstr /v "change profile Memberships User's" account_temp1.txt                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0101 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0102 START                                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################    1.02 Administrator 계정 이름 바꾸기    ######################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 관리자 계정에 Administrator 계정 이름을 변경하여 사용하는 경우 양호             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net localgroup Administrators | findstr /V "Comment Members completed" | findstr .           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

net localgroup Administrators | findstr /V "Comment Members completed" | findstr .           > %infosec%\1.02-result.txt
type 1.02-result.txt | findstr /V "Alias name" | findstr /i administrator | findstr .        > %infosec%\result.txt

net localgroup Administrators | findstr /V "Comment Members completed" | findstr . | findstr /V "Alias name" | findstr /i administrator | findstr . > nul
if %errorlevel% equ 0 (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=Administrator																		>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=O																				>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
del %infosec%\1.02-result.txt 2>nul
del %infosec%\result.txt 2>nul

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0102 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0103 START                                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################          1.03 GUEST 계정 상태          ########################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: Guest 계정 비활성화일 경우 양호                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net user guest | find "User name"                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net user guest | find "Account active"                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

net user guest | find "Account active" | %script%\awk -F" " {print$3}        >> %infosec%\result.txt

net user guest | find "Account active" | find "Yes" > nul
if %errorlevel% equ 0 (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=Yes												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=No												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

del %infosec%\result.txt 2>nul

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0103 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0104 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################     1.04 최종 로그인 사용자 계정 노출     ######################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "마지막 사용자 이름 표시 안함" 정책이 "사용"으로 설정되어 있을 경우 양호        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (DontDisplayLastUserName = 1)                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\DontDisplayLastUserName" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

%script%\reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\DontDisplayLastUserName" | %script%\awk -F" " {print$3} >> %infosec%\result.txt

for /f "delims= tokens=1" %%r in (result.txt) do set result=%%r
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=%result%												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

del %infosec%\result.txt 2>nul

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0104 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0105 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ########################     1.05 로그온 캐시 설정 오류     ########################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "캐시 할 로그온의 횟수(도메인컨트롤러가 사용 불가능할 경우에 대비)" 항목에      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.        "0번(로그온 캐시 안 함)"으로 설정되어 있으면 양호                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

FOR /F "delims=" %%i IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v cachedlogonscount') DO SET infosec_result=%%i
if defined infosec_result (
	reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v cachedlogonscount >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
	echo Registry key value not found: HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\cachedlogonscount >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
SET infosec_result=

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0105 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0106 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ########################      1.06 Autologon 기능 제어      ########################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: AutoAdminLogon 값이 없거나, AutoAdminLogon 0으로 설정되어 있는 경우 양호        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (DefaultPassword 엔트리가 존재한다면 삭제할 것을 권고)                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [AutoAdminLogon (1:Enable, 0:Disable, Default:Disable)]                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoAdminLogon" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [Username]                                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\DefaultUserName" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [DefaultPassword]                                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\DefaultPassword" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0106 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0107 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ########################    1.07 계정 잠금 임계값 설정    ############################# >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 계정 잠금 임계값이 5이하의 값으로 설정되어 있는 경우 양호  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ net accounts 를 통한 계정 잠금 임계값 설정 확인                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type net-accounts.txt | find "Lockout threshold"                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


type net-accounts.txt | find "Lockout threshold" | %script%\awk -F" " {print$3}        		> %infosec%\result.txt

type %infosec%\result.txt | find /i "never" > nul
if %errorlevel% neq 1 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=Never												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
for /f %%r in (result.txt) do echo Result=%%r												 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
)

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 레지스트리 값을 통한 원격 접속 계정 잠금 임계값 설정 확인  [인터뷰 필요]            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
FOR /F "delims=" %%i IN ('reg query HKLM\SYSTEM\CurrentControlSet\Services\RemoteAccess\Parameters\AccountLockout') DO SET infosec_result=%%i
if defined infosec_result (
	%script%\reg query HKLM\SYSTEM\CurrentControlSet\Services\RemoteAccess\Parameters\AccountLockout >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
	echo Registry key value not found: HKLM\SYSTEM\CurrentControlSet\Services\RemoteAccess\Parameters\AccountLockout >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
SET infosec_result=

del %infosec%\result.txt 2>nul
echo 0107 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###########################        2. 계정 관리       ################################# >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0201 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ########################        2.01 로컬 로그온 허용        ########################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "로컬 로그온 허용" 정책에 "Administrators", "IUSR_" 만 존재할 경우 양호         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (Administrators = *S-1-5-32-544), (IUSR = *S-1-5-17)                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "SeInteractiveLogonRight"                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

type Local_Security_Policy.txt | Find /I "SeInteractiveLogonRight" | %script%\awk -F= {print$2}                      >> %infosec%\result.txt

for /F "delims=, tokens=1-26" %%a in (result.txt) do (
	echo %%a  >> result2.txt 2> nul
	echo %%b  >> result2.txt 2> nul
	echo %%c  >> result2.txt 2> nul
	echo %%d  >> result2.txt 2> nul
	echo %%e  >> result2.txt 2> nul
	echo %%f  >> result2.txt 2> nul
	echo %%g  >> result2.txt 2> nul
	echo %%h  >> result2.txt 2> nul
	echo %%i  >> result2.txt 2> nul
	echo %%j  >> result2.txt 2> nul
	echo %%k  >> result2.txt 2> nul
	echo %%l  >> result2.txt 2> nul
	echo %%m  >> result2.txt 2> nul
	echo %%n  >> result2.txt 2> nul
	echo %%o  >> result2.txt 2> nul
	echo %%p  >> result2.txt 2> nul
	echo %%q  >> result2.txt 2> nul
	echo %%r  >> result2.txt 2> nul
	echo %%s  >> result2.txt 2> nul
	echo %%t  >> result2.txt 2> nul
	echo %%u  >> result2.txt 2> nul
	echo %%v  >> result2.txt 2> nul
	echo %%w  >> result2.txt 2> nul
	echo %%x  >> result2.txt 2> nul
	echo %%y  >> result2.txt 2> nul
	echo %%z  >> result2.txt 2> nul
)

type result2.txt | findstr /V /i "*S-1-5-32-544 *S-1-5-17 ECHO" >> result3.txt

type result3.txt | findstr "*S-1" > nul
if NOT ERRORLEVEL 1 (
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

if ERRORLEVEL 1 (
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

del %infosec%\result.txt 2>nul
del %infosec%\result2.txt 2>nul
del %infosec%\result3.txt 2>nul

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0201 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0202 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ######################      2.02 익명 SID/이름 변환 허용      ######################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "익명 SID/이름 변환 허용" 정책이 "사용 안 함" 으로 되어 있을 경우 양호          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (LSAAnonymousNameLookup = 0)                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver = 2000
if %WinVer% equ 1 (
	echo Win 2000 해당사항 없음                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: winver >= 2003
if %WinVer% geq 2 (
	type Local_Security_Policy.txt | Find /I "LSAAnonymousNameLookup"                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type Local_Security_Policy.txt | Find /I "LSAAnonymousNameLookup" | %script%\awk -F" " {print$3}                      > %infosec%\result.txt

	for /f "delims= tokens=1" %%r in (result.txt) do echo Result=%%r	>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

del %infosec%\result.txt 2>nul

)

echo.                                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0202 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0203 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###############    2.03 원격터미널 접속 가능한 사용자 그룹 제한    #################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: (관리자 계정을 제외한) 원격접속이 가능한 계정을 생성하여 타 사용자의 원격접속을 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 제한하고, 원격접속 사용자 그룹에 불필요한 계정이 등록되어 있지 않을 경우 양호   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver = 2000
if %WinVer% equ 1 (
	echo Win 2000 해당사항 없음                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: winver >= 2008_R2
if %WinVer% geq 4 (
	net start | find /i "Remote Desktop Services" >nul
	IF NOT ERRORLEVEL 1 (
		echo ☞ Remote Desktop Services Enable                                          	>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo ☞ 원격 터미널 접속 허용 계정                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		net localgroup "Administrators" | findstr /V "Comment Members completed" | findstr .         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		net localgroup "Remote Desktop Users" | findstr /V "Comment Members completed" | findstr .   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)
	IF ERRORLEVEL 1 (
		echo ☞ Remote Desktop Services Disable                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)
) else (
	NET START | FIND "Terminal Service" > NUL
	IF NOT ERRORLEVEL 1 (
		echo ☞ Terminal Service Enable                                          			>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo ☞ 원격 터미널 접속 허용 계정                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		net localgroup "Administrators" | findstr /V "Comment Members completed" | findstr .         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		net localgroup "Remote Desktop Users" | findstr /V "Comment Members completed" | findstr .   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)
	IF ERRORLEVEL 1 (
		echo ☞ Terminal Service Disable                                             		 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0203 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #########################        3. 비밀번호 관리       ############################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0301 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##############    3.01 SNMP 서비스 GET Community 스트링 설정 오류    ################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: SNMP GET Community 이름이 public, private 이 아닌 유추하기 어렵게 설정되어      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 있을 경우 양호                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ SNMP 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find "SNMP Service" > NUL
IF NOT ERRORLEVEL 1 (
	ECHO ☞ SNMP Service Enable                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)	ELSE (
	ECHO ☞ SNMP Service Disable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 301-end
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [SNMP ValidCommunities 설정]                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" | findstr . >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" | findstr . >> %infosec%\result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type result.txt | findstr /i "REG_DWORD" > nul
if %ERRORLEVEL% neq 0 (
	echo "string 값이 설정되어 있지 않음(N/A)"                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo "서비스 중지 권고"                                                						   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo [SNMP Trap Commnunities 설정]                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration" /s | findstr . >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 301-end
	)


echo [SNMP Trap Commnunities 설정]                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration" /s | findstr . >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


type result.txt | findstr /i "public private" > nul
	if %ERRORLEVEL% equ 0 (
	echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
	if %ERRORLEVEL% neq 0 (
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
	
	
	

:301-end
del %infosec%\result.txt 2>nul
echo 0301 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0302 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##############    3.02 SNMP 서비스 SET Community 스트링 설정 오류    ################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: SNMP SET Community 이름이 public, private 이 아닌 유추하기 어렵게 설정되어      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 있을 경우 양호                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ SNMP 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find "SNMP Service" > NUL
IF NOT ERRORLEVEL 1 (
	ECHO ☞ SNMP Service Enable                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)	ELSE (
	ECHO ☞ SNMP Service Disable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 302-end
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [SNMP ValidCommunities 설정]                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" | findstr . >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" | findstr . >> %infosec%\result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type result.txt | findstr /i "REG_DWORD" > nul
if %ERRORLEVEL% neq 0 (
	echo "string 값이 설정되어 있지 않음(N/A)"                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo "서비스 중지 권고"                                                						   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo [SNMP Trap Commnunities 설정]                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration" /s | findstr . >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 302-end
	)


echo [SNMP Trap Commnunities 설정]                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration" /s | findstr . >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


type result.txt | findstr /i "public private" > nul
	if %ERRORLEVEL% equ 0 (
	echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
	if %ERRORLEVEL% neq 0 (
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
	
	
	

:302-end
del %infosec%\result.txt 2>nul
echo 0302 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0303 START                                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #################      3.03 계정에 대한 비밀번호 미설정          ###################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 비밀번호 미설정 계정 미존재 시 양호                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 미사용 계정, 사용자 계정에 대해 인터뷰 필요                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■                                                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 사용자 계정 정보 확인                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ****************************  User Accounts List  *****************************         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net user | find /V "successfully" | findstr .                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 계정 별 패스워드 설정 여부 확인                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo *****************************  Account Information  ***************************         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        > %infosec%\account.txt 2>nul
FOR /F "tokens=1,2,3 skip=4" %%i IN ('net user') DO (
echo -------------------------------------------------------------------------------         >> %infosec%\account.txt 2>nul
net user %%i >> account.txt 2>nul
echo -------------------------------------------------------------------------------         >> %infosec%\account.txt 2>nul
net user %%j >> account.txt 2>nul
echo -------------------------------------------------------------------------------         >> %infosec%\account.txt 2>nul
net user %%k >> account.txt 2>nul
)
findstr "Password required --" account.txt                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0303 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0304 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #####################     3.04 비밀번호 보안정책 설정 오류     ######################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 비밀번호 보안정책에 다음과 같이 설정된 경우 양호  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo MinimumPasswordAge 1  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo MaximumPasswordAge 90 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo MinimumPasswordLength 8 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo PasswordComplexity 1  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo PasswordHistorySize 12 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "MinimumPasswordAge"                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "MaximumPasswordAge ="                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "MinimumPasswordLength"                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "PasswordComplexity"                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "PasswordHistorySize"                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0304 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0305 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##################     3.05 비밀번호 장기간 미변경 계정 존재     ###################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 최종 패스워드 변경일이 90일 이전인 경우                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 비밀번호 미변경 계정에 대해 인터뷰 필요                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 패스워드 최대 사용기간 설정 확인                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "MaximumPasswordAge"                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 계정 별 패스워드 변경 내역 확인                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
FOR /F "tokens=1 skip=4" %%i IN ('net user') DO net user %%i >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2>nul
FOR /F "tokens=2 skip=4" %%i IN ('net user') DO net user %%i >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2>nul
FOR /F "tokens=3 skip=4" %%i IN ('net user') DO net user %%i >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2>nul

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0305 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0306 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##################      3.06 유추가능한 비밀번호 사용 여부      ####################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 비밀번호 유추가능한 계정이 없는 경우 양호                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : "암호는 복잡성을 만족해야 함" 정책이 "사용" 여부 확인                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (PasswordComplexity = 1 일 경우 복잡성 설정되어 있음)                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 유추가능한 비밀번호 사용 여부에 대해 인터뷰 필요                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 패스워드 복잡성 설정 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "PasswordComplexity"                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 참고 : 해당 서버 계정 정보                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ****************************  User Accounts List  *****************************         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net user | find /V "successfully" | findstr .                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo *****************************  Account Information  ***************************         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        > %infosec%\account.txt 2>nul
FOR /F "tokens=1,2,3 skip=4" %%i IN ('net user') DO (
echo -------------------------------------------------------------------------------         >> %infosec%\account.txt 2>nul
net user %%i >> account.txt 2>nul
echo -------------------------------------------------------------------------------         >> %infosec%\account.txt 2>nul
net user %%j >> account.txt 2>nul
echo -------------------------------------------------------------------------------         >> %infosec%\account.txt 2>nul
net user %%k >> account.txt 2>nul
)
findstr "User active Comment Last --" account.txt                                            > %infosec%\account_temp1.txt
findstr /v "change profile Memberships User's" account_temp1.txt                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0306 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0307 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###############    3.07 해독 가능한 암호화를 사용하여 암호 저장    #################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 해독 가능한 암호화를 사용하여 암호 저장; 정책 사용안함,                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : ClearTextPassword=0인 경우 양호                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

type Local_Security_Policy.txt | Find /I "ClearTextPassword"                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

type Local_Security_Policy.txt | Find /I "ClearTextPassword"  |  %script%\awk -F" " {print$3}    >> %infosec%\result.txt

for /f "delims= tokens=1" %%r in (result.txt) do set result=%%r
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=%result%												 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

del %infosec%\result.txt 2>nul
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0307 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##########################        4. 서비스 관리       ################################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0401 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ######################      4.01 IIS 웹서비스 정보 숨김      ########################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 웹서비스의 에러페이지가 별도로 지정되어 있는 경우 양호                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 400, 401, 403, 404, 500 에러에 대해 별도의 페이지가 지정되어 있는 경우          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
::echo ■       : (취약 예문) prefixLanguageFilePath="%SystemDrive%\inetpub\custerr" path="401.htm" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
rem 기본 설정이기 때문에 위 설정은 취약함.
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find "World Wide Web Publishing Service" > NUL
IF NOT ERRORLEVEL 1 (
	ECHO ☞ IIS Service Enable                                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 4-01-enable
)	ELSE (
	ECHO ☞ IIS Service Disable                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 401
)

:4-01-enable
echo [등록 사이트]                                                                        	>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	type website-list.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	type website-name.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [기본 설정]                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	%systemroot%\System32\inetsrv\APPCMD list config | findstr "<error"                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

:: iis ver <= 6
if %iis_ver_major% leq 6 (
cscript %script%\adsutil.vbs enum W3SVC | findstr "400, 401, 403, 404, 500,"                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo *** 사이트별 설정 확인                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	for /f "delims=" %%i in (website-name.txt) do (
			echo [WebSite Name] %%i                                          						>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			echo ---------------------------------------------------------------                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			%systemroot%\System32\inetsrv\appcmd list config %%i | findstr "<error" 				>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			echo.                                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
)

:: iis ver <= 6
if %iis_ver_major% leq 6 (
	FOR /F "tokens=1 delims=[]" %%i in (website-list.txt) do (
		echo [WebSite AppRoot] %%i                                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo -----------------------------------------------------------------------               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		cscript %script%\adsutil.vbs enum %%i/root | findstr "400, 401, 403, 404, 500," > nul
		IF NOT ERRORLEVEL 1 (
			cscript %script%\adsutil.vbs enum %%i/root | findstr "400, 401, 403, 404, 500,"          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			echo.                                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		) ELSE (
			echo 기본 설정이 적용되어 있음.                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			echo.                                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)
	)
)
echo.                                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


:401
echo 0401 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0402 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #############    4.02 불필요한 ODBC/OLE-DB 데이터 소스와 드라이브 제거    ############# >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 시스템 DSN 부분의 Data Source를 현재 사용하고 있는 경우 양호                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : Data Dource 사용 여부에 대해 인터뷰 필요                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources" | find "REG_SZ"                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources" | find "REG_SZ"                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ※ 결과 값이 없을 경우 불필요한 ODBC/OLE-DB가 존재하지 않음 						     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0402 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0403 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #####################      4.03 HTTP/FTP/SMTP 배너 차단      ########################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: HTTP, FTP, SMTP 접속시 배너 정보가 보인지 않는 경우 양호                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find "World Wide Web Publishing Service" > NUL
IF NOT ERRORLEVEL 1 (
echo ---------------------------------HTTP Banner-------------------------------------       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	cscript %script%\http_banner.vbs >nul
	type http_banner.txt								>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2>nul
echo ---------------------------------------------------------------------------------       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	del http_banner.txt 2>nul
)	ELSE (
	ECHO ☞ IIS Service Disable                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find /i "ftp" > NUL
IF NOT ERRORLEVEL 1 (
echo -----------------------------------FTP Banner------------------------------------       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	cscript %script%\ftp_banner.vbs >nul
	type ftp_banner.txt								>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2>nul
echo ---------------------------------------------------------------------------------       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	del ftp_banner.txt 2>nul
)	ELSE (
	ECHO ☞ FTP Service Disable                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find /i "smtp" > NUL
IF NOT ERRORLEVEL 1 (
echo ---------------------------------SMTP Banner-------------------------------------       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	cscript %script%\smtp_banner.vbs >nul
	type smtp_banner.txt								>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ---------------------------------------------------------------------------------       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	del smtp_banner.txt 2>nul
)	ELSE (
	ECHO ☞ SMTP Service Disable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0403 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###########################        5. 권한 관리        ################################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0501 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #######################       5.01 SNMP 접근 통제 설정       ########################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 특정 호스트로부터만 SNMP 패킷을 받아들이기로 설정되어 있는 경우 양호            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (PermittedManagers 설정이 있으면 양호)                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (PermittedManagers 설정이 없으면 모든 호스트에서 SNMP 패킷을 받을 수 있어 취약) >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ SNMP 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find "SNMP Service" > NUL
IF NOT ERRORLEVEL 1 (
	ECHO ☞ SNMP Service Enable                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)	ELSE (
	ECHO ☞ SNMP Service Disable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 501-end
	)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [SNMP ValidCommunities 설정]                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" | findstr . >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" | findstr . >> %infosec%\result.txt
type %infosec%\result.txt | findstr /i "REG_DWORD" > nul
if %ERRORLEVEL% neq 0 (
	echo "string 값이 설정되어 있지 않음(N/A)"                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo "서비스 중지 권고"                                                						   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 501-end
	)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [SNMP Access Control 설정]                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers" | findstr . >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers" | findstr . > %infosec%\result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

type %infosec%\result.txt | findstr /i "REG_SZ" > nul
	if %ERRORLEVEL% EQU 0 (
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
	if %ERRORLEVEL% NEQ 0 (
	echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

:501-end

del %infosec%\result.txt 2>nul
echo 0501 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0502 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ######################        5.02 FTP 접근 제어 설정        ########################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : 특정 IP 주소에서만 FTP 서버에 접속하도록 접근 제어 설정을 적용한 경우 양호     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 참고 : metabase.xml 파일 기준 설명        											 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : IIsFtpService	Location ="/LM/MSFTPSVC" 는 FTP 사이트 기본 설정                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : IIsFtpVirtualDir	Location ="/LM/MSFTPSVC/ID/ROOT"는 FTP 개별 사이트 설정      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 개별 사이트에 IPSecurity 설정이 없으면 FTP 사이트 기본 설정을 적용 받음        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : IPSecurity="" 접근제어 없음, IPSecurity="0102~" 접근제어 설정 있음.            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 마지막에 사이트명이 붙지 않은 설정 내용은 점검시 고려 안함.                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 2008이상 ipSecurity allowUnlisted 설정이 False로 되어야 양호                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : ipSecurity allowUnlisted True경우 액세스 허용 / False 경우 액세스 거부         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ FTP 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist ftp-enable.txt (
	echo ☞ FTP Service Enable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	net start | findstr /i "ftp"                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 5-02-enable
) else (
	echo ☞ FTP Service Disable                                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 5-02-end
)

:5-02-enable
:: iis ver = 0
if %iis_ftp_ver_major%==0 (
	echo ☞ 윈도우 기본 FTP외 타 FTP 서비스 사용중 (수동확인^)                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 5-02-end
)
echo [등록 사이트]                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ftp_ver_major% geq 7 (
	type ftpsite-list.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: iis ver <= 6
if %iis_ftp_ver_major% leq 6 (
	type ftpsite-name.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

:: iis ver >= 7
if %iis_ftp_ver_major% geq 7 (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo *** 사이트별 FTP 접근제어 설정 확인                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	
	for /f "delims=" %%a in (ftpsite-name.txt) do (
		%systemroot%\System32\inetsrv\appcmd list config %%a /section:ipsecurity | find /i "ipAddress" > nul
		echo [FTP-Site Name] %%a                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo -----------------------------------------------------                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		if not errorlevel 1 (
			%systemroot%\System32\inetsrv\appcmd list config %%a /section:ipsecurity | find /i "ipAddress" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			%systemroot%\System32\inetsrv\appcmd list config %%a /section:ipsecurity | find /i "ipAddress" >> %infosec%\result.txt
			%systemroot%\System32\inetsrv\appcmd list config %%a /section:ipsecurity | find /i "ipSecurity AllowUnlisted" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			%systemroot%\System32\inetsrv\appcmd list config %%a /section:ipsecurity | find /i "ipSecurity AllowUnlisted" >> %infosec%\result.txt
			echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		) else (
			echo * 접근제한 설정 없음                                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			)
		)
)
:: iis ver <= 6
if %iis_ftp_ver_major% leq 6 (
	echo [FTP 접근제어 설정]                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo -----------------------------------------------------                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	cscript %script%\ftp_ipsecurity.vbs >nul
	type ftp-ipsecurity.txt                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)



if %iis_ftp_ver_major% geq 7 (
	goto 5-022-enable
) 
if %iis_ftp_ver_major% leq 6 (
	goto 5-021-enable
)

:5-022-enable
type %infosec%\result.txt | find "ipSecurity allowUnlisted" | find "true" > nul
	if %ERRORLEVEL% NEQ 0 (
		echo Result=false												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
		echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
	if %ERRORLEVEL% EQU 0 (
		echo Result=true												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
		echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
)
del %infosec%\result.txt 2>nul	
goto 5-02-end

:5-021-enable
type ftp-ipsecurity.txt | find "SiteName" | find "Access Allow" > nul
		if %ERRORLEVEL% NEQ 0 (
			echo Result=false												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
			echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)
		if %ERRORLEVEL% EQU 0 (
			echo Result=true												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
			echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)	
)
del %infosec%\ftp-ipsecurity.txt 2>nul

:5-02-end
echo 0502 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0503 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #################    5.03 관리자 그룹에 최소한의 사용자 포함    ####################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: Administrator 그룹에 불필요한 관리자 계정이 없을 경우 양호                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 관리자 그룹 내 최소한 사용자 계정 포함 여부 인터뷰 필요                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net localgroup Administrators | findstr /V "Comment Members completed" | findstr .           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        > %infosec%\admin-account.txt 2>nul
echo *********************  Administrators Account Information  ********************         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
FOR /F "tokens=1,2,3,4 skip=6" %%j IN ('net localgroup administrators') DO (
net user %%j %%k %%l %%m >> %infosec%\admin-account.txt 2>nul
echo -------------------------------------------------------------------------------         >> %infosec%\admin-account.txt 2>nul
)
findstr c/:"User name | Account active | Last logon | -----" admin-account.txt               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0503 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0504 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###############   5.04 Everyone 사용 권한을 익명 사용자에게 적용    ################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : “Everyone 사용 권한을 익명 사용자에게 적용” 정책이 “사용안함” 으로 되어 있을 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 		: (EveryoneIncludesAnonymous=4,0 이면 양호)                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver = 2000
if %WinVer% equ 1 (
	echo Win 2000 해당사항 없음                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: winver >= 2003
if %WinVer% geq 2 (
	type Local_Security_Policy.txt | Find /I "EveryoneIncludesAnonymous"                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type Local_Security_Policy.txt | Find /I "EveryoneIncludesAnonymous"						 >> %infosec%\result.txt

for /f "tokens=2 delims==" %%r in (result.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

del %infosec%\result.txt 2>nul
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0504 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0505 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ################    5.05 일반 사용자의 프린터 드라이버 설치 제한    ################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "사용자가 프린터 드라이버를 설치할 수 없게 함" 정책이 "사용"으로 설정된 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (AddPrinterDrivers=4,1 이면 양호)                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "AddPrinterDrivers"                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "AddPrinterDrivers" | %script%\awk -F= {print$2}       >> %infosec%\result.txt
for /f %%r in (result.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

del %infosec%\result.txt 2>nul


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0505 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0506 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #####################     5.06 FTP 디렉토리 접근권한 설정     ######################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : FTP 홈 디렉터리에 Everyone의 접근 권한이 존재하지 않으면 양호				              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ FTP 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist ftp-enable.txt (
	echo ☞ FTP Service Enable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	net start | findstr /i "ftp"                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 5-06-enable
) else (
	echo ☞ FTP Service Disable                                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 5-06-end
)


:5-06-enable
:: iis ver = 0
if %iis_ftp_ver_major%==0 (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ 윈도우 기본 FTP외 타 FTP 서비스 사용중 (수동확인^)                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 5-06-end
)
echo.                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [등록 사이트]                                                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ftp_ver_major% geq 7 (
	type ftpsite-list.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: iis ver <= 6
if %iis_ftp_ver_major% leq 6 (
	type ftpsite-name.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

:: iis ver >= 7
if %iis_ftp_ver_major% geq 7 (
	echo [홈디렉토리 정보 - WEB/FTP 구분용]                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo -----------------------------------------------------                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%systemroot%\System32\inetsrv\appcmd list config -section:system.applicationHost/sites | findstr /i "name protocol physicalpath" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

echo.                                                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo *** 사이트별 홈디렉토리 접근권한 확인                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
for /f "delims=" %%a in (ftpsite-physicalpath.txt) do (
	echo [FtpSite HomeDir] %%a                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo -----------------------------------------------------                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	call cacls %%a                                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	call cacls %%a                                                                          >> %infosec%\result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

type %infosec%\result.txt | findstr /i "everyone" > nul
if %ERRORLEVEL% NEQ 0 (
 echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
if %ERRORLEVEL% EQU 0 (
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
del %infosec%\result.txt 2>nul



:5-06-end
echo 0506 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0507 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #######################    5.07 SAM 파일 접근 통제 설정     ########################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: SAM 파일 접근권한에 Administrator, System 그룹만 모든권한으로 등록된 경우 양호  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

cacls %systemroot%\system32\config\SAM >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
cacls %systemroot%\system32\config\SAM > %infosec%\result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

type %infosec%\result.txt | find /V "NT AUTHORITY\SYSTEM" | find /V "BUILTIN\Administrators" | find "\" > nul
	if %errorlevel% neq 0 (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	) 
	if %errorlevel% equ 0 (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
echo.                                                                              	     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
del %infosec%\result.txt 2>nul
echo 0507 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0508 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###################     5.08 사용자별 홈 디렉토리 권한 설정     ####################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 사용자 홈 디렉터리에 Eveyone 권한이 없을 경우 양호                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. > %infosec%\home-directory.txt
dir "C:\Users\*" | find "<DIR>" | findstr /V "All Defalt ."                                  >> %infosec%\home-directory.txt
FOR /F "tokens=5" %%i IN (home-directory.txt) DO cacls "C:\Users\%%i" | find /I "Everyone" > nul
IF %ERRORLEVEL% equ 1 (
echo ☞ Everyone 권한이 할당된 홈디렉터리가 발견되지 않았음.                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) ELSE (
	FOR /F "tokens=5" %%i IN (home-directory.txt) DO cacls "C:\Users\%%i" | find /I "Everyone" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0508 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0509 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###############    5.09 시스템 로그 파일 디렉토리 권한 설정 오류   #################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 시스템 로그 파일 디렉토리에 Users 권한 없는 경우 양호                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
cacls %systemroot%\system32\config\sam >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0509 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0510 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #################   5.10 이벤트 로그에 대한 접근 권한 설정 미비    #################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 이벤트 로그는 관리자 인외 임의의 사용자가 볼 수 없는 경우                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 이벤트 로그 접근 권한 관련 레지스트리 3개 값이 모두 1일 경우 양호               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ◎ "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Application" 값 확인  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Application" | find "RestrictGuestAccess" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ◎ "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Security" 값 확인     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Security" | find "RestrictGuestAccess" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ◎ "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\System" 값 확인       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\System" | find "RestrictGuestAccess" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0510 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0511 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################    5.11 감사기록에 대한 접근 통제 설정     ####################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 감사 및 보안 로그 관리에 Everyone 그룹과 Users 그룹이 존재하지 않으면 양호      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
cacls %systemroot%\system32\logfiles >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
cacls %systemroot%\system32\config >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0511 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0512 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##################     5.12 로그온하지 않고 시스템 종료 허용     ###################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준1: "로그온 하지 않고 시스템 종료 허용"이 "사용안함"으로 설정되어 있는 경우 양호   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : (ShutdownWithoutLogon	0 이면 양호)                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
FOR /F "delims=" %%i IN ('reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system /v ShutdownWithoutLogon') DO SET infosec_result=%%i
if defined infosec_result (
	reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system /v ShutdownWithoutLogon >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
	echo Registry key value not found: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system\ShutdownWithoutLogon >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0512 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0513 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##################    5.13 네트워크를 통한 접근 권한 설정 미비    ##################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 필요한 그룹만 접근 허용이 되어있으면 양호                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 네트워크를 통한 시스템 그룹 접근이 허용된 사용자                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "SeNetworkLogonRight"                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 네트워크를 통한 시스템 그룹 접근이 거부된 사용자                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "SeDenyNetworkLogonRight"                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ [참고] Windows 사용자 sid 확인                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
wmic useraccount get name,sid > 513a.txt
type 513a.txt                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ [참고] Windows 그룹계정 sid 확인                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
wmic group get name,sid > 513b.txt
type 513b.txt                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
del 513a.txt
del 513b.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0513 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0514 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###############   5.14 일반 사용자의 백업 및 복구 권한 설정 미비    ################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "파일 및 디렉토리 백업"항목과 "파일 및 디렉토리 복구"항목에 대해 그룹별 접근제어 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 권한 설정에 Everyone 그룹이나 Guest 그룹, User 그룹에 대해 권한 미존재 시 양호  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 백업 권한 확인                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "SeBackupPrivilege"                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 복구 권한 확인                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "SeRestorePrivilege"                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ Windows 사용자 sid 확인                                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
wmic useraccount get name,sid > 514a.txt
type 514a.txt                                                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ Windows 그룹계정 sid 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
wmic group get name,sid > 514b.txt
type 514b.txt                                                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
del 514a.txt
del 514b.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0514 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0515 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ############  5.15 일반 사용자의 시스템 자원 소유권 변경 권한 설정 미비  ############## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "파일 또는 다른 개체의 소유권 가져오기" 항목 권한에 Administrators 그룹만 존재할 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 시스템 자원 소유권한 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "SeTakeOwnershipPrivilege"                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ Windows 사용자 sid 확인                                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
wmic useraccount get name,sid > 515a.txt
type 515a.txt                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ Windows 그룹계정 sid 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
wmic group get name,sid >515b.txt
type 515b.txt                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
del 515a.txt
del 515b.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0515 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###########################        6. 설정 관리        ################################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0601 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###################     6.01 불필요한 SMTP 서비스 실행 여부     ####################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: SMTP를 동작중이지 않거나 업무상 사용중인 경우 양호                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : SMTP 서비스 사용 시 사용용도에 대해 인터뷰 필요                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 프로세스 명 확인을 통한 SMTP 동작 확인                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
NET START | find /i "SMTP" > NUL
IF NOT ERRORLEVEL 1 echo ☞ SMTP Service Enable                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
IF ERRORLEVEL 1 echo ☞ SMTP Service Disable                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 포트명(default : 25) 확인을 통한 SMTP 동작 확인                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
netstat -an | findstr :25 > NUL
IF NOT ERRORLEVEL 1 echo ☞ SMTP Service Enable                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
IF ERRORLEVEL 1 echo ☞ SMTP Service Disable                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 서비스 조회(SMTPSVC) 확인을 통한 SMTP 동작 확인                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
sc query SMTPSVC                                                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0601 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0602 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #####################       6.02 Anonymous FTP 비활성화       ######################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : FTP를 사용하지 않거나 "익명 연결 허용"이 체크되어 있지 않은 경우 양호(Default : 사용 안 함) >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 참고 : metabase.xml 파일 기준 설명        											 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : IIsFtpService	Location ="/LM/MSFTPSVC" 는 FTP 사이트 기본 설정                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : FTP 사이트를 새로 생성 시 해당 기본 설정을 적용 받음.							 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : IIsFtpServer	Location ="/LM/MSFTPSVC/ID"는 FTP 사이트에 등록된 개별 사이트 설정 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 개별 사이트에 AllowAnonymous 설정이 없으면 FTP 사이트 기본 설정을 적용 받음    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : IIsFtpServer	Location ="/LM/MSFTPSVC/~/Public FTP Site"는 진단 시 고려하지 안함 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist ftp-enable.txt (
	echo ☞ FTP Service Enable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	net start | findstr /i "ftp"                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-02-enable
) else (
	echo ☞ FTP Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-02-end
)

:6-02-enable
:: iis ver = 0
if %iis_ftp_ver_major%==0 (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ 윈도우 기본 FTP외 타 FTP 서비스 사용중                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-02-end
)

echo.                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [등록 사이트]                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ftp_ver_major% geq 7 (


	type ftpsite-list.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo [FTP 서버 설정 확인]                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo -----------------------------------------------------                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%systemroot%\System32\inetsrv\appcmd list config -section:system.applicationHost/sites | findstr /i "name protocol anonymousAuthentication enabled" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%systemroot%\System32\inetsrv\appcmd list config -section:system.applicationHost/sites | findstr /i "name protocol anonymousAuthentication enabled" > %infosec%\result.txt
	echo.                                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-022-enable	
) 
	type ftpsite-name.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo [기본 설정]                                                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo -----------------------------------------------------                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	cscript %script%\adsutil.vbs enum MSFTPSVC | find /i "AllowAnonymous"                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	cscript %script%\adsutil.vbs enum MSFTPSVC | find /i "AllowAnonymous"                   > %infosec%\result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo *** 사이트별 설정 확인                                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	for /f "tokens=1 delims=[]" %%i in (ftpsite-list.txt) do (
		echo [FtpSite AppRoot] %%i                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo -----------------------------------------------------                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		cscript %script%\adsutil.vbs enum %%i | find /i "AllowAnonymous" > nul
		if not errorlevel 1 (
			cscript %script%\adsutil.vbs enum %%i | find /i "AllowAnonymous"                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			cscript %script%\adsutil.vbs enum %%i | find /i "AllowAnonymous"                 > %infosec%\result.txt
			echo.                                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			goto 6-021-enable
		) 
			echo AllowAnonymous : 기본 설정이 적용되어 있음.                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			echo AllowAnonymous : 기본 설정이 적용되어 있음.                                 > %infosec%\result.txt
			echo.                                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		goto 6-021-enable
	)


::7이상
:6-022-enable
type %infosec%\result.txt | find /i "anonymousAuthentication" | find /i "true" > nul
::echo %errorlevel%
if %errorlevel% neq 0 (
	echo Result=false												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-02-end
) else (
	echo Result=true												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-02-end
)



:6-021-enable
::6미만
type %infosec%\result.txt | find /i "AllowAnonymous" | find /i "True" > nul
if %errorlevel% neq 0 (
 echo Result=false												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-02-end
)
echo Result=true												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt



:6-02-end
del %infosec%\result.txt 2>nul
echo 0602 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0603 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #####################      6.03 하드디스크 기본 공유 제거      ######################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 기본공유 항목(C$, D$)이 존재하지 않고 AutoShareServ4er 레지스트리 값이 0일 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : NT의 경우 기본공유 항목이 존재하지 않고 AutoShareWks 레지스트리 값이 0일 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ☞ 하드디스크 기본 공유 확인                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ---------------------------------------------------------------------------------       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net share | FIND /V "IPC$" | FIND /V "command PRINT$ FAX$" | FIND "$" | findstr /I "^[A-Z]"  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net share | FIND /V "IPC$" | FIND /V "command PRINT$ FAX$" | FIND "$" | findstr /I "^[A-Z]" > nul
if %ERRORLEVEL% EQU 1 (
echo 기본 공유 폴더가 존재 하지 않습니다.													>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ☞ Registry 설정								                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ---------------------------------------------------------------------------------       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters\AutoShareServer" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
::%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters\AutoShareServer" | %script%\awk -F" " {print$3} > defaultshare.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

net share | FIND /V "IPC$" | FIND /V "command PRINT$ FAX$" | FIND "$" | findstr /I "^[A-Z]" > nul
IF %ERRORLEVEL% EQU 0 (	
	set result02021=F
) else (
	set result02021=O
)

%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters\AutoShareServer" | find "0" > nul
	if %ERRORLEVEL% EQU 0 (
		set result02022=O
		)
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters\AutoShareServer" | find "0" > nul
	if %ERRORLEVEL% EQU 1 (
		set result02022=F
		)
if not %result02021% == %result02022% (
	echo Result=F                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
	echo Result=%result02021%                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0603 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0604 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
chcp 949
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################     6.04 공유 권한 및 사용자 그룹 설정     ####################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 일반공유 폴더가 없거나 공유 디렉토리 접근 권한이 Everyone 없는 등 접근통제가    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 이루어 지는 경우 양호                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 일반공유 폴더 존재 시 인터뷰 확인 필요                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net share | find /v "$" | find /v "명령"			                                      	 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net share | find /v "$" | find /v "명령" | find /v "------"                                    	 > %infosec%\inf_share_folder.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type inf_share_folder.txt | find "\" > nul
IF %ERRORLEVEL% neq 0 echo 공유폴더가 존재하지 않습니다.								>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo ☞ cacls 결과                                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver = 2000
if %WinVer% equ 1 (
	FOR /F "tokens=2 skip=3" %%j IN (inf_share_folder.txt) DO cacls %%j                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2>nul
	
	FOR /F "tokens=2 skip=3" %%j IN (inf_share_folder.txt) DO cacls %%j  					>> %infosec%\result.txt
	type %infosec%\result.txt | findstr /i "everyone" > nul
	if NOT ERRORLEVEL 1 (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
	if ERRORLEVEL 1 (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
)
:: winver >= 2003
if %WinVer% geq 2 (	
	fsutil fsinfo drives 																	 > %infosec%\inf_using_drv_temp1.txt
	type inf_using_drv_temp1.txt | find /i "\" 												 > %infosec%\inf_using_drv_temp2.txt

	echo.																					 > %infosec%\inf_using_drv_temp3.txt
	FOR /F "tokens=1-26" %%a IN (inf_using_drv_temp2.txt) DO (
		echo %%a >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%b >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%c >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%d >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%e >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%f >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%g >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%h >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%i >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%j >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%k >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%l >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%m >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%n >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%o >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%p >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%q >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%r >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%s >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%t >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%u >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%v >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%w >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%x >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%y >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%z >> %infosec%\inf_using_drv_temp3.txt 2> nul
	)
	type inf_using_drv_temp3.txt | find /i "\" | find /v "A:\" 								 > %infosec%\inf_using_drv.txt
	
	FOR /F "tokens=1" %%a IN (inf_using_drv.txt) DO (
		type inf_share_folder.txt | find "%%a"												 >> %infosec%\inf_share_folder_temp.txt
	
	)
	
	%script%\sed "s/   */?/g" %infosec%\inf_share_folder_temp.txt 							 > %infosec%\inf_share_folder_temp_sed.txt
	type inf_share_folder_temp_sed.txt | findstr "^?"										 > %infosec%\inf_share_folder_temp_sed2.txt
	
	for /F "tokens=2 delims= " %%a in (inf_share_folder_temp.txt) do cacls ^"%%a^"		 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	for /F "tokens=2 delims=?" %%a in (inf_share_folder_temp_sed.txt) do cacls ^"%%a^"		 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	for /F "tokens=1 delims=?" %%a in (inf_share_folder_temp_sed2.txt) do cacls ^"%%a^"		 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	
	for /F "tokens=2 delims= " %%a in (inf_share_folder_temp.txt) do cacls ^"%%a^"		 >> %infosec%\result.txt
	for /F "tokens=2 delims=?" %%a in (inf_share_folder_temp_sed.txt) do cacls ^"%%a^"        >> %infosec%\result.txt 
	for /F "tokens=1 delims=?" %%a in (inf_share_folder_temp_sed2.txt) do cacls ^"%%a^"		  >> %infosec%\result.txt
	
	type %infosec%\result.txt | findstr /i "everyone" 2>nul
	if NOT ERRORLEVEL 1 (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
	if ERRORLEVEL 1 (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Everyone 권한이 존재하지 않습니다.														>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
	
)

del %infosec%\result.txt 2>nul
chcp 437
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0604 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0605 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###################     6.05 로컬 계정의 빈 암호 사용 제한      ####################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한" 정책이 "사용"으로 되어 있을 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (LimitBlankPasswordUse = 4,1)                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
rem 결과 값이 존재하지 않으면 Default 설정 적용(Default 설정: LimitBlankPasswordUse 1 양호)
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver = 2000
if %WinVer% equ 1 (
	echo Win 2000 해당사항 없음                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: winver >= 2003
if %WinVer% geq 2 (
	type Local_Security_Policy.txt | Find /I "LimitBlankPasswordUse"                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type Local_Security_Policy.txt | Find /I "LimitBlankPasswordUse"                >> %infosec%\result.txt
	for /f "delims== tokens=2" %%r in (result.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

del %infosec%\result.txt 2>nul

	
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0605 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0606 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##############    6.06 원격 터미널 서비스의 암호화 수준 설정 미흡    ################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 터미널 서비스를 사용하지 않는 경우 양호                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 터미널 서비스를 사용 시 암호화 수준을 "클라이언트와 호환가능(중간)" 이상으로 설정한 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (MinEncryptionLevel	2 이상이면 양호)                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver >= 2008_R2
if %WinVer% geq 4 (
	goto 6-061-enable
) else (
	goto 6-062-enable
)

:6-061-enable
net start | find /i "Remote Desktop Services" >nul
	IF NOT ERRORLEVEL 1 (
		echo ☞ Remote Desktop Services Enable                                          	>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo ☞ 원격 터미널 서비스 암호화 수준 설정 확인                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo --------------------------------------------------------------------------------- >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\MinEncryptionLevel" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\MinEncryptionLevel" | %script%\awk -F" " {print$3}	> %infosec%\result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		for /f %%r in (result.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                     
		)
	IF ERRORLEVEL 1 (
		echo ☞ Remote Desktop Services Disable                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=2												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)

goto 6-06-end

:6-062-enable
NET START | FIND "Terminal Service" > NUL
	IF NOT ERRORLEVEL 1 (
		echo ☞ Terminal Service Enable                                          			>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo ☞ 원격 터미널 서비스 암호화 수준 설정 확인                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo --------------------------------------------------------------------------------- >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\MinEncryptionLevel" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\MinEncryptionLevel" | %script%\awk -F" " {print$3}	> %infosec%\result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		for /f %%r in (result.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)
	IF ERRORLEVEL 1 (
		echo ☞ Terminal Service Disable                                             		 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=2												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)

:6-06-end

	


del %infosec%\result.txt 2>nul

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0606 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0607 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #####################     6.07 Telnet 인증 방식 설정 미비     ######################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: Telnet 서비스가 구동 되고 있지 않거나, 인증방법이 NTLM만 허용일 경우 양호       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : [참고]                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (SecurityMechanism 2. NTLM)                                                 	 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (SecurityMechanism 6. NTLM, Password)                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (SecurityMechanism 4. Password)                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find /i "telnet" > NUL
IF NOT ERRORLEVEL 1 (
	ECHO ☞ TELNET Service Enable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto telnet-enable
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	) ELSE (
	ECHO ☞ TELNET Service Disable 																	>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto telnet-end
)

:telnet-enable
	%script%\reg query "HKLM\Software\Microsoft\TelnetServer\1.0" /s | findstr . | find /v "Listing of" | find /v "system was unable" > nul
	IF %ERRORLEVEL% neq 0 (
		reg query "HKLM\Software\Microsoft\TelnetServer\1.0" /s | findstr /i "SecurityMechanism" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		reg query "HKLM\Software\Microsoft\TelnetServer\1.0" /s | findstr /i "SecurityMechanism" >> %infosec%\result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	) else (
		%script%\reg query "HKLM\Software\Microsoft\TelnetServer\1.0" /s | findstr /i "SecurityMechanism" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%script%\reg query "HKLM\Software\Microsoft\TelnetServer\1.0" /s | findstr /i "SecurityMechanism" >> %infosec%\result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
	
:: winver < 2008R2
if %WinVer% leq 3 (
goto 0607-2008
)

:: winver > 2008
if %WinVer% geq 4 (
 goto 0607-2008R2
)


:0607-2008
type %infosec%\result.txt | findstr /i "REG_DWORD" | find "2" > nul
	if %ERRORLEVEL% neq 1 (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto telnet-end
	) else (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto telnet-end
	)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


:0607-2008R2
type %infosec%\result.txt | findstr /i "REG_DWORD" | findstr /i "0x2" > nul
	if %ERRORLEVEL% neq 1 (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto telnet-end
	) else (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto telnet-end
	)
echo.  	
	
	
:telnet-end
del %infosec%\result.txt 2>nul
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0607 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0608 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##################    6.08 원격 터미널 접속 타임아웃 미설정     ####################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 원격 터미널을 사용하지 않거나, 사용 시 Session Timeout이 설정되어 있는 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (MaxIdleTime 설정 확인 방법: 60000=1분, 300000=5분)                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

:: winver <= 2008
if %WinVer% leq 3 (
	goto 608-2008
)

:: winver = 2008_R2
if %WinVer% equ 4 (
	goto 608-2008r2
)

:: winver >= 2012
if %WinVer% geq 5 (
	goto 608-2012
)



:608-2008
NET START > netstart.txt
type netstart.txt | FIND "Terminal Service" > NUL
	IF %ERRORLEVEL% neq 1 (
		echo ☞ Terminal Service Enable                                          			>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo ☞ 원격 터미널 Session Timeout 설정                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo ---------------------------------------------------------------------------------       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%script%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /s | findstr "MaxIdleTime" > %infosec%\idletime.txt
		type idletime.txt | findstr /v "fInheritMaxIdleTime"                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		type %infosec%\idletime.txt | findstr /v "fInheritMaxIdleTime" | find "REG_DWORD" | %script%\awk -F" " {print$3}        > %infosec%\result.txt
		for /f %%r in (result.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.
		) else (
		echo ☞ Terminal Service Disable                                             		 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=1												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		goto 608-end		
		)
goto 608-end



:608-2008R2
net start > netstart.txt
type netstart.txt | find /i "Remote Desktop Services" > nul
	IF %ERRORLEVEL% neq 1 (
		echo ☞ Remote Desktop Services Enable                                          	>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo ☞ 원격 터미널 Session Timeout 설정                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo ---------------------------------------------------------------------------------       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%script%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /s | findstr "MaxIdleTime" > %infosec%\idletime.txt
		type idletime.txt | findstr /v "fInheritMaxIdleTime"                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		type %infosec%\idletime.txt | findstr /v "fInheritMaxIdleTime" | find "REG_DWORD" | %script%\awk -F" " {print$3}        > %infosec%\result.txt
		for /f %%r in (result.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.        
		) else (
		echo ☞ Remote Desktop Services Disable                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=1												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		goto 608-end		
		)
goto 608-end	


:608-2012
net start > netstart.txt
type netstart.txt | find /i "Remote Desktop Services" > nul
	IF %ERRORLEVEL% neq 1 (
		echo ☞ Remote Desktop Services Enable                                          	>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo ☞ 원격 터미널 Session Timeout 설정                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo ---------------------------------------------------------------------------------       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%script%\reg query "SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /s | findstr "MaxIdleTime" > %infosec%\idletime.txt
		type idletime.txt | findstr /v "fInheritMaxIdleTime"                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		) else (
		echo ☞ Remote Desktop Services Disable                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=1												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		goto 608-end		
		)
		
	type %infosec%\idletime.txt | findstr /v "fInheritMaxIdleTime" | find "REG_DWORD"	
		if %ERRORLEVEL% neq 0 (
		echo IdleTime 설정이 되어 있지 않습니다.					>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=0												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		) else (
		type %infosec%\idletime.txt | findstr /v "fInheritMaxIdleTime" | find "REG_DWORD" | %script%\awk -F" " {print$3}        > %infosec%\result.txt
		for /f %%r in (result.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.											>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)
		
goto 608-end	

		
		
:608-end
echo.     																								>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
del %infosec%\result.txt 2>nul                                                                                   
del %infosec%\netstart.txt 2>nul
echo 0608 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0609 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ######################    6.09 SMB 세션 중단 관리 설정 미비   ######################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: '로그온 시간이 만료되면 클라리언트 연결 끊기' 정책을 "사용"으로,                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt         
echo.      : '세션 연결을 중단하기 전에 필요한 유휴시간' 정책을 "15분"으로 설정한 경우 양호  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ '로그온 시간이 만료되면 클라리언트 연결 끊기' 정책                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters\EnableForcedLogOff" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ '세션 연결을 중단하기 전에 필요한 유휴시간' 정책                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters\AutoDisconnect" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0609 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0610 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ################    6.10 SAM 계정과 공유의 익명 열거 허용 안 함    #################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "SAM 계정과 공유의 익명 열거 허용 안함" 정책이 "사용"이고,                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : "SAM 계정의 익명 열거 허용 안함" 정책이 "사용"으로 설정되어 있는 경우 양호      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (2003 이상 : restrictanonymous	1 이고, RestrictAnonymousSAM	1 이면 양호)     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (2000 : restrictanonymous	2 이고, RestrictAnonymousSAM	2 이면 양호)         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [SAM 계정과 공유의 익명 열거 허용 안함 설정]                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Control\LSA\restrictanonymous"             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [SAM 계정의 익명 열거 허용 안함 설정]                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\System\CurrentControlSet\Control\Lsa\RestrictAnonymousSAM"	         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Control\LSA\restrictanonymous" | %script%\awk -F" " {print$3}       > %infosec%\result.txt
for /f %%r in (result.txt) do set restrict=%%r


%script%\reg query "HKLM\System\CurrentControlSet\Control\Lsa\RestrictAnonymousSAM"	| %script%\awk -F" " {print$3}         > %infosec%\result.txt
for /f %%s in (result.txt) do echo Result=%restrict%:%%s												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
del %infosec%\result.txt 2>nul
echo 0610 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0611 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################    6.11 NetBIOS 바인딩 서비스 구동 점검    ####################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: TCP/IP와 NetBIOS 간의 바인딩이 제거 되어있는 경우 (Registry 값이 2일때) 양호    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 예외: Windows 2000 이하의 환경에서 AD를 사용할 경우 제외                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (NetBIOS 사용 안함 설정: NetbiosOptions 0x2 양호)                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (NetBIOS 사용 설정: NetbiosOptions 0x1 취약)                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (기본 값: NetbiosOptions 0x0 취약)                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (수동점검 방법) 인터넷 프로토콜(TCP/IP)의 등록정보 ▶ 고급 ▶ Wins 탭의 TCP/IP에서 NetBIOS 사용 안함 (139포트차단) >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver = 2000
if %WinVer% equ 1 (
	%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces" | findstr /iv "listing" > 2-18-netbios-list.txt
	for /f "tokens=1 delims=[" %%a in (2-18-netbios-list.txt) do echo %%a >> 2-18-netbios-list-1.txt
	for /f "tokens=1 delims=]" %%a in (2-18-netbios-list-1.txt) do echo %%a >> 2-18-netbios-list-2.txt
	FOR /F %%a IN (2-18-netbios-list-2.txt) do echo HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\%%a\NetbiosOptions >> 2-18-netbios-query.txt
	FOR /F %%a IN (2-18-netbios-query.txt) do %script%\reg query %%a >> 2-18-netbios-result.txt
	echo [NetBIOS over TCP/IP 설정 현황]                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo -----------------------------------------------------                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	TYPE 2-18-netbios-result.txt	                            							>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: winver >= 2003
if %WinVer% geq 2 (
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces" /s | findstr . >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2>nul
)
echo.                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0611 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0612 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ######################       6.12 불필요한 서비스 제거       ########################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 시스템에서 필요하지 않는 취약한 서비스가 중지되어 있을 경우 양호                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (1) Alerter(서버에서 클라이언트로 경고메세지를 보냄)                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (2) Clipbook(서버내 Clipbook를 다른 클라이언트와 공유)                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (3) Messenger(Net send 명령어를 이용하여 클라이언트에 메시지를 보냄)          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (4) Simple TCP/IP Services(Echo, Discard, Character, Generator, Daytime, 등)  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | findstr "Alerter ClipBook Messenger"                                             > %infosec%\service.txt
net start | find "Simple TCP/IP Services"                                                    >> %infosec%\service.txt

net start | findstr /I "Alerter ClipBook Messenger TCP/IP" service.txt > NUL
IF ERRORLEVEL 1 ECHO ☞ 불필요한 서비스가 존재하지 않음.                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
IF NOT ERRORLEVEL 1 (
echo ☞ 아래와 같은 불필요한 서비스가 발견되었음.                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type service.txt                                                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | findstr /I "Alerter ClipBook Messenger TCP/IP" service.txt > NUL
IF ERRORLEVEL 1 ECHO Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
IF NOT ERRORLEVEL 1 echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0612 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0613 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #######################      6.13 FTP 서비스 구동 점검      ########################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: FTP 서비스를 사용하지 않거나, 업무상 사용 중인 경우 양호                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : FTP 서비스 사용 시 사용용도에 대해 인터뷰 필요                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ FTP 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist ftp-enable.txt (
	echo ☞ FTP Service Enable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	net start | findstr /i "ftp"                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-13-enable
) else (
	echo ☞ FTP Service Disable                                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-13-end
)

:6-13-enable


echo [등록 사이트]                                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ftp_ver_major% geq 7 (
	type ftpsite-list.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: iis ver <= 6
if %iis_ftp_ver_major% leq 6 (
	type ftpsite-name.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


:6-13-end
echo 0613 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0614 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #######################       6.14 IIS WebDAV 비활성화       ########################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : 다음 중 한 가지라도 해당되는 경우 양호                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 1. IIS 를 사용하지 않을 경우                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 2. DisableWebDAV 값이 1로 설정되어 있을경우                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 3. Windows NT, 2000은 서비스팩 4 이상이 설치되어 있을 경우                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 4. Windows 2003, Windows 2008은 WebDAV 가 금지 되어 있을 경우                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 참고 : "0,C:\WINDOWS\system32\inetsrv\httpext.dll,0,WEBDAV,WebDAV" (WebDAV 금지-양호) >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : "1,C:\WINDOWS\system32\inetsrv\httpext.dll,0,WEBDAV,WebDAV" (WebDAV 허용-취약) >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 2008 이상인 경우 allowed="false"   (WebDAV 금지-양호) 						 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 2008 이상인 경우 allowed="True"    (WebDAV 허용-취약) 						 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist iis-enable.txt (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Enable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-14-enable
) else (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-14-end
)

:6-14-enable

:: winver = 2000
if %WinVer% equ 1 (
	ECHO ☞ Win 2000일 경우 서비스팩 4 이상 양호                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type systeminfo.txt | find /i "kernel version"                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type systeminfo.txt | find /i "service pack"                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type systeminfo.txt | find /i "os version" | find /i /v "bios" | %script%\awk -F" " {print$6}	> %infosec%\result.txt
	goto 6.14-2000
	echo.
)

:: iis ver =< 6
if %iis_ver_major% leq 6 (
	echo [WebDAV 동작 확인]                                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo -----------------------------------------------------                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%script%\adsutil.vbs enum W3SVC | find /i "webdav" | find /v "WebDAV;WEBDAV"            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%script%\adsutil.vbs enum W3SVC | find /i "webdav" | find /v "WebDAV;WEBDAV"            > %infosec%\result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6.14-2003
)


:: iis ver >=7
if %iis_ver_major% geq 6 (
	echo [WebDAV 동작 확인]                                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo -----------------------------------------------------                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%systemroot%\System32\inetsrv\appcmd list config -section:isapiCgiRestriction | find /i "webdav" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%systemroot%\System32\inetsrv\appcmd list config -section:isapiCgiRestriction | find /i "webdav" > %infosec%\result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6.14-2008
)

:6.14-2003
type result.txt | find "1," >nul
if %errorlevel% equ 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 6-14-end
)

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 6-14-end



:6.14-2008	
type result.txt | find /i "true" >nul
if %errorlevel% equ 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 6-14-end
)

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 6-14-end


:6-14-end
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [참고 - Registry 설정(DisableWebDAV)]                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\registry\DisableWebDAV" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\DisableWebDAV" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ※ 결과 값이 존재하지 않을 경우 다른 참고정보 검토                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo [참고 - OS Version, Service Pack]                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver = 2000
if %WinVer% equ 1 (
	type systeminfo.txt | find /i "kernel version"                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type systeminfo.txt | find /i "service pack"                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

:: winver >= 2003
if %WinVer% geq 2 (
	type systeminfo.txt | find /i "os name"                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type systeminfo.txt | find /i "os version" | find /i /v "bios"                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
del %infosec%\result.txt 2>nul
echo 0614 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0615 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##################   6.15 불필요한 Tmax WebtoB 서비스 구동 여부   ##################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: Webtob 웹서버가 동작중이지 않거나 업무상 사용중인 경우 양호                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : Webtob 웹서버 동작 시 사용용도에 대해 인터뷰 필요                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 프로세스 명 확인을 통한 (WEBTOB)서비스 동작 확인                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt  
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt  
net start | find /i "webtob" > NUL
IF NOT ERRORLEVEL 1 (
echo ☞ WEBTOB Service Enable     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo ☞ WEBTOB Service Disable    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 서비스 조회(WEBTOB) 확인을 통한 서비스 동작 확인                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
sc query Webtob       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0615 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0616 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #########################      6.16 IIS CGI 실행 제한      ############################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : 해당 디렉터리 Everyone에 모든 권한, 수정 권한, 쓰기 권한이 부여되지 않은 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 해당 디렉터리를 사용하지 않는 경우 양호                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 해당 디렉터리 : C:\inetpub\scripts,  C:\inetpub\cgi-bin                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist iis-enable.txt (
	echo ☞ IIS Service Enable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6.16-end
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

IF EXIST C:\inetpub\scripts (
	cacls C:\inetpub\scripts                                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	cacls C:\inetpub\scripts                                                                 > %infosec%\result.txt
	echo.                                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) ELSE (
	echo C:\inetpub\scripts 디렉터리가 존재하지 않음.                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

IF EXIST C:\inetpub\cgi-bin (
	cacls C:\inetpub\cgi-bin                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	cacls C:\inetpub\cgi-bin                                                                >> %infosec%\result.txt
) ELSE (
	echo C:\inetpub\cgi-bin 디렉터리가 존재하지 않음.                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

type %infosec%\result.txt | find /i /v "(ID)R" | find /i "everyone" > nul
if %errorlevel% equ 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

:6.16-end
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0616 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0617 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ########################     6.17 IIS 서비스 구동 점검     ############################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : IIS 서비스가 불필요하게 동작하지 않는 경우 양호(담당자 인터뷰)                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt              
if exist iis-enable.txt (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Enable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-17-enable
) else (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=Disabled																		>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-17-end
)


:6-17-enable

echo [IIS Version 확인]                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type iis-version.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo [등록 사이트]                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	type website-list.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	type website-name.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

:6-17-end

echo 0617 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0618 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #####################      6.18 IIS 디렉터리 리스팅 제거      ######################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : 디렉터리 리스팅이 불가능할 경우 양호                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 기본 설정 및 사이트별 "디렉터리 검색" 설정이 False 이면 양호                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist iis-enable.txt (
	echo ☞ IIS Service Enable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-18-enable
) else (
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-18-end
)

:6-18-enable

echo [등록 사이트]                                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	type website-list.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	type website-name.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo [기본 설정]                                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	%systemroot%\System32\inetsrv\appcmd list config | find /i "directoryBrowse"             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%systemroot%\System32\inetsrv\appcmd list config | find /i "directoryBrowse"             > %infosec%\result.txt
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	cscript %script%\adsutil.vbs get W3SVC/EnableDirBrowsing  | find /i /v "Microsoft"      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	cscript %script%\adsutil.vbs get W3SVC/EnableDirBrowsing  | find /i /v "Microsoft"      > %infosec%\result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo *** 사이트별 설정 확인                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	for /f "delims=" %%i in (website-name.txt) do (
		echo [WebSite Name] %%i                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo -----------------------------------------------------                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%systemroot%\System32\inetsrv\appcmd list config %%i | find /i "directoryBrowse"       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%systemroot%\System32\inetsrv\appcmd list config %%i | find /i "directoryBrowse"      >> %infosec%\result.txt
		echo.                                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	for /f "tokens=1 delims=[]" %%i in (website-list.txt) do (
		echo [WebSite AppRoot] %%i                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo -----------------------------------------------------                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		cscript %script%\adsutil.vbs enum %%i/root | find /i "EnableDirBrowsing" > nul
		if not errorlevel 1 (
			cscript %script%\adsutil.vbs enum %%i/root | find /i "EnableDirBrowsing"         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			cscript %script%\adsutil.vbs enum %%i/root | find /i "EnableDirBrowsing"         >> %infosec%\result.txt
			echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		) else (
			echo * 기본 설정이 적용되어 있음.                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)
	)
)

type result.txt | find /i "true" > nul
if %errorlevel% equ 0 (
echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=true												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=false												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

:6-18-end
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
del %infosec%\result.txt 2>nul
echo 0618 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0619 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##################       6.19 IIS 상위 디렉터리 접근 금지       ####################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : 상위 디렉터리 접근 설정이 비활성화 되어 있어, 접근이 불가능한 경우 양호        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : "상위 경로 사용" 옵션이 체크되어 있지 않을 경우 양호                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : (asp enableParentPaths="false")                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist iis-enable.txt (
	echo ☞ IIS Service Enable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-19-enable
) else (
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-19-end
)

:6-19-enable
echo [등록 사이트]                                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	type website-list.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	type website-name.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo [기본 설정]                                                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	%systemroot%\System32\inetsrv\appcmd list config /section:asp | find /i "enableParentPaths" > nul
	IF NOT ERRORLEVEL 1 (
		%systemroot%\System32\inetsrv\appcmd list config /section:asp | find /i "enableParentPaths" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%systemroot%\System32\inetsrv\appcmd list config /section:asp | find /i "enableParentPaths" > %infosec%\result.txt
	) ELSE (
		echo * 설정값 없음 * 기본설정 : enableParentPaths=false                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	cscript %script%\adsutil.vbs get W3SVC/AspEnableParentPaths  | find /i /v "Microsoft"    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	cscript %script%\adsutil.vbs get W3SVC/AspEnableParentPaths  | find /i /v "Microsoft"    > %infosec%\result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo *** 사이트별 설정 확인                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	for /f "delims=" %%i in (website-name.txt) do (
		%systemroot%\System32\inetsrv\appcmd list config %%i /section:asp | find /i "enableParentPaths" > nul
		echo [WebSite Name] %%i                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo -----------------------------------------------------                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		if not errorlevel 1 (
			%systemroot%\System32\inetsrv\appcmd list config %%i /section:asp | find /i "enableParentPaths" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			%systemroot%\System32\inetsrv\appcmd list config %%i /section:asp | find /i "enableParentPaths" >> %infosec%\result.txt
			echo.                                                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		) else (
			echo * 설정값 없음 * 기본설정 : enableParentPaths=false                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)
	)
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	for /f "tokens=1 delims=[]" %%i in (website-list.txt) do (
		echo [WebSite AppRoot] %%i                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo -----------------------------------------------------                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		cscript %script%\adsutil.vbs enum %%i/root | find /i "AspEnableParentPaths" > nul
		if not errorlevel 1 (
			cscript %script%\adsutil.vbs enum %%i/root | find /i "AspEnableParentPaths"     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			cscript %script%\adsutil.vbs enum %%i/root | find /i "AspEnableParentPaths"     >> %infosec%\result.txt
			echo.                                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		) else (
			echo AspEnableParentPaths : * 기본 설정이 적용되어 있음.                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)
	)
)



type result.txt | find /i "true" > nul
if %errorlevel% equ 0 (
echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=true											   	>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=false												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:6-19-end
del %infosec%\result.txt 2>nul
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0619 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0620 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ######################      6.20 IIS 불필요한 파일 제거       ######################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : IISSamples, IISHelp 가상디렉터리가 존재하지 않을 경우 양호                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 		 (IIS 7.0 이상 버전 해당 사항 없음)						                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist iis-enable.txt (
	echo ☞ IIS Service Enable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-20-enable
) else (
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-20-end
)

:6-20-enable
echo [가상 디렉터리 설정 현황]                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	echo ☞ IIS 7.0 이상 버전 해당 사항 없음							                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

::20160114 수정함(해당사항 없음으로 변경함)
::if %iis_ver_major% geq 7 (
	::%systemroot%\System32\inetsrv\appcmd list config -section:system.applicationHost/sites | find /i "virtualdirectory" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
::)

::20160114 수정함(IISSample 등 없는지 판단가능하게 변경함)
:: iis ver <= 6
::if %iis_ver_major% leq 6 (
	::%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Virtual Roots" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
::)

if %iis_ver_major% leq 6 (
	%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Virtual Roots" | findstr "IISSamples IISHelp" >> %infosec%\sample-app.txt
	type sample-app.txt                                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	findstr "IISSamples IISHelp" sample-app.txt > NUL
	IF ERRORLEVEL 1 (
		ECHO * 점검결과: IISSamples, IISHelp 가상디렉터리가 존재하지 않음.                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt		
	)	ELSE (
		ECHO * 점검결과: IISSamples, IISHelp 가상디렉터리가 존재함.                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt				
	)
)

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

:6-20-end
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0620 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0621 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################      6.21 IIS 웹 프로세스 권한 제한       ######################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : IIS 서비스가 서비스 운영에 필요한 최소한 권한으로 설정되어 있으면 양호         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist iis-enable.txt (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Enable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6.21-end
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo [World Wide Web Publishing Service 동작 계정]                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\ObjectName"                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\ObjectName"                 >> %infosec%\result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo [IIS Admin Service 동작 계정]                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\IISADMIN\ObjectName"              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\IISADMIN\ObjectName"              >> %infosec%\result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

type %infosec%\result.txt | find "LocalSystem" > nul
if %errorlevel% equ 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:6.21-end
del %infosec%\result.txt 2>nul
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0621 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0622 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #######################        6.22 IIS 링크 사용금지        ########################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : 웹 컨텐츠 디렉터리에 바로가기 파일이 존재하지 않으면 양호                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 웹 사이트 홈디렉터리에 심볼릭 링크, aliases, *.lnk 파일이 존재하지 않으면 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist iis-enable.txt (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Enable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-22-enable
) else (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-22-end
)

:6-22-enable
echo [등록 사이트]                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	type website-list.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	type website-name.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

:: iis ver >= 7
if %iis_ver_major% geq 7 (
	echo [홈디렉토리 정보 - WEB/FTP 구분용]                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo -----------------------------------------------------                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%systemroot%\System32\inetsrv\appcmd list config -section:system.applicationHost/sites | findstr /i "name protocol physicalpath" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo *** 사이트별 불필요 파일 체크                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
for /f "delims=" %%a in (website-physicalpath.txt) do (
	echo [Website HomeDir] %%a                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo -----------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	call cd /d %%a			2>nul
	attrib /s | find /i ".lnk"                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	attrib /s | find /i ".lnk"                                                                >> %infosec%\%result.txt
	cd /d %infosec%
	echo.                                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ※ 결과 값이 존재하지 않으면 양호                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

type %infosec%\result.txt | find ".lnk" > nul
if %errorlevel% equ 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)


:6-22-end
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
del %infosec%\result.txt 2>nul
echo 0622 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0623 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##################     6.23 IIS 파일 업로드 및 다운로드 제한     ###################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : 파일 업로드 및 다운로드 제한 설정 존재 시 양호                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 웹 서비스의 서버 자원관리를 위해 업로드 및 다운로드 용량을 제한한 경우 양호    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
if exist iis-enable.txt (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Enable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-23-enable
) else (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt	
	goto 6-23-end
)

:6-23-enable
echo [등록 사이트]                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	type website-list.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	type website-name.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo [기본 설정]                                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	%systemroot%\System32\inetsrv\appcmd list config | findstr /i "maxAllowedContentLength maxRequestEntityAllowed bufferingLimit" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	cscript %script%\adsutil.vbs enum W3SVC | findstr /i "AspMaxRequestEntityAllowed AspBufferingLimit" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo * 값이 없을 경우 기본 설정이 적용되어 있음.                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo *** 사이트별 설정 확인                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	for /f "delims=" %%a in (website-name.txt) do (
		echo [WebSite Name] %%a                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo -----------------------------------------------------                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%systemroot%\System32\inetsrv\appcmd list config %%a | findstr /i "maxAllowedContentLength maxRequestEntityAllowed bufferingLimit" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo * 값이 없을 경우 기본 설정이 적용되어 있음.                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	for /f "tokens=1 delims=[]" %%i in (website-list.txt) do (
		echo [WebSite AppRoot] %%i                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo -----------------------------------------------------                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		cscript %script%\adsutil.vbs enum %%i | find /i "AspMaxRequestEntityAllowed" > nul
		if not errorlevel 1 (
			cscript %script%\adsutil.vbs enum %%i | find /i "AspMaxRequestEntityAllowed"  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		) else (
			echo AspMaxRequestEntityAllowed : * 기본 설정이 적용되어 있음.                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)
		cscript %script%\adsutil.vbs enum %%i | find /i "AspBufferingLimit" > nul
		if not errorlevel 1 (
			cscript %script%\adsutil.vbs enum %%i | find /i "AspBufferingLimit"           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		) else (
			echo AspBufferingLimit          : * 기본 설정이 적용되어 있음.                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		)
	)
)

echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


:6-23-end
echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0623 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0624 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###################       6.24  IIS DB 연결 취약점 점검          ###################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : .asp에 asp.dll 파일 맵핑 존재시(GET, HEAD, POST, TRACE) 양호                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 7.0이상- 요청 필터링에서 .asa, .asax 확장자가 False로 설정되어 있으면 양호     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo                   요청 필터링에서 .asa, .asax 확장자가 True로 설정되어 있을 경우        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo                   .asa, .asax 매핑이 등록되어 있어야 양호                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo                   (만약, Global.asa 파일을 사용하지 않는 경우 해당 사항 없음.)          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo                 > (1) fileExtension=".asa" allowed="false" 이면 양호                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo                 > (2) fileExtension=".asa" allowed="true" 이면, .asa 맵핑 확인          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo   	    : 6.0이하- .asa 매핑이 존재할 경우 양호                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo                   (설정 예) ".asa,C:\WINDOWS\system32\inetsrv\asp.dll,5,GET,HEAD,POST,TRACE" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo                    GET,HEAD,POST,TRACE 동사: 다음으로 제한								 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist iis-enable.txt (
	echo ☞ IIS Service Enable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-24-enable
) else (
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt	
	goto 6-24-end
)

:6-24-enable
echo [등록 사이트]                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	type website-list.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	type website-name.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo [기본 설정]                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	%systemroot%\System32\inetsrv\appcmd list config | find /i ".asa" | find /i /v "httpforbiddenhandler" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	cscript %script%\adsutil.vbs enum W3SVC | find /i ".asa"                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo *** 사이트별 설정 확인                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	for /f "delims=" %%a in (website-name.txt) do (
		echo [WebSite Name] %%a                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo -----------------------------------------------------                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%systemroot%\System32\inetsrv\appcmd list config %%a | find /i ".asa" | find /i /v "httpforbiddenhandler" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	for /f "tokens=1 delims=[]" %%i in (website-list.txt) do (
		echo [WebSite AppRoot] %%i                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo -----------------------------------------------------                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		cscript %script%\adsutil.vbs enum %%i/root | find /i ".asa" > nul
		if not errorlevel 1 (
			cscript %script%\adsutil.vbs enum %%i/root | find /i ".asa"                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			echo.                                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		) else (
			cscript %script%\adsutil.vbs enum %%i/root | find /i "ScriptMaps" > nul
			if not errorlevel 1 (
				echo .asa 맵핑이 등록되어 있지 않음. [취약]                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
				echo.                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			) else (
				echo * 기본 설정이 적용되어 있음.                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
				echo.                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			)
		)
	)
)
echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt	
:6-24-end
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0624 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0625 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #######################     6.25 IIS 가상 디렉토리 제거     ########################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : 해당 웹사이트에 IIS Admin, IIS Adminpwd 가상 디렉터리가 존재하지 않을 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo        : IIS 6.0 이상 버전 해당 사항 없음 												 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
if exist iis-enable.txt (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Enable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-25-enable
) else (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-25-end
)

:6-25-enable
echo [가상 디렉터리 설정 현황]                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
rem ##########20160114 6.0 이상 해당 사항 없음으로 소스 수정 시작##########
:: iis ver >= 6
if %iis_ver_major% geq 6 (
echo ☞ IIS 6.0 이상 버전 해당 사항 없음 												 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt	
echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 6-25-end
)

:: iis ver < 5
if %iis_ver_major% lss 5 (
	%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Virtual Roots" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Virtual Roots" >> %infosec%\result.txt
)
type %infosec%\result.txt | find /i "IIS" | findstr /I "Admin Adminpwd" > nul
if %errorlevel% equ 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
rem ##########20160114 6.0 이상 해당 사항 없음으로 소스 수정 끝##########


rem ##########20160114 6.0 이상 해당 사항 없음으로 소스 삭제 시작##########
:: iis ver >= 7
::if %iis_ver_major% geq 7 (
	::%systemroot%\System32\inetsrv\appcmd list config -section:system.applicationHost/sites | find /i "virtualdirectory" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
::)
:: iis ver <= 6
::if %iis_ver_major% leq 6 (
	::%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Virtual Roots" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
::)
rem ##########20160114 6.0 이상 해당 사항 없음으로 소스 삭제 끝##########
del %infosec%\result.txt 2>nul
:6-25-end
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0625 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0626 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ######################     6.26 IIS 데이터 파일 ACL 적용     ########################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : 웹디렉터리 하위 파일들에 Everyone 권한이 없을 경우 양호                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : (정적컨텐트 파일은 Read 권한만 있을 경우 양호)                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist iis-enable.txt (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Enable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-26-enable
) else (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-26-end
)

:6-26-enable
echo [등록 사이트]                                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: iis ver >= 7
if %iis_ver_major% geq 7 (
	type website-list.txt                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: iis ver <= 6
if %iis_ver_major% leq 6 (
	type website-name.txt                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo *** 사이트별 파일 Everyone 권한 체크                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo (exe, dll, cmd, pl, asp, inc, shtm, shtml, txt, gif, jpg, html)                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
for /f "delims=" %%a in (website-physicalpath.txt) do (
	echo [Website HomeDir] %%a                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2> nul
	echo -----------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	call cd /d %%a 2> nul																				
	cd 2> nul
	cacls *.exe /t | find /i "everyone"                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2> nul
	cacls *.dll /t | find /i "everyone"                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2> nul
	cacls *.cmd /t | find /i "everyone"                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2> nul
	cacls *.pl /t | find /i "everyone"                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2> nul
	cacls *.asp /t | find /i "everyone"                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2> nul
	cacls *.inc /t | find /i "everyone"                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2> nul
	cacls *.shtm /t | find /i "everyone"                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2> nul
	cacls *.shtml /t | find /i "everyone"                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2> nul
	cacls *.txt /t | find /i "everyone"                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2> nul
	cacls *.gif /t | find /i "everyone"                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2> nul
	cacls *.jpg /t | find /i "everyone"                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2> nul
	cacls *.html /t | find /i "everyone"                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 2> nul
	cacls *.exe /t | find /i "everyone"                                                      >> %infosec%\result.txt 2> nul
	cacls *.dll /t | find /i "everyone"                                                      >> %infosec%\result.txt 2> nul
	cacls *.cmd /t | find /i "everyone"                                                      >> %infosec%\result.txt 2> nul
	cacls *.pl /t | find /i "everyone"                                                       >> %infosec%\result.txt 2> nul
	cacls *.asp /t | find /i "everyone"                                                      >> %infosec%\result.txt 2> nul
	cacls *.inc /t | find /i "everyone"                                                      >> %infosec%\result.txt 2> nul
	cacls *.shtm /t | find /i "everyone"                                                     >> %infosec%\result.txt 2> nul
	cacls *.shtml /t | find /i "everyone"                                                    >> %infosec%\result.txt 2> nul
	cacls *.txt /t | find /i "everyone"                                                      >> %infosec%\result.txt 2> nul
	cacls *.gif /t | find /i "everyone"                                                      >> %infosec%\result.txt 2> nul
	cacls *.jpg /t | find /i "everyone"                                                      >> %infosec%\result.txt 2> nul
	cacls *.html /t | find /i "everyone"                                                     >> %infosec%\result.txt 2> nul
	cd /d %infosec% 2> nul
	echo.                                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) 2> nul
echo ※ 결과 값이 존재하지 않으면 양호                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

type %infosec%\result.txt | find /i "everyone" > nul
if %errorlevel% equ 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

:6-26-end
del %infosec%\result.txt 2>nul
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0626 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0627 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###################      6.27 IIS 미사용 스크립트 매핑 제거      ###################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : 취약한 매핑(.htr .idc .stm .shtm .shtml .printer .htw .ida .idq)이 존재하지    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : 않는 경우 양호                                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : Windows 2003 이후 버전은 패치가 되어 양호함                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist iis-enable.txt (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Enable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-27-enable
) else (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-27-end
)

:6-27-enable
if %WinVer% geq 2 (
	echo ☞ Windows 2003 이후 버전은 패치가 되어 해당사항 없음							>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-27-end
) else (
	echo [등록 사이트]                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo -----------------------------------------------------                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	:: iis ver >= 7
	if %iis_ver_major% geq 7 (
		type website-list.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
	:: iis ver <= 6
	if %iis_ver_major% leq 6 (
		type website-name.txt                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

	:: iis ver >= 7
	if %iis_ver_major% geq 7 (
		echo [미사용 스크립트 매핑 확인]                                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo -----------------------------------------------------                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%systemroot%\System32\inetsrv\appcmd list config | find /i "scriptprocessor" | findstr /i ".htr .idc .stm .shtm .shtml .printer .htw .ida .idq" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo ※ 결과 값이 존재하지 않으면 양호                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)

	:: iis ver <= 6
	if %iis_ver_major% leq 6 (
		echo [기본 설정]                                                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo -----------------------------------------------------                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		cscript %script%\adsutil.vbs enum W3SVC | findstr /i ".htr .idc .stm .shtm .shtml .printer .htw .ida .idq" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		cscript %script%\adsutil.vbs enum W3SVC | findstr /i ".htr .idc .stm .shtm .shtml .printer .htw .ida .idq" >> %infosec%\result.txt
		echo ※ 결과 값이 존재하지 않으면 양호                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

		echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo *** 사이트별 설정 확인                                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		for /f "tokens=1 delims=[]" %%i in (website-list.txt) do (
			echo [WebSite AppRoot] %%i                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			echo -----------------------------------------------------------------------        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			cscript %script%\adsutil.vbs enum %%i/root | findstr /i ".htr .idc .stm .shtm .shtml .printer .htw .ida .idq" > nul
			if not errorlevel 1 (
				cscript %script%\adsutil.vbs enum %%i/root | findstr /i ".htr .idc .stm .shtm .shtml .printer .htw .ida .idq" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
				cscript %script%\adsutil.vbs enum %%i/root | findstr /i ".htr .idc .stm .shtm .shtml .printer .htw .ida .idq" >> %infosec%\result.txt
				echo.                                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
			) else (
				cscript %script%\adsutil.vbs enum %%i/root | find /i "ScriptMaps" > nul
				if not errorlevel 1 (
					echo * 취약한 맵핑이 등록되어 있지 않음. [양호]                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
					echo.                                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
				) else (
					echo * 기본 설정이 적용되어 있음.                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
					echo.                                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
				)
			)
		)
	)
)

type %infosec%\result.txt | findstr /i ".htr .idc .stm .shtm .shtml .printer .htw .ida .idq" > nul
if %errorlevel% equ 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)


del %infosec%\result.txt 2>nul
:6-27-end
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0627 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0628 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###################      6.28 IIS Exec 명령어 쉘 호출 진단       ###################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준 : 해당 서비스의 레지스트리 값이 0일 경우 양호                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\SSIEnableCmdDirective  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : (참고1) IIS 5.0 버전에서 해당 레지스트리 값이 없을 경우 양호                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■      : (참고2) IIS 7.0 이상 양호                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist iis-enable.txt (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Enable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-28-enable
) else (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-28-end
)

:6-28-enable
:: iis ver >= 6
if %iis_ver_major% geq 6 (
	echo ☞ IIS 6.0 이상 양호			                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6-28-end
)

:: iis ver < 6
if %iis_ver_major% lss 6 (
	echo [Registry 설정] 			                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo -----------------------------------------------------                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\SSIEnableCmdDirective" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\SSIEnableCmdDirective" >> %infosec%\result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)


type %infosec%\result.txt | find /V "0" | findstr /i "SSIEnableCmdDirective" > nul
if %errorlevel% equ 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
del %infosec%\result.txt 2>nul

:6-28-end
echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0628 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0629 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###############    6.29 미흡한 Apache Tomcat 기본 계정 사용 여부    ################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: Apache Tomcat 서비스가 동작중이지 않거나 tomcat/tomcat 또는 관리자 계정/패스워드>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : tomcat/admin 이외의 다른 패스워드로 설정되어 있는 경우 양호                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo. ◎ 프로세스 명 확인을 통한 (Apache Tomcat)서비스 동작 확인                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find /i "Apache Tomcat" > NUL
IF NOT ERRORLEVEL 1 (
echo ☞ Apache Tomcat Service Enable     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo ☞ Apache Tomcat Service Disable    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo. ◎ 포트번호 확인을 통한 (Apache Tomcat)서비스 동작 확인                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
netstat -ao | find /i "8080" > NUL
IF NOT ERRORLEVEL 1 (
echo ☞ Apache Tomcat Service Enable     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ Apache Tomcat 계정 정보 확인                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type %%CATALINA_HOME%%\conf\tomcat-users.xml                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo ☞ Apache Tomcat Service Disable    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0629 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0630 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################     6.30 DNS Recursive Query 설정 미흡    ######################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: DNS 서비스가 동작중이지 않거나 Resursive Query를 제한하는 레지스트리 값이 1일 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 서비스 조회(DNS) 확인을 통한 서비스 동작 확인                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
sc query dns                                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 프로세스 명 확인을 통한 (DNS)서비스 동작 확인                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find /i "DNS Server" > NUL 
IF NOT ERRORLEVEL 1 (
echo ☞ DNS Service Enable     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo ☞ DNS Service Disable    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ DNS Recursive Query 설정                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -------------------------------------------------------                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HLKM\SYSTEM\CurrentControlSet\Services\DNS\Parameters /v NoRecursion" | findstr .  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0630 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0631 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #######################    6.31 DNS Zone Transfer 설정     ############################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: DNS 서비스 설정이 아래 기준 중 하나라도 해당되는 경우 양호(SecureSecondaries 2) >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (1) DNS 서비스를 사용하지 않을 경우                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (2) 영역 전송 허용을 하지 않을 경우                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (3) 특정 서버로만 영역 전송을 허용하는 경우                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : * 레지스트리값(영역전송 허용안함:3, 아무서버로나:0, 이름서버탭에나열된 서버로만:1, 다음서버로만:2 ) >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : [참고]                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : 결과 값이 없을 경우 DNS 서버에 등록된 정/역방향 조회 영역이 없는 것으로,      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : DNS 서비스를 사용하지 않을 경우 서비스를 중지할 것을 권고                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ DNS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find "DNS Server" > NUL
IF NOT ERRORLEVEL 1 (
	ECHO ☞ DNS Service Enable                                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)	ELSE (
	ECHO ☞ DNS Service Disable                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
	goto 0631-end
	echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)


:: winver < 2008R2
if %WinVer% leq 3 (
goto 0631-2008
)

:: winver > 2008
if %WinVer% geq 4 (
 goto 0631-2008R2
)


:0631-2008
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | findstr . | find /v "Listing of" | find /v "system was unable" >nul
	IF %ERRORLEVEL% NEQ 0 (
		reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "SecureSecondaries" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "SecureSecondaries" >> %infosec%\result.txt
	) else (
		%script%\reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "SecureSecondaries" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%script%\reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "SecureSecondaries" >> %infosec%\result.txt
	)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type %infosec%\result.txt | %script%\awk -F" " {print$3} | find "0" > nul
	if %ERRORLEVEL% NEQ 0 (
		echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
		echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		goto 0631-end
	)
	if %ERRORLEVEL% EQU 0 (
		echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
		echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		goto 0631-end
	)
)

:0631-2008R2
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | findstr . | find /v "Listing of" | find /v "system was unable" >nul
	IF %ERRORLEVEL% NEQ 0 (
		reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "SecureSecondaries" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "SecureSecondaries" >> %infosec%\result.txt
	) else (
		%script%\reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "SecureSecondaries" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%script%\reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones" /s | find "SecureSecondaries" >> %infosec%\result.txt
	)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type %infosec%\result.txt | find "0x0" > nul
	if %ERRORLEVEL% NEQ 0 (
		echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
		echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		goto 0631-end
	)
	if %ERRORLEVEL% EQU 0 (
		echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
		echo.                                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		goto 0631-end
	)
)

:0631-end
del %infosec%\result.txt 2>nul	
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0631 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0632 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###################    6.32 RDS (Remote Data Services) 제거     ####################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 다음의 중 한가지라도 해당되는 경우 양호                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (1) IIS 를 사용하지 않는 경우                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (2) Windows 2000 sp4, Windows 2003 sp2, Windows 2008 이상 양호                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (3) 디폴트 웹사이트에 MSADC 가상 디렉터리가 존재하지 않을 경우                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (4) 해당 레지스트리 값이 존재하지 않을 경우                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ IIS 서비스 동작 여부 확인                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if exist iis-enable.txt (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Enable                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo ☞ IIS Service Disable                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6.32-end
)

:: OS Version, Service Pack 버전 체크
echo [OS Version 확인]                                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt	
:: winver = 2000
if %WinVer% equ 1 (
	ECHO ☞ Win 2000일 경우 서비스팩 4 이상 양호                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type systeminfo.txt | find /i "kernel version"                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type systeminfo.txt | find /i "service pack"                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type systeminfo.txt | find /i "os version" | find /i /v "bios" | %script%\awk -F" " {print$6}	> %infosec%\result.txt
	goto 6.32-2000
	echo.
)

:: winver >= 2003
if %WinVer% geq 2 (
	ECHO ☞ Windows 2003 sp2 이상, Windows 2008 이상 양호                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type systeminfo.txt | find /i "os name"                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type systeminfo.txt | find /i "os version" | find /i /v "bios"                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if %WinVer% EQU 2 (
	type systeminfo.txt | find /i "os version" | find /i /v "bios" | %script%\awk -F" " {print$6}     > %infosec%\result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6.32-2003
	)

if %WinVer% geq 3 (
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6.32-end
	)

:6.32-2000
type systeminfo.txt | find /i /v "bios" | find /V "N/A" | find /i "os version" >nul
if %errorlevel% neq 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 6.32-2003-0
)

for /f %%r in (result.txt) do set SP=%%r       
if %SP% geq 4 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 6.32-end
)

:6.32-2003-0	
%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Virtual Roots" | find /i "msadc" >> %infosec%\msadcdir.txt
	type msadcdir.txt                                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	find /i "msadc" msadcdir.txt > NUL
	IF ERRORLEVEL 1 (
		ECHO * 점검결과: MSADC 가상디렉터리가 존재하지 않음.                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt		
		goto 6.32-end
)

%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\ADCLaunch" /s | findstr /i "RDSServer.DataFactory AdvancedDataFactory VbBusObj.VbbusObjCls" >> %infosec%\RDSREG.txt
type %infosec%\RDSREG.txt                                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	findstr /i "RDSServer.DataFactory AdvancedDataFactory VbBusObj.VbbusObjCls" RESREG.txt > NUL
	IF ERRORLEVEL 1 (
		ECHO * 점검결과: 등록된 REG값이 존재하지 않음.                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt		
		goto 6.32-end
)

		echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt		
		goto 6.32-end
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

:6.32-2003

type systeminfo.txt | find /i /v "bios" | find /V "N/A" | find /i "os version" >nul
if %errorlevel% neq 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 6.32-2003-1
)

for /f %%r in (result.txt) do set SP=%%r       
if %SP% geq 2 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 6.32-end
)

:6.32-2003-1

%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Virtual Roots" | find /i "msadc" >> %infosec%\msadcdir.txt
	type msadcdir.txt                                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	find /i "msadc" msadcdir.txt > NUL
	IF ERRORLEVEL 1 (
		ECHO * 점검결과: MSADC 가상디렉터리가 존재하지 않음.                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt		
		goto 6.32-end
)

%script%\reg query "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\ADCLaunch" /s | findstr /i "RDSServer.DataFactory AdvancedDataFactory VbBusObj.VbbusObjCls" >> %infosec%\RDSREG.txt
type %infosec%\RDSREG.txt                                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	findstr /i "RDSServer.DataFactory AdvancedDataFactory VbBusObj.VbbusObjCls" RESREG.txt > NUL
	IF ERRORLEVEL 1 (
		ECHO * 점검결과: 등록된 REG값이 존재하지 않음.                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt		
		goto 6.32-end
)

		echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt		
		goto 6.32-end
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt	

	
:6.32-end	
del %infosec%\result.txt 2>nul
del %infosec%\msadcdir.txt 2>nul
del %infosec%\RDSREG.txt 2>nul

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0632 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0633 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##############    6.33 원격으로 액세스할 수 있는 레지스트리 경로    ################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: Remote Registry Service 가 중지되어 있을 경우 양호                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : AD를 사용할 경우 해당 레지스트리 확인, 불필요한 계정(Everyone 포함) 미존재 시 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 레지스트리 값 HKLM\System\CurrentControlSet\Control\SecurePipeServers           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ Remote Registry service 동작 여부 확인                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
sc query RemoteRegistry                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find "Remote Registry" > NUL
IF NOT ERRORLEVEL 1 (
	ECHO ☞ Remote Registry Service Enable                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)	ELSE (
	ECHO ☞ Remote Registry Service Disable                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find "Remote Registry"                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 레지스트리 값 확인(AD 사용 시)                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
FOR /F "delims=" %%i IN ('reg query HKLM\System\CurrentControlSet\Control\SecurePipeServers') DO SET infosec_result=%%i
if defined infosec_result (
	reg query HKLM\System\CurrentControlSet\Control\SecurePipeServers >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
	echo Registry key value not found: HKLM\System\CurrentControlSet\Control\SecurePipeServers %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
SET infosec_result=

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0633 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0634 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ######################      6.34 LAN Manager 인증 수준      ########################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "LAN Manager 인증 수준" 정책에 "NTLMv2 응답만 보냄"으로 설정되어 있는 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 참고  : (LM NTML 응답 보냄: LmCompatibilityLevel=4,0)                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (LM NTML NTLMv2세션 보안 사용(협상된 경우): LmCompatibilityLevel=4,1)         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (NTLM 응답 보냄: LmCompatibilityLevel=4,2)                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (NTLMv2 응답만 보냄: LmCompatibilityLevel=4,3)                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (NTLMv2 응답만 보냄WLM거부: LmCompatibilityLevel=4,4)                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (NTLMv2 응답만 보냄WLM거부 NTLM 거부: LmCompatibilityLevel=4,5)               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : 값이 없을 경우 아무것도 설정이 안 된 상태임                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 주의: 해당 설정을 수정하면 클라이언트나 서비스 또는 응용 프로그램과의 호환성에 영향을 미칠 수 있음. >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ "LAN Manager 인증 수준" 정책 설정 확인                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "LmCompatibilityLevel"           					 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "LmCompatibilityLevel" > nul
if %errorlevel% equ 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "LmCompatibilityLevel" | %script%\awk -F= {print$2}       >> %infosec%\result.txt
for /f %%r in (result.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 값이 존재 하지 않음                                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

del %infosec%\result.txt 2>nul
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0634 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0635 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###############    6.35 보안 채널 데이터 디지털 암호화 또는 서명    ################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 아래 3가지 정책이 "사용" 으로 되어 있을 경우 양호                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 참고: (1) 도메인 구성원: 보안 채널 데이터를 디지털 암호화 또는 서명(항상)             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (2) 도메인 구성원: 보안 채널 데이터를 디지털 암호화(가능한 경우)                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (3) 도메인 구성원: 보안 채널 데이터를 디지털 서명(가능한 경우)                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (4,1)사용, (4,0)사용 안 함                							  		   	 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 보안 채널 데이터 디지털 암호화 또는 서명 설정값 확인                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Findstr /I "RequireSignOrSeal SealSecureChannel SignSecureChannel" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

type Local_Security_Policy.txt | Findstr /I "RequireSignOrSeal SealSecureChannel SignSecureChannel" | findstr "4.0 unable" > nul
if %errorlevel% equ 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=4,0												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=4,1												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

echo 0635 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0636 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #########################       6.36 화면보호기 설정       ############################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 화면 보호기를 설정하고, 암호를 사용하며, 대기 시간이 10분일 경우 양호           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 참고: 레지스트리 값이 없을 경우 AD 또는 OS설치 후 설정을 하지 않은 경우임             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 화면보호기 설정값 확인                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKCU\Control Panel\Desktop\ScreenSaveActive"                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKCU\Control Panel\Desktop\ScreenSaverIsSecure"                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKCU\Control Panel\Desktop\ScreenSaveTimeOut"                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [AD(Active Directory)일 경우 레지값]                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop\ScreenSaverIsSecure" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop\ScreenSaveTimeOut" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

%script%\reg query "HKCU\Control Panel\Desktop\ScreenSaveActive"                             > %infosec%\result.txt
%script%\reg query "HKCU\Control Panel\Desktop\ScreenSaverIsSecure"                         >> %infosec%\result.txt
type %infosec%\result.txt | find /V "1" | find /I "REG_SZ" > nul
if %errorlevel% equ 0 (
	goto 6.36-start
	echo.                                                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKCU\Control Panel\Desktop\ScreenSaveTimeOut"                           > %infosec%\result.txt
type result.txt | %script%\awk -F" " {print$3}      						                >> %infosec%\result1.txt
for /f %%r in (result1.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 6.36-end
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


:6.36-start
echo.                                                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop\ScreenSaverIsSecure" > %infosec%\result.txt

type %infosec%\result.txt | find /V "0" | find /V "unable to find" | find /I "REG_SZ" > nul
	if %errorlevel% neq 0 (
	echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 6.36-end
	)
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	%script%\reg query "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop\ScreenSaveTimeOut" > %infosec%\result.txt
	type result.txt | %script%\awk -F" " {print$3}      						                >> %infosec%\result1.txt
	for /f %%r in (result1.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

:6.36-end

del %infosec%\result.txt 2>nul
del %infosec%\result1.txt 2>nul
echo.                                                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0636 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0637 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ######################      6.37 NTFS 파일 시스템 미사용      ######################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 파일시스템이 보안 기능을 제공 해주는 NTFS 파일 시스템만 사용중인 경우 양호      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	fsutil fsinfo drives 																	 > %infosec%\inf_using_drv_temp1.txt
	type inf_using_drv_temp1.txt | find /i "\" 												 > %infosec%\inf_using_drv_temp2.txt
	echo.																					 > %infosec%\inf_using_drv_temp3.txt
	FOR /F "tokens=1-26" %%a IN (inf_using_drv_temp2.txt) DO (
		echo %%a >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%b >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%c >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%d >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%e >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%f >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%g >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%h >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%i >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%j >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%k >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%l >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%m >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%n >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%o >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%p >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%q >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%r >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%s >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%t >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%u >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%v >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%w >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%x >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%y >> %infosec%\inf_using_drv_temp3.txt 2> nul
		echo %%z >> %infosec%\inf_using_drv_temp3.txt 2> nul
	)
	type inf_using_drv_temp3.txt | find /i "\" | find /v "A:\" 								 > %infosec%\inf_using_drv.txt
	FOR /F "tokens=1" %%a IN (inf_using_drv.txt) DO (
		echo.                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo %%a                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		fsutil fsinfo drivetype %%a												 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		fsutil fsinfo volumeinfo %%a												 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		fsutil fsinfo drivetype %%a												 > %infosec%\result.txt
	type %infosec%\result.txt | find /I "Fixed Drive" > nul
	type %infosec%\result.txt | find /I "Fixed Drive" > nul
	if not errorlevel 1 (
	fsutil fsinfo volumeinfo %%a												 >> %infosec%\result1.txt
	)
)
	type %infosec%\result1.txt | find /I "File System Name" | find /i "fat" > nul
	if %errorlevel% equ 0 (
	echo.                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=FAT												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	) else (
	echo.                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=NTFS												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
	
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [참고]                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo C: 드라이브 권한 확인(NTFS일 경우 계정별 권한 부여 설정이 출력됨)                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
cacls c:\ 																					 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


del %infosec%\result.txt 2>nul
del %infosec%\result1.txt 2>nul
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0637 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0638 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ########################      6.38 백신 프로그램 설치      ############################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 바이러스 백신 프로그램이 설치되어 있는 경우 양호                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 결과값에 백신 List 미 출력 시 설치 여부 인터뷰 필요                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
set vaccine="kaspersky norton bitdefender turbo avast v3"

echo ☞ Process List                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
for %%a IN (%vaccine%) DO (
type tasklist.txt | findstr /i %%a 															>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type tasklist.txt | findstr /i %%b >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type tasklist.txt | findstr /i %%c >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type tasklist.txt | findstr /i %%d >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type tasklist.txt | findstr /i %%e >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type tasklist.txt | findstr /i %%f >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

echo. 																						 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ☞ Service list                                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
for %%a IN (%vaccine%) DO (
net start | findstr /i %%a >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | findstr /i %%b >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | findstr /i %%c >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | findstr /i %%d >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | findstr /i %%e >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | findstr /i %%f >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ※ 결과가 없는 경우 프로세스 목록 및 인터뷰를 통해 확인 필요                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0638 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0639 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##################    6.39 이동식 미디어 포맷 및 꺼내기 허용    ####################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "이동식미디어 포맷 및 꺼내기 허용" 정책이 "Administrators"으로 되어 있거나, 결과가 없는 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (결과가 없으면 아무 그룹도 정의되지 않음: Default Administrators만 사용 가능 양호) >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (AllocateDASD=1,"0" 이면 Administrators 양호)                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (AllocateDASD=1,"1" 이면 Administrators 및 Power Users)                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (AllocateDASD=1,"2" 이면 Administrators 및 Interactive Users)                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 이동식 미디어 포맷 및 꺼내기 허용 설정 값 확인                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "AllocateDASD"                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ※ 결과가 없을 경우 Default로 Administrators 만 사용 가능함 							>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

type Local_Security_Policy.txt | Find /I "AllocateDASD" > nul
if %errorlevel% neq 0 (
echo Result=0												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
type Local_Security_Policy.txt | Find /I "AllocateDASD" | %script%\awk -F, {print$2} | find "0" > nul
if %errorlevel% equ 0 (
echo Result=0												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
type Local_Security_Policy.txt | Find /I "AllocateDASD" | %script%\awk -F, {print$2} | find "1" > nul
if %errorlevel% equ 0 (
echo Result=1												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
type Local_Security_Policy.txt | Find /I "AllocateDASD" | %script%\awk -F, {print$2} | find "2" > nul
if %errorlevel% equ 0 (
echo Result=2												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0639 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0640 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ########################      6.40 방화벽 기능 미사용      ############################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 방화벽 기능 활성화되어 있으면 양호                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 윈도우 운영체게 자체 방화벽 또는 3rd party 방화벽 사용 여부 확인 필요           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 홈 또는 회사 네트워크 방화벽 활성화 여부 확인                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile"  | findstr "EnableFirewall"    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 공용 네트워크 방화벽 활성화 여부 확인                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile\EnableFirewall" | findstr "EnableFirewall"  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0640 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0641 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################    6.41 불필요한 TELNET 서비스 구동 여부   ####################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: Telnet 서비스가 동작중이지 않을 경우 양호                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : TELNET 서비스 사용 시 사용용도에 대해 인터뷰 필요                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ TELNET service 동작 여부 확인                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | findstr /i "telnet" > NUL
IF NOT ERRORLEVEL 1 (
echo ☞ TELNET Service Enable     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) else (
echo ☞ TELNET Service Disable    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0641 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0642 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #####################    6.42 시스템 사용 주의사항 미출력    ########################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 시스템의 불법적인 사용에 대한 경고 메시지/제목이 설정되어 있는 경우 양호        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : LegalNoticeCaption에 제목, LegalNoticeText에 내용이 입력된 경우                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 시스템 경고 메시지/제목 출력 여부 확인                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\legalnoticecaption" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\legalnoticetext" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0642 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###########################        7. 패치 관리        ################################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0701 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##################    7.01 최신 서비스팩 적용    ###################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 최신 서비스팩이 설치되어 있을 경우 양호                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (Windows NT 6a, Windows 2000 SP4, Windows 2003 SP2, Windows 2008 SP2)         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (Windows 2008R2 SP1, Windows 2012, 2012r2는 SP이 없음) 						 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type systeminfo.txt | find "Microsoft"                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type systeminfo.txt | find "Pack"                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo [OS Version 확인]                                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo -----------------------------------------------------                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt	
:: winver = 2000
if %WinVer% equ 1 (
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	type systeminfo.txt | find /i "service pack" | find /i /v "bios" | %script%\awk -F" " {print$6}		        > %infosec%\result.txt
	echo.
	goto 0701-2000
)

:: winver = 2003
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
if %WinVer% EQU 2 (
	type systeminfo.txt | find /i "os version" | find /i /v "bios" | %script%\awk -F" " {print$6}		        > %infosec%\result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 0701-2003
	)

:: winver = 2008
if %WinVer% EQU 3 (
	type systeminfo.txt | find /i "os version" | find /i /v "bios" | %script%\awk -F" " {print$6}		        > %infosec%\result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 0701-2008
	)

:: winver = 2008R2
if %WinVer% EQU 4 (
	type systeminfo.txt | find /i "os version" | find /i /v "bios" | %script%\awk -F" " {print$6}		        > %infosec%\result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 0701-2008R2
	)
	
:: winver = 2012&2012R2
if %WinVer% GEQ 5 (
	echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 0701-end
	)

:0701-2000
type systeminfo.txt | find /i /v "bios" | find /V "N/A" | find /i "os version" >nul
if %errorlevel% neq 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 0701-end
)

for /f %%r in (result.txt) do set SP=%%r       
if %SP% geq 4 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 0701-end
)
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 0701-end

:0701-2003
type systeminfo.txt | find /i /v "bios" | find /V "N/A" | find /i "os version" >nul
if %errorlevel% neq 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 0701-end
)

for /f %%r in (result.txt) do set SP=%%r       
if %SP% geq 2 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 0701-end
)
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 0701-end

:0701-2008
type systeminfo.txt | find /i /v "bios" | find /V "N/A" | find /i "os version" >nul
if %errorlevel% neq 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 0701-end
)

for /f %%r in (result.txt) do set SP=%%r       
if %SP% geq 2 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 0701-end
)
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 0701-end

:0701-2008R2
type systeminfo.txt | find /i /v "bios" | find /V "N/A" | find /i "os version" >nul
if %errorlevel% neq 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 0701-end
)

for /f %%r in (result.txt) do set SP=%%r       
if %SP% geq 1 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=O												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 0701-end
)
echo Result=F												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 0701-end

:0701-end	
del %infosec%\result.txt 2>nul
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0701 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0702 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ######################      7.02 백신 프로그램 업데이트      ########################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 바이러스 백신 프로그램의 최신 엔진 업데이트가 설치되어 있는 경우 양호           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 자동 업데이트 기능 사용 시 양호                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ☞ 수동 점검 (백신 업데이트 일자 확인)                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0702 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0703 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #######################       7.03 최신 HOT FIX 적용       ############################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 최신 Hotfix가 설치되어 있을 경우 양호                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type systeminfo.txt | findstr /i "hotfix kb"                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0703 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##############################        8. 감사        ################################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0801 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ######################    8.01 불필요한 예약된 작업 존재     ########################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 예약된 작업에 불필요한 명령어나 파일이 없을 경우 양호                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 예약된 작업 List에 대해 실제 필요 작업 여부 인터뷰 확인 필요                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver >= 2003
if %WinVer% geq 2 (
	echo ☞ 예약된 작업 확인                                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo                                                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	schtasks | findstr [0-9][0-9][0-9][0-9]      	                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ☞ at 명령어로 등록한 작업 확인                                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
at                                                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver >= 2003
if %WinVer% geq 2 (
	echo [참고] schtasks 전체                                                      				 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	schtasks                 									                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0801 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0802 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###################    8.02 불필요한 시작프로그램 존재 여부    ######################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 시작 프로그램 목록을 정기적으로 검사하고 불필요한 서비스가 없는 경우 양호       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (담당자 인터뷰 및 시작 프로그램 점검관련 보고서 확인)                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ☞ 시작 프로그램 확인(HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run)  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ---------------------------------------------------------------------------------       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver = 2000
if %WinVer% equ 1 (
	%script%\reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: winver >= 2003
if %WinVer% geq 2 (
	%script%\reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" | findstr . | find /v "Listing of" | find /v "system was unable" >nul
	IF NOT ERRORLEVEL 0 (
		reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	) else (
		%script%\reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ☞ 시작 프로그램 확인(HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run) >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ---------------------------------------------------------------------------------       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver = 2000
if %WinVer% equ 1 (
	%script%\reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run"        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: winver >= 2003
if %WinVer% geq 2 (
	%script%\reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run" | findstr . | find /v "Listing of" | find /v "system was unable" >nul
	IF NOT ERRORLEVEL 0 (
		reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	) else (
		%script%\reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0802 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0803 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #####################      8.03 정보보호 관련 감사 미실시      ######################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 아래 각 항목에 대해 권고 사항대로 설정했을 경우                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : AuditObjectAccess=2                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : AuditAccountManage=3                                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : AuditLogonEvents=3                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : AuditPrivilegeUse=2                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : AuditDSAccess=2                                                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : AuditAccountLogon=3                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : AuditSystemEvents=2                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : AuditPolicyChange=3                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : AuditProcessTracking=2                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 정보보호 관련 감사 설정값 확인                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Findstr /I "AuditObjectAccess" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Findstr /I "AuditAccountManage" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Findstr /I "AuditLogonEvents" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Findstr /I "AuditPrivilegeUse" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Findstr /I "AuditDSAccess" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Findstr /I "AuditAccountLogon" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Findstr /I "AuditSystemEvents" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Findstr /I "AuditPolicyChange" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Findstr /I "AuditProcessTracking" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt                                                                                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0803 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0804 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #####################     8.04 로그의 정기적 검토 및 보고     ######################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: 로그기록에 대해 정기적 검토, 분석, 리포트 작성 및 보고 등의 조치가 이루어지는 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo ☞ 수동 점검 (담당자 인터뷰 수행)                                                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0804 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0805 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ############    8.05 보안 감사를 로그할 수 없는 경우 즉시 시스템 종료    ############## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "보안 감사를 로그할 수 없는 경우 즉시 시스템 종료" 정책이 "사용안함"으로 설정되어 있는 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : (CrashOnAuditFail = 4,0 이면 양호)                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt 
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 보안 감사를 로그할 수 없는 경우 즉시 시스템 종료 정책 설정값 확인                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "CrashOnAuditFail"                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
type Local_Security_Policy.txt | Find /I "CrashOnAuditFail" | %script%\awk -F= {print$2}       >> %infosec%\result.txt
for /f %%r in (result.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

del %infosec%\result.txt 2>nul
echo 0805 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###########################        9. 보안 관리        ################################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0901 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #######################     9.01 디스크볼륨 암호화 설정     ########################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "데이터 보호를 위해 내용을 암호화" 정책이 선택 된 경우 양호                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 예외: 해당 서버사 물리적으로 보호 된 장소(IDC 내, PC시건장치 등)에 위치해 있을 경우   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■     : 또는 하드디스크 교체 시 기존 하드디스크의 디가우징 또는 천공 등 폐기 관련 규정 수행 시 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ☞ 인터뷰 확인 필요                                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver = 2000
if %WinVer% equ 1 (
	FOR /F "tokens=1 delims=\" %%a IN ("%cd%") DO (
		echo %%a\ 																			 > %infosec%\inf_using_drv.txt
	)
	echo ☞ current using drive volume														 > %infosec%\inf_Encrypted_file_check.txt
	type inf_using_drv.txt 																	 >> %infosec%\inf_Encrypted_file_check.txt
	FOR /F "tokens=1" %%a IN (inf_using_drv.txt) DO (
		echo.								 												 >> %infosec%\inf_Encrypted_file_check.txt
		echo ☞ Search within the %%a drive...  											 >> %infosec%\inf_Encrypted_file_check.txt
		cipher /s:%%a | find "E "        												 	 >> %infosec%\inf_Encrypted_file_check.txt 2> nul
		if errorlevel 1 echo Encrypted file is not exist 									 >> %infosec%\inf_Encrypted_file_check.txt
		echo.								 												 >> %infosec%\inf_Encrypted_file_check.txt
	)
	type inf_Encrypted_file_check.txt 														 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: winver = 2003
if %WinVer% equ 2 (
	echo ☞ Current using drive volume 														 > %infosec%\inf_Encrypted_file_check.txt
	type inf_using_drv.txt 																	 >> %infosec%\inf_Encrypted_file_check.txt

	FOR /F "tokens=1" %%a IN (inf_using_drv.txt) DO (
		echo.								 												 >> %infosec%\inf_Encrypted_file_check.txt
		echo ☞ Search within the %%a drive...  											 >> %infosec%\inf_Encrypted_file_check.txt
		cipher /s:%%a | find "E " | findstr "^E"											 >> %infosec%\inf_Encrypted_file_check.txt 2> nul
		if errorlevel 1 echo Encrypted file is not exist 									 >> %infosec%\inf_Encrypted_file_check.txt
		echo.								 												 >> %infosec%\inf_Encrypted_file_check.txt
	)
	type inf_Encrypted_file_check.txt 														 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
:: winver <= 2008
if %WinVer% geq 3 (
	echo ☞ Windows 2008 이상 해당사항 없음 													 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=M/T												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0901 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0902 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #####################    9.02 Dos공격 방어 레지스트리 설정    ######################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: Dos 공격에 대한 방어 레지스트리가 설정되어 있는 경우 양호                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (1) SynAttackProtect = REG_DWORD 0 ▶ 1 로 변경 시 양호                       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (2) EnableDeadGWDetect = REG_DWORD 1(True) ▶ 0 으로 변경 시 양호             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (3) KeepAliveTime = REG_DWORD 7,200,000(2시간) ▶ 300,000(5분)으로 변경 시 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (4) NoNameReleaseOnDemand = REG_DWORD 0(False) ▶ 1 로 변경 시 양호           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Dos공격 방어 레지스트리 설정값 확인                                                     >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ◎ SynAttackProtect 설정                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\SynAttackProtect" /s >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ◎ EnableDeadGWDetect 설정                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\EnableDeadGWDetect" /s >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ◎ KeepAliveTime 설정                                                                   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\KeepAliveTime" /s >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ◎ NoNameReleaseOnDemand 설정                                                           >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo --------------------------------------------------------                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\NoNameReleaseOnDemand" /s >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0902 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0903 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###############    9.03 세션 연결을 중단하기 전에 필요한 유휴시간    ################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: "로그온 시간이 만료되면 클라이언트 연결 끊기" 정책을 "사용"으로 설정하고,       >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : "세션 연결을 중단하기 전에 필요한 유휴 시간" 정책이 "15분"으로 설정된 경우 양호 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (EnableForcedLogOff	1 이고, AutoDisconnect	15 이면 양호)                    >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 로그온 시간이 만료되면 클라이언트 연결 끊기 정책 설정값 확인                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters\EnableForcedLogOff" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo. ◎ 로그온 시간이 만료되면 클라이언트 연결 끊기 설정 확인                               >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
%script%\reg query "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters\AutoDisconnect" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


%script%\reg query "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters\EnableForcedLogOff" > %infosec%\result.txt
type %infosec%\result.txt | find "EnableForcedLogOff" | find "1" > nul
if %errorlevel% neq 0 (
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo Result=0												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
goto 9-03end
)
%script%\reg query "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters\AutoDisconnect" | %script%\awk -F" " {print$3}       > %infosec%\result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
for /f %%r in (result.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

:9-03end

del %infosec%\result.txt 2>nul
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 0903 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ############################        10. DB 관리        ################################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 1001 START >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
SET /A item_count+=1
echo [+] %item_count%
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #######################    10.01 Windows 인증 모드 사용     ########################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 기준: Windows 인증 모드로 설정되어 있는 경우 양호 (LoginMode 1 이면 양호)             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (1) LoginMode 1 이면 Windows 인증 모드                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■       : (2) LoginMode 2 이면 SQL Server 및 Windows 인증 모드                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■ 현황                                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver = 2000
if %WinVer% equ 1 (
	echo Win 2000 해당사항 없음                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	goto 10.01-end
)

:: winver >= 2003
if %WinVer% geq 2 (
	net start | find "SQL Server" > NUL
	IF NOT ERRORLEVEL 1 (
		ECHO ☞ SQL Server Enable                                                                  >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		goto 10.01-start
		echo.                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)	ELSE (
		ECHO ☞ SQL Server Disable                                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo Result=N/A												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		goto 10.01-end
	)
)


:10.01-start

%script%\reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server" /s | find "LoginMode" > nul
	IF %ERRORLEVEL% neq 0 (
		reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server" /s | find "LoginMode" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server" /s | find "LoginMode" | %script%\awk -F" " {print$3}       > %infosec%\result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		for /f %%r in (result.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	) else (
		%script%\reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server" /s | find "LoginMode" >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		%script%\reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server" /s | find "LoginMode" | %script%\awk -F" " {print$3} > %infosec%\result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		for /f %%r in (result.txt) do echo Result=%%r												>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
		echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
	)

:10.01-end
del %infosec%\result.txt 2>nul

echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo 1001 END >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo @@FINISH>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


::시스템 정보 출력 시작
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###############################  Interface Information  ############################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
ipconfig /all                                                                                >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###############################  System Information  ################################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


:: winver = 2000
if %WinVer% equ 1 (
	%script%\psinfo                                                                          > systeminfo.txt
	echo Hotfix:                                                                             >> systeminfo.txt
	%script%\reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\HotFix"            >> systeminfo.txt
	type systeminfo.txt                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)

:: winver >= 2003
if %WinVer% geq 2 (
	type %infosec%\systeminfo_ko.txt                                                         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###############################  tasklist Information  ################################ >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
:: winver = 2000
if %WinVer% equ 1 (
	%script%\pslist                                                                          > tasklist.txt
	type %infosec%\tasklist.txt	                                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt	
)

:: winver >= 2003
if %WinVer% geq 2 (
	tasklist																				 > %infosec%\tasklist.txt 2>nul
	type %infosec%\tasklist.txt	                                                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt	
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo #################################  Port Information  ################################## >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
netstat -an | find /v "TIME_WAIT"                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ############################  Service Daemon Information  ############################# >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net start | find /v "started" | find /v "completed"                                          >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ##########################  Environment Variable Information  ######################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
set											                                                 >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt

echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################  metabase.xml  ################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
IF EXIST C:\WINDOWS\system32\inetsrv\MetaBase.xml (
	type C:\WINDOWS\system32\inetsrv\MetaBase.xml                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
) ELSE (
	echo C:\WINDOWS\system32\inetsrv\MetaBase.xml 존재하지 않음.                             >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
)
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
del %infosec%\account.txt 2>nul
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ###############                      계정 정보                     #################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ####################################################################################### >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ****************************  User Accounts List  *****************************         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net user | find /V "successfully"                                                            >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ************************  Group List - net localgroup  ************************         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
net localgroup | find /V "successfully"                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo *****************************  Account Information  ***************************         >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
FOR /F "tokens=1,2,3 skip=4" %%i IN ('net user') DO (
net user %%i >> account.txt 2>nul
net user %%j >> account.txt 2>nul
net user %%k >> account.txt 2>nul
)
type account.txt >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt



::시스템 정보 출력 끝



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::: 공통 부분 시작2::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



echo.>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.>> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo END_RESULT                                                                              >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
del %infosec%\account.txt 2>nul
del %infosec%\account_temp1.txt 2>nul
del %infosec%\account_temp2.txt 2>nul
del %infosec%\account_temp3.txt 2>nul
del %infosec%\admin-account.txt 2>nul
del %infosec%\service.txt 2>nul
del %infosec%\idletime.txt 2>nul
del %infosec%\home-directory.txt 2>nul
del %infosec%\home-directory-acl.txt 2>nul
del %infosec%\Local_Security_Policy.txt 2>nul
del %infosec%\net-accounts.txt 2>nul
del %infosec%\reg-website-list.txt 2>nul
del %infosec%\systeminfo.txt 2>nul
del %infosec%\systeminfo_ko.txt 2>nul
del %infosec%\tasklist.txt 2>nul
del %infosec%\real_ver.txt 2>nul
del %infosec%\inf_share_folder.txt 2>nul
del %infosec%\inf_share_folder_temp.txt 2>nul
del %infosec%\inf_share_folder_temp_sed.txt 2>nul
del %infosec%\inf_share_folder_temp_sed2.txt 2>nul
del %infosec%\inf_Encrypted_file_check.txt 2>nul
del %infosec%\AutoLogon_REG_Export.txt 2>nul


rem Netbios 관련
del %infosec%\2-18-netbios-list-1.txt 2> nul
del %infosec%\2-18-netbios-list-2.txt 2> nul
del %infosec%\2-18-netbios-list.txt 2> nul
del %infosec%\2-18-netbios-query.txt 2> nul
del %infosec%\2-18-netbios-result.txt 2> nul


rem DB 관리 관련
del %infosec%\unnecessary-user.txt 2>nul
del %infosec%\password-null.txt 2>nul


rem IIS 관련 del
del %infosec%\iis-enable.txt 2>nul
del %infosec%\iis-version.txt 2>nul
del %infosec%\website-list.txt 2>nul
del %infosec%\website-name.txt 2>nul
del %infosec%\website-physicalpath.txt 2>nul
del %infosec%\sample-app.txt 2>nul


rem FTP 관련 del
del %infosec%\ftp-enable.txt 2>nul
del %infosec%\ftpsite-list.txt 2>nul
del %infosec%\ftpsite-name.txt 2>nul
del %infosec%\ftpsite-physicalpath.txt 2>nul
del %infosec%\ftp-ipsecurity.txt 2>nul


rem 파일 드라이브 경로 관련 del
del %infosec%\inf_using_drv_temp3.txt 2>nul
del %infosec%\inf_using_drv_temp2.txt 2>nul
del %infosec%\inf_using_drv_temp1.txt 2>nul
del %infosec%\inf_using_drv.txt 2>nul



echo.                                                                                        >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■   END Time  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
date /t                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
time /t                                                                                      >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt


echo.
echo ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■■■                                                              ■■■   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■■■       Windows %WinVer_name% Security Check is Finished       ■■■   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■■■                                                              ■■■   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■   >> %infosec%\%COMPUTERNAME%.WINDOWS.%WinVer_name%.result.txt
echo.
echo [+] Windows Security Check is Finished
pause

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::: 공통 부분 끝2::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

