Class Guild {
    static Do() {
        DebugLog.Log("Гильдия", "`n")
        Firestone.Click(1482, 127) ; Клик на здание гильдии
        
        this.CollectPicks() ; Забрать заодно кирки
        this.Expeditions()

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
