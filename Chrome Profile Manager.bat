@echo off
chcp 65001 >nul
title Chrome Profiles Autostart
setlocal enabledelayedexpansion

:: Пути
:: chrome_exe - БЕЗ КАВЫЧЕК
set chrome_exe=C:\Program Files\Google\Chrome\Application\chrome.exe
:: user_data - С КАВЫЧКАМИ
set user_data="C:\Users\$username$\AppData\Local\Google\Chrome\User Data"

:: Проверка существования Chrome
if not exist "%chrome_exe%" (
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

:: Получаем список профилей
set i=0
for /f "delims=" %%A in ('powershell -Command "Get-ChildItem -Path '%user_data%' -Filter 'Profile *' | Sort-Object { [int]($_.Name -replace '\D') } | ForEach-Object { $_.Name }"') do (
    set /a i+=1
    set "profile[!i!]=%%A"
)

:: Проверка наличия профилей
if !i!==0 (
    echo Ошибка: Профили не найдены
    pause
    exit /b 1
)

:: Возврат к стандартному интерфейсу CMD
cmd.exe /c exit
cls

:menu
    echo.
    echo ==============================
    echo ===      Главное меню      ===
    echo ==============================
    echo 1 - Посмотреть список профилей
    echo 2 - Запуск профилей
    echo 3 - Выход из программы
    echo ==============================
    set /p "choice=Выберите опцию (1-3): "

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
    echo.
    echo ================================
    echo ===   2 - Запуск профилей    ===
    echo ================================
    echo 1 - Запустить профиля выборочно
    echo 2 - Запустить диапазон профилей
    echo 3 - Вернуться в главное меню
    echo ================================

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
        set /p "urls=или Введите ссылки через пробел (Enter - пропустить): "
        echo.
        echo Запуск выбранных профилей...

        for %%a in (!profiles!) do (
            echo Проверка профиля: %%a
            if %%a geq 1 if %%a leq !i! (
                set "profile_path=!profile[%%a]!"
                echo Запуск профиля: !profile_path!
                timeout /t 1 /nobreak >nul
                start "" "%chrome_exe%" --profile-directory="!profile_path!" !urls!
            ) else (
                echo Ошибка: Профиль %%a не существует
            )
        )
        echo.
        pause
        cls
        goto menu
    ) else if "!sub_choice!"=="2" (
        cls
        echo Выберите диапазон профилей для запуска
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
                echo Запуск профилей с !start! по !end!...
                for /L %%i in (!start!,1,!end!) do (
                    if %%i geq 1 if %%i leq !i! (
                        set "profile_path=!profile[%%i]!"
                        echo Запуск профиля: !profile_path!
                        timeout /t 1 /nobreak >nul
                        start "" "%chrome_exe%" --profile-directory="!profile_path!" !urls!
                    ) else (
                        echo Ошибка: Профиль %%i не существует
                    )
                )
            )
        )
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
) else if "%choice%"=="3" (
    echo.
    echo Выход из программы...
    timeout /t 2 /nobreak >nul
    exit /b 0
) else (
    echo.
    echo Неверный выбор, пожалуйста, попробуйте снова.
    pause
    cls
    goto menu
)
