Class Oracle {
    ; Координате левого верхнего угла красных иконок благословений xy+40
    static blessings_coordinates := Map(
        1,  [1421, 160], ; Престижность
        2,  [1588, 203], ; Дождь из золота
        3,  [1706, 323], ; Герои с маной
        4,  [1751, 490], ; Герои с яростью
        5,  [1709, 658], ; Герои с эенергией
        6,  [1587, 777], ; Специализация танка
        7,  [1420, 824], ; Специализация целителя
        8,  [1254, 777], ; Специализация бойца
        9,  [1133, 655], ; Кулачный бой
        10, [1090, 490], ; Точность
        11, [1132, 326], ; Заклинания
        12, [1256, 204], ; Сила стража
        13, [1430, 478], ; Судьба
    )

    static Do() {
        DebugLog.Log("Оракул", "`n")
        
        ; Проверяем, висит ли красный значёк у здания.
        if !Firestone.Icons.Red.Check(1114, 935, 1152, 970)
            return
    
        Firestone.Click(1026, 911, 500)
    
        this.CollectDailyReward()
    
        this.Rituals()

        this.Blessings()
        
        Firestone.Esc()
    }

    static CollectDailyReward() {
        ; Забрать ежедневный бесплатный подарок оракула
        if Firestone.Icons.Red.Check(860, 660, 903, 695)
        {
            DebugLog.Log("Сбор бесплатной ежедневной награды")
            Firestone.Click(824, 738, 500)

            if PixelGetColor(467, 815) == 0x5B5EAA
            {
                Firestone.Click(641, 739, 500)
            }

            Firestone.Esc()
        }
    }

    static Blessings() {
        ; Если автоматические благословения отключены, выходим
        if !Firestone.CurrentSettings.Get('auto_blessings', 0)
            return

        DebugLog.Log("== Благословения ==")
        ; Красный значок у вкладки благословений
        if !Firestone.Icons.Red.Check(868, 491, 903, 525) {
            return
        }

        Firestone.Click(823, 562) ; Переход на вкладку благословений

        blessings := this.blessings_coordinates.Clone()
        blessings_priority := Firestone.CurrentSettings.Get('oracle_blessings_priority', 0)

        if Firestone.CurrentSettings.Get('oracle_blessings_priority', 0) != 0
        {
            DebugLog.Log("Поиск приоритетных благословений...")
            blessings_priority := StrSplit(blessings_priority, ',', '`n`r`t ')
            for n in blessings_priority
            {
                n := Integer(n)
                if n > 0 && n < 13
                {
                    if coords := blessings.Get(n, 0) {
                        blessings.Delete(n)
                        this.UpgradeBlessing(coords[1], coords[2], n)
                    }
                }
            }
        }

        DebugLog.Log("Поиск благословений...")
        for num, coords in blessings
        {
            this.UpgradeBlessing(coords[1], coords[2], num)
        }
    }

    static Rituals() {
        DebugLog.Log("== Ритуалы ==")
        ;; Проверяем, висит ли красный значок у ритуалов.
        if !Firestone.Icons.Red.Check(860, 317, 903, 356) {
            return
        }
    
        Firestone.Click 825, 393, 500
    
        ; Проверяем зелёные кнопки и кликаем
        rituals := [
            [1050, 440, 1100, 510], ; Гармония
            [1460, 440, 1520, 510], ; Безмятежность
            [1050, 790, 1100, 850], ; Концентрация
            [1460, 790, 1520, 850] ; Послушание
        ]
        clicks := 0

        DebugLog.Log("Поиск новых ритуалов или завершение...")
        loop 2
        {
            for ritual in rituals
            {
                if Firestone.Buttons.Green.CheckAndClick(ritual[1], ritual[2], ritual[3], ritual[4])
                {
                    clicks += 1
                    MouseMove 0, 0
                    break ; Прерываем этот цикл, если сделали клик.
                }

                if clicks >= 2 ; Если 2 клика сделали, то можно заврешать циклы.
                    break 2 ; по идее это не нужно, но пусть будет
            }
        }
    }

    static UpgradeBlessing(x, y, num) {
        if Firestone.Icons.Red.Check(x, y, x+40, y+40)
        {
            DebugLog.Log("Прокачиваю благословение номер " num)
            Firestone.Click(x-70, y+70)
            While Firestone.Buttons.Green.WaitAndClick(1337, 754, 1355, 838, 1000)
            {
                Tools.Sleep(500)
                MouseMove 0, 0
            }

            Firestone.Esc()
        }
    }
}
