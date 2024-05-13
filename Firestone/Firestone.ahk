Class Firestone {
	static Buttons := {
		Green: Button(0x0AA008),
		Red: Button(0xE7473F),
		Orange: Button(0xFBAC46)
	}

    static Icons := {
        Red: Button(0xF30000),
        Close: Button(0xFF620A)
    }

    ; Принудительный возврат на главный экран (Много раз жмёт Esc, потом кликает на закрытие диалога)
    static BackToMainScreen(){
        game_good := false
        loop 5 {
            MouseMove 0, 0
            this.Esc(500)
            
            if this.Buttons.Green.Wait(1032, 706, 1059, 780, 500) {
                ; Хорошо, мы на главном экране, можно продолжать скрипт
                this.Click 1537, 275, 500
                game_good := true
                break
            } else {
                if Tools.WaitForSearchPixel(928, 609, 948, 684, 0xFF7760, 1, 500) {
                    ; Хорошо, мы на главном экране, можно продолжать скрипт
                    this.Click 1398, 279, 500 ;; Клик по окошку "Нравится игра?"
                }
            }
        }

        if !game_good {
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
		this.IsActive()

		loop clickcount
		{
			Click x, y
			Tools.Sleep(wait)
		}
	}

    static ScrollUp(times := 10) {
        this.Scroll("{WheelUp}", times)
    }

    static ScrollDown(times := 10) {
        this.Scroll("{WheelDown}", times)
    }

    static Scroll(UpOrDown, times) {
        loop times
        {
            Firestone.Press(UpOrDown, 30)
        }
    }

	static Press(key, wait := 1000) {
		this.IsActive()
	
		Send key
		Tools.Sleep(wait)
	}

    static IsActive() {
        global firestone_hwid
        if !WinExist(firestone_hwid)
        {
            throw 'Окно с игрой не найдено!'
        }
    
        if !WinActive(firestone_hwid)
        {
            throw 'Окно перестало быть активным!'
        }
    }

    static FindAllWindows(){
        SetWinDelay(500)

        hwids := WinGetList("ahk_exe Firestone.exe")
        this.BorderlessAndResizeAll(hwids)

        return hwids
    }

    static BorderlessAndResizeAll(hwids) {
        Loop hwids.Length
        {
            i := 0
            hwid := hwids[A_Index]
            loop 5
            {
                i += 1
                    
                if this.SetWindowBorderless(hwid) && this.SetWindowSize(hwid)
                    break
                
                if i >= 5
                {
                    MsgBox("Не могу сделать окну нужный размер или убрать рамку!")
                    Exit
                }

                Sleep 500
            }
        }
    }

    static SetWindowBorderless(hwid) {
        if (WinGetStyle(hwid) != 336265216)
            WinSetStyle(-0xC40000, hwid)
        else
            return true

        return false
    }

    static SetWindowSize(hwid) {
        WinGetPos(&x, &y, &w, &h, hwid)
        if (x != 0 || y != 0 || w != 1920 || h != 1018)
            WinMove(0, 0, 1920, 1018, hwid)
        else
            return true

        return false
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
