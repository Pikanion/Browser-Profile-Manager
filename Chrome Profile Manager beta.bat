@echo off
chcp 65001 >nul
title Chrome Profiles Manager
setlocal enabledelayedexpansion

:: Пути
set chrome_exe="C:\Program Files\Google\Chrome\Application\chrome.exe"
set user_data="C:\Users\schku\AppData\Local\Google\Chrome\User Data"

:: Проверка существования Chrome
if not exist %chrome_exe% (
    echo Ошибка: Chrome не найден по указанному пути
    echo Путь: %chrome_exe%
    pause
    exit /b 1
)

:: Проверка существования папки с профилями
if not exist %user_data% (
    echo Ошибка: Папка с профилями не найдена
    echo Путь: %user_data%
    pause
    exit /b 1
)

:: Загрузка списка профилей
call :reload_profiles

:menu
    echo.
    echo ==============================
    echo ===     Главное меню       ===
    echo ==============================
    echo 1 - Посмотреть список профилей
    echo 2 - Создание профилей
    echo 3 - Запуск профилей
    echo 4 - Выход из программы
    echo ==============================
    echo.
    set /p "choice=Выберите опцию (1-4): "

if "%choice%"=="1" (
    cls
    echo Список профилей:
    for /L %%n in (1,1,!i!) do (
        echo %%n - !profile[%%n]!
    )
    echo.
    echo Всего профилей: !i!
    echo.
    pause
    cls
    goto menu
) else if "%choice%"=="2" (
    cls
    echo Создание новых профилей
    set /p "num_profiles=Сколько профилей нужно создать: "
    
    :: Создаем новые профили
    for /L %%n in (1,1,!num_profiles!) do (
        :: Находим следующий доступный номер профиля
        set /a next_profile=!max_profile_num!+%%n
        set "new_profile_name=Profile !next_profile!"
        echo.
        echo Создание профиля №!next_profile!
        start "" %chrome_exe% --profile-directory="!new_profile_name!" --no-startup-window
        timeout /t 2 /nobreak >nul

        :: Закрытие профиля (с проверкой наличия процесса)
        powershell -Command "$processes = Get-Process chrome -ErrorAction SilentlyContinue; if ($processes) { $processes | Where-Object {$_.CommandLine -like '*--profile-directory=\"!new_profile_name!\"*'} | ForEach-Object { $_.CloseMainWindow() } }"
        timeout /t 1 /nobreak >nul
        echo Профиль №!next_profile! создан
    )
    echo.
    echo Профили успешно созданы.
    echo.
    echo Выход в главное меню...
    timeout /t 2 /nobreak >nul
    cls
    :: Автоматически обновляем список профилей после создания
    call :reload_profiles
    goto menu
) else if "%choice%"=="3" (
    cls
    echo.
    echo ================================
    echo ===   [3] Запуск профилей    ===
    echo ================================
    echo 1 - Запустить профиля выборочно
    echo 2 - Запустить диапазон профилей
    echo 3 - Вернуться в главное меню
    echo ================================
    echo.
    set /p "sub_choice=Выберите опцию (1-3): "

    if "!sub_choice!"=="1" (
        cls
        echo Выберите профили для запуска
        echo.
        echo Список профилей:
        echo.
        for /L %%n in (1,1,!i!) do (
            echo %%n - !profile[%%n]!
        )
        echo.
        set /p "profiles=Введите номера профилей через пробел (Например, 1 5 10): "
        echo.
        set /p "urls=Введите ссылки через пробел (Enter - пропустить): "
        echo.
        cls
        echo Запуск выбранных профилей...
        echo.
        
        for %%a in (!profiles!) do (
            if %%a geq 1 if %%a leq !i! (
                set "profile_path=!profile[%%a]!"
                echo Запуск профиля: !profile_path!
                timeout /t 2 /nobreak >nul
                start "" %chrome_exe% --profile-directory="!profile_path!" !urls!
            ) else (
                echo Ошибка: Профиль %%a не существует
            )
        )
        echo.
        echo Запуск профилей выполнен.
        echo.
        pause
        cls
        goto menu

    ) else if "!sub_choice!"=="2" (
        cls
        echo Выберите диапазон профилей для запуска.
        echo.
        echo Список профилей:
        echo.
        for /L %%n in (1,1,!i!) do (
            echo %%n - !profile[%%n]!
        )
        echo.
        set /p "ranges=Введите диапазоны профилей через запятую (Например, 1-3,5-7): "
        echo.
        set /p "urls=Введите ссылки через пробел (Enter - пропустить): "
        
        :: Обработка каждого диапазона
        for %%r in (!ranges!) do (
            set "range=%%r"
            for /f "tokens=1,2 delims=-" %%a in ("!range!") do (
                set "start=%%a"
                set "end=%%b"
                
                echo.
                cls
                echo Запуск профилей с !start! по !end!...
                echo.
                timeout /t 1 /nobreak >nul
                for /L %%i in (!start!,1,!end!) do (
                    if %%i geq 1 if %%i leq !i! (
                        set "profile_path=!profile[%%i]!"
                        echo Запуск профиля: !profile_path!
                        timeout /t 2 /nobreak >nul
                        start "" %chrome_exe% --profile-directory="!profile_path!" !urls!
                    ) else (
                        echo Ошибка: Профиль %%i не существует
                    )
                )
            )
        )
        echo.
        echo Запуск профилей выполнен.
        echo.
        pause
        cls
        goto menu

    ) else if "!sub_choice!"=="3" (
        cls
        goto menu
    ) else (
        echo.
        echo Неверный выбор, пожалуйста, попробуйте снова.
        pause
        cls
        goto menu
    )
) else if "%choice%"=="4" (
    echo.
    echo Выход из программы...
    timeout /t 1 /nobreak >nul
    exit
) else (
    echo.
    echo Неверный выбор, пожалуйста, попробуйте снова.
    pause
    cls
    goto menu
)

:reload_profiles
::echo Обновляем список профилей...
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
::echo Список профилей обновлен.
cls
goto menu
