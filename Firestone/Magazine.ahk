Class Magazine {
    __New(Firestone) {
        this.Firestone := Firestone
    }

    Do() {
        if this.Firestone.Settings.Get('daily_magazine', false) == 1
            return

        DebugLog.Log("Магазин", "`n")
        this.Firestone.Click(1300, 343)
    
        DebugLog.Log("== Подарок ==")
        reward_1 := false
        if Tools.PixelSearch(432, 869, 442, 879, 0x5B5EAA, 1)
        {
            this.Firestone.Click(592, 743, 1000)
            
            if !Tools.PixelSearch(432, 869, 442, 879, 0x5B5EAA, 1)
            {
                reward_1 := true
            }
        }
        else ; Видимо награду уже собрали
            reward_1 := true
    
        DebugLog.Log("== Ежедневная отметка ==")
        reward_2 := false
        if this.Firestone.Icons.Red.Check(1425, 25, 1474, 76)
        {
            this.Firestone.Click(1381, 91)
            if Tools.PixelSearch(1261, 796, 1404, 841, 0x4CA02E, 1)
            {
                this.Firestone.Click 1324, 811
                if !this.Firestone.Icons.Red.Check(1425, 25, 1474, 76)
                {
                    reward_2 := true
                }
            }
        }
        else
            reward_2 := true

        if reward_1 && reward_2
        {
            this.Firestone.Settings.Set('daily_magazine', true)
        }

        this.Firestone.Esc()
    }
}