Class Tavern {
    static Do() {
        if !Firestone.Icons.Red.Check(814, 910, 848, 949) ; У Таверны нет значка, выходим
            return

        Firestone.Click(717, 911) ; Заходим в Таверну из города
        
        this.CollectTokens()

        Firestone.Esc()
    }

    static CollectTokens() {
        Firestone.Click(1731, 42) ; Клик по иконке плюса для обмена пива
    
        while Tools.WaitForSearchPixel(344-5, 437-5, 344+5, 437+5, 0x3CA8E1, 1, 1000) {
            Firestone.Click(521, 509)
        }
    
        Firestone.Esc()
    }
}