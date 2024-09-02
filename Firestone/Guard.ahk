Class Guard {
    __New(Firestone) {
        this.Firestone := Firestone
    }

    Do() {
        DebugLog.Log("Страж", "`n")
        
        ; Проверяем, висит ли красный значок у здания.
        if !this.Firestone.Icons.Red.Check(738, 281, 783, 324)
            return
        
        this.Firestone.Click(625, 230) ; Здание стража

        this.CollectFreeXP()
        this.Evolution()
        
        this.Firestone.Esc()
    }

    CollectFreeXP() {
        DebugLog.Log("== Сбор опыта ==")
        if this.Firestone.Buttons.Green.CheckAndClick(1022, 703, 1053, 791) ; Кнопка бесплатного опыта
        {
            ; Добавить настройку в конфиг
            if this.Firestone.Settings.Get('auto_enlightenment', 0) > 0
                this.Firestone.Buttons.Green.CheckAndClick(1415, 700, 1471, 792,,,500, this.Firestone.Settings.Get('auto_enlightenment', 0)) ; Клик на озарение, если был сбор бесплатного опыта
        }
    }

    Evolution() {
        if !this.Firestone.Icons.Red.Check(1506, 87, 1542, 123)
            return

        this.Firestone.Click(1442, 137)

        DebugLog.Log("== Эволюция ==")
        if this.Firestone.Buttons.Green.CheckAndClick(1001, 676, 1115, 760) ; проверем кнопку и эволюционируем
            this.Firestone.TelegramSend('Эволюция стража!', true)

        ; После эволюциюю можно попробовать дождаться появление кнопки опыта по времени
        this.Firestone.Buttons.Green.WaitAndClick(1022, 703, 1053, 791, 10000) ; Кнопка бесплатного опыта
    }
}