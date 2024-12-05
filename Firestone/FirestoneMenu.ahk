Class FirestoneMenu extends Menu {
    __New() {
        this.FirestoneRunMenu := Menu()

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
        this.Add('Действия', this.FirestoneRunMenu)
        
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

        this.CreateSubMenu()
    }

    CreateSubMenu() {
        this.FirestoneRunMenu.Add('Проверить почту', ObjBindMethod(FirestoneController, 'RunMailbox'))
        this.FirestoneRunMenu.Add('Прокачка стража', ObjBindMethod(FirestoneController, 'RunGuard'))
        this.FirestoneRunMenu.Add('Прокачать героев', ObjBindMethod(FirestoneController, 'RunHerosUpgrades'))
        this.FirestoneRunMenu.Add('Открыть сундуки', ObjBindMethod(FirestoneController, 'RunBags'))
        this.FirestoneRunMenu.Add('Сканировать цвета в сумках', ObjBindMethod(FirestoneController, 'RunBagsColors'))
        
    }
}
