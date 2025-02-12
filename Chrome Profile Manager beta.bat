@echo off
chcp 65001 >nul
title Chrome Profiles Manager v0.1.0
setlocal enabledelayedexpansion

:: Пользовательские пути (можно изменить при необходимости)
set "CHROME_PATH="
set "USER_DATA_PATH="

:: Если пути заданы вручную, используем их
if defined CHROME_PATH set "chrome_exe=!CHROME_PATH!" & goto :chrome_found

:: Поиск Chrome в стандартных путях и реестре
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" set "chrome_exe="C:\Program Files\Google\Chrome\Application\chrome.exe"" & goto :chrome_found
if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" set "chrome_exe="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"" & goto :chrome_found

:: Поиск Chrome через реестр
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe" /ve 2^>nul') do set "chrome_exe="%%~b"" & goto :chrome_found
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Clients\StartMenuInternet\Google Chrome\shell\open\command" /ve 2^>nul') do set "chrome_exe="%%~b"" & goto :chrome_found

:chrome_found
    :: Использование пользовательских путей заместо стандартных (если они заданы)
    if not "!USER_DATA_PATH!"=="" (set "user_data=!USER_DATA_PATH!") else (set "user_data=%LOCALAPPDATA%\Google\Chrome\User Data")
    if not exist "!chrome_exe!" powershell -Command "Write-Host 'Ошибка: Chrome не найден...' -ForegroundColor Red" & pause >nul & exit /b 1

:: Загрузка списка профилей
call :reload_profiles

:menu
    cls & echo.
    echo ================================
    powershell -Command "[Console]::Write('===       '); Write-Host 'Главное меню' -ForegroundColor DarkGreen -NoNewLine; [Console]::WriteLine('       ===')"
    echo ================================
    echo 1 - Просмотр данных профилей
    echo 2 - Создание профилей
    echo 3 - Запуск профилей
    echo 4 - Закрытие профилей            [В разработке]
    powershell -Command "Write-Host '0 - Выход из программы' -ForegroundColor DarkGray"
    echo ================================
    echo. & set /p "main_choice=Выберите опцию (1-4): "

    if "%main_choice%"=="0" goto exit
    if "%main_choice%"=="1" goto show_profiles_data
    if "%main_choice%"=="2" goto create_profiles
    if "%main_choice%"=="3" goto launch_profiles
    if "%main_choice%"=="4" goto close_profiles
    
    echo. & powershell -Command "Write-Host 'Неверный выбор, попробуйте снова...' -ForegroundColor Red" & timeout /t 2 /nobreak >nul & goto menu

:show_profiles_data
    cls & echo.
    echo ================================
    powershell -Command "[Console]::Write('===   '); Write-Host '[1] Просмотр данных' -ForegroundColor Yellow -NoNewLine; [Console]::WriteLine('    ===')"
    echo ================================
    echo 1 - Показать список профилей
    echo 2 - Показать список прокси        [В разработке]
    echo 3 - Показать список юзер-агентов  [В разработке]
    powershell -Command "Write-Host '0 - Вернуться в главное меню' -ForegroundColor DarkGray"
    echo ================================
    echo. & set /p "sub_choice=Выберите опцию (1-3): "

    if "!sub_choice!"=="1" goto show_profiles_list
    if "!sub_choice!"=="2" goto show_proxies_list
    if "!sub_choice!"=="3" goto show_user_agents_list
    if "!sub_choice!"=="0" goto menu

    echo. & powershell -Command "Write-Host 'Неверный выбор, попробуйте снова...' -ForegroundColor Red" & timeout /t 2 /nobreak >nul & goto show_profiles_data

    :show_profiles_list
        cls & echo.
        echo Список профилей:
        echo.
        for /L %%n in (1,1,!i!) do (
            echo %%n - !profile[%%n]!
        )
        echo. & echo Нажмите любую клавишу для возврата... & pause >nul & goto show_profiles_data

    :show_proxies_list
        cls & echo. & echo В разработке. & timeout /t 1 /nobreak >nul & cls & echo. & echo В разработке.. & timeout /t 1 /nobreak >nul & cls & echo. & echo В разработке... & timeout /t 1 /nobreak >nul & goto show_profiles_data

    :show_user_agents_list   
        cls & echo. & echo В разработке. & timeout /t 1 /nobreak >nul & cls & echo. & echo В разработке.. & timeout /t 1 /nobreak >nul & cls & echo. & echo В разработке... & timeout /t 1 /nobreak >nul & goto show_profiles_data

