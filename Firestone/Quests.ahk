Class Quests {
    static Do() {
        DebugLog.Log("Квесты в профиле", "`n")
        Firestone.Press("{Q}")
        
        this.CheckDaily()
        this.CheckWeekly()
        
        Firestone.Esc()
    }

    static CheckDaily() {
        ; Дейлики
        DebugLog.Log("Проверяем дейлики...")
        if !Firestone.Icons.Red.Check(929, 82, 969, 115)
            return
        
        Firestone.Click(773, 130)

        loop 8
        {
            if !this.Complete()
                break
        }
    }

    static CheckWeekly() {
        DebugLog.Log("Проверяем виклики...")
        if !Firestone.Icons.Red.Check(1322, 79, 1364, 113)
            return

        Firestone.Click(1167, 132)
    
        loop 8
        {
            if !this.Complete()
                break
        }
    }

    static Complete() {
        MouseMove 0, 0
        If Firestone.Buttons.Green.WaitAndClick(1576, 263, 1613, 309, 1000)
        {
            Firestone.Buttons.Green.WaitAndClick(1035, 635, 1099, 727, 500)
            return true
        }
        
        return false
    }
}