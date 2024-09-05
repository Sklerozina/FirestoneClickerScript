Class Firestone {
	Buttons := {
		Green: Button(this, 0x0AA008),
		Red: Button(this, 0xE7473F),
		Orange: Button(this, 0xFBAC46),
        Blue: Button(this, 0x1289FF),
        White: Button(this, 0xFFFFFF),
	}

    Icons := {
        Red: Button(this, 0xF30000),
        Close: Button(this, 0xFF620A)
    }

    Window := unset

    hwid := unset
    Settings := unset
    saved_mouse_position_x := 0
    saved_mouse_position_y := 0
    prestige_mode := false

    __New(hwid) {
        this.hwid := hwid

        this.Window := FirestoneWindow(hwid)

        this.SetCurrentSettings()

        this.Mailbox := Mailbox(this)
        this.HerosUpgrades := HerosUpgrades(this)
        this.Magazine := Magazine(this)
        this.Merchant := Merchant(this)
        this.Tavern := Tavern(this)
        this.Alchemy := Alchemy(this)
        this.Guard := Guard(this)
        this.Mechanic := Mechanic(this)
        this.Guild := Guild(this)
        this.Library := Library(this)
        this.Oracle := Oracle(this)
        this.WarCampaignMap := WarCampaignMap(this)
        this.Bags := Bags(this)
        this.Quests := Quests(this)
        this.Arena := Arena(this)
        this.Events := Events(this)
    }

    SetCurrentSettings() {
        Settings.Reload()
        ProcessPath := WinGetProcessPath(this.Window.hwid)
    
        this.Settings := Settings.Section(ProcessPath)
    
        defaults := Map(
            'name', '',
            'lvlup_priority', '17',
            'alchemy', '111',
            'oracle_blessings_priority', 0,
            'map_missions_priority', 'monster, sea, dragon, scout, adventure, war',
            'daily_arena', 1,
            'daily_tavern', 1,
            'daily_magazine', 1,
            'daily_merchant', 1,
            'daily_crystal', 1,
            'daily_date', FormatTime(, 'yyyyMMdd'),
            'open_boxes', 0,
            'auto_complete_quests', 0,
            'auto_research', 0,
            'auto_blessings', 0,
            'auto_arena', 0,
            'auto_tavern', 0,
            'auto_tavern_daily_roll', 0,
            'auto_mailbox', 0,
            'auto_merchant', 0,
            'auto_merchant_sell_items', 0,
            'auto_guild_crystal', 0,
            'auto_events', 0,
            'auto_enlightenment', 0,
        )
    
        for key, value in defaults {
            if !this.Settings.Has(key)
                this.Settings.Set(key, value)
        }
    }

    ; Принудительный возврат на главный экран (Много раз жмёт Esc, потом кликает на закрытие диалога)
    BackToMainScreen(){
        DebugLog.Log('Возврат на главный экран', "`n")
        game_good := false
        i := 1
        loop 8 {
            DebugLog.Log('Попытка ' . i++)
            this.Window.Activate()

            if i == 6
            {
                ; К этому моменту мы уже должны быть на главном
                DebugLog.Log("Свернуть и развернуть, вдруг поможет?")
                WinMinimize()
                Tools.Sleep(1000)
                WinRestore
                Tools.Sleep(1000)
                this.Window.Activate()
            }
            
            MouseMove 0, 0
            this.Esc(500)
            
            if this.Buttons.Green.Wait(1032, 706, 1059, 780, 500) {
                DebugLog.Log('Кнопка найдена')
                ; Хорошо, мы на главном экране, можно продолжать скрипт
                this.Click 1537, 275, 500
                game_good := true
                break
            } else {
                DebugLog.Log('Кнопка не найдена')
                DebugLog.Log('Проверяем не появлось ли окно `"Вам нравится игра?`"')
                if Tools.WaitForSearchPixel(928, 609, 948, 684, 0xFF7760, 1, 500) {
                    DebugLog.Log('Окно обнаружено')
                    ; Хорошо, мы на главном экране, можно продолжать скрипт
                    this.Click 1398, 279, 500 ;; Клик по окошку "Нравится игра?"
                }
                else
                {
                    DebugLog.Log('Окно не обнаружено')
                }

                ; Возможно открылся новый герой?
                if Tools.PixelSearch(702, 135, 783, 176, 0xE31923, 1) {
                    DebugLog.Log('Новый герой?')
                    this.TelegramSend('Доступен новый герой!', true)
                    Firestone.Click(509, 524)
                }
            }
        }

        if !game_good {
            DebugLog.Log('Игра сломалась!')
            this.TelegramSend("Игра сломалась!")
            throw 'Игра сломалась!'
        }
    }

    ResetDailys() {
        date := FormatTime(, 'yyyyMMdd')

        if this.Settings.Get('daily_date', date) == date
            return

        DebugLog.Log("Сброс дейликов! Новый день!")
        this.Settings.Set('daily_merchant', 0)
        this.Settings.Set('daily_arena', 0)
        this.Settings.Set('daily_tavern', 0)
        this.Settings.Set('daily_crystal', 0)
        this.Settings.Set('daily_magazine', 0)
        this.Settings.Set('daily_date', date)
    }

    ; Кнопка города
    City() {
        this.Press("{t}")
    }

    Esc(wait := 1000) {
        this.Press("{ESC}", wait)
    }

	Click(x, y, wait := 1000, clickcount := 1) {
        DebugLog.Log("Клик: (" . Round(x) . "x" . Round(y) . ")")
		this.Window.IsActive()

		loop clickcount
		{
			Click x, y
			Tools.Sleep(wait)
		}
	}

    ScrollUp(times := 10, wait := 250) {
        this.Press("{WheelUp}", 30, times)
        Tools.Sleep(wait)
    }

    ScrollDown(times := 10, wait := 250) {
        this.Press("{WheelDown}", 30, times)
        Tools.Sleep(wait)
    }

	Press(key, wait := 1000, times := 1) {
        DebugLog.Log(key . " (" . times . ")")
		this.Window.IsActive()
	
        loop times
        {
            Send key
		    Tools.Sleep(wait)
        }
	}

    TelegramSend(text, silent := false) {
        chatid :=  Settings.Section('GENERAL').Get('TELEGRAM_CHAT_ID', 0)
        token := Settings.Section('GENERAL').Get('BOT_TOKEN', '')
    
        if chatid == 0 || token == ""
            return

        name := this.Settings.Get('name', '') != '' ? this.Settings.Get('name', '') : WinGetProcessPath(Firestone.hwid)
        
        text := "<b>" name "</b>`n`n" text
        return Tools.TelegramSend(text, chatid, token, silent)
    }
}
