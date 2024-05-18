Class Alchemy {
    static buttons := Map(
        1, [855, 722, 935, 748], ; Кровь
        2, [1205, 722, 1285, 748], ; Пыль
        3, [1555, 722, 1635, 748] ; Монетки
    )

    static Do(alchemy_settings) {
        DebugLog.Log("Алхимия", "`n")
        
        ;; Проверяем, висит ли красный значёк у здания.
        if !Firestone.Icons.Red.Check(570, 808, 614, 851)
            return
    
        Firestone.Click(480, 790)
    
        slot_ok := Map(
            1, false,
            2, false,
            3, false,
        )
    
        alchemy_up := [
            SubStr(alchemy_settings, 1, 1),
            SubStr(alchemy_settings, 2, 1),
            SubStr(alchemy_settings, 3, 1)
        ]
        
        ; Прокликивает в первый раз
        for a in [2, 3, 1] ; За пыль, монетки, кровь
        {
            if (alchemy_up[a] == "1")
            {
                DebugLog.Log("== Слот " a " ==")
                if this.Click(a)
                {
                    slot_ok.Set(a, true)
                    MouseMove 0, 0
                }
            }
        }
        
        ; Прокликиваем второй раз с большей задержкой из-за затупов интерфейса
        for a in [2, 3, 1] ; За пыль, монетки, кровь
        {
            if (alchemy_up[a] == "1") && slot_ok.Get(a) == true
            {
                DebugLog.Log("Слот " a)
                if this.Click(a, 2500)
                {
                    slot_ok.Set(a, true)
                    MouseMove 0, 0
                }
            }
        }
    
        Firestone.Esc()
    }

    static Click(slot, timeout := 500) {
        coords := this.buttons.Get(slot)
        DebugLog.Log("Поиск зелёной кнопки... (" coords[1] "x" coords[2] " - " coords[3] "x" coords[4] ")")

        ; Пробуем найти и нажать зелёную кнопку
        if !Firestone.Buttons.Green.WaitAndClick(coords[1], coords[2], coords[3], coords[4], timeout)
        {
            DebugLog.Log("Кнопка не найдена, ищем оранжевую кнопку...")
            if Firestone.Buttons.Orange.CheckAndClick(coords[1], coords[2], coords[3], coords[4], timeout)
            {
                return true
            }
            else
            {
                DebugLog.Log("Кнопка не найдена")
            }
        }
        else
        {
            return true
        }

        return false
    }
}