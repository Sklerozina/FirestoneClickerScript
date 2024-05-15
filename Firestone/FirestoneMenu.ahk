Class FirestoneMenu {
    static Menu := Menu()

    static Create() {
        this.Menu.Add("Включить", this.OnOff) ; вкл/выкл
        this.Menu.Add("Режим престижа", this.PrestigeModeOnOff)
    }

    static OnOff(Item, *) {
        RunOnOff()
    }

    static PrestigeModeOnOff(Item, *) {
        PrestigeModeOnOff()
    }
}
