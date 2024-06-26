Class WarCampaignMap {
    ;; Координаты заданий для карты
    static missions := Map(
        'mystery', MapMissions([MapMissionDomination(954, 503), MapMissionDomination(728, 350)], Button(0xCF6639, 5)),
        ; ~20 minutes
        'scout', MapMissions([
            MapMission(866, 207), MapMission(1390, 320), MapMission(1333, 409), MapMission(1216, 435), MapMission(536, 472), MapMission(682, 493),
            MapMission(845, 640), MapMission(1266, 673), MapMission(1455, 552), MapMission(907, 335), MapMission(696, 198), MapMission(499, 158), MapMission(1338, 619),
            MapMission(1291, 159), MapMission(818, 345), MapMission(1134, 416), MapMission(630, 330), MapMission(1087, 860)
        ], Button(0xFFBE8C, 5)),
        ; ~40 minutes
        'adventure', MapMissions([MapMission(564, 262), MapMission(1289, 280), MapMission(1480, 227), MapMission(789, 476), MapMission(672, 569), MapMission(1433, 663),
            MapMission(668, 728), MapMission(854, 515), MapMission(1034, 648), MapMission(466, 306), MapMission(478, 387), MapMission(445, 644),
            MapMission(1012, 500), MapMission(1418, 394), MapMission(1318, 517), MapMission(1411, 845)], Button(0xFFFB02, 5)),
        ; ~1-2 hours
        'war', MapMissions([MapMission(1214, 285), MapMission(1008, 401), MapMission(779, 602), MapMission(1140, 600), MapMission(1450, 469), MapMission(840, 767),
            MapMission(1047, 769), MapMission(1325, 774), MapMission(1147, 948), MapMission(1202, 521), MapMission(760, 822), MapMission(709, 646),
            MapMission(954, 190), MapMission(896, 732), MapMission(1400, 753), MapMission(1245, 360), MapMission(646, 392), MapMission(920, 575)], Button(0xF23B27, 5)),
        ; Seas, Monsters, Dragons
        'dragon', MapMissions([MapMission(467, 891), MapMission(599, 534), MapMission(611, 166), MapMission(1476, 740)], Button(0xFFB736, 5)),
        'monster', MapMissions([MapMission(960, 772), MapMission(1097, 522), MapMission(873, 422), MapMission(542, 947, true)], Button(0x521770, 5)), ; 542, 947 - эту только принудительно кликать
        'sea', MapMissions([MapMission(1137, 312), MapMission(374, 972), MapMission(1245, 819), MapMission(836, 944, true)], Button(0x68E5F7, 5)) ; 836, 944 - эту только принудительно кликать
    )

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

    static CheckMissions(force := false){
        ; Проверить, есть ли не задания на карте и попытаться их начать.
        if (this.CheckSquad() || force == true)
        {
            ; Мисси при событии "Мировое господство"
            DebugLog.Log("=== Прокликиваем подарки ===")
            this.missions.Get('mystery').EachMapMissions(force, false)

            for mission_type in this.Get_Priority()
            {
                DebugLog.Log('=== Прокликиваем ' mission_type ' ===')
                this.missions.Get(mission_type).EachMapMissions(force, false)
            }
        }
    }

    static CheckSquad() {
        return Tools.PixelSearch(646, 946, 816, 1016, 0xF9E7CE, 1)
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
                this.DoWMMission(630, 700, 890, 770) ; Подземелье 1
                DebugLog.Log("Подземелье 2")
                this.DoWMMission(1027, 707, 1288, 775) ; Подземелье 2
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
                DebugLog.Log("Бой длился " Round((A_TickCount - start_time) / 1000) " секунд" )
        }
        else
            return 0
    }

    static Get_Priority() {
        defaults := Map(
            'monster', '',
            'sea', '',
            'dragon', '',
            'scout', '',
            'adventure', '',
            'war', '')
        
        priority := Firestone.CurrentSettings.Get('map_missions_priority', 'monster, sea, dragon, scout, adventure, war')
        priority := StrSplit(priority, ",", " `t`n`r")
        
        ; Заполняем список, проверяя, что такой тип миссий у нас есть.
        list := []
        for p in priority
        {
            if defaults.Has(p)
                list.Push(p)
        }

        ; пробегаемся по списку типов и добавляем типы миссий, которых не хватает в конец
        for d in defaults
        {
            found := false
            for p in priority
            {
                if p == d
                {
                    found := true
                    break
                }
            }

            if !found
                list.Push(d)
        }

        return list
    }
}