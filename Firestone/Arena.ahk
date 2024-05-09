Class Arena {
    static Do() {
        Firestone.Press "{K}", 2000
        rerol := true
    
        loop 20 {
            MouseMove 0, 0
            ;; Обновляем Арену
            if rerol
            {
                rerol := false
                ;if WaitForSearchPixel(834, 143, 891, 197, 0x0AA208, 1, 30000) {
                if !Firestone.Buttons.Green.WaitAndClick(834, 143, 891, 197, 30000)
                {
                    Firestone.Press "{ESC}"
                    return
                }
            }
    
            ; Проверяем флаг
            ru_color1 := PixelGetColor(1050, 236)
            ru_color2 := PixelGetColor(1050, 248)
            ru_color3 := PixelGetColor(1050, 263)
            if (ru_color1 == 0xF2F1F2 && ru_color2 == 0x0053B5 && ru_color3 == 0xD90029) {
                rerol := true
                continue
            }
    
            ;; Жмём кнопку битвы и подтверждения
            if Firestone.Buttons.Green.WaitAndClick(864, 588, 890, 636) {
                ;; Здесь нужно детектить, что попытки кончились
                if Firestone.Buttons.Green.Wait(1061, 657, 1063, 703, 1000) {
                    ; ой, попытки закончились
                    Firestone.Press "{ESC}"
                    CurrentSettings.Set('arena_today', true)
                    Settings.Save()
                    break
                }
    
                Firestone.Click 956, 548 ; Кнопка старта боя

                ;; Ждём появление кнопки победы или поражения в конце битвы
                Firestone.Buttons.Green.WaitAndClick(906, 724, 908, 789, 600000)
            }
        }
    
        ; Закрываем окно арены
        Firestone.Press "{ESC}"
    }
}