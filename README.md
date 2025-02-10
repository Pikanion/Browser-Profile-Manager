<!-- ### **[RU](#Tittle_RU) / [EN](#Tittle_EN)** -->
###### Contact me: **[Telegram](https://t.me/pikanion)** - if you have ideas or suggestions

# <a id="Tittle_RU">Chrome-Profile-Manager (RU)</a>
## Описание
Скрипт для работы с гугл профилями для Windows. 

Текущий функционал:
- Просмотр количества профилей в Google Chrome.
- Создание профилей. 
- Запуск профилей.   

## Запуск скрипта

Перед запуском скрипта нужно будет поменять две переменные в нем:
1. Проверить и/или заменить путь до .exe файла Google Chrome в строке 8.
``` Batchfile
set chrome_exe="C:\Program Files\Google\Chrome\Application\chrome.exe"
```
2. Заменить юзернейм и/или путь в строке 10.
```Batchfile
set user_data="C:\Users\$username$\AppData\Local\Google\Chrome\User Data"
```

## Roadmap
- [x] Запуск ссылок
- [x] Функция создания новых профилей
- [ ] Закрытие профилей (выборочно или массово)
- [ ] Массовый запуск с определенными: прокси, юзерагентом и отключенным WebRTC
- [ ] Просмотр списков прокси и юзерагентов внутри скрипта
- [ ] Создание шаблонов запуска профилей
- [ ] Скачивание расширений на выбранные профиля (???)
- [ ] Поддержка английского языка
