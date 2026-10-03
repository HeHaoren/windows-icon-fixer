@echo off
chcp 65001 >nul
title Windows 图标快速修复工具

:: ===== 自提权（需要管理员权限）=====
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 正在请求管理员权限...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:menu
cls
echo ================================================
echo          Windows 图标快速修复工具
echo ================================================
echo.
echo   [1] 修复桌面快捷方式图标（重建图标缓存）
echo   [2] 修复开始菜单磁贴图标（重注册 UWP 应用）
echo   [3] 两项都修复
echo   [0] 退出
echo.
set /p choice=请输入选项 [0-3] 然后回车：

if "%choice%"=="1" goto do_desktop
if "%choice%"=="2" goto do_tile
if "%choice%"=="3" goto do_both
if "%choice%"=="0" goto do_exit
echo.
echo 无效输入，请重新选择。
timeout /t 2 >nul
goto menu

:: ===== 修复桌面快捷方式图标 =====
:do_desktop
call :fix_desktop
echo.
pause
goto menu

:: ===== 修复磁贴图标 =====
:do_tile
call :fix_tile
echo.
pause
goto menu

:: ===== 两项都修复 =====
:do_both
call :fix_desktop
call :fix_tile
echo.
pause
goto menu

:do_exit
exit /b


:: ===== 子程序：重建图标缓存 =====
:fix_desktop
echo.
echo [1/3] 结束资源管理器进程...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
echo [2/3] 删除图标缓存文件...
del /f /q "%LocalAppData%\IconCache.db" >nul 2>&1
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\iconcache_*.db" >nul 2>&1
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
echo [3/3] 重启资源管理器...
start explorer.exe
echo.
echo 桌面图标缓存已重建，图标短暂空白后会自动恢复。
goto :eof

:: ===== 子程序：重注册 UWP 应用 =====
:fix_tile
echo.
echo 正在重新注册 UWP 应用以修复磁贴图标...
echo 这一步需要 1-5 分钟，请耐心等待，勿关闭窗口...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers | ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register ($_.InstallLocation + '\AppXManifest.xml') -ErrorAction SilentlyContinue }"
echo.
echo 磁贴应用已重新注册，磁贴图标应已恢复。
goto :eof
