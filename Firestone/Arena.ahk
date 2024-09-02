Class Arena {
    __New(Firestone) {
        this.Firestone := Firestone
    }

    Do() {
        DebugLog.Log("Арена", "`n")
        this.Firestone.Press "{K}", 2000
        rerol := true
    
        i := 0
        loop 20 {
            DebugLog.Log("== Попытка " i++ " ==")
            MouseMove 0, 0
            ;; Обновляем Арену
            if rerol
            {
                DebugLog.Log("=== Реролим противников ===")
                rerol := false
                ;if WaitForSearchPixel(834, 143, 891, 197, 0x0AA208, 1, 30000) {
                DebugLog.Log("Поиск кнопки рерола...")
                if !this.Firestone.Buttons.Green.WaitAndClick(834, 143, 891, 197, 30000)
                {
                    DebugLog.Log("Кнопка не найдена")
                    this.Firestone.Press "{ESC}"
                    return
                }
            }
    
            ; Проверяем флаг
            ru_color1 := PixelGetColor(1050, 236)
            ru_color2 := PixelGetColor(1050, 248)
            ru_color3 := PixelGetColor(1050, 263)
            if (ru_color1 == 0xF2F1F2 && ru_color2 == 0x0053B5 && ru_color3 == 0xD90029) {
                DebugLog.Log("Своих не бьём!")
                rerol := true
                continue
            }
    
            ;; Жмём кнопку битвы и подтверждения
            DebugLog.Log("Ищем кнопку битвы...")
            if this.Firestone.Buttons.Green.WaitAndClick(864, 588, 890, 636) {

                ;; Здесь нужно детектить, что попытки кончились
                DebugLog.Log("Поиск кнопки оплаты дополнительных попыток...")
                if this.Firestone.Buttons.Green.Wait(1061, 657, 1063, 703, 1000) {
                    DebugLog.Log("Кнопка найдена, арена на сегодня всё")
                    ; ой, попытки закончились
                    this.Firestone.Press "{ESC}"
                    this.Firestone.Settings.Set('daily_arena', true)
                    break
                }
                else
                {
                    DebugLog.Log("Кнопка не найдена, продолжаем")
                }
    
                this.Firestone.Click 956, 548 ; Кнопка старта боя

                ;; Ждём появление кнопки победы или поражения в конце битвы
                start_time := A_TickCount
                DebugLog.Log("Ожидаем окончания битвы...")
                if !this.Firestone.Buttons.Green.WaitAndClick(906, 724, 908, 789, 600000) {
                    DebugLog.Log('Не могу дождаться кнопки завершения Арены')
                    throw 'Не могу дождаться кнопки завершения Арены'
                }
                else
                {
                    DebugLog.Log("Бой длился " Round((A_TickCount - start_time) / 1000) " секунд" )
                }
            }
        }
    
        ; Закрываем окно арены
        this.Firestone.Press "{ESC}"
    }
}