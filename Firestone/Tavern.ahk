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
                DebugLog.Log("Ждём пояления синей кнопки...")
                if Firestone.Buttons.Blue.Wait(873, 808, 890, 863, 30000) {
                    DebugLog.Log("Дождались")
                    Firestone.CurrentSettings.Set('daily_tavern', true)
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