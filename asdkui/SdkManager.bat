@echo off
setlocal enabledelayedexpansion

set BASE_PATH=%~dp0
set JAR_PATH=%BASE_PATH%lib\sdkmanager.jar;%BASE_PATH%lib\swtmenubar.jar
set PATH_CONFIG=%BATH_PATH%local.properties

for /f "tokens=1,2 delims==" %%a in (%PATH_CONFIG%) do set %%a=%%b

if [%TOOLS_DIR%] == [] (
    echo "TOOLS_DIR (path to tools of android-sdk-windows) does not set in %PATH_CONFIG%"
    rem exit /b
    echo "Using %BASE_PATH%  as tools directory"
    set TOOLS_DIR=%BASE_PATH%
)
if [%WORK_DIR%] == [] set WORK_DIR=%TOOLS_DIR%
if [%JAVA_EXE%] == [] set JAVA_EXE=java
if [%JAVAW_EXE%] == [] set JAVAW_EXE=javaw
if [%WITH_CONSOLE%] == [] set WITH_CONSOLE=1

for /f "delims=" %%a in ('"%JAVA_EXE%" -jar %BASE_PATH%lib\archquery.jar') do set SWT_PATH=%BASE_PATH%lib\windows\%%a

if defined ANDROID_SWT set SWT_PATH=%ANDROID_SWT%

if %WITH_CONSOLE% == 0 (
    set LAUNCH_CMD=start %JAVAW_EXE%
) else (
    set LAUNCH_CMD=call %JAVA_EXE%
)

%LAUNCH_CMD% ^
    -Dcom.android.sdkmanager.toolsdir=%TOOLS_DIR% ^
    -Dcom.android.sdkmanager.workdir=%WORK_DIR% ^
    -classpath "%JAR_PATH%;%SWT_PATH%\swt.jar" com.android.sdkmanager.Main %*

