Class Guild {
    static Do() {
        DebugLog.Log("Гильдия", "`n")
        Firestone.Click(1482, 127) ; Клик на здание гильдии
        
        this.CollectPicks() ; Забрать заодно кирки
        this.Expeditions()
        this.Crystal()

        Firestone.Esc() ; Выйти в город
    }

    static CollectPicks() {
        DebugLog.Log("== Сбор кирок ==")
        if Firestone.Icons.Red.Check(739, 284, 780, 324)
        {
            Firestone.Click 660, 211, 500 ;; Здание магазина

            if Firestone.Icons.Red.Check(161, 668, 196, 709){
                Firestone.Click 211, 721, 500
                Firestone.Click 712, 410, 500
            }

            Firestone.Esc()
        }
    }

    static Crystal() {
        if Firestone.CurrentSettings.Get('auto_guild_crystal', 0) == 0
            return

        if Firestone.CurrentSettings.Get('daily_crystal', 1) == 1
            return

        DebugLog.Log("== Кристалл ==")

        Firestone.Click(1650, 832) ; Переход в кристалл

        DebugLog.Log("Кликаем множитель, пока не будет x5")
        good := false
        loop 10 ; Бескончный цикл не делаю, чтобы случайно не залочить скрипт
        {
            if Firestone.Buttons.White.CheckPixels(1793, 879, 1783, 878, 1782, 889, 1780, 898, 1759, 884, 1771, 901)
            {
                DebugLog.Log("x5 найдено!")
                good := true
                break
            }

            Firestone.Click(1866, 887)
        }

        if good
        {
            if Firestone.Buttons.Green.CheckAndClick(847, 845, 1076, 926) {
                DebugLog.Log("Ударил по кристаллу")
                Firestone.CurrentSettings.Set('daily_crystal', 1)
            }
        }

        Firestone.Esc() ; Обратно на экран гильдии
    }

    static Expeditions() {
        DebugLog.Log("== Экспедиции ==")
        
        ;; Проверяем, висит ли красный значёк у здания.
        if !Firestone.Icons.Red.Check(405, 443, 435, 475)
            return
    
        Firestone.Click(296, 387) ; Клик на здание экспедиций
        Firestone.Buttons.Green.WaitAndClick(1185, 267, 1229, 328, 1000)
        MouseMove 0, 0
        Firestone.Buttons.Green.WaitAndClick(1185, 267, 1229, 328, 1000)
        Firestone.Esc() ; Закрыть окно экспедиций
    }
}
