Class FirestoneMenu extends Menu {
    __New() {
        this.Add(AppVersion, (*) => (0))
        this.Disable(AppVersion)
        this.Add()
        this.Add("Включить", (*) => (
            RunOnOff()
        )) ; вкл/выкл
        this.Add("Режим престижа", (*) => (
            PrestigeModeOnOff()
        ))
        this.Add()
        this.Add("Пометить все дейлики сделанными", (*) => (
            SetAllDailyComplete()
        ))
        this.Add("Сбросить дейлики (Сделать все ещё раз)", (*) => (
            SetAllDailyUncomplete()
        ))
        this.Add()
        this.Add("Включить логи", (*) => (
            LogsOnOff()
        ))
        this.Add("Перезапустить скрипт", (*) => (
            Reload()
        ))
        this.Add()
        this.Add("Закрыть меню", (*) => (0))
    }
}
