Class Oracle {
    static Do() {
        ; Проверяем, висит ли красный значёк у здания.
        if !Firestone.Icons.Red.Check(1108, 931, 1152, 970)
            return
    
        Firestone.Click(1026, 911, 500)
    
        this.CollectdailyReward()
    
        this.Rituals()
        
        Firestone.Esc()
    }

    static CollectdailyReward() {
        ; Забрать ежедневный бесплатный подарок оракула
        if Firestone.Icons.Red.Check(860, 660, 903, 695) {
            Firestone.Click(824, 738, 500)

            if PixelGetColor(467, 815) == 0x5B5EAA
            {
                Firestone.Click(641, 739, 500)
            }

            Firestone.Esc()
        }
    }

    static Rituals() {
        ;; Проверяем, висит ли красный значёк у ритуалов.
        if !Firestone.Icons.Red.Check(860, 317, 903, 356) {
            Firestone.Esc()
            return
        }
    
        Firestone.Click 825, 393, 500
    
        ; Проверяем зелёные кнопки и кликаем
        rituals := [
            [1050, 440, 1100, 510] ; Гармония
            [1460, 440, 1520, 510] ; Безмятежность
            [1050, 790, 1100, 850] ; Концентрация
            [1460, 790, 1520, 850] ; Послушание
        ]
        clicks := 0

        loop 2 {
            for ritual in rituals {
                if Firestone.Buttons.Green.CheckAndClick(ritual[1], ritual[2], ritual[3], ritual[4])
                    clicks += 1

                if clicks >= 2 ; Если 2 клика сделали, то можно заврешать циклы.
                    break 2
            }
        }
    }
}
