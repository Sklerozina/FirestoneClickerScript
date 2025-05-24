Class Tavern {
    __New(Firestone) {
        this.Firestone := Firestone
    }

    cards_coordinates := [
        [686, 306],
        [964, 297],
        [1231, 302],
        [684, 687],
        [965, 672],
        [1239, 676]
    ]

    Do() {
        if this.Firestone.Settings.Get('auto_tavern') == 0
            return

        DebugLog.Log("Таверна", "`n")
         ; У Таверны нет значка, выходим
        if !this.Firestone.Icons.Red.Check(814, 910, 848, 949) && !(this.Firestone.Settings.Get('daily_tavern') == 0 && this.Firestone.Settings.Get('auto_tavern_daily_roll') == 1)
            return

        this.Firestone.Click(717, 911) ; Заходим в Таверну из города
        
        this.CollectTokens()
        this.DailyRoll()

        this.Firestone.Esc()
    }

    DailyRoll() {
        ; Крутил при условии, что не крутили таверну сегодня, включен обмен пива на токены, включены крутки
        if this.Firestone.Settings.Get('daily_tavern') == 0 && this.Firestone.Settings.Get('auto_tavern_daily_roll') == 1
        {
            DebugLog.Log("== Ежедневные 10 круток ==")
            if (this.Firestone.Buttons.White.CheckPixels(1093, 934, 1099, 933, 1096, 954, 1110, 941, 1118, 932, 1124, 943, 1116, 955) || ; проверяем цифру 10
            this.Firestone.Buttons.White.CheckPixels(980, 934, 984, 933, 983, 952, 1007, 933, 996, 949, 1009, 935)) && this.Firestone.Buttons.Green.WaitAndClick(1016, 913, 941, 1053, 1000)
            {
                Tools.Sleep()
                click_coords := this.cards_coordinates[Random(1, this.cards_coordinates.Length)]
                this.Firestone.Click(click_coords[1], click_coords[2])
                this.Firestone.Settings.Set('daily_tavern', true)

                DebugLog.Log("Ждём пояления синей кнопки... или чёрного экрана")
                ok := false
                Loop 60 {
                    Tools.Sleep(1000)
                    if this.Firestone.Buttons.Blue.Wait(873, 808, 890, 863, 250)
                        ok := true

                    if Tools.WaitForSearchPixel(1560-5, 832-5, 1560+5, 832+5, 0x000000, 0, 250)
                    {
                        DebugLog.Log("Обнаружен артефакт!")
                        this.Firestone.TelegramSend('Выпал новый артефакт!', true)
                        this.Firestone.Icons.Close.WaitAndClick(1777, 19, 1894, 91, 10000) ; Ищем кнопку с крестиком для закрытия и нажимаем
                        ok := true
                    }

                    if ok
                    {
                        DebugLog.Log("Дождались")
                        break
                    }
                }

                if this.Firestone.Settings.Get('auto_event_mode') == 1
                {
                    DebugLog.Log("Делаем дополнительные две крутки...")
                    Loop 2 {
                        if this.Firestone.Buttons.Green.WaitAndClick(709, 918, 752, 970) {
                            Tools.Sleep()
                            click_coords := this.cards_coordinates[Random(1, this.cards_coordinates.Length)]
                            this.Firestone.Click(click_coords[1], click_coords[2])

                            if Tools.WaitForSearchPixel(1560-5, 832-5, 1560+5, 832+5, 0x000000, 0, 1000)
                            {
                                DebugLog.Log("Обнаружен артефакт!")
                                this.Firestone.TelegramSend('Выпал новый артефакт!', true)
                                this.Firestone.Icons.Close.WaitAndClick(1777, 19, 1894, 91, 10000) ; Ищем кнопку с крестиком для закрытия и нажимаем
                                ok := true
                            }
                        }
                    }
                }

                ; Проверяем доступность сборки нового артефакта
                if this.Firestone.Buttons.Green.Check(108, 451, 128, 540)
                {
                    DebugLog.Log("Найдена кнопка для собрки артефакта")
                    this.Firestone.TelegramSend('Можно собрать артефакт!', true)
                }
                
            }
            else
            {
                DebugLog.Log("Не могу найти кнопку с цифрой 10... нужно больше пива!")
            }
            ;this.Firestone.Settings.Set('daily_tavern', true)
        }
    }

    CollectTokens() {
        DebugLog.Log("== Обмен пива ==")
        this.Firestone.Click(1731, 42) ; Клик по иконке плюса для обмена пива
    
        while Tools.WaitForSearchPixel(344-5, 437-5, 344+5, 437+5, 0x3CA8E1, 1, 1000) {
            this.Firestone.Click(521, 509)
        }
        else
            Tools.Sleep 1000
    
        this.Firestone.Esc()
    }
}