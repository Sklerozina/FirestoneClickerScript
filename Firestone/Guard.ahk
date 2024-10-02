Class Guard {
    __New(Firestone) {
        this.Firestone := Firestone
    }

    Do(force := false) {
        DebugLog.Log("Страж", "`n")
        
        ; Проверяем, висит ли красный значок у здания.
        if !this.Firestone.Icons.Red.Check(738, 281, 783, 324) && !force
            return
        
        this.Firestone.Click(625, 230) ; Здание стража

        this.FindActiveGuard()

        this.CollectFreeXP()
        this.Evolution()
        this.HolyDamageUpgrade()
        
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

    HolyDamageUpgrade() {
        this.Firestone.Click(1437, 140) ; Вкладка святого урона
        this.Firestone.Press("{Left}", 500, 5) ; Выбираем самого левого стража

        Loop 5
        {
            if this.Firestone.Icons.Red.Check(1466, 79, 1504, 115) {
                While this.Firestone.Buttons.Green.WaitAndClick(1569, 707, 1602, 753, 1000)
                {
                    MouseMove 0, 0
                    Tools.Sleep 250
                }
            }

            this.Firestone.Press("{Right}", 500)
        }
    }

    FindActiveGuard() {
        ; Ищем кнопку "Активировать", если её нет, значит мы уже в активном страже
        if !this.Firestone.Buttons.Green.Check(527, 692, 537, 752)
            return

        this.Firestone.Press("{Left}", 500, 5) ; Выбираем самого левого стража

        loop 5
        {
            ; Проверяем наличие кнопки "Активировать"
            if !this.Firestone.Buttons.Green.Check(527, 692, 537, 752) {
                ; Кнопки нет, значит страж активный
                Tools.Sleep(500)
                return
            }

            ; выбираем следующего
            this.Firestone.Press("{Right}", 500)
        }
    }
}