Class MapMissionDomination {
    __New(x, y, force_click := false) {
        this.x := x
        this.y := y
        this.force_click := force_click
    }

    Click() {
        this.Firestone.Click this.x, this.y, 100
        ; Зелёная кнопка принятия
    
        ; Смотрим, появилось окно или нет, если не появилось, значит можно не проверять кнопки.
        ; Должно ускорить поиск миссий
        DebugLog.Log("Поиск окна миссии...")
        if !Tools.WaitForSearchPixel(414, 206, 424, 216, 0xE1CDAC, 1, 250) {
            DebugLog.Log("Окно миссии не найдено")
            return false
        }

        MouseMove 0, 0

        DebugLog.Log("Поиск кнопки досрочного завершения...")
        ; if(CheckForImage(1251, 720, 1491, 790, "*120 images/FreeOrange.png"))
        if(this.Firestone.Buttons.Orange.CheckAndClick(1257, 811, 1322, 825))
        {
            DebugLog.Log("Поиск кнопки подтверждения...")
            this.Firestone.Buttons.Green.WaitAndClick(802, 572, 828, 637, 5000)
            return true
        }

        return false
    }
}