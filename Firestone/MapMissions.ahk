Class MapMissions {
    missions := unset
    icon := unset

    __New(missions, icon?) {
        this.missions := missions
        if IsSet(icon)
            this.icon := icon
    }

    EachMapMissions(force := false, finish := false) {
        try_finish := false

        For m in this.missions
        {
            If !WarCampaignMap.CheckSquad() && force == false
                break
    
            DebugLog.Log("Координаты: " m.x "x" m.y)
            if m.force_click == true || force == true
            {
                if m.Click()
                    try_finish := true
            }
            else
            {
                if this.icon.Check(m.x-10, m.y-30, m.x+10, m.y+30)
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
            WarCampaignMap.FinishMissions()
    }
}