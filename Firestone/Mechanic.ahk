Class Mechanic {
    __New(Firestone) {
        this.Firestone := Firestone
    }

    Do() {
        DebugLog.Log("Механик", "`n")
        
        ; Проверяем, висит ли красный значок у здания.
        if !this.Firestone.Icons.Red.Check(1325, 839, 1369, 882)
            return
        
        this.Firestone.Click(1230, 800) ; Клик на здание механика

        this.CollectTools()
    }

    CollectTools() {
        ; Проверяем, висит ли красный значёк у механика.
        DebugLog.Log("== Инструменты ==")
        if !this.Firestone.Icons.Red.Check(724, 306, 759, 336)
        {
            this.Firestone.Esc()
            return
        }
            
        this.Firestone.Click(600, 460) ; Клик на выбор Механика
        if this.Firestone.Buttons.Green.CheckAndClick(1536, 642, 1570, 718) ; Клик на кнопку получения инструментов
            DebugLog.Log("Инструменты собраны")
        
        this.Firestone.Esc()
    }
}