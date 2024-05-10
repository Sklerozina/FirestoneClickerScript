Кликер для игры [Firestone](https://store.steampowered.com/app/1013320/Firestone/), убирающий некоторую рутину и дающий возможность не сидеть у компа 24/7.

Игра должна быть в разрешении 1920x1018, без рамок, например с помощью [Borderless Gaming](https://github.com/Codeusa/Borderless-Gaming/releases) приложения.
Любое движение мышью иили нажатие клавиатуры прерывает выполнения скрипта на время.
Запускать нужно FireStone.ahk в основной директории.

The game must be in 1920x1018 resolution, borderless windows, e.g. using [Borderless Gaming](https://github.com/Codeusa/Borderless-Gaming/releases) app.
Any mouse movement or keyboard press interrupts script execution for a while.
Run FireStone.ahk from main directory.

Скрипт выполняет свою работу каждые 5 минут.

## Умеет
* Делать экспедиции
* Забирать инструменты у механика
* Забирать лут с карты военной кампании
* Прокачивать стража (бесплатная прокачка каждые несколько часов)
* Забирать и ставить алхимию (все 3 или на выбор)
* Завершать и ставить новые мисси на карте в порядке приоритета (Подарки, 20 минут, 3-6 часов, 40 минут, 1 час)
* Делать ежедневные задание военной кампании
* Делать арену (опционально)
* Открывать сумки (опционально)
* Прокачивать усиления героев в приоритете выставленным в конфиге
* Режим престижа, прокачивает всех героев каждую 1 минуту
* Забирать ежедневные подкарки в магазине и награды дня
* Делать ритуалы Оракула и забирать ежедневный подарок
* Обменивать пиво на жетоны
* Забирать бесплатные кирки
* Забирать награды в профиле за ежедневную активность и еженедельную
* Ставить исследования Firestone в библиотеке (опционально и пока не очень по умному)
* Отправлять в Telegram уведомления, в случае, если не получается попать на главный экран игры.

## Настройк в settings.ini
settings.ini создаётся автоматически

alchemy=111 (какие слоты алхимии исследовать, 111 - все слоты, 100 - только за кровь, 101 - за кровь и монеты, 010 - за пыль)
arena_today=1 (чисто технический параметр. 1 - означает, что сегодня все попытки на арене были потрачены, 0 - арена ещё не делалась или остались попытки)
auto_arena=1 (1 - делать арену, 0 - не делать арену, по умолчанию 0)
auto_complete_quests=1 (1 - забирать награды за ежедненвые/еженедельные задания в профиле, 0 - не трогать, по умолчанию 0)
auto_research=1 (1 - делать исследования Firestone в библиотеке, 0 - не делать, по умолчанию 0)
lvlup_priority=17 (Какие слоты прокачивать в усилениях (клавиша U), от 1 до 7 (сверху-вниз), по умолчанию - 17, если нужно прокачвать например общие усиления, стража и предпоследнего героя, то значение будет 126, 1234567 - прокачивать всех, 134567 - прокачивать всех, кроме стража)
open_boxes=1 (1 - Проверять и открывать коробки автоматически, 0 - не открывать, по умолчанию 0)
