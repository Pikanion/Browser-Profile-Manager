@echo off
chcp 65001 >nul
title Chrome Profiles Manager v0.1.0
setlocal enabledelayedexpansion

:: Получение ESC-последовательности для использования цветов ANSI
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

:: Определение цветов ANSI
    set "RED=%ESC%[91m"
    set "YELLOW=%ESC%[93m"
    set "GREEN=%ESC%[92m"
    set "CYAN=%ESC%[96m"
    set "BLUE=%ESC%[94m"
    set "MAGENTA=%ESC%[95m"
    set "DARKGREEN=%ESC%[32m"
    set "DARKGRAY=%ESC%[90m"
    set "RESET=%ESC%[0m"

:: Пользовательские пути
set "BRAVE_PATH="
set "USER_DATA_PATH="

:: Поиск Brave
    if defined BRAVE_PATH set "brave_exe=!BRAVE_PATH!" & goto :brave_found
    if exist "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" set "brave_exe="C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"" & goto :brave_found
    if exist "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe" set "brave_exe="C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe"" & goto :brave_found

    for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\brave.exe" /ve 2^>nul') do set "brave_exe="%%~b"" & goto :brave_found
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Clients\StartMenuInternet\Brave\shell\open\command" /ve 2^>nul') do set "brave_exe="%%~b"" & goto :brave_found

:brave_found
    if not "!USER_DATA_PATH!"=="" (set "user_data=!USER_DATA_PATH!") else (set "user_data=%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data")
    if not exist "!brave_exe!" echo %RED%Ошибка: Brave не найден...%RESET% & pause >nul & exit /b 1

:: Загрузка списка профилей
call :reload_profiles

:menu
    cls & echo.
    echo ================================
    echo ===       %DARKGREEN%Главное меню%RESET%       ===
    echo ================================
    echo 1 - Просмотр данных профилей
    echo 2 - Создание профилей
    echo 3 - Запуск профилей
    echo 4 - Закрытие профилей            [В разработке]
    echo %DARKGRAY%0 - Выход из программы%RESET%
    echo ================================
    echo. & set /p "main_choice=Выберите опцию (1-4): "

    if "%main_choice%"=="" goto menu
    if "%main_choice%"=="0" goto exit
    if "%main_choice%"=="1" goto show_profiles_data
    if "%main_choice%"=="2" goto create_profiles
    if "%main_choice%"=="3" goto launch_profiles
    if "%main_choice%"=="4" goto close_profiles
    
    echo. & echo %RED%Неверный выбор, попробуйте снова...%RESET% & timeout /t 2 /nobreak >nul & goto menu

:show_profiles_data
    cls & echo.
    echo ================================
    echo ===   %YELLOW%[1] Просмотр данных%RESET%    ===
    echo ================================
    echo 1 - Показать список профилей
    echo 2 - Показать список прокси        [В разработке]
    echo 3 - Показать список юзер-агентов  [В разработке]
    echo %DARKGRAY%0 - Вернуться в главное меню%RESET%
    echo ================================
    echo. & set /p "sub_choice=Выберите опцию (1-3): "
    
    if "%sub_choice%"=="" goto show_profiles_data
    if "!sub_choice!"=="1" goto show_profiles_list
    if "!sub_choice!"=="2" goto show_proxies_list
    if "!sub_choice!"=="3" goto show_user_agents_list
    if "!sub_choice!"=="0" goto menu

    echo. & echo %RED%Неверный выбор, попробуйте снова...%RESET% & timeout /t 2 /nobreak >nul & goto show_profiles_data

    :show_profiles_list
        cls & echo.
        echo Список профилей:
        echo.
        for /L %%n in (1,1,!i!) do (
            echo %%n - !profile[%%n]!
        )
        echo. & echo Нажмите любую клавишу для возврата... & pause >nul & goto show_profiles_data

    :show_proxies_list
        cls & echo. & echo В разработке. & timeout /t 2 /nobreak >nul & goto show_profiles_data

    :show_user_agents_list   
        cls & echo. & echo В разработке. & timeout /t 2 /nobreak >nul & goto show_profiles_data

