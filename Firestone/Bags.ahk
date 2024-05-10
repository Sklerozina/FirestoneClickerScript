Class Bags {
    static box_coordinates := ["1808:776", "1659:776", "1501:776", "1808:639", "1659:639", "1501:639", "1808:478", "1659:478", "1501:478", "1808:318", "1659:318", "1501:318", "1808:172", "1659:172", " 1501:172"]

    static Do() {
        Firestone.Press("{B}")

        this.OpenBoxes()
    
        Firestone.Esc()
    }

    static OpenBoxes() {
        Firestone.Click(1373, 548, 500)
        
        i := 0
        For coords in this.box_coordinates
        {
            box_opened := false
            coords := StrSplit(coords, ":")
            x := coords[1]
            y := coords[2]
    
            i += 1
            if (Tools.PixelSearch(x-10, y-10, x+10, y+10, 0x9E7F67, 1))
            {
                ; MsgBox "В " . i . " пусто!"
                continue
            }
    
            ; MsgBox "Сундук обнаружен в слоте " . i . " по координатам " . x . ":" . y
            
            Firestone.Click(x, y, 1000)
    
            ;; Проверяем, что сундук и правда открылся, а не ложное срабатывание
            if !Tools.PixelSearch(590-10, 86-10, 1301+10, 851+10, 0x9CC4E3, 1)
            {
                Tools.Sleep 1000
                continue
            }

            if Tools.PixelSearch(631, 754, 1272, 825, 0x365E91, 1)
            {
                ; MsgBox "Этот сундук нельзя открыть!"
                Firestone.Esc()
                continue
            }

            if Firestone.Buttons.Green.FindAndClick(1283, 696, 1301, 851) ; x50
                box_opened := true
            else if Firestone.Buttons.Green.FindAndClick(1153, 696, 1176, 851) ; x25
                box_opened := true
            else if Firestone.Buttons.Green.FindAndClick(863, 696, 1053, 851) ; x10
                box_opened := true

            MouseMove 0, 0

            loop 20 ;; Ждём распаковку
            {
                ;; Проверяем наличие зелёной кнопки
                Firestone.Buttons.Green.WaitAndClick(835, 804, 1085, 869, 250)
                
                ;; проверяем наличие крестика
                if Firestone.Icons.Close.WaitAndClick(1817-15, 52-15, 1817+15, 52+15, 250)
                    break
                    
                Tools.Sleep 1000 ;; продолжаем ждать
            }
        }
    }
}