:create_profiles
    cls & echo.
    echo ================================
    powershell -Command "[Console]::Write('===  '); Write-Host '[2] Создание профилей' -ForegroundColor Yellow -NoNewLine; [Console]::WriteLine('   ===')"
    echo ================================
    powershell -Command "Write-Host '0 - Отмена создания профилей' -ForegroundColor DarkGray"
    echo ================================
    echo. & set /p "num_profiles=Сколько профилей нужно создать: "
    echo.
    
    if "!num_profiles!"=="0" goto menu
    
    :: Проверка на числовой ввод
    echo !num_profiles!| findstr /r "^[1-9][0-9]*$" >nul
    if errorlevel 1 (
        powershell -Command "Write-Host 'Ошибка: !num_profiles! не является числом...' -ForegroundColor Red" & echo. & timeout /t 2 /nobreak >nul & goto create_profiles
    )

    :: Создание профилей
    for /L %%n in (1,1,!num_profiles!) do (
        
        set /a next_profile=!max_profile_num!+%%n
        set "new_profile_name=Profile !next_profile!"
        echo.
        echo Создание профиля №!next_profile!...
        start "" %chrome_exe% --profile-directory="!new_profile_name!" --no-startup-window
        timeout /t 2 /nobreak >nul

        :: Закрытие профиля
        powershell -Command "$processes = Get-Process chrome -ErrorAction SilentlyContinue; if ($processes) { $processes | Where-Object {$_.CommandLine -like '*--profile-directory=\"!new_profile_name!\"*'} | ForEach-Object { $_.CloseMainWindow() } }"
        timeout /t 1 /nobreak >nul
        powershell -Command "Write-Host 'Профиль №!next_profile! успешно создан!' -ForegroundColor DarkGreen"
    )
    echo. & powershell -Command "Write-Host 'Профили успешно созданы...' -ForegroundColor Green" & pause >nul & call :reload_profiles & goto menu

:launch_profiles
    cls & echo.
    echo ================================
    powershell -Command "[Console]::Write('===   '); Write-Host '[3] Запуск профилей' -ForegroundColor Yellow -NoNewLine; [Console]::WriteLine('    ===')"
    echo ================================
    echo 1 - Запустить выбранные профили
    echo 2 - Запустить диапазон профилей
    powershell -Command "Write-Host '0 - Вернуться в главное меню' -ForegroundColor DarkGray"
    echo ================================
    echo. & set /p "sub_choice=Выберите опцию (1-2): "

    if "!sub_choice!"=="1" goto launch_selected_profiles
    if "!sub_choice!"=="2" goto launch_range_profiles
    if "!sub_choice!"=="0" goto menu
    
    echo. & powershell -Command "Write-Host 'Неверный выбор, попробуйте снова...' -ForegroundColor Red" & timeout /t 2 /nobreak >nul & goto launch_profiles

    :launch_selected_profiles
        cls & echo.
        echo Выберите профили для запуска из списка.
        echo.
        for /L %%n in (1,1,!i!) do (
            echo %%n - !profile[%%n]!
        )
        
        echo. & set /p "profiles=Введите номера профилей через пробел (Например, 1 5 10): "
        echo. & set /p "urls=Введите ссылки через пробел (Enter - пропустить): "
        cls & echo. & echo Запуск выбранных профилей... & echo.
        
        for %%a in (!profiles!) do (
            if %%a geq 1 if %%a leq !i! (
                set "profile_path=!profile[%%a]!"
                timeout /t 2 /nobreak >nul
                echo Запуск профиля: !profile_path!.
                start "" !chrome_exe! --profile-directory="!profile_path!" !urls!
            ) else (
                powershell -Command "Write-Host 'Ошибка: Профиль %%a не существует.' -ForegroundColor Red" & timeout /t 2 /nobreak >nul & goto launch_selected_profiles
            )
        )
        echo. & powershell -Command "Write-Host 'Выбранные профили запущены...' -ForegroundColor Green" & echo. & pause >nul & goto launch_profiles

    :launch_range_profiles
        cls & echo.
        echo Выберите диапазон профилей для запуска из списка.
        echo.
        for /L %%n in (1,1,!i!) do (
            echo %%n - !profile[%%n]!
        )
        
        echo. & set /p "ranges=Введите диапазоны профилей через запятую (Например, 1-3,5-7): "
        echo. & set /p "urls=Введите ссылки через пробел (Enter - пропустить): "
        
        for %%r in (!ranges!) do (
            set "range=%%r"
            for /f "tokens=1,2 delims=-" %%a in ("!range!") do (
                set "start=%%a"
                set "end=%%b"
                
                cls & echo.
                echo Запуск профилей с !start! по !end!...
                echo.
                timeout /t 1 /nobreak >nul
                for /L %%i in (!start!,1,!end!) do (
                    if %%i geq 1 if %%i leq !i! (
                        set "profile_path=!profile[%%i]!"
                        timeout /t 2 /nobreak >nul
                        echo Запуск профиля: !profile_path!.
                        start "" !chrome_exe! --profile-directory="!profile_path!" !urls!
                    ) else (
                        powershell -Command "Write-Host 'Ошибка: Профиль %%i не существует.' -ForegroundColor Red" & timeout /t 2 /nobreak >nul & goto launch_range_profiles
                    )
                )
            )
        )
        echo. & powershell -Command "Write-Host 'Выбранные профили запущены...' -ForegroundColor Green" & echo. & pause >nul & goto launch_profiles

