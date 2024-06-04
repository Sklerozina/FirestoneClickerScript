Class Firestone {
	static Buttons := {
		Green: Button(0x0AA008),
		Red: Button(0xE7473F),
		Orange: Button(0xFBAC46),
        Blue: Button(0x1289FF),
        White: Button(0xFFFFFF),
	}

    static Icons := {
        Red: Button(0xF30000),
        Close: Button(0xFF620A)
    }

    static Window := unset
    static Menu := FirestoneMenu()

    static hwid := unset
    static hwids := unset
    static CurrentSettings := unset
    static saved_mouse_position_x := 0
    static saved_mouse_position_y := 0
    static prestige_mode := false

    static Set(hwid) {
        this.hwid := hwid

        this.Window := FirestoneWindow(hwid)

        this.SetCurrentSettings()
    }

    static SetCurrentSettings() {
        Settings.Reload()
        ProcessPath := WinGetProcessPath(this.Window.hwid)
    
        this.CurrentSettings := Settings.Section(ProcessPath)
    
        defaults := Map(
            'name', '',
            'lvlup_priority', '17',
            'open_boxes', 0,
            'auto_complete_quests', 0,
            'daily_arena', 1,
            'daily_tavern', 1,
            'daily_magazine', 1,
            'daily_merchant', 1,
            'daily_crystal', 1,
            'alchemy', '111',
            'oracle_blessings_priority', 0,
            'auto_research', 0,
            'auto_blessings', 0,
            'auto_arena', 0,
            'auto_tavern', 0,
            'auto_tavern_daily_roll', 0,
            'auto_mailbox', 0,
            'auto_merchant', 0,
            'auto_guild_crystal', 0,
        )
    
        for key, value in defaults {
            if !this.CurrentSettings.Has(key)
                this.CurrentSettings.Set(key, value)
        }
    }

    static FindAllWindows(){
        hwids := WinGetList("ahk_exe Firestone.exe")

        return hwids
    }

    ; Принудительный возврат на главный экран (Много раз жмёт Esc, потом кликает на закрытие диалога)
    static BackToMainScreen(){
        DebugLog.Log('Возврат на главный экран', "`n")
        game_good := false
        i := 1
        loop 8 {
            DebugLog.Log('Попытка ' . i++)

            if i == 6
            {
                ; К этому моменту мы уже должны быть на главном
                DebugLog.Log("Свернуть и развернуть, вдруг поможет?")
                WinMinimize()
                Tools.Sleep(1000)
                WinRestore
                Tools.Sleep(1000)
                Firestone.Window.Activate()
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

    static ResetDailys() {
        ; Магазин сбрасывается отдельно
        Firestone.CurrentSettings.Set('daily_merchant', 0)
        Firestone.CurrentSettings.Set('daily_arena', 0)
        Firestone.CurrentSettings.Set('daily_tavern', 0)
        Firestone.CurrentSettings.Set('daily_crystal', 0)
    }

    ; Кнопка города
    static City() {
        this.Press("{t}")
    }

    static Esc(wait := 1000) {
        this.Press("{ESC}", wait)
    }

	static Click(x, y, wait := 1000, clickcount := 1) {
        DebugLog.Log("Клик: (" . Round(x) . "x" . Round(y) . ")")
		this.Window.IsActive()

		loop clickcount
		{
			Click x, y
			Tools.Sleep(wait)
		}
	}

    static ScrollUp(times := 10) {
        this.Press("{WheelUp}", 30, times)
    }

    static ScrollDown(times := 10) {
        this.Press("{WheelDown}", 30, times)
    }

	static Press(key, wait := 1000, times := 1) {
        DebugLog.Log(key . " (" . times . ")")
		this.Window.IsActive()
	
        loop times
        {
            Send key
		    Tools.Sleep(wait)
        }
	}

    static TelegramSend(text, silent := false) {
        chatid :=  Settings.Section('GENERAL').Get('TELEGRAM_CHAT_ID', 0)
        token := Settings.Section('GENERAL').Get('BOT_TOKEN', '')
    
        if chatid == 0 || token == ""
            return

        name := this.CurrentSettings.Get('name', '') != '' ? this.CurrentSettings.Get('name', '') : WinGetProcessPath(Firestone.hwid)
        
        text := "<b>" name "</b>`n`n" text
        return Tools.TelegramSend(text, chatid, token, silent)
    }
}
