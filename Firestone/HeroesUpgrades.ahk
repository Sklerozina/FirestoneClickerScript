Class HerosUpgrades {
    static coords := Map(
        1, [1652, 134, 1776, 219], ; Общее усиление
        2, [1652, 251, 1776, 323],
        3, [1652, 366, 1776, 438],
        4, [1652, 479, 1776, 551],
        5, [1652, 593, 1776, 665],
        6, [1652, 704, 1776, 776],
        7, [1652, 817, 1776, 889]
    )

    static Do(lvlup_priority := "1765432", prestige_mode := false) {   
        DebugLog.Log("Прокачка героев", "`n")
        Firestone.Press("{u}", 500)
    
        if prestige_mode
        {
            this.UpgradeHero(1) ; 1
            for slot in [1, 7, 6, 5, 4, 3, 2]
            {
                this.UpgradeHero(slot, 5) ; 1
            }
        } else {
            loop parse lvlup_priority {
                switch A_LoopField {
                    case "1":
                        this.UpgradeHero(1) ; 1
                    case "2":
                        this.UpgradeHero(2, 5) ; 2
                    case "3":
                        this.UpgradeHero(3, 5) ; 3
                    case "4":
                        this.UpgradeHero(4, 5) ; 4
                    case "5":
                        this.UpgradeHero(5, 5) ; 5
                    case "6":
                        this.UpgradeHero(6, 5) ; 6
                    case "7":
                        this.UpgradeHero(7, 5) ; 7
                }
            }
        }
    
        Firestone.Press("{u}")
    }

    static UpgradeHero(slot, clicks := 1) {
        coords := this.coords.Get(slot)
        if Firestone.Buttons.Green.CheckAndClick(coords[1], coords[2], coords[3], coords[4],,, 200, clicks)
            DebugLog.Log('Прокачал слот ' . slot)
    }
}