:create_profiles
    cls & echo.
    echo ================================
    echo ===  %YELLOW%[2] Создание профилей%RESET%   ===
    echo ================================
    echo %DARKGRAY%0 - Отмена создания профилей%RESET%
    echo ================================
    echo. & set /p "num_profiles=Сколько профилей нужно создать: "
    echo.
    
    if "!num_profiles!"=="0" goto menu
    
    echo !num_profiles!| findstr /r "^[1-9][0-9]*$" >nul
    if errorlevel 1 (
        echo %RED%Ошибка: !num_profiles! не является числом...%RESET% & echo. & timeout /t 2 /nobreak >nul & goto create_profiles
    )

    for /L %%n in (1,1,!num_profiles!) do (
        set /a next_profile=!max_profile_num!+%%n
        set "new_profile_name=Profile !next_profile!"
        echo.
        echo Создание профиля №!next_profile!...
        start "" !brave_exe! --profile-directory="!new_profile_name!" --no-startup-window
        timeout /t 2 /nobreak >nul
        echo %DARKGREEN%Профиль №!next_profile! успешно создан!%RESET%
    )
    echo. & echo %GREEN%Профили успешно созданы...%RESET% & pause >nul & call :reload_profiles & goto menu

:launch_profiles
    cls & echo.
    echo ================================
    echo ===   %YELLOW%[3] Запуск профилей%RESET%    ===
    echo ================================
    echo 1 - Запустить выбранные профили
    echo 2 - Запустить диапазон профилей
    echo %DARKGRAY%0 - Вернуться в главное меню%RESET%
    echo ================================
    echo. & set /p "sub_choice=Выберите опцию (1-2): "

    if "%sub_choice%"=="" goto launch_profiles
    if "!sub_choice!"=="1" goto launch_selected_profiles
    if "!sub_choice!"=="2" goto launch_range_profiles
    if "!sub_choice!"=="0" goto menu
    
    echo. & echo %RED%Неверный выбор, попробуйте снова...%RESET% & timeout /t 2 /nobreak >nul & goto launch_profiles

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
                start "" !brave_exe! --profile-directory="!profile_path!" !urls! --window-name="!profile[%%a]!"
            ) else (
                echo %RED%Ошибка: Профиль %%a не существует.%RESET% & timeout /t 2 /nobreak >nul & goto launch_selected_profiles
            )
        )
        echo. & echo %GREEN%Выбранные профили запущены...%RESET% & echo. & pause >nul & goto launch_profiles

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
                        start "" !brave_exe! --profile-directory="!profile_path!" !urls! --window-name="!profile_path!"
                    ) else (
                        echo %RED%Ошибка: Профиль %%i не существует.%RESET% & timeout /t 2 /nobreak >nul & goto launch_range_profiles
                    )
                )
            )
        )
        echo. & echo %GREEN%Выбранные профили запущены...%RESET% & echo. & pause >nul & goto launch_profiles

:close_profiles
    cls & echo.
    echo ================================
    echo ===  %YELLOW%[4] Закрытие профилей%RESET%   ===
    echo ================================
    echo 1 - Закрыть все профили
    echo 2 - Закрыть выбранные профили
    echo %DARKGRAY%0 - Вернуться в главное меню%RESET%
    echo ================================
    echo. & set /p "sub_choice=Выберите опцию (1-2): "

    if "%sub_choice%"=="" goto close_profiles
    if "!sub_choice!"=="1" goto close_all_profiles
    if "!sub_choice!"=="2" goto close_selected_profiles
    if "!sub_choice!"=="0" goto menu

    echo. & echo %RED%Неверный выбор, попробуйте снова...%RESET% & timeout /t 2 /nobreak >nul & goto close_profiles

    :close_all_profiles
        cls & echo. & echo В разработке. & timeout /t 2 /nobreak >nul & goto close_profiles
    :close_selected_profiles
        cls & echo. & echo В разработке. & timeout /t 2 /nobreak >nul & goto close_profiles

:exit
    echo. & echo %RED%Вы%YELLOW%х%GREEN%о%CYAN%д %BLUE%и%MAGENTA%з %YELLOW%п%GREEN%р%CYAN%о%BLUE%г%MAGENTA%р%RED%а%YELLOW%мм%CYAN%ы%RESET%... & timeout /t 2 /nobreak >nul & exit

:reload_profiles
    set i=0
    set max_profile_num=0
    for /f "delims=" %%A in ('powershell -Command "Get-ChildItem -Path '%user_data%' -Filter 'Profile *' | ForEach-Object { $_.Name -replace 'Profile ', '' } | Where-Object { $_ -match '^\d+$' } | Sort-Object {[int]$_} | Select-Object -Last 1"') do (
        set "max_profile_num=%%A"
    )

    for /f "delims=" %%A in ('powershell -Command "Get-ChildItem -Path '%user_data%' -Filter 'Profile *' | Sort-Object { [int]($_.Name -replace '\D') } | ForEach-Object { $_.Name }"') do (
        set /a i+=1
        set "profile[!i!]=%%A"
    )

    goto menu