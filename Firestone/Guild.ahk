Class Guild {
    __New(Firestone) {
        this.Firestone := Firestone
    }

    Do() {
        DebugLog.Log("Гильдия", "`n")
        this.Firestone.Click(1482, 127) ; Клик на здание гильдии
        
        this.CollectPicks() ; Забрать заодно кирки
        this.Expeditions()
        this.Crystal()

        this.Firestone.Esc() ; Выйти в город
    }

    CollectPicks() {
        DebugLog.Log("== Сбор кирок ==")
        if this.Firestone.Icons.Red.Check(739, 284, 780, 324)
        {
            this.Firestone.Click 660, 211, 500 ;; Здание магазина

            if this.Firestone.Icons.Red.Check(161, 668, 196, 709){
                this.Firestone.Click 211, 721, 500
                this.Firestone.Click 712, 410, 500
            }

            this.Firestone.Esc()
        }
    }

    Crystal() {
        if this.Firestone.Settings.Get('auto_guild_crystal', 0) == 0
            return

        if this.Firestone.Settings.Get('daily_crystal', 1) == 1
            return

        DebugLog.Log("== Кристалл ==")

        this.Firestone.Click(1650, 832) ; Переход в кристалл

        DebugLog.Log("Кликаем множитель, пока не будет x5")
        good := false
        loop 10 ; Бескончный цикл не делаю, чтобы случайно не залочить скрипт
        {
            if this.Firestone.Buttons.White.CheckPixels(1793, 879, 1783, 878, 1782, 889, 1780, 898, 1759, 884, 1771, 901)
            {
                DebugLog.Log("x5 найдено!")
                good := true
                break
            }

            this.Firestone.Click(1866, 887)
        }

        if good
        {
            if this.Firestone.Buttons.Green.CheckAndClick(847, 845, 1076, 926) {
                DebugLog.Log("Ударил по кристаллу")
                this.Firestone.Settings.Set('daily_crystal', 1)
            }
        }

        this.Firestone.Esc() ; Обратно на экран гильдии
    }

    Expeditions() {
        DebugLog.Log("== Экспедиции ==")
        
        ;; Проверяем, висит ли красный значёк у здания.
        if !this.Firestone.Icons.Red.Check(405, 443, 435, 475)
            return
    
        this.Firestone.Click(296, 387) ; Клик на здание экспедиций
        this.Firestone.Buttons.Green.WaitAndClick(1185, 267, 1229, 328, 1000)
        MouseMove 0, 0
        this.Firestone.Buttons.Green.WaitAndClick(1185, 267, 1229, 328, 1000)
        this.Firestone.Esc() ; Закрыть окно экспедиций
    }
}
