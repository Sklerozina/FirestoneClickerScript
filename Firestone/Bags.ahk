Class Bags {
    __New(Firestone) {
        this.Firestone := Firestone
        this.Chests := Chests(this.Firestone)
    }

    Do() {
        DebugLog.Log("Сумки", "`n")
        this.Firestone.Press("{B}")

        ; this.OpenChests()
        this.Chests.Open()
    
        this.Firestone.Esc()
    }
}