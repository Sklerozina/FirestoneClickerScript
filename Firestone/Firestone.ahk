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
            this.Esc(250)
            
            if this.Buttons.Green.Wait(1032, 706, 1059, 780, 1000) {
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
		FindFirestoneWindowAndActivate

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
		FindFirestoneWindowAndActivate
	
		Send key
		Tools.Sleep(wait)
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
