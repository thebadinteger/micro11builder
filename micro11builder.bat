@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Micro11 Builder
echo Welcome to the Micro11 image creator!
timeout /t 3 /nobreak > nul
cls

set DriveLetter=
set /p DriveLetter=Please enter the drive letter for the Windows 11 ISO to modify: 
set "DriveLetter=%DriveLetter::=%"
set "DriveLetter=%DriveLetter%:"
echo.
if not exist "%DriveLetter%\sources\boot.wim" (
	echo.Can't find Windows OS Installation files in the specified Drive Letter..
	echo.
	echo.Please enter the correct Drive Letter..
	goto :Stop
)

if not exist "%DriveLetter%\sources\install.wim" (
	echo.Can't find Windows OS Installation files in the specified Drive Letter..
	echo.
	echo.Please enter the correct Drive Letter..
	goto :Stop
)

mkdir C:\micro11
echo Copying Windows image. This will take around 1 minute depending on your PC's specs.
xcopy /E /I /H /R /Y /J "%DriveLetter%\*" C:\micro11 >nul
echo Copying complete!
timeout /t 2 /nobreak > nul
cls
echo Getting image information...
dism /Get-WimInfo /wimfile:c:\micro11\sources\install.wim
set index=
set /p index=Please enter the image index: 
set "index=%index%"
echo Mounting Windows image. This might take a while.
echo.
md c:\scratchdir
dism /mount-image /imagefile:C:\micro11\sources\install.wim /index:%index% /mountdir:c:\scratchdir
echo Mounting complete! Performing removal of applications...
echo Removing Bloatware...
call :RemoveApp "Clipchamp"
call :RemoveApp "BingNews"
call :RemoveApp "BingWeather"
call :RemoveApp "GamingApp"
call :RemoveApp "GetHelp"
call :RemoveApp "Getstarted"
call :RemoveApp "MicrosoftOfficeHub"
call :RemoveApp "MicrosoftSolitaireCollection"
call :RemoveApp "People"
call :RemoveApp "PowerAutomateDesktop"
call :RemoveApp "Todos"
call :RemoveApp "WindowsAlarms"
call :RemoveApp "windowscommunicationsapps"
call :RemoveApp "WindowsFeedbackHub"
call :RemoveApp "WindowsMaps"
call :RemoveApp "WindowsSoundRecorder"
call :RemoveApp "Xbox"
call :RemoveApp "YourPhone"
call :RemoveApp "ZuneMusic"
call :RemoveApp "ZuneVideo"
call :RemoveApp "MicrosoftFamily"
call :RemoveApp "QuickAssist"
call :RemoveApp "MicrosoftTeams"
echo Removing Copilot (if folder exists)
if exist "C:\scratchdir\windows\inboxapps\Microsoft.Copilot" (
    rd /s /q "C:\scratchdir\windows\inboxapps\Microsoft.Copilot" >nul 2>&1
)

echo Removing Edge (if folders exist)
if exist "C:\scratchdir\program files (x86)\microsoft\Edge" (
    rd /s /q "C:\scratchdir\program files (x86)\microsoft\Edge" >nul 2>&1
)
if exist "C:\scratchdir\program files (x86)\microsoft\EdgeCore" (
    rd /s /q "C:\scratchdir\program files (x86)\microsoft\EdgeCore" >nul 2>&1
)
if exist "C:\scratchdir\program files (x86)\microsoft\EdgeUpdate" (
    rd /s /q "C:\scratchdir\program files (x86)\microsoft\EdgeUpdate" >nul 2>&1
)
echo Removing of system apps complete! Now proceeding to removal of system packages...
timeout /t 1 /nobreak > nul
cls
echo Removing Media Player Legacy:
dism /image:c:\scratchdir /Disable-Feature /FeatureName:WindowsMediaPlayer /Remove >nul 2>&1

echo Removing OneDrive:
if exist "C:\scratchdir\Windows\System32\OneDriveSetup.exe" (
    takeown /f C:\scratchdir\Windows\System32\OneDriveSetup.exe >nul 2>&1
    icacls C:\scratchdir\Windows\System32\OneDriveSetup.exe /grant Administrators:F /T /C >nul 2>&1
    del /f /q /s "C:\scratchdir\Windows\System32\OneDriveSetup.exe" >nul 2>&1
)
echo Components removal complete!
timeout /t 2 /nobreak > nul
cls
echo Loading registry...
reg load HKLM\zCOMPONENTS "c:\scratchdir\Windows\System32\config\COMPONENTS" >nul
reg load HKLM\zDEFAULT "c:\scratchdir\Windows\System32\config\default" >nul
reg load HKLM\zNTUSER "c:\scratchdir\Users\Default\ntuser.dat" >nul
reg load HKLM\zSOFTWARE "c:\scratchdir\Windows\System32\config\SOFTWARE" >nul
reg load HKLM\zSYSTEM "c:\scratchdir\Windows\System32\config\SYSTEM" >nul
echo Bypassing system requirements(on the system image):
			Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1" /f >nul 2>&1
echo Disabling reserved storage
			Reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /t REG_DWORD /D "0" /f >nul 2>&1
