#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2

SendMode "InputThenPlay"

^y:: {
    static toggled := false
	
    toggled := !toggled

	if !toggled {
		MsgBox "Скрипт приостановлен."
		Exit
	}
	
	While toggled
	{
		Sleep 5000
		if WinExist("ahk_exe Firestone.exe")
		{
			WinActivate
		}
		Sleep 1000
		CollectTools
		Sleep 2000
		CollectXPGuard

		Sleep 600000 ; Ждём минуту
	}
        
}

; Сбор инструментов
CollectTools() {
	ClickCityIcon()
	FClick 1230, 800 ; Клик на здание механика
	FClick 600, 460 ; Клик на выбор Механик
	FClick 1620, 680 ; Клик на кнопку получения инструментов
	Press "{Esc}"
	Press "{Esc}"
}

; Прокачка стража
CollectXPGuard() {
	Press "{G}"
	FClick 1150, 765
	Press "{Esc}"
}

FindFirestoneWindowAndActivate() {
	if !WinActive("ahk_exe Firestone.exe")
	{
		MsgBox "Окно перестало быть активным! Принудительный выход."
		Exit
	}
}

; Клик на иконку города на главном экране
ClickCityIcon() {
	FClick 1850, 185 ; Клик на иконку города
}

FClick(x, y) {
	FindFirestoneWindowAndActivate

	Click x, y
	Sleep 1000
}

Press(key) {
	FindFirestoneWindowAndActivate

	Send key
	Sleep 1000
}