#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2

SendMode "InputThenPlay"
SetControlDelay -1  ; May improve reliability and reduce side effects.
; Thread "Interrupt", 0  ; Make all threads always-interruptible.

^+e:: {
	MsgBox "Скрипт перезапущен."
	Reload
}

hwids := 0
firestone_hwid := 0

^y:: {
    global firestone_hwid
	hwids := FindAllFirestones()
	Loop hwids.Length
	{
        firestone_hwid := hwids[A_Index]
        If WinExist(firestone_hwid){
            ;MouseMove(1850, 185)
			Click(1850, 185)
		}
	}
}

DoWMDailys() {
	global firestone_hwid
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
		;MouseClickDrag("L", 265, 575, 1427, 575, 100)
		;SendEvent "{Click 100 200 0}
		SendEvent "{Click 265 575 Down}{click 1427 575 Up}"
	}
}

; Запускается по таймеру
DoWork() {
	global firestone_hwid
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
	Press "{u}", 500
	FClick(1771, 180, 200)
	FClick(1758, 875, 200)
	FClick(1758, 758, 200)
	FClick(1758, 644, 200)
	FClick(1758, 527, 200)
	FClick(1758, 424, 200)
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
	global firestone_hwid
	if !WinExist(firestone_hwid)
	{
		MsgBox "Окно с игрой не найдено! Принудительный выход."
		Exit
	}

	if !WinActive(firestone_hwid)
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

FClick(x, y, wait := 1000) {
	FindFirestoneWindowAndActivate

	Click x, y
	Sleep wait
}

Press(key, wait := 1000) {
	FindFirestoneWindowAndActivate

	Send key
	Sleep wait
}

FindAllFirestones() {
	return WinGetList("ahk_exe Firestone.exe")
}
