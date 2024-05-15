Class FirestoneMenu {
    static Menu := Menu()

    static Create() {
        this.Menu.Add(AppVersion, (*) => (false))
        this.Menu.Disable(AppVersion)
        this.Menu.Add()
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
