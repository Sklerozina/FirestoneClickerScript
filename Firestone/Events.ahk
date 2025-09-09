Class Events {
    __New(Firestone) {
        this.Firestone := Firestone
    }

    last_run := Map()
    corrds_red_icons := [
        [1409, 262, 1444, 304],
        [1410, 436, 1446, 478]
    ]
    decorated_heroes_coords := [
        [228, 550, 248, 604], ; 1
        [654, 550, 670, 604], ; 2
        [1073, 550, 1091, 604], ; 3
        [1492, 550, 1516, 604], ; 4
        [228, 862, 248, 919], ; 5
        [654, 862, 670, 919], ; 6
        [1070, 862, 1093, 919], ; 7
        [1492, 862, 1516, 919], ; 8
    ]

    Do() {
        DebugLog.Log("События", "`n")

        ; Проверяем красную иконку у событий, если не горит, то и не трогаем.
        ; Пока отключаю, иконка часто багует, лучше заходить периодически и проверять
        ; if !this.Firestone.Icons.Red.Check(1712, 148, 1741, 179)
        ;     return
        if (!this.last_run.Has(this.Firestone.Window.hwid) || DateDiff(A_Now, this.last_run.Get(this.Firestone.Window.hwid, A_Now), 'Minutes') > 30)
        {
            this.last_run.Set(this.Firestone.Window.hwid, A_Now)

            ; Эту можно удалить, когда эпики обновят до 9.0.2
            this.Firestone.Click(1684, 207) ; <— удалить

            if PixelGetColor(1478, 201) != 0xCECBEC ; <— удалить
                this.Firestone.Click(1239, 918)
            
            ; Проверяем цвет рамки и убеждаемся, что окно открылось
            if PixelGetColor(1478, 201) != 0xCECBEC
                return ; Пока просто выходим и пробуем в следующий раз

            for coord in this.corrds_red_icons
            {
                DebugLog.Log("Проверяю координаты красной иконки " coord[1] "x" coord[2] " - " coord[3] "x" coord[4])
                if (this.Firestone.Icons.Red.CheckAndClick(coord[1], coord[2], coord[3], coord[4]))
                {
                    ; Проверяем, что это за событие
                    if this.Firestone.Icons.Red.CheckAndClick(1288, 8, 1324, 44, 1125, 43, 2000) ; Найдена красная иконка "испытания", похоже на стандартное событие
                    {
                        DebugLog.Log("Обнаружено стандартное событие")
                        ; Ограниченный 3 этапами цикл
                        loop 3 {
                            ; Если ни одной кнопки не найдено, прерываем цикл раньше.
                            if !this.Firestone.Buttons.Green.FindAndClick(1369, 326, 1371, 880, 1000)
                                break
                        }

                        this.Firestone.Esc()
                    } else if PixelGetColor(677, 59) == 0x4F419C { ; Цвет фона у названия события
                        DebugLog.Log("Обнаружено событие 'Прославленные герои'")
                        this.DecoratedHeroes()
                    } else if PixelGetColor(1765, 485) == 0xDE9D29 { ; Годовщина
                        DebugLog.Log("Обнаружено событие 'Годовщина'")
                        this.Anniversary()
                    } else {
                        ; Неизвестное событие, просто выходим                        
                        this.Firestone.Esc()
                    }
                }
            }

            this.Firestone.Esc()
        }
        else
            DebugLog.Log("Время ещё не пришло, осталось ждать " Round((this.last_run.Get(this.Firestone.Window.hwid, 0) + 1800000 - A_TickCount) / 1000) " секунд")
    }

    Anniversary() {
        this.Firestone.Buttons.Green.FindAndClick(1121, 813, 1147, 866) ; Забрать ежедневную награду
        
        if this.Firestone.Icons.Red.CheckAndClick(663, 118, 690, 149, 548, 168)
        {
            loop 3
            {
                if A_Index == 1 {
                    MouseMove(854, 457)
                    this.Firestone.ScrollUp(100)
                } else {
                    MouseMove(854, 457)
                    this.Firestone.ScrollDown(52)
                }

                loop 5
                {
                    if !this.Firestone.Buttons.Green.FindAndClick(228, 831, 1779, 831)
                        break
                }
            }
        }

        this.Firestone.Esc()
    }

    ; Decorated heroes / Прославленные герои
    DecoratedHeroes() {
        ; Проверяем, горит ли иконка у испытаний
        if !this.Firestone.Icons.Red.Check(526, 119, 553, 149)
        {
            this.Firestone.Esc()
            return
        }

        loop 3
        {
            for coord in this.decorated_heroes_coords
            {
                if this.Firestone.Buttons.Green.CheckAndClick(coord[1], coord[2], coord[3], coord[4], 200)
                {
                    MouseMove 0, 0 ; если был клик, убираем мышку
                    Tools.Sleep(500) ; Небольшая пауза, чтобы кнопка потухла
                }
            }
        }

        this.Firestone.Esc()     
    }
}