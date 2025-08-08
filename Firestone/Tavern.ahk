Class Tavern {
    __New(Firestone) {
        this.Firestone := Firestone
        this.new_interface := 0
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
            Tools.Sleep(500)

            if Tools.PixelSearch(706-5, 216-5, 706+5, 216+5, 0x7B3D23, 1) { ; Проверка на наличия выбора в таверне
                DebugLog.Log("Обнаружен новый интерфейс")
                this.new_interface := 1
            }
        }
        else
            return
        
        if this.new_interface == 0 {
            this.Firestone.Click(775, 478)
            this.CollectTokens()
            this.DailyRoll()
            this.Firestone.Esc()
        }
        else {
            if this.Firestone.Icons.Red.Check(899, 303, 937, 336) || (this.Firestone.Settings.Get('daily_tavern') == 0 && this.Firestone.Settings.Get('auto_tavern_daily_roll') == 1) {
                if !Tools.PixelSearch(706-5, 216-5, 706+5, 216+5, 0x7B3D23, 1) { ; Проверка на наличие выбора в таверне
                    this.Firestone.Click(717, 911) ; Заходим в Таверну из города
                }
                
                ; Делаем таверную рутину
                this.Firestone.Click(775, 494) ; в саму таверну из выбора
                this.CollectTokens()
                this.DailyRollNew()
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
    }

    DailyRollNew() {
        ; Крутил при условии, что не крутили таверну сегодня, включен обмен пива на токены, включены крутки
        if this.Firestone.Settings.Get('daily_tavern') == 0 && this.Firestone.Settings.Get('auto_tavern_daily_roll') == 1
        {
            DebugLog.Log("== Ежедневные 10 круток ==")

            DebugLog.Log("Кликаем множитель, пока не будет x10")
            good := false
            loop 10 ; Бескончный цикл не делаю, чтобы случайно не залочить скрипт
            {
                if this.Firestone.Buttons.White.CheckPixels(1774, 884, 1775, 873)
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

    ; Удалить, после выхода 9.0 версии игры в эпиках
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

    ScarabsGame() {
        Loop 50 { ; Крутим казино, если есть на что
            if !this.Firestone.Buttons.Green.WaitAndClick(1143, 869, 1160, 951, 10000)
                break
            
            MouseMove 0,0
        }

        if this.Firestone.Icons.Red.Check(1864, 155, 1897, 189) || this.Firestone.Icons.Red2.Check(1864, 155, 1897, 189) { ; Усыпальница фараона забрать награды
            this.Firestone.Click(1813, 205)

            if Tools.PixelSearch(230-5, 575-5, 230+5, 575+5, 0x168700, 1) {
                DebugLog.Log("Можно получить зверя!")
                this.Firestone.TelegramSend('Можно получить зверя!', true)
            }

            loop 20 {
                if this.Firestone.Buttons.Green.WaitAndClick(1005, 935, 1021, 976, 10000) {
                    this.Firestone.Esc()
                }
                else
                    break
            
                MouseMove 0,0
            }

            if this.Firestone.Icons.Red.Check(1865, 371, 1894, 402) || this.Firestone.Icons.Red2.Check(1865, 371, 1894, 402) { ; Усыпальница фараона -> Цели
                this.Firestone.Click(1815, 418)
                MouseMove(613, 482)
                Tools.Sleep(250)
                this.Firestone.ScrollUp(100)

                loop 20 {
                    this.Firestone.Buttons.Green.CheckAndClick(961, 638, 1085, 668,,, 500)
                    MouseMove(613, 482)
                    Tools.Sleep(250)
                    this.Firestone.ScrollDown(8)
                }

                this.Firestone.Esc()
            }

            this.Firestone.Esc()
        }

        this.Firestone.Esc()
    }
}