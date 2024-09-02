Class MapMissions {
    missions := unset
    icon := unset

    __New(Firestone, missions, icon?) {
        this.missions := missions
        this.Firestone := Firestone

        For m in this.missions {
            m.Firestone := Firestone
        }

        if IsSet(icon)
            this.icon := icon
    }

    EachMapMissions(force := false, finish := false) {
        try_finish := false

        For m in this.missions
        {
            If !this.Firestone.WarCampaignMap.CheckSquad() && force == false
                break
    
            DebugLog.Log("Координаты: " m.x "x" m.y)
            if m.force_click == true || force == true
            {
                if m.Click()
                    try_finish := true
            }
            else
            {
                if this.icon.Check(m.x-30, m.y-30, m.x+30, m.y+30)
                {
                    DebugLog.Log('Иконка найдена!')
                    if m.Click()
                        try_finish := true
                }
                else
                {
                    DebugLog.Log('Иконка не найдена, пропуск')
                }
            }            
        }

        if try_finish == true || finish == true
            this.Firestone.WarCampaignMap.FinishMissions()
    }
}