:close_profiles
    cls & echo.
    echo ================================
    powershell -Command "[Console]::Write('===  '); Write-Host '[4] Закрытие профилей' -ForegroundColor Yellow -NoNewLine; [Console]::WriteLine('   ===')"
    echo ================================
    echo 1 - Закрыть все профили
    echo 2 - Закрыть выбранные профили
    powershell -Command "Write-Host '0 - Вернуться в главное меню' -ForegroundColor DarkGray"
    echo ================================
    echo. & set /p "sub_choice=Выберите опцию (1-2): "

    if "!sub_choice!"=="1" goto close_all_profiles
    if "!sub_choice!"=="2" goto close_selected_profiles
    if "!sub_choice!"=="0" goto menu

    echo. & powershell -Command "Write-Host 'Неверный выбор, попробуйте снова...' -ForegroundColor Red" & timeout /t 2 /nobreak >nul & goto close_profiles

    :close_all_profiles
        cls & echo. & echo В разработке. & timeout /t 1 /nobreak >nul & cls & echo. & echo В разработке.. & timeout /t 1 /nobreak >nul & cls & echo. & echo В разработке... & timeout /t 1 /nobreak >nul & goto close_profiles
    :close_selected_profiles
        cls & echo. & echo В разработке. & timeout /t 1 /nobreak >nul & cls & echo. & echo В разработке.. & timeout /t 1 /nobreak >nul & cls & echo. & echo В разработке... & timeout /t 1 /nobreak >nul & goto close_profiles

:exit
    ::just for fun
    echo. & powershell -Command "[Console]::Write(''); Write-Host 'В' -ForegroundColor Red -NoNewline; Write-Host 'ы' -ForegroundColor Yellow -NoNewline; Write-Host 'х' -ForegroundColor Green -NoNewline; Write-Host 'о' -ForegroundColor Cyan -NoNewline; Write-Host 'д' -ForegroundColor Blue -NoNewline; [Console]::Write(' '); Write-Host 'и' -ForegroundColor Magenta -NoNewline; Write-Host 'з' -ForegroundColor Red -NoNewline; [Console]::Write(' '); Write-Host 'п' -ForegroundColor Yellow -NoNewline; Write-Host 'р' -ForegroundColor Green -NoNewline; Write-Host 'о' -ForegroundColor Cyan -NoNewline; Write-Host 'г' -ForegroundColor Blue -NoNewline; Write-Host 'р' -ForegroundColor Magenta -NoNewline; Write-Host 'а' -ForegroundColor Red -NoNewline; Write-Host 'м' -ForegroundColor Yellow -NoNewline; Write-Host 'м' -ForegroundColor Green -NoNewline; Write-Host 'ы' -ForegroundColor Cyan -NoNewline; [Console]::Write('...')" & timeout /t 2 /nobreak >nul & exit

:reload_profiles
    :: Получаем список профилей и находим максимальный номер
    set i=0
    set max_profile_num=0
    for /f "delims=" %%A in ('powershell -Command "Get-ChildItem -Path '%user_data%' -Filter 'Profile *' | ForEach-Object { $_.Name -replace 'Profile ', '' } | Where-Object { $_ -match '^\d+$' } | Sort-Object {[int]$_} | Select-Object -Last 1"') do (
        set "max_profile_num=%%A"
    )

    :: Получаем список профилей для отображения
    for /f "delims=" %%A in ('powershell -Command "Get-ChildItem -Path '%user_data%' -Filter 'Profile *' | Sort-Object { [int]($_.Name -replace '\D') } | ForEach-Object { $_.Name }"') do (
        set /a i+=1
        set "profile[!i!]=%%A"
    )

    goto menu
