Class Chests {
    box_coordinates_mobile := ["1808:776", "1659:776", "1501:776",
    "1808:639", "1659:639", "1501:639",
    "1808:478", "1659:478", "1501:478",
    "1808:318", "1659:318", "1501:318",
    "1808:172", "1659:172", " 1501:172"]
    box_coordinates_pc := ["1837:837", "1712:837", "1586:837",
    "1837:712", "1712:712", "1586:712",
    "1837:588", "1712:588", "1586:588",
    "1837:466", "1712:466", "1586:466",
    "1837:340", "1712:340", "1586:340"]

    chests := Map(
        ; Герои
        'common', 0x4A3429,
        'uncommon', 0xECAC70,
        'rare', 0x554847,
        'epic', 0x243B3C,
        'legendary', 0x68645E, 
        'mythic', 0xA08C8B,
        
        ; Танки
        'wooded', 0x472726,
        'iron', 0x63768D,
        'golden', 0xEDA535,
        'diamond', 0x3F3E3E,
        
        ; Оракул
        'comet', 0xFFCFAD,
        'lunar', 0xF7FFEF,
        'solar', 0x18BAF7,
        'mystery_box', 0x4A04A5,
        'oracles_gift', 0xFFE700,
    )

    __New(Firestone) {
        this.Firestone := Firestone
    }

    CheckColor(x, y, color) {
        return Tools.PixelSearch(x-20, y-20, x+20, y+20, color, 0)
    }

    Open() {
        i := 0
        DebugLog.Log("Проверка слотов...")

        if Tools.PixelSearch(1814-5, 21-5, 1814+5, 21+5, 0xE1CDAC, 1) ; Проверка фона, если фон есть, то интерфейс мобильный
        {
            this.Firestone.Click(1373, 548, 250)
            box_coordinates := this.box_coordinates_mobile
        }
        else ; Иначе интерфейс ПК
        {
            this.Firestone.Click(1485, 434, 250)
            box_coordinates := this.box_coordinates_pc
        }

        MouseMove(0, 0)
        Tools.Sleep(250)

        For coords in box_coordinates
        {
            box_opened := false
            coords := StrSplit(coords, ":")
            x := coords[1]
            y := coords[2]
    
            i += 1
            
            DebugLog.Log("Слот " i " (" x "x" y ")...")

            for name, color in this.chests {
                if this.Firestone.Settings.Get('open_any', 0) == 1
                {
                    if (Tools.PixelSearch(x-5, y-5, x+5, y+5, 0x9E7F67, 0))
                    {
                        ; MsgBox "В " . i . " пусто!"
                        continue
                    }
                    else
                    {
                        DebugLog.Log("Слот " i "(" x "x" y ")...")
                        this.OpenChest(x, y)
                    }

                    continue 2
                }

                if (Tools.PixelSearch(x-5, y-5, x+5, y+5, 0x9E7F67, 0))
                {
                    ; В ячейке пусто и нет смысла искать!
                    continue 2
                }

                if this.Firestone.Settings.Get('open_' . name, 0) != 1
                    continue

                ; Ищем совпадение
                if this.CheckColor(x, y, color) {
                    DebugLog.Log('Нашёл ' name ' в слоте ' i)

                    ; открываем сундуки
                    this.OpenChest(x, y)
                    
                    break
                }
            }
        }
    }

    OpenChest(x, y) {
        this.Firestone.Click(x, y, 1000)
        ;; Проверяем, что сундук и правда открылся, а не ложное срабатывание
        DebugLog.Log("Проверка появления окна...")
        if !Tools.PixelSearch(590-10, 86-10, 1301+10, 851+10, 0x9CC4E3, 1)
        {
            DebugLog.Log("Окно не найдено")
            return
        }

        MouseMove 0, 0

        DebugLog.Log("Поиск кнопок x50 или x25 или x10...")
        if this.Firestone.Buttons.Green.FindAndClick(1283, 696, 1301, 851) ; x50
            box_opened := true
        else if this.Firestone.Buttons.Green.FindAndClick(1153, 696, 1176, 851) ; x25
            box_opened := true
        else if this.Firestone.Buttons.Green.FindAndClick(863, 696, 1053, 851) ; x10
            box_opened := true
        else
        {
            this.Firestone.Esc()
            return
        }

        start_time := A_TickCount
        DebugLog.Log("Ожидаем распаковку...")
        loop 20 ;; Ждём распаковку
        {
            ;; Проверяем наличие зелёной кнопки
            this.Firestone.Buttons.Green.WaitAndClick(835, 804, 1085, 869, 250)
            
            ;; проверяем наличие крестика
            if this.Firestone.Icons.Close.WaitAndClick(1817-15, 52-15, 1817+15, 52+15, 250)
                break
                
            Tools.Sleep 1000 ;; продолжаем ждать
        }
        DebugLog.Log("Распаковка заняла " Round((A_TickCount - start_time) / 1000) " секунд" )
    }

    WriteColors() {
        this.Firestone.Press("{B}")

        DebugLog.Log("Проверка слотов...")

        if Tools.PixelSearch(1814-5, 21-5, 1814+5, 21+5, 0xE1CDAC, 1) ; Проверка фона, если фон есть, то интерфейс мобильный
        {
            this.Firestone.Click(1373, 548, 250)
            box_coordinates := this.box_coordinates_mobile
        }
        else ; Иначе интерфейс ПК
        {
            this.Firestone.Click(1485, 434, 250)
            box_coordinates := this.box_coordinates_pc
        }

        MouseMove(0, 0)
        Tools.Sleep(250)

        chest_colors := Map()

        slots := InputBox("Укажите какие слоты сумки сканировать, через запятую.`nОт 1 до 15.`nНапример: 1,2,3,12", "Сканирование слотов").value
        slots := StrSplit(slots, ",", " ")
        Sleep 500
        scan := Map() ; Какие слоты сканировать на цвета

        for slot in slots
        {
            scan.Set(Integer(slot), "")
        }

        i := 0
        For coords in box_coordinates
        {
            i += 1

            if !scan.Has(i) {
                continue
            }
            coords := StrSplit(coords, ":")
            x := coords[1]
            y := coords[2]
            x_start := x-15
            y_start := y-15
            
            if !chest_colors.Has(i)
                chest_colors.Set(i, Map())

            c := 0
            Loop 30
            {
                c_y := 0
                Loop 30
                {
                    color := String(PixelGetColor(x_start+c, y_start+c_y))

                    if !chest_colors.Get(i).Has(color)
                        chest_colors.Get(i).Set(color, 1)
                    else
                        chest_colors.Get(i).Set(color, chest_colors.Get(i).Get(color)+1)

                    c_y += 1
                }

                c += 1
            }

            DebugLog.Log("Слот " i "(" x "x" y ")...")
        }

        for chest, colors in chest_colors
        {
            DebugLog.Log("Слот " chest " (" x "x" y ")...")
            for color_string, color_count in colors
            {
                if color_count > 2 ; Выводим, если цвет попадается 2 или более раз
                    DebugLog.Log("  " color_string ": " . color_count)
            }
        }
        this.Firestone.Esc()
        MsgBox "я закончил"
        Exit
    }
}