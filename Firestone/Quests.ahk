Class Quests {
    __New(Firestone) {
        this.Firestone := Firestone
    }

    Do() {
        DebugLog.Log("Квесты в профиле", "`n")
        this.Firestone.Press("{Q}")
        
        this.CheckDaily()
        this.CheckWeekly()
        
        this.Firestone.Esc()
    }

    CheckDaily() {
        ; Дейлики
        DebugLog.Log("Проверяем дейлики...")
        if !this.Firestone.Icons.Red.Check(929, 82, 969, 115)
            return
        
        this.Firestone.Click(773, 130)

        loop 8
        {
            if !this.Complete()
                break
        }
    }

    CheckWeekly() {
        DebugLog.Log("Проверяем виклики...")
        if !this.Firestone.Icons.Red.Check(1322, 79, 1364, 113)
            return

        this.Firestone.Click(1167, 132)
    
        loop 8
        {
            if !this.Complete()
                break
        }
    }

    Complete() {
        MouseMove 0, 0
        If this.Firestone.Buttons.Green.WaitAndClick(1576, 263, 1613, 309, 1000)
        {
            this.Firestone.Buttons.Green.WaitAndClick(1035, 635, 1099, 727, 500)
            return true
        }
        
        return false
    }
}