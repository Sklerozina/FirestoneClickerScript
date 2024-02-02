#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2

^y:: {
    static toggled := false
	
    toggled := !toggled
	
	if WinExist("ahk_exe Firestone.exe")
	{
		if !WinActive("ahk_exe Firestone.exe")
		{
			WinActivate
		}
	}
	
	While toggled
	{
		Click 1850 185 ; Кликаем на иконку города
		Sleep 500
		Click 1230 800 
		Sleep 500		
		Click 600 460
		Sleep 500
		Click 1620 680
		Sleep 1000
		Click 1620 680
		Sleep 1000
		
	}
        
}