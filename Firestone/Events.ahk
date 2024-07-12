Class Events {
    static last_run := Map()
    static corrds_red_icons := [
        [1409, 262, 1444, 304],
        [1410, 436, 1446, 478]
    ]

    static Do() {
        DebugLog.Log("События", "`n")
        if (!this.last_run.Has(Firestone.Window.hwid) || this.last_run.Get(Firestone.Window.hwid, 0) < A_TickCount - 1800000)
        {
            this.last_run.Set(Firestone.Window.hwid, A_TickCount)
            ; Проверяем красную иконку у событий, если не горит, то и не трогаем.
            if !Firestone.Icons.Red.Check(1712, 148, 1741, 179)
                return

            Firestone.Click(1684, 207)

            ; Проверяем цвет рамки и убеждаемся, что окно открылось
            if PixelGetColor(1478, 201) != 0xCECBEC
                return ; Пока просто выходим и пробуем в следующий раз

            for coord in this.corrds_red_icons
            {
                DebugLog.Log("Проверяю координаты красной иконки " coord[1] "x" coord[2] " - " coord[3] "x" coord[4])
                if (Firestone.Icons.Red.CheckAndClick(coord[1], coord[2], coord[3], coord[4]))
                {
                    ; Проверяем, что это за событие
                    if Firestone.Icons.Red.CheckAndClick(1288, 8, 1324, 44, 1125, 43, 2000) ; Найдена красная иконка "испытания", похоже на стандартное событие
                    {
                        DebugLog.Log("Обнаружено стандартное событие")
                        ; Ограниченный 3 этапами цикл
                        loop 3 {
                            ; Если ни одной кнопки не найдено, прерываем цикл раньше.
                            if !Firestone.Buttons.Green.FindAndClick(1369, 326, 1371, 880, 1000)
                                break
                        }

                        Firestone.Esc()
                    }
                    
                    ; Decorated heroes?
                    if (PixelGetColor(677, 59) == 0x4F419C){ ; Цвет фона у названия события
                        DebugLog.Log("Обнаружено событие 'Прославленные герои'")
                        this.DecoratedHeroes()
                    }

                }
            }

            Firestone.Esc()
        }
        else
            DebugLog.Log("Время ещё не пришло, осталось ждать " Round(A_TickCount - this.last_run.Get(Firestone.Window.hwid, 0) / 1000))
    }

    ; Decorated heroes
    static DecoratedHeroes() {
        ; Проверяем, горит ли иконка у испытаний
        if !Firestone.Icons.Red.Check(526, 119, 553, 149)
        {
            Firestone.Esc()
            return
        }

        loop 3
        {
            Firestone.Buttons.Green.CheckAndClick(228, 550, 248, 604) ; 1
            ;Firestone.Buttons.Green.CheckAndClick() ; 2
            Firestone.Buttons.Green.CheckAndClick(1073, 550, 1091, 604) ; 3
            Firestone.Buttons.Green.CheckAndClick(1492, 550, 1516, 604) ; 4
            Firestone.Buttons.Green.CheckAndClick(228, 862, 248, 919) ; 5 примерно
            ;Firestone.Buttons.Green.CheckAndClick() ; 6
            Firestone.Buttons.Green.CheckAndClick(1070, 862, 1093, 919) ; 7
            Firestone.Buttons.Green.CheckAndClick(1492, 862, 1516, 919) ; 8 примерно
        }

        Firestone.Esc()
        
    }
}