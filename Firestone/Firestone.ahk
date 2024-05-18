Class Firestone {
	static Buttons := {
		Green: Button(0x0AA008),
		Red: Button(0xE7473F),
		Orange: Button(0xFBAC46),
        Blue: Button(0x1289FF)
	}

    static Icons := {
        Red: Button(0xF30000),
        Close: Button(0xFF620A)
    }

    static Window := unset

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
            'auto_research', 0,
            'lvlup_priority', '17',
            'open_boxes', 0,
            'auto_complete_quests', 0,
            'auto_arena', 0,
            'daily_tavern', false,
            'alchemy', '111'
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
                DebugLog.Log("Клик в центр экрана, вдруг поможет")
                Firestone.Click(912, 481)
            }

            Firestone.Window.Activate() ; В попытках победить баг или не баг, когда игра как бы теряет фокус но Ahk это не замечает
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
            }
        }

        if !game_good {
            DebugLog.Log('Игра сломалась!')
            this.TelegramSend("Игра сломалась!")
            throw 'Игра сломалась!'
        }
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

    static TelegramSend(text) {
        chatid :=  Settings.Section('GENERAL').Get('TELEGRAM_CHAT_ID', 0)
        token := Settings.Section('GENERAL').Get('BOT_TOKEN', "")
    
        if chatid == 0 {
            Settings.Section('GENERAL').Set('TELEGRAM_CHAT_ID', 'NONE')
        }

        if token == "" {
            Settings.Section('GENERAL').Set('BOT_TOKEN', "")
        }
    
        if chatid == "NONE" || chatid == 0 || token == ""
            return
    
        return Tools.TelegramSend(text, chatid, token)
    }
}