echo Disabling Teams:
Reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\Communications" /v "ConfigureChatAutoInstall" /t REG_DWORD /d "0" /f >nul 2>&1
echo Disabling Sponsored Apps:
Reg add "HKLM\zNTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSOFTWARE\Microsoft\PolicyManager\current\device\Start" /v "ConfigureStartPins" /t REG_SZ /d "{\"pinnedList\": [{}]}" /f >nul 2>&1
echo Enabling Local Accounts on OOBE:
Reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t REG_DWORD /d "1" /f >nul 2>&1
Reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "HideOnlineAccountScreen" /t REG_DWORD /d "1" /f >nul 2>&1
echo Disabling Reserved Storage:
Reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t REG_DWORD /d "0" /f >nul 2>&1
echo Disabling Chat icon:
Reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows\Windows Chat" /v "ChatIcon" /t REG_DWORD /d "3" /f >nul 2>&1
Reg add "HKLM\zNTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d "0" /f >nul 2>&1
echo Tweaking complete!
echo Unmounting Registry...
reg unload HKLM\zCOMPONENTS >nul 2>&1
reg unload HKLM\zDRIVERS >nul 2>&1
reg unload HKLM\zDEFAULT >nul 2>&1
reg unload HKLM\zNTUSER >nul 2>&1
reg unload HKLM\zSCHEMA >nul 2>&1
reg unload HKLM\zSOFTWARE >nul 2>&1
reg unload HKLM\zSYSTEM >nul 2>&1
echo Replacing Wallpapers
if exist "C:\scratchdir\Windows\Web\Wallpaper\Windows\img19.jpg" (
    del /f /q "C:\scratchdir\Windows\Web\Wallpaper\Windows\img19.jpg" >nul 2>&1
)
if exist "%~dp0wallpaperdark.jpg" (
    copy /y "%~dp0wallpaperdark.jpg" "C:\scratchdir\Windows\Web\Wallpaper\Windows\img19.jpg" >nul
)
if exist "%~dp0wallpaperlight.jpg" (
    copy /y "%~dp0wallpaperlight.jpg" "C:\scratchdir\Windows\Web\Wallpaper\Windows\img0.jpg" >nul
)
if exist "C:\scratchdir\Windows\Web\Screen\img100.jpg" (
    del /f /q "C:\scratchdir\Windows\Web\Screen\img100.jpg" >nul 2>&1
)
if exist "%~dp0wallpaperdark.jpg" (
    copy /y "%~dp0wallpaperdark.jpg" "C:\scratchdir\Windows\Web\Screen\img100.jpg" >nul
)
echo Cleaning up image...
dism /image:c:\scratchdir /Cleanup-Image /StartComponentCleanup /ResetBase
echo Cleanup complete.
echo Unmounting image...
dism /unmount-image /mountdir:c:\scratchdir /commit

echo Exporting image...
Dism /Export-Image /SourceImageFile:c:\micro11\sources\install.wim /SourceIndex:%index% /DestinationImageFile:c:\micro11\sources\install2.wim /compress:max
del c:\micro11\sources\install.wim
ren c:\micro11\sources\install2.wim install.wim
echo Windows image completed. Continuing with boot.wim.
timeout /t 2 /nobreak > nul
cls
echo Mounting boot image:
dism /mount-image /imagefile:c:\micro11\sources\boot.wim /index:2 /mountdir:c:\scratchdir
echo Loading registry...
reg load HKLM\zCOMPONENTS "C:\scratchdir\Windows\System32\config\COMPONENTS" >nul
reg load HKLM\zDEFAULT "C:\scratchdir\Windows\System32\config\default" >nul
reg load HKLM\zSOFTWARE "C:\scratchdir\Windows\System32\config\SOFTWARE" >nul
reg load HKLM\zSYSTEM "C:\scratchdir\Windows\System32\config\SYSTEM" >nul

echo Bypassing system requirements(on the setup image):
Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /t REG_DWORD /d "1" /f >nul 2>&1
Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f >nul 2>&1
Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d "1" /f >nul 2>&1
Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
Reg add "HKLM\zSYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1" /f >nul 2>&1
echo Tweaking complete! 
echo Unmounting Registry...
reg unload HKLM\zCOMPONENTS >nul 2>&1
reg unload HKLM\zDRIVERS >nul 2>&1
reg unload HKLM\zDEFAULT >nul 2>&1
reg unload HKLM\zNTUSER >nul 2>&1
reg unload HKLM\zSCHEMA >nul 2>&1
reg unload HKLM\zSOFTWARE >nul 2>&1
reg unload HKLM\zSYSTEM >nul 2>&1
echo Unmounting image...
dism /unmount-image /mountdir:c:\scratchdir /commit 
cls
echo the micro11 image is now completed. Proceeding with the making of the ISO...
echo Copying unattended file for bypassing MS account on OOBE...
if exist "%~dp0autounattend.xml" (
    copy /y "%~dp0autounattend.xml" C:\micro11\autounattend.xml >nul
)
echo.
echo Creating ISO image...
if exist "%~dp0oscdimg.exe" (
    "%~dp0oscdimg.exe" -m -o -u2 -udfver102 -bootdata:2#p0,e,bC:\micro11\boot\etfsboot.com#pEF,e,bC:\micro11\efi\microsoft\boot\efisys.bin C:\micro11 "%~dp0micro11.iso"
) else (
    echo oscdimg.exe not found in script directory! Skipping ISO creation.
)
echo Creation completed! Press any key to exit the script...
pause 
echo Performing Cleanup...
rd c:\micro11 /s /q 
rd c:\scratchdir /s /q 
echo Creation Complete.
pause
exit

:RemoveApp
for /f "tokens=2 delims=:" %%a in ('dism /image:C:\scratchdir /Get-ProvisionedAppxPackages ^| findstr /i "PackageName" ^| findstr /i "%~1"') do (
    set "pkg=%%a"
    set "pkg=!pkg: =!"
    echo Removing !pkg!...
    dism /image:C:\scratchdir /Remove-ProvisionedAppxPackage /PackageName:!pkg! >nul
)
exit /b

:Stop
pause
exit
