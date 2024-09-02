Class FirestoneController {
    static Firestones := Map()
    static Menu := FirestoneMenu()
    static prestige_mode := false

    static __New() {
        this.FindAllWindows()
    }

    static FindAllWindows(){
        hwids := WinGetList("ahk_exe Firestone.exe")

        for hwid in hwids {
            path := WinGetProcessPath(hwid)
            if !this.Firestones.Has(path)
                this.Firestones.Set(path, Firestone(hwid))
            else
                this.Firestones.Get(path).hwid := hwid
        }
    }
}