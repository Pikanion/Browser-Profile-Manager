<!-- ### **[RU](#Tittle_RU) / [EN](#Tittle_EN)** -->
###### Contact me: **[Telegram](https://t.me/pikanion)** - if you have ideas or suggestions

# <a id="Tittle_RU">Browser Profiles Manager (RU)</a>
## Описание
Скрипт для работы с профилями в браузере для Windows. 

Текущий функционал:
- Просмотр количества профилей в Chrome/Brave.
- Создание профилей. 
- Запуск профилей:
    - Можно открывать выборочно
    - Можно открывать диапазонами
    - Можно задавать ссылки на сайты, которые будут открыты при запуске профилей

## Работа скрипта

Скрипт не зависим от местонахождения, работает в любой папке. Если Chrome/Brave был установлен в пользовательские директории, тогда нужно указать их в строках 7 и 8. После "=" добавить путь в кавычках.
``` Batchfile
set "CHROME_PATH="ТУТ ПУТЬ""
set "USER_DATA_PATH="ТУТ ПУТЬ""
```
> Чтобы изменить строки, нужно открыть .bat файл любым текстовым редактором.

## Roadmap
- [x] Запуск ссылок
- [x] Функция создания новых профилей
- [ ] Закрытие профилей (выборочно или массово)
- [ ] Массовый запуск с определенными: прокси, юзерагентом и отключенным WebRTC
- [ ] Создание шаблонов запуска профилей
- [ ] Скачивание расширений на выбранные профиля (???)
- [ ] Поддержка английского языка
