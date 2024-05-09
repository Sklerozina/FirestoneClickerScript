Class Guild {
    static Do() {
        Firestone.Click(1482, 127) ; Клик на здание гильдии
        
        this.CollectPicks() ; Забрать заодно кирки
        this.Expeditions()

        Firestone.Esc() ; Выйти в город
    }

    static CollectPicks() {
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
        ;; Проверяем, висит ли красный значёк у здания.
        if not Firestone.Icons.Red.Check(405, 443, 435, 475)
        {
            Firestone.Esc() ; Выйти в город
            return
        }
    
        Firestone.Click(296, 387) ; Клик на здание экспедиций
        Firestone.Buttons.Green.WaitAndClick(1187, 258, 1216, 345, 1000)
        MouseMove 0, 0
        Firestone.Buttons.Green.WaitAndClick(1187, 258, 1216, 345, 1000)
        Firestone.Esc() ; Закрыть окно экспедиций
    }
}
