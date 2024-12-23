Class FirestoneController {
    static Firestones := Map()
    static Menu := FirestoneMenu()
    static prestige_mode := false

    static __New() {
        this.FindAllWindows()
    }

    static RestartAllWindows() {
        for Path, Firestone in this.Firestones
        {
            Firestone.Restart()
        }
    }

    static FindAllWindows(){
        hwids := WinGetList("ahk_exe Firestone.exe")

        for hwid in hwids {
            path := WinGetProcessPath(hwid)
            this.Firestones.Set(path, Firestone(hwid))
        }
    }

    static GetFirestone(window) {
        path := WinGetProcessPath(window)

        if !this.Firestones.Has(path) {
            MsgBox 'Перезапустите скрипт и попробуйте ещё раз!'
            return false
        }

        return this.Firestones.Get(path)
    }

    static GetFirestoneCursor() {
        MouseGetPos(,, &window)
        return this.GetFirestone(window)
    }

    static RunSingle(Firestone, Method) {
        try
        {
            Firestone.BackToMainScreen()
            Method()
        }
        catch String as err
        {
            DebugLog.Log("Прерываю работу. " . err . " (From Catch)")
            Tp "Прерываю работу. " . err, -2000
        }
    }

    static RunMailbox(*) {
        Firestone := this.GetFirestoneCursor()
        this.RunSingle(Firestone, ObjBindMethod(Firestone.Mailbox, 'Do', true))
    }

    static RunGuard(*) {
        Firestone := this.GetFirestoneCursor()
        try
        {
            Firestone.BackToMainScreen()
            Firestone.City()
            Firestone.Guard.Do(true)
            Firestone.Esc()
        }
        catch String as err
        {
            DebugLog.Log("Прерываю работу. " . err . " (From Catch)")
            Tp "Прерываю работу. " . err, -2000
        }
    }

    static RunHerosUpgrades(*) {
        Firestone := this.GetFirestoneCursor()
        this.RunSingle(Firestone, ObjBindMethod(Firestone.HerosUpgrades, 'Do'))
    }

    static RunBags(*) {
        Firestone := this.GetFirestoneCursor()
        this.RunSingle(Firestone, ObjBindMethod(Firestone.Bags, 'Do'))
    }

    static RunBagsColors(*) {
        Firestone := this.GetFirestoneCursor()
        this.RunSingle(Firestone, ObjBindMethod(Firestone.Bags.Chests, 'WriteColors'))
    }
}