Class Merchant {
    __New(Firestone) {
        this.Firestone := Firestone
    }

    sell_scroll_buttons := [
        [930, 576, 950, 617],
        [1254, 576, 1277, 617],
        [1578, 576, 1604, 617],
    ]

    slots := Map(
        ; Страница 1
        1, [930, 576, 950, 617], ; Свиток скорости
        2, [1254, 576, 1277, 617], ; Свиток урона
        3, [1578, 576, 1604, 617], ; Свиток здоровья
        4, [1026, 851, 1078, 936], ; Дар Мидаса
        5, [1347, 895, 1399, 934], ; Мешочек золота
        6, [1671, 854, 1724, 934], ; Ведро золота
        ; Страница 2
        7, [1028, 271, 1073, 315], ; Ящик золота
        8, [1358, 272, 1402, 316], ; Бочка золота
        9, [1684, 273, 1727, 313], ; Барабаны войны
        10, [1034, 595, 1077, 639], ; Броня дракона
        11, [1350, 594, 1403, 636], ; Руна стража
        12, [1682, 593, 1728, 634], ; Тотем страданий
        13, [1039, 915, 1077, 956], ; Тотем уничтожения
    )

    Do() {
        ; Если автоматический торговец выключен
        if this.Firestone.Settings.Get('auto_merchant') == 0
            return

        DebugLog.Log("Торговец", "`n")

        ; Если дейлик уже сделан, выходим
        if this.Firestone.Settings.Get('daily_merchant') == 1
            return

        this.Firestone.Click(1462, 610) ; Здание торговца
        this.Firestone.Click(1115, 154) ; Вкладка продажим за монеты

        DebugLog.Log("Кликаем множитель, пока не будет x10")
        loop 10 ; Бескончный цикл не делаю, чтобы случайноне залочить скрипт
        {
            if this.Firestone.Buttons.White.CheckPixels(1732, 218, 1732, 233, 1736, 226, 1742, 219, 1740, 232, 1754, 218, 1753, 233, 1765, 226, 1770, 217, 1772, 233, 1777, 223)
            {
                DebugLog.Log("x10 найдено!")
                break
            }

            this.Firestone.Click(1800, 223)
        }

        MouseMove(1111, 344)
        Tools.Sleep(250)
        this.Firestone.ScrollUp(32)

        buttons := [
            this.slots.Get(1),
            this.slots.Get(2),
            this.slots.Get(3)
        ]

        while buttons.Length > 0 ; Перебираем кнопки, если вдруг уже всё продано
        {
            sell := buttons.RemoveAt(Random(1, buttons.Length)) ; Выбираем рандомный свиток для продажи

            if this.Firestone.Buttons.Green.WaitAndClick(sell[1], sell[2], sell[3], sell[4], 2000)
            {
                this.Firestone.Settings.Set('daily_merchant', true) ; Сегодня можно сюда больше не заходить
                break
            }
        }

        sell_items := this.Firestone.Settings.Get('auto_merchant_sell_items', 0)
        if (sell_items != 0 AND sell_items != '')
        {
            sell_items := Sort(sell_items, 'N U D,')
            sell_items_arr := StrSplit(sell_items, ',', ' ')
            down := false

            for slot in sell_items_arr
            {
                slot := Integer(slot)

                if slot > 6 && down == false
                {
                    down := true
                    MouseMove(1111, 344)
                    this.Firestone.ScrollDown(32)
                }

                if this.slots.Has(slot)
                {
                    sell := this.slots.Get(slot)

                    Loop 10
                    {
                        MouseMove(0, 0)
                        if !this.Firestone.Buttons.Green.WaitAndClick(sell[1], sell[2], sell[3], sell[4], 2000)
                            break
                    }
                }
            }
        }

        this.Firestone.Esc()
    }
}