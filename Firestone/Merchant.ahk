Class Merchant {
    static sell_scroll_buttons := [
        [930, 576, 950, 617],
        [1254, 576, 1277, 617],
        [1578, 576, 1604, 617],
    ]

    static Do() {
        ; Если автоматический торговец выключен
        if Firestone.CurrentSettings.Get('auto_merchant') == 0
            return

        DebugLog.Log("Торговец", "`n")

        ; Если дейлик уже сделан, выходим
        if Firestone.CurrentSettings.Get('daily_merchant') == 1
            return

        Firestone.Click(1462, 610) ; Здание торговца
        Firestone.Click(1115, 154) ; Вкладка продажим за монеты

        DebugLog.Log("Кликаем множитель, пока не будет x10")
        loop 10 ; Бескончный цикл не делаю, чтобы случайноне залочить скрипт
        {
            if Firestone.Buttons.White.CheckPixels(1732, 218, 1732, 233, 1736, 226, 1742, 219, 1740, 232, 1754, 218, 1753, 233, 1765, 226, 1770, 217, 1772, 233, 1777, 223)
            {
                DebugLog.Log("x10 найдено!")
                break
            }

            Firestone.Click(1800, 223)
        }

        MouseMove(1111, 344)
        Tools.Sleep(250)
        Firestone.ScrollUp(32)

        buttons := this.sell_scroll_buttons.Clone()

        while buttons.Length > 0 ; Перебираем кнопки, если вдруг уже всё продано
        {
            sell := buttons.RemoveAt(Random(1, buttons.Length)) ; Выбираем рандомный свиток для продажи

            if Firestone.Buttons.Green.WaitAndClick(sell[1], sell[2], sell[3], sell[4], 2000)
            {
                Firestone.CurrentSettings.Set('daily_merchant', true) ; Сегодня можно сюда больше не заходить
                break
            }
        }

        Firestone.Esc()
    }
}