Class FirestoneWindow {
    hwid := unset

    __New(hwid) {
        this.hwid := hwid
        this.BorderlessAndResize()
        this.Activate()
    }

    BorderlessAndResize() {
        SetWinDelay(500)

        i := 0
        loop 5
        {
            i += 1
            
            this.Restore()

            if this.SetBorderless() && this.SetSize()
                break
            
            if i >= 5
            {
                MsgBox("Не могу сделать окну нужный размер или убрать рамку!")
                Exit
            }

            Sleep 500
        }
    }

    Activate() {
        If WinExist(this.hwid)
            WinActivate
        else
        {
            DebugLog.Log('Окно с игрой не найдено!')
            throw 'Окно с игрой не найдено!'
        }
    }

    IsActive() {
        if !WinExist(this.hwid)
        {
            DebugLog.Log('Окно с игрой не найдено!')
            throw 'Окно с игрой не найдено!'
        }
    
        if !WinActive(this.hwid)
        {
            DebugLog.Log('Окно перестало быть активным!')
            throw 'Окно перестало быть активным!'
        }
    }

    Restore() {
        minmax := WinGetMinMax(this.hwid)
        if minmax != 0
            WinRestore(this.hwid)
    
    }

    SetBorderless() {
        if (WinGetStyle(this.hwid) != 336265216)
            WinSetStyle(-0xC40000, this.hwid)
        else
            return true

        return false
    }

    SetSize() {
        WinGetPos(&x, &y, &w, &h, this.hwid)
        if (x != 0 || y != 0 || w != 1920 || h != 1018)
            WinMove(0, 0, 1920, 1018, this.hwid)
        else
            return true

        return false
    }
}