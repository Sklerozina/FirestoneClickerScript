Class Firestone {
	Buttons := {
		Green: Button(this, 0x0AA008),
		Red: Button(this, 0xE7473F),
		Orange: Button(this, 0xFBAC46),
        Organe_Buy: Button(this, 0xF7A242),
        Blue: Button(this, 0x1289FF),
        White: Button(this, 0xFFFFFF),
        NewGreen: Button(this, 0x54A433),
        Gray: Button(this, 0xA5A2A5, 5)
	}

    Icons := {
        Red: Button(this, 0xF30000),
        Red2: Button(this, 0xFF0000),
        Close: Button(this, 0xFF620A),
    }

    Window := unset

    hwid := unset
    Settings := unset
    saved_mouse_position_x := 0
    saved_mouse_position_y := 0
    prestige_mode := false
    progress_bar_found := 0
    force_restart := false

    __New(hwid) {
        this.hwid := hwid

        this.Window := FirestoneWindow(hwid, this)

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

    Restart() {
        run_string := this.Settings.Get('run_string')
        if run_string == ''
        {
            DebugLog.Log('Строка запуска для игры пустая, не могу запустить!')
            throw 'Строка запуска для игры пустая, не могу запустить!'
        }
            

        if !this.Window.Close()
        {
            DebugLog.Log('Не получается закрыть игру для перезапуска!')
            this.TelegramSend("Не получается закрыть игру для перезапуска!")
            throw 'Не получается закрыть игру для перезапуска!'
        }

        Sleep(30000) ; Всё равно лучше подождать ещё

        if !this.Window.Open(run_string)
        {
            DebugLog.Log('Не получается запустить игру!')
            this.TelegramSend("Не получается запустить игру!")
            throw 'Не получается запустить игру!'
        }

        this.hwid := this.Window.hwid
    }

    SetCurrentSettings() {
        Settings.Reload()
        ProcessPath := WinGetProcessPath(this.Window.hwid)
    
        this.Settings := Settings.Section(ProcessPath)
    
        defaults := Map(
            'name', '',
            'autorun_if_notfound', 0,
            'auto_restart_every_hours', 0,
            'run_string', '',
            'lvlup_priority', '17',
            'alchemy', '111',
            'oracle_blessings_priority', 0,
            'map_missions_priority', 'monster, sea, dragon, scout, adventure, war',
            'screenshot_crystal', 0,
            
            ; Дейли
            'daily_arena', 1,
            'daily_tavern', 1,
            'daily_magazine', 1,
            'daily_merchant', 1,
            'daily_crystal', 1,
            'daily_date', FormatTime(, 'yyyyMMdd'),
            'daily_chaos_rift', 1,
            
            ; коробки
            'open_boxes', 0,
            'open_any', 0,
            'open_common', 0,
            'open_uncommon', 0,
            'open_rare', 0,
            'open_epic', 0,
            'open_legendary', 0,
            'open_mythic', 0,
            'open_wooded', 0,
            'open_iron', 0,
            'open_golden', 0,
            'open_diamond', 0,
            'open_comet', 0,
            'open_lunar', 0,
            'open_solar', 0,
            'open_mystery_box', 0,
            'open_oracles_gift', 0,

            ; auto
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
            'auto_chaos_rift', 0,
            'auto_guard_holy_upgrade', 0,
            'auto_event_mode', 0,
            'auto_map_refresh_gems', 0,
            'auto_scarab_game', 0,
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

            if !this.CheckLoadProgressBar()
                this.progress_bar_found := 0
                
            
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
                    this.Click(509, 524)
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
        this.Settings.Set('daily_chaos_rift', 0)
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
        this.CheckWhiteScreen()
        this.CheckLoadProgressBar()

		loop clickcount
		{
			Click x, y
			Tools.Sleep(wait)
		}
	}

    ScrollUp(times := 10, wait := 500) {
        this.Press("{WheelUp}", 30, times)
        Tools.Sleep(wait)
    }

    ScrollDown(times := 10, wait := 500) {
        this.Press("{WheelDown}", 30, times)
        Tools.Sleep(wait)
    }

	Press(key, wait := 1000, times := 1) {
        DebugLog.Log(key . " (" . times . ")")
		this.Window.IsActive()
        this.CheckWhiteScreen()
        this.CheckLoadProgressBar()
	
        loop times
        {
            Send(key)
		    Tools.Sleep(wait)
        }
	}

    CheckLoadProgressBar() {
        if PixelSearch(&oX, &oY, 0, 995, 8, 1016, 0xFAE56A, 3)
        {
            this.progress_bar_found += 1

            if this.progress_bar_found >= 3
            {
                this.TelegramSend("Обнаружена полоса загрузки, пытаюсь перезапустить!")
                this.force_restart := true
            }

            DebugLog.Log('Обнаружена полоса загрузки, прервываю работу!')
            throw 'Обнаружена полоса загрузки, прервываю работу!'
        }
        else
            return false
    }

    CheckWhiteScreen() {
        if PixelGetColor(1822, 26) == 0xFFFFFF && PixelGetColor(38, 609) == 0xFFFFFF
        {
            DebugLog.Log('Обнаружен экран покупки, прервываю работу!')
            this.TelegramSend("Обнаружен экран покупки!")
            throw 'Обнаружен экран покупки!'
        } 
    }

    TelegramSend(text, silent := false) {
        chatid :=  Settings.Section('GENERAL').Get('TELEGRAM_CHAT_ID', 0)
        token := Settings.Section('GENERAL').Get('BOT_TOKEN', '')
    
        if chatid == 0 || token == ""
            return

        name := this.Settings.Get('name', '') != '' ? this.Settings.Get('name', '') : WinGetProcessPath(Firestone.Window.hwid)
        
        text := "<b>" name "</b>`n`n" text
        return Tools.TelegramSend(text, chatid, token, silent)
    }
}
