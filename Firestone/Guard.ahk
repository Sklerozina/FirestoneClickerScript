Class Guard {
    static Do() {
        DebugLog.Log("Страж", "`n")
        
        ; Проверяем, висит ли красный значок у здания.
        if !Firestone.Icons.Red.Check(738, 281, 783, 324)
            return
        
        Firestone.Click(625, 230) ; Здание стража

        this.CollectFreeXP()
        this.Evolution()
        
        Firestone.Esc()
    }

    static CollectFreeXP() {
        DebugLog.Log("== Сбор опыта ==")
        Firestone.Buttons.Green.CheckAndClick(1022, 703, 1053, 791) ; Кнопка бесплатного опыта
    }

    static Evolution() {
        if !Firestone.Icons.Red.Check(1506, 87, 1542, 123)
            return

        Firestone.Click(1442, 137)

        DebugLog.Log("== Эволюция ==")
        if Firestone.Buttons.Green.CheckAndClick(1001, 676, 1115, 760) ; проверем кнопку и эволюционируем
            Firestone.TelegramSend('Эволюция стража!', true)

        ; После эволюциюю можно попробовать дождаться появление кнопки опыта по времени
        Firestone.Buttons.Green.WaitAndClick(1022, 703, 1053, 791, 10000) ; Кнопка бесплатного опыта
    }
}