Class WarCampaignMap {
    ;; Координаты заданий для карты
    static map_world_domination_missions := {954:503, 728:350}
    ; ~20 minutes
    static map_litle_missons := {866:207, 1390:320, 1333:409, 1216:435, 536:472, 682:493, 845:640, 1266:673, 1455:552, 907:335, 696:198, 499:158, 1338:619, 1291:159, 818:345, 1134:416, 630:330, 1087:860}
    ; ~40 minutes
    static map_small_missons := {564:262, 1289:280, 1480:227, 789:476, 672:569, 1433:663, 668:728, 854:515, 1034:648, 466:306, 478:387, 445:644, 1012:500, 1418:394, 1318:517, 1411:845}
    ; ~1-2 hours
    static map_medium_missons := {1214:285, 1008:401, 773:621, 1140:600, 1450:469, 840:767, 1047:769, 1325:774, 1147:948, 1202:521, 760:822, 702:656, 951:198, 896:732, 1400:753, 1245:360, 646:392, 921:578}
    ; Seas, Monsters, Dragons
    static map_big_missons := {1097:522, 459:899, 596:540, 1485:749, 374:972, 836:944, 957:787, 542:947, 609:169, 1245:819, 1137:310, 873:422}

    static Do() {
        DebugLog.Log("Карта", "`n")
        map_status := ''

        Firestone.Press("{m}")

        DebugLog.Log("Переход на карту военной кампании")
        Firestone.Click(1834, 583, 500) ; Клик для перехода на карту военной кампании
        
        DebugLog.Log("Поиск лута...")
        Firestone.Buttons.Green.CheckAndClick(36, 912, 67, 965)  ; Забрать лут  

        DebugLog.Log("Переход на карту миссий")
        Firestone.Click(1832, 438, 500) ; Вернуться обратно на карту миссий
    
        ; Прокликать завершённые задания
        DebugLog.Log("== Миссии ==")
        map_status := this.FinishMissions()
        if map_status == 'hangup'
            this.CheckMissions(true)
        else
            this.CheckMissions
        
        Firestone.Click(1834, 583, 500) ; Клик для перехода на карту военной кампании
    
        DebugLog.Log("== Дейлики военной кампании ==")
        this.DoWMDailys()
    
        Firestone.Esc()
    }

    static FinishMissions() {
        DebugLog.Log("=== Завершение активных миссий ===")
        ; Попробовать завершить задания, которым осталось меньше 3-х минут
        loop 20 ; Ограничим цикл, если вдруг что-то пошло не так.
        {
            if not Tools.PixelSearch(14, 208, 263, 341, 0xF7E5CB, 1)
            {
                DebugLog.Log("Миссии не найдены")
                break
            }
            else
            {
                DebugLog.Log("Миссия обнаружена")
                Firestone.Click 138, 239, 500
                ; окно подтверждения принятия награды "награды миссии"
                DebugLog.Log("Поиск кнопки подтверждения...")
                if Firestone.Buttons.Green.CheckAndClick(802, 572, 828, 637)
                    continue

                DebugLog.Log("Поиск кнопки досрочного завершения...")
                ; if(CheckForImage(1251, 720, 1491, 790, "*120 images/FreeOrange.png"))
                if(Firestone.Buttons.Orange.CheckAndClick(1251, 720, 1491, 790))
                {
                    DebugLog.Log("Поиск кнопки подтверждения...")
                    Firestone.Buttons.Green.WaitAndClick(802, 572, 828, 637, 5000)
                    continue
                }
        
                ; Проверяем наличие кнопки отмены
                DebugLog.Log("Поиск кнопки отмены...")
                if(Firestone.Buttons.Red.Check(967, 713, 1009, 783)){
                    Firestone.Press("{Esc}")
                    break
                }
    
                if (Tools.PixelSearch(85, 274, 138, 332, 0xADABAD, 1)) {
                    DebugLog.Log("Похоже миссия зависла")
                    return 'hangup'
                }
            }
        }
    }

    static EachMapMissions(missions, force := false, finish := false) {
        try_finish := false
        For x, y in missions.OwnProps()
        {
            If !this.CheckSquad() && force == false
                break
            else
                DebugLog.Log('Все отряды работают или нет миссий.')
    
            if this.ClickOnMapMission(x, y)
                try_finish := true
        }
    
        if try_finish == true || finish == true
            this.FinishMissions()
    }

    static CheckMissions(force := false){
        ; Проверить, есть ли не задания на карте и попытаться их начать.
        if (this.CheckSquad() || force == true)
        {
            ; Мисси при событии "Мировое господство"
            DebugLog.Log("=== Прокликиваем подарки ===")
            this.EachMapMissions(this.map_world_domination_missions, force)
            DebugLog.Log("=== Прокликиваем 20 минутки ===")
            this.EachMapMissions(this.map_litle_missons, force)
            DebugLog.Log("=== Прокликиваем 4-6 часов ===")
            this.EachMapMissions(this.map_big_missons, force)
            DebugLog.Log("=== Прокликиваем 40 минутки ===")
            this.EachMapMissions(this.map_small_missons, force)
            DebugLog.Log("=== Прокликиваем 1-2 часов ===")
            this.EachMapMissions(this.map_medium_missons, force)
        }
    }

    static CheckSquad() {
        return Tools.PixelSearch(646, 946, 816, 1016, 0xF9E7CE, 1)
    }
    
    static ClickOnMapMission(x, y) {
        Firestone.Click x, y, 100
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

    static DoWMDailys() {
        ; Здесь можно проверить, светятся ли невыполненные дейлики
        DebugLog.Log("Поиск красного значка у кнопки...")
        if (Firestone.Icons.Red.Check(1850, 900, 1900, 950))
        {
            Firestone.Click(1777, 977) ; Ежедневные миссии
            DebugLog.Log("=== Освобождение ===")
            Firestone.Click(720, 779) ; Кнопка выбора, освобождение
            MouseMove 513, 489
            Firestone.ScrollUp(60)
    
            Tools.Sleep 500
            DebugLog.Log("Миссия 1")
            this.DoWMMission(190, 700, 450, 770) ; 1
            DebugLog.Log("Миссия 2")
            this.DoWMMission(580, 700, 850, 770) ; 2
            DebugLog.Log("Миссия 3")
            this.DoWMMission(985, 700, 1240, 770) ; 3
            DebugLog.Log("Миссия 4")
            this.DoWMMission(1380, 700, 1640, 770) ; 4
            DebugLog.Log("Миссия 5")
            this.DoWMMission(1777, 700, 1800, 770) ; 5
    
            MouseMove 513, 489
            Firestone.ScrollDown(60)
    
            DebugLog.Log("Миссия 6")
            this.DoWMMission(280, 700, 540, 770) ; 6
            DebugLog.Log("Миссия 7")
            this.DoWMMission(680, 710, 929, 768) ; 7
    
            Firestone.Esc() ; Вышли на карту
    
            ; Зайти ещё раз и проверить вторую стопку дейликов
            DebugLog.Log("=== Подземелья ===")
            Firestone.Click(1777, 977, 500) ; Ежедневные миссии
            if Firestone.Buttons.Green.CheckAndClick(1100, 740, 1340, 810) ; 
            {
                DebugLog.Log("Подземелье 1")
                this.DoWMMission(630, 700, 890, 770) ; 1 подземелье
                Firestone.Esc() ; Вышли на карту
            }
            else
            {
                Firestone.Esc()
            }
        }
    }
    
    static DoWMMission(zone_x1, zone_y1, zone_x2, zone_y2) {
        Tools.Sleep 500
        DebugLog.Log("Поиск кнопки... (" zone_x1 "x" zone_y1 " - " zone_x2 "x" zone_y2 ")")
        if Firestone.Buttons.Green.CheckAndClick(zone_x1, zone_y1, zone_x2, zone_y2)
        {
            MouseMove(0, 0) ; Убираем мышь, чтобы не светила кнопку
            start_time := A_TickCount
            DebugLog.Log("Ожидаем завершение боя...")
            if !Firestone.Buttons.Green.WaitAndClick(926, 734, 956, 764, 120000) ; Ждём появление кнопки подтверждения
            {
                DebugLog.Log('Кнопка завершения боя так и не появилась!')
                throw 'Военная кампания, кнопка завершения боя так и не появилась!'
            }
            else
                DebugLog.Log("Бой длился " (A_TickCount - start_time) / 1000 " секунд" )
        }
        else
            return 0
    }
}