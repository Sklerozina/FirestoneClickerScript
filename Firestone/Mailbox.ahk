Class Mailbox {
    static mails := [
        [720, 199],
        [720, 337],
        [720, 480],
        [720, 619],
        [720, 757],
        [720, 896],
    ]

    static Do() {
        if Firestone.CurrentSettings.Get('auto_mailbox', 0) == 0
            return

        ; Проверяем значок у иконки почты
        if !Firestone.Icons.Red.Check(97, 718, 128, 748)
            return

        if !Tools.PixelSearch(63-5, 750-5, 63+5, 750+5, 0xFED279, 1) ; На всякий случай проверим, что в облати есть иконка почты
            return

        DebugLog.Log('== Почта ==')
        Firestone.Click(58, 764) ; Клик на иконку почты

        Firestone.Click(514, 959) ; Клик в самое нижнее письмо, чтобы новые можно было найти по цвету
        
        Firestone.ScrollUp(30) ; Прокрутка вверх, на всякий случай
        Tools.Sleep(1000) ; Дать интерфейсу успокоиться

        DebugLog.Log('Проверяю почту...')
        for mail in this.mails
        {
            this.CheckMail(mail[1], mail[2])
        }

        Firestone.Esc()
    }

    static CheckMail(x, y) {
        DebugLog.Log('Проверяю письмо в (' x 'x' y ')')
        if Tools.PixelSearch(x-5, y-20, x+5, y+20, 0xE4CCB2, 1)
        {
            DebugLog.Log('Нашёл письмо (' x 'x' y ')')
            Firestone.Click(x, y)
        }
        else
            return false

        if Firestone.Buttons.Green.CheckAndClick(1098, 753, 1138, 816)
        {
            DebugLog.Log('Забрал награду')
            ; Здесь надо сделать проверу на появление второй кнопки для подтверждения получения награды...
            Firestone.Buttons.Green.WaitAndClick(1058, 640, 1096, 706, 5000)
            return true
        }
            
    }
}