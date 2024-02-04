#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2

SendMode "InputThenPlay"
; Thread "Interrupt", 0  ; Make all threads always-interruptible.

^+e:: {
	MsgBox "Скрипт перезапущен."
	Reload
}

hwids := 0

;^d:: {
;	DoWMDailys
;}

^y:: {
    static toggled := false
	
    toggled := !toggled

	if !toggled {
		MsgBox "Скрипт приостановлен."
		Reload
	}
	
	if toggled
	{
		MsgBox "Запускаю."
		DoWork
		SetTimer DoWork, 300000
	}
        
}

DoWMDailys() {
	hwids := FindAllFirestones()
	Loop hwids.Length
	{
        firestone_hwid := hwids[A_Index]
        If WinExist(firestone_hwid){
			WinActivate
		}
	
		Press "{m}"
		FClick(1834, 583) ; Клик для перехода на карту военной кампании
		FClick(1777, 977)
		FClick(720, 779) ; Кнопка выбора, освобождение
		MouseClickDrag("L", 265, 575, 1427, 575, 100)
	}
}

; Запускается по таймеру
DoWork() {
	hwids := FindAllFirestones()
	Loop hwids.Length
	{
        firestone_hwid := hwids[A_Index]
        If WinExist(firestone_hwid){
			WinActivate
		}

		BackToMainScreen ; Принудительный возврат на главный экран (Много раз жмёт Esc, а потом кликает на закрытие диалога)
		Sleep 1000
		DoUpgrades
		Sleep 1000
		CollectMapLoot
		Sleep 1000
		DoExpeditions
		Sleep 2000
		CollectTools
		Sleep 2000
		CollectXPGuard
	}
}

DoUpgrades() {
	Press "{u}"
	FClick(1771, 180)
	FClick(1758, 875)
	FClick(1758, 758)
	FClick(1758, 644)
	FClick(1758, 527)
	FClick(1758, 424)
	Press "{u}"
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

; Экспедиции
DoExpeditions() {
	ClickGuildIcon
	FClick(296, 387) ; Клик на здание экспедиций
	FClick(1305, 296) ; Клик на кнопку принятия экспедиции
	Sleep 1000
	FClick(1305, 296) ; Клик на кнопку принятия экспедиции
	Press "{Esc}"
	Press "{Esc}"
}

CollectMapLoot() {
	Press "{m}"
	FClick(1834, 583) ; Клик для перехода на карту военной кампании
	FClick(143, 953)
	Press "{Esc}"
}

FindFirestoneWindowAndActivate() {
	if !WinExist
	{
		MsgBox "Окно с игрой не найдено! Принудительный выход."
		Exit
	}

	if !WinActive
	{
		Result := MsgBox("Окно перестало быть активным! Мне продолжить?",, "YesNo")
		if Result = "Yes"
			WinActivate
		else
			Reload
	}
}

BackToMainScreen(){
	Press "{Esc}"
	Press "{Esc}"
	Press "{Esc}"
	FClick(1537, 275)
}

; Клик на иконку города на главном экране
ClickCityIcon() {
	; FClick 1850, 185 ; Клик на иконку города
	Press "{t}"
}

; Клик на иконку гильдии
ClickGuildIcon() {
	FClick 1865, 442 ; Клик на иконку города
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

FindAllFirestones() {
	return WinGetList("ahk_exe Firestone.exe")
}
