Class Magazine {
    static Do() {
        Firestone.Click(1300, 343)
    
        if Tools.PixelSearch(432, 869, 442, 879, 0x5B5EAA, 1)
        {
            Firestone.Click(592, 743, 200)
        }
    
        if Firestone.Icons.Red.Check(1425, 25, 1474, 76)
        {
            Firestone.Click(1381, 91)
            if Tools.PixelSearch(1261, 796, 1404, 841, 0x4CA02E, 1)
            {
                Firestone.Click 1324, 811
            }
        }
    
        Firestone.Esc()
    }
}