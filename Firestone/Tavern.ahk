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
        if this.Firestone.Icons.Red.Check(814, 910, 848, 949) || (this.Firestone.Settings.Get('daily_tavern') == 0 && this.Firestone.Settings.Get('auto_tavern_daily_roll') == 1) {
            this.Firestone.Click(717, 911) ; Заходим в Таверну из города
        }
        else
            return
        
        if this.Firestone.Icons.Red.Check(899, 303, 937, 336) || (this.Firestone.Settings.Get('daily_tavern') == 0 && this.Firestone.Settings.Get('auto_tavern_daily_roll') == 1) {
            if !Tools.PixelSearch(706-5, 216-5, 706+5, 216+5, 0x7B3D23, 1) { ; Проверка на наличие выбора в таверне
                this.Firestone.Click(717, 911) ; Заходим в Таверну из города
            }
            
            ; Делаем таверную рутину
            this.Firestone.Click(775, 494) ; в саму таверну из выбора
            this.CollectTokens()
            this.DailyRoll()
            this.Firestone.Esc()
        }
        else
            this.Firestone.Esc()

        if !Tools.PixelSearch(706-5, 216-5, 706+5, 216+5, 0x7B3D23, 1) { ; Проверка на наличия выбора в таверне
            this.Firestone.Click(717, 911) ; Заходим в Таверну из города
        }

        if this.Firestone.Icons.Red.Check(1276, 302, 1311, 330) && this.Firestone.Settings.Get('auto_scarab_game', 0) {
            this.Firestone.Click(1149, 496)
            this.ScarabsGame()
        }
        else {
            if Tools.PixelSearch(706-5, 216-5, 706+5, 216+5, 0x7B3D23, 1) { ; Проверка на наличия выбора в таверне
                this.Firestone.Esc()
            }
        }
    }

    DailyRoll() {
        ; Крутил при условии, что не крутили таверну сегодня, включен обмен пива на токены, включены крутки
        if this.Firestone.Settings.Get('daily_tavern') == 0 && this.Firestone.Settings.Get('auto_tavern_daily_roll') == 1
        {
            DebugLog.Log("== Ежедневные 10 круток ==")

            DebugLog.Log("Кликаем множитель, пока не будет x10")
            good := false
            loop 10 ; Бескончный цикл не делаю, чтобы случайно не залочить скрипт
            {
                if this.Firestone.Buttons.White.CheckPixels(1774, 884) && !this.Firestone.Buttons.White.CheckPixels(1766, 899)
                {
                    DebugLog.Log("x10 найдено!")
                    good := true
                    break
                }

                this.Firestone.Click(1678, 872)
            }

            if good
            {
                this.Firestone.Buttons.Green.WaitAndClick(845, 946, 862, 980, 1000)
                click_coords := this.cards_coordinates[Random(1, this.cards_coordinates.Length)]
                this.Firestone.Click(click_coords[1], click_coords[2])
                this.Firestone.Settings.Set('daily_tavern', true)

                DebugLog.Log("Ждём пояления синей кнопки... или чёрного экрана")
                ok := false
                Loop 60 {
                    Tools.Sleep(1000)
                    if this.Firestone.Buttons.Blue.Wait(900, 810, 915, 865, 250) {
                        ok := true
                    }

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

                    DebugLog.Log("Кликаем множитель, пока не будет x1")
                    good := false
                    loop 10 ; Бескончный цикл не делаю, чтобы случайно не залочить скрипт
                    {
                        if this.Firestone.Buttons.White.CheckPixels(1785, 868, 1768, 882)
                        {
                            DebugLog.Log("x1 найдено!")
                            good := true
                            break
                        }

                        this.Firestone.Click(1678, 872)
                    }

                    if good {
                        Loop 2 {
                            if this.Firestone.Buttons.Green.WaitAndClick(this.Firestone.Buttons.Green.WaitAndClick(845, 946, 862, 980, 1000)) {
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
                }

                ; Проверяем доступность сборки нового артефакта
                if this.Firestone.Buttons.Green.Check(195, 940, 215, 999)
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

    ScarabsGame() {
        ; Если кнопка на входе серая, нет смысла искать зелёную и ждать 10 секунд
        if !this.Firestone.Buttons.Gray.Wait(1058, 913, 1081, 946, 1000)
        {
            Loop 50 { ; Крутим казино, если есть на что
                if !this.Firestone.Buttons.Green.WaitAndClick(1040, 911, 1066, 956, 10000)
                    break
                
                MouseMove 0,0
            }
        }

        if this.Firestone.Icons.Red.Check(1864, 155, 1897, 189) || this.Firestone.Icons.Red2.Check(1864, 155, 1897, 189) { ; Усыпальница фараона забрать награды
            this.Firestone.Click(1813, 205) ; клик на усыпальницу 

            if !this.Firestone.Buttons.Gray.Wait(1188, 939, 1206, 977, 1000) ; Если кнопка на входе серая, нет смысла искать зелёную и ждать 10 секунд
            {
                loop 20 {
                    if !this.Firestone.Buttons.Green.WaitAndClick(1005, 935, 1021, 976, 10000)
                        break
                
                    MouseMove 0,0
                }
            }

            if this.Firestone.Icons.Red.Check(1865, 371, 1894, 402) || this.Firestone.Icons.Red2.Check(1865, 371, 1894, 402) { ; Усыпальница фараона -> Цели
                this.Firestone.Click(1815, 418, 2000) ; клик на цели

                loop 10 {
                    if !this.Firestone.Buttons.White.FindAndClick(162, 721, 1754, 732)
                        return
                    
                    MouseMove(0, 0)
                    Tools.Sleep(250)
                }

                this.Firestone.Esc() ; выходим из целей
            }

            this.Firestone.Esc() ; выходим из усыпальницы
        }
        
        Tools.Sleep(1000)
        
        if Tools.PixelSearch(210, 587, 354, 624, 0x148700, 3) {
            DebugLog.Log("Можно получить зверя!")
            this.Firestone.TelegramSend('Можно получить зверя!', true)
        }

        this.Firestone.Esc() ; Выходим из игр скарабея в город
    }
}