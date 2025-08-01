Class Guard {
    slots := Map(
        1, [742, 935],
        2, [888, 935],
        3, [1032, 936],
        4, [1173, 932],
    )

    slots_icons := Map(
        1, [784, 863, 818, 895],
        2, [924, 863, 963, 895],
        3, [1070, 863, 1105, 895],
        4, [1215, 863, 1246, 895],
    )

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
        this.RarityUp()
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
        DebugLog.Log("== Эволюция ==")
        if !this.Firestone.Icons.Red.Check(1307, 78, 1343, 117)
            return

        this.Firestone.Click(1280, 147)

        if this.Firestone.Buttons.Green.CheckAndClick(1001, 676, 1115, 760) ; проверем кнопку и эволюционируем
            this.Firestone.TelegramSend('Эволюция стража!', true)

        ; После эволюциюю можно попробовать дождаться появление кнопки опыта по времени
        this.Firestone.Buttons.Green.WaitAndClick(1022, 703, 1053, 791, 10000) ; Кнопка бесплатного опыта
    }

    RarityUp() {
         DebugLog.Log("== Эволюция ==")
        if !this.Firestone.Icons.Red.Check(1624, 77, 1661, 112)
            return

        this.Firestone.Click(1593, 136)

        if this.Firestone.Buttons.Green.CheckAndClick(1326, 566, 1360, 604) ; проверем кнопку и эволюционируем
            this.Firestone.TelegramSend('Редкость стража повышена!', true)
    }

    HolyDamageUpgrade() {
        DebugLog.Log("== Святой урон ==")
        if this.Firestone.Settings.Get('auto_guard_holy_upgrade', 0) == 0
            return
        
        this.Firestone.Click(1437, 140) ; Вкладка святого урона
        
        For n, coords in this.slots
        {
            DebugLog.Log("Страж " n )
            this.Firestone.Click(coords[1], coords[2], 250)
            While this.Firestone.Buttons.Green.WaitAndClick(1764, 670, 1787, 750, 500)
            {
                MouseMove 0, 0
            }
        }
    }

    FindActiveGuard() {
        DebugLog.Log("Поиск активного стража...")
        ; Ищем кнопку "Активировать", если её нет, значит мы уже в активном страже
        if !this.Firestone.Buttons.Green.Check(527, 692, 537, 752)
            return

        For n, coords in this.slots
        {
            this.Firestone.Click(coords[1], coords[2], 500)
            ; Проверяем наличие кнопки "Активировать"
            if !this.Firestone.Buttons.Green.Check(527, 692, 537, 752) {
                ; Кнопки нет, значит страж активный
                Tools.Sleep(500)
                return
            }
        }
    }
}