@echo off
setlocal enabledelayedexpansion
REM TOEKN: https://www.logo.dev/dashboard/playground/logo-images
set "API_TOKEN=[INPUT YOUR log.dev TOKEN]"
set "OUTPUT_DIR=result"
set "OUTPUT_CSV=%OUTPUT_DIR%\logos.csv"
set "FAILED_LIST=%OUTPUT_DIR%\failed.txt"

REM 创建输出目录
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM 写 CSV 头
echo domain,logo_url > "%OUTPUT_CSV%"

REM 清空失败列表
break > "%FAILED_LIST%"

for /f "usebackq delims=" %%L in ("domains.txt") do (
    set "line=%%L"

    REM 去掉 http(s):// 和路径，只取域名部分
    set "domain=!line!"
    set "domain=!domain:http://=!"
    set "domain=!domain:https://=!"

    for /f "tokens=1 delims=/" %%A in ("!domain!") do set "domain=%%A"

    REM 去掉 www. 前缀
    if /i "!domain:~0,4!"=="www." set "clean_domain=!domain:~4!" else set "clean_domain=!domain!"

    REM 跳过空行
    if "!clean_domain!"=="" (
        echo Skipped empty line
        goto :continue
    )

    echo Fetching logo for: !clean_domain!

    REM 拼接 logo URL
    set "logo_url=https://img.logo.dev/!clean_domain!?token=%API_TOKEN%&retina=true"

    REM 下载图片
    curl -s --fail "!logo_url!" -o "%OUTPUT_DIR%\!clean_domain!.png"

    if !errorlevel! equ 0 (
        echo !clean_domain!,!logo_url! >> "%OUTPUT_CSV%"
    ) else (
        echo ❌ Failed to download logo for: !clean_domain!
        echo !clean_domain! >> "%FAILED_LIST%"
    )

    :continue
)

echo.
echo ✅ Done!
echo Logos saved in: %OUTPUT_DIR%
echo CSV file: %OUTPUT_CSV%
echo Failed list: %FAILED_LIST%

endlocal
pause
