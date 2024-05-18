Class Guard {
    static Do() {
        DebugLog.Log("Страж", "`n")
        
        ; Проверяем, висит ли красный значок у здания.
        if !Firestone.Icons.Red.Check(738, 281, 783, 324)
            return
        
        Firestone.Click(625, 230) ; Здание стража

        this.CollectFreeXP()
        
        Firestone.Esc()
    }

    static CollectFreeXP() {
        DebugLog.Log("== Сбор опыта ==")
        Firestone.Buttons.Green.CheckAndClick(1022, 703, 1053, 791) ; Кнопка бесплатного опыта
    }
}