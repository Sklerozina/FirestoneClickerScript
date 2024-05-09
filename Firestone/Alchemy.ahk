Class Alchemy {
    static buttons := Map(
        1, [834, 721, 868, 783] ; Кровь
        2, [1186, 721, 1219, 783], ; Пыль
        3, [1535, 721, 1572, 783] ; Монетки
    )

    static Do(alchemy_settings) {
        ;; Проверяем, висит ли красный значёк у здания.
        if !Firestone.Icons.Red.Check(570, 808, 614, 851)
            return
    
        Firestone.Click(480, 790)
    
        slot_ok := Map(
            1, false
            2, false
            3, false
        )
    
        alchemy := [
            SubStr(alchemy_settings, 1, 1),
            SubStr(alchemy_settings, 2, 1),
            SubStr(alchemy_settings, 3, 1)
        ]
        
        ; Прокликивает в первый раз
        for a in [2, 3, 1] ; За пыль, монетки, кровь
        {
            if (alchemy[a] == "1")
            {
                if this.Click(a)
                    slot_ok.Set(a ,true)
            }
        }
        
        ; Прокликиваем второй раз с большей задержкой из-за затупов интерфейса
        for a in [2, 3, 1] ; За пыль, монетки, кровь
        {
            if (alchemy[a] == "1") && slot_ok.Get(a) == true
            {
                if this.Click(a, 2500)
                    slot_ok[a].Set(true)
            }
        }
    
        Firestone.Esc()
    }

    static Click(slot, timeout := 500) {
        coords := this.buttons.Get(slot)

        ; Пробуем найти и нажать зелёную кнопку
        if !Firestone.Buttons.Green.WaitAndClick(coords[1], coords[2], coords[3], coords[4], timeout)
        {
            if Firestone.Buttons.Orange.CheckAndClick(coords[1], coords[2], coords[3], coords[4], timeout)
            {
                return true
            }
        }
        else
        {
            return true
        }

        return false
    }
}