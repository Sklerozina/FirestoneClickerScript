Class Tools {
    static WaitForSearchPixel(x1, y1, x2, y2, color, variation := 0, timeout := 30000) {
        t := 0
        while t <= timeout
        {
            if PixelSearch(&OutputX, &OutputY, x1, y1, x2, y2, color, variation)
            {
                return true
            }
            this.Sleep 250
            t += 250
        }
    
        return false
    }

    static PixelSearch(x1, y1, x2, y2, color, variation) {
        return PixelSearch(&FoundX, &FoundY, x1, y1, x2, y2, color, variation)
    }

    static CheckForImage(X1, Y1, X2, Y2, image) {
        try
        {
            return ImageSearch(&OutputX, &OutputY, X1, Y1, X2, Y2, image)
        }
        catch as exc
            MsgBox "Возникла неожиданная ошибка с поиском изображения:`n" exc.Message
    }

    static Sleep(m := 1000) {
        MouseGetPos(&Mx1, &My1)
    
        Sleep m
    
        MouseGetPos(&Mx2, &My2)
    
        ; Если мышка двигалась пока спали, пропускаем задачу
        If((Mx1 != Mx2) && (My1 != My2) || A_TimeIdlePhysical <= m) {
            throw 'Мышка двигалась или было нажатие клавиатуры.'
        }
    }

    static TelegramSend(text, chatid) {
        token := "7169992032:AAF341dSqS8K94V-immfgNaHTkjmPIsJoDc"
        data:= "chat_id=" . chatid .
            "&text=" . text .
            "&parse_mode=HTML" .
            "&disable_web_page_preview=1"
    
        ; https://learn.microsoft.com/en-us/windows/win32/winhttp/winhttprequest
        web := ComObject('WinHttp.WinHttpRequest.5.1')
        web.Open('POST', "https://api.telegram.org/bot" . token . "/sendMessage", True)
        web.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
        web.Send(data)
        web.WaitForResponse()
        return web.ResponseText
    }
}
