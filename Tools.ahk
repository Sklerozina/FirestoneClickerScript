Class Tools {
    static WaitForSearchPixel(x1, y1, x2, y2, color, variation := 0, timeout := 30000) {
        t := 0
        while t <= timeout
        {
            if PixelSearch(&OutputX, &OutputY, x1, y1, x2, y2, color, variation)
            {
                return true
            }
            this.Sleep 250
            t += 250
        }
    
        return false
    }

    static PixelSearch(x1, y1, x2, y2, color, variation) {
        return PixelSearch(&FoundX, &FoundY, x1, y1, x2, y2, color, variation)
    }

    static Sleep(m := 1000) {
        MouseGetPos(&Mx1, &My1)
    
        Sleep m
    
        MouseGetPos(&Mx2, &My2)
    
        ; Если мышка двигалась пока спали, пропускаем задачу
        If((Mx1 != Mx2) && (My1 != My2) || A_TimeIdlePhysical <= m) {
            throw 'Мышка двигалась или было нажатие клавиатуры.'
        }
    }
}