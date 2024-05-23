Class Tavern {
    static cards_coordinates := [
        [686, 306],
        [964, 297],
        [1231, 302],
        [684, 687],
        [965, 672],
        [1239, 676]
    ]

    static Do() {
        if Firestone.CurrentSettings.Get('auto_tavern') == 0
            return

        DebugLog.Log("Таверна", "`n")
         ; У Таверны нет значка, выходим
        if !Firestone.Icons.Red.Check(814, 910, 848, 949) && !(Firestone.CurrentSettings.Get('daily_tavern') == 0 && Firestone.CurrentSettings.Get('auto_tavern_daily_roll') == 1)
            return

        Firestone.Click(717, 911) ; Заходим в Таверну из города
        
        this.CollectTokens()
        this.DailyRoll()

        Firestone.Esc()
    }

    static DailyRoll() {
        ; Крутил при условии, что не крутили таверну сегодня, включен обмен пива на токены, включены крутки
        if Firestone.CurrentSettings.Get('daily_tavern') == 0 && Firestone.CurrentSettings.Get('auto_tavern_daily_roll') == 1
        {
            DebugLog.Log("== Ежедневные 10 круток ==")
            if Firestone.Buttons.Green.WaitAndClick(931, 913, 941, 965, 1000) 
            {
                click_coords := this.cards_coordinates[Random(1, this.cards_coordinates.Length)]
                Firestone.Click(click_coords[1], click_coords[2])

                DebugLog.Log("Ждём пояления синей кнопки... или чёрного экрана")
                ok := false
                Loop 60 {
                    Tools.Sleep(1000)
                    if Firestone.Buttons.Blue.Wait(873, 808, 890, 863, 250)
                        ok := true

                    if Tools.WaitForSearchPixel(1560-5, 832-5, 1560+5, 832+5, 0x000000, 0, 250)
                    {
                        DebugLog.Log("Обнаружен артефакт!")
                        Firestone.TelegramSend('Выпал новый артефакт!', true)
                        Firestone.Icons.Close.WaitAndClick(1777, 19, 1894, 91, 10000) ; Ищем кнопку с крестиком для закрытия и нажимаем
                        ok := true
                    }

                    if ok
                    {
                        DebugLog.Log("Дождались")
                        Firestone.CurrentSettings.Set('daily_tavern', true)
                        break
                    }
                }

                ; Проверяем доступность сборки нового артефакта
                if Firestone.Buttons.Green.Check(108, 451, 128, 540)
                {
                    DebugLog.Log("Найдена кнопка для собрки артефакта")
                    Firestone.TelegramSend('Можно собрать артефакт!', true)
                }
                
            }
                ;Firestone.CurrentSettings.Set('daily_tavern', true)
        }
    }

    static CollectTokens() {
        DebugLog.Log("== Обмен пива ==")
        Firestone.Click(1731, 42) ; Клик по иконке плюса для обмена пива
    
        while Tools.WaitForSearchPixel(344-5, 437-5, 344+5, 437+5, 0x3CA8E1, 1, 1000) {
            Firestone.Click(521, 509)
        }
        else
            Tools.Sleep 1000
    
        Firestone.Esc()
    }
}