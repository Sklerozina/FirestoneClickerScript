Class Library {
    static buttons := Map(
        1, [483, 880, 507, 950],
        2, [1132, 880, 1165, 950]
    )

    static columns := [
        [30, 485],
        [486, 949],
        [950, 1414],
        [1415, 1884]
    ]

    static research_count := 0

    static Do() {
        DebugLog.Log("Библиотека", "`n")
        
        ; Проверяем, висит ли красный значок у здания.
        if !Firestone.Icons.Red.Check(384, 641, 424, 680)
            return

        Firestone.Click(313, 630) ; Здание библиотеки

        this.Research()

        Firestone.Esc()
    }

    static Research() {
        this.research_count := 0
        DebugLog.Log("== Исследования Firestone ==")
        Firestone.Click(1813, 930) ; Переход в Firestone исследования
    
        MouseMove 0, 0

        if Tools.PixelSearch(445, 939, 461, 976, 0x285483, 1)
        {
            DebugLog.Log("Найдено активное исследование в слоте 1")
            this.research_count += 1
        }
    
        if Tools.PixelSearch(1090, 939, 1105, 976, 0x285483, 1)
        {
            DebugLog.Log("Найдено активное исследование в слоте 2")
            this.research_count += 1
        }
        
        ; Проверка первого слота
        loop 2
        {
            if this.CheckSlot(1)
                this.research_count -= 1

            MouseMove 0, 0
            Tools.Sleep 500
        }
    
        ;; Проверка второго слота
        ; Проверка на оранжевую кнопку, досрочное бесплатное завершение
        ; if CheckForImage(1090, 879, 1301, 958, "*120 images/ResearchFree.png")
        if this.research_count > 0 {
            if this.CheckSlot(2)
            {
                DebugLog.Log("Исследование завершено")
                this.research_count -= 1
            }
                
    
            MouseMove 0, 0
            Tools.Sleep 500
        }
        
        ;; Добавить проверку на второе исследование
        if (this.research_count < 2)
        {
            DebugLog.Log("Поиск новых исследований...")
            i := 1
            loop 3
            {
                ; двигаем в начало, если это второй цикл, таким образом экономим время
                if i == 2
                {
                    Firestone.ScrollUp(50, 1000)
                }
                else if i == 3 ; Двигаем дальше, если это 3-й цикл
                {
                    Firestone.ScrollDown(35)
                }

                sort_columns := Sort("1, 2, 3, 4", "Random N D,")
                DebugLog.Log("Порядок колонок: " sort_columns)
                columns := StrSplit(sort_columns, ",", " ")
              
                for column in columns
                {
                    column := this.columns.Get(Integer(column))
                    slots := Sort("226, 348, 472, 596,  718", "Random N D,")
                    DebugLog.Log("Порядок слотов: " slots)
                    ys := StrSplit(slots, ",", " ")
                    for y in ys
                    {
                        y := Integer(y)
                        if this.FindResearch(y, column[1], column[2])
                        {
                            DebugLog.Log("Начинаем новое исследование")
                            this.research_count += 1
                        }
                            

                        if (this.research_count == 2)
                            break 3
                    }
                }

                Tools.Sleep 200

                i += 1
            }
        }
    }

    static CheckSlot(slot) {
        coords := this.buttons.Get(slot)

        ; Проверка на оранжевую кнопку, досрочное завершение
        ;if CheckForImage(462, 899, 634, 948, "*120 images/ResearchFree.png") ; Пока не удаляю, на случай, если по цвету не будет работать
        DebugLog.Log("Пробуем завершить исследование в слоте " slot "...")
        if Firestone.Buttons.Orange.CheckAndClick(coords[1], coords[2], coords[3], coords[4])
            return true

        ; Проверить зелёную кнопку завершения
        if Firestone.Buttons.Green.CheckAndClick(coords[1], coords[2], coords[3], coords[4])
            return true

        return false
    }

    static FindResearch(row_y, from, to) {
        if PixelSearch(&OutputX, &OutputY, from, row_y, to, row_y, 0x0D49DE, 1)
        {
            ; попробовать кликнуть
            Firestone.Click(OutputX, OutputY)
            MouseMove 0, 0
            ;; Подождать окно принятия
            if Firestone.Buttons.Green.WaitAndClick(669, 707, 928, 775, 1000)
                return true
        }
    }
}