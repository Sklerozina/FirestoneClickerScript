Class FirestoneWindow {
    hwid := unset
    process_path := unset
    last_start := A_Now

    __New(hwid) {
        this.hwid := hwid
        this.process_path := WinGetProcessPath(hwid)
        this.BorderlessAndResize()
    }

    Close() {
        ; Если окна нет, то пропускаем
        if !WinExist(this.hwid)
            return true

        WinClose(this.hwid)
        if WinWaitClose(this.hwid,, 120000)
            return true
        else
            return false
    }

    Open(run_string) {
        Run(run_string)
        if WinWait('ahk_exe ' this.process_path,, 300000)
        {
            this.hwid := Integer(WinGetID('ahk_exe ' this.process_path))
            Sleep(30000) ; 30 секунд на запуск?
            this.BorderlessAndResize()
            this.last_start := A_Now
            return true
        }
        else
        {
            return false
        }
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
                MsgBox("Не могу сделать окну нужный размер или убрать рамку! Убедитесь, что игра в оконном режиме!")
                Exit
            }

            Sleep 500
        }
    }

    Exist() {
        return WinExist(this.hwid)
    }

    Activate() {
        If WinExist(this.hwid) {
            WinActivate
            Sleep(500)

            if !WinActive(this.hwid) ; Есть у меня непонятный бог, что окно не весгда активируется 🤔
            {
                WinMinimize(this.hwid)
                Sleep(1000)
                WinRestore(this.hwid)
                WinActivate
            }
        }
            
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