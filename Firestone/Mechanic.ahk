Class Mechanic {
    static Do() {
        ; Проверяем, висит ли красный значок у здания.
        if !Firestone.Icons.Red.Check(1325, 839, 1369, 882)
            return
        
        Firestone.Click(1230, 800) ; Клик на здание механика

        this.CollectTools()
    }

    static CollectTools() {
        ; Проверяем, висит ли красный значёк у механика.
        if !Firestone.Icons.Red.Check(724, 306, 759, 336)
        {
            Firestone.Esc()
            return
        }
            
        Firestone.Click(600, 460) ; Клик на выбор Механика
        Firestone.Buttons.Green.CheckAndClick(1536, 642, 1570, 718) ; Клик на кнопку получения инструментов
        Firestone.Esc()
    }
}