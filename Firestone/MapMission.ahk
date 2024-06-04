Class MapMission {
    __New(x, y, force_click := false) {
        this.x := x
        this.y := y
        this.force_click := force_click
    }

    Click() {
        Firestone.Click this.x, this.y, 100
        ; Зелёная кнопка принятия
    
        ; Смотрим, появилось окно или нет, если не появилось, значит можно не проверять кнопки.
        ; Должно ускорить поиск миссий
        DebugLog.Log("Поиск окна миссии...")
        if !Tools.WaitForSearchPixel(414, 206, 424, 216, 0xE1CDAC, 1, 250) {
            DebugLog.Log("Окно миссии не найдено")
            return false
        }

        MouseMove 0, 0
    
        ; Проверяем наличие кнопки принятия миссии и кликаем её
        DebugLog.Log("Поиск кнопки старта миссии...")
        if !Firestone.Buttons.Green.WaitAndClick(955, 802, 990, 886, 500) ; Ищем кнопку и кликаем, если нет, проверяем другие варианты
        {
            DebugLog.Log("Поиск кнопки досрочного завершения...")
            if(Firestone.Buttons.Orange.CheckAndClick(1251, 720, 1491, 790))
            {
                DebugLog.Log("Поиск кнопки подтверждения...")
                if Firestone.Buttons.Green.WaitAndClick(802, 572, 828, 637, 5000)
                    DebugLog.Log("Кнопка найдена")

                return true
            }
    
            ; Проверяем наличие кнопки отмены
            DebugLog.Log("Поиск кнопки отмены...")
            if(Firestone.Buttons.Red.Check(967, 713, 1009, 783))
            {
                Firestone.Press("{Esc}")
                return true
            }

            ; Возможно клик был по выполненной миссии, проверяем наличие кнопки
            DebugLog.Log("Поиск кнопки подтверждения...")
            if Firestone.Buttons.Green.CheckAndClick(802, 572, 828, 637)
                return true
    
            ; if(Tools.CheckForImage(1024, 803, 1164, 874, "*80 images/NotEnoughSquads.png"))
            ; {
            ;     Firestone.Esc()
            ;     return true
            ; }
            DebugLog.Log("Какое-то окно точно открылось, но мы не знаем что за окно")
            Firestone.Esc() ; если дошли сюда, то какое-то окно мы точно открыли

            ; окно подтверждения принятия награды "награды миссии"
            
        }

        return false
    }
}