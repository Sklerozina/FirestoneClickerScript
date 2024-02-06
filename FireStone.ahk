#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2

SendMode "InputThenPlay"
; Thread "Interrupt", 0  ; Make all threads always-interruptible.

^+e:: {
	MsgBox "Скрипт перезапущен."
	Reload
}

hwids := 0
firestone_hwid := 0
saved_mouse_position_x := 0
saved_mouse_position_y := 0
prestige_mode := false

; Сменить режим апгрейда героев
^NumpadEnd::
^Numpad1::
{
	global prestige_mode

	prestige_mode := !prestige_mode
	if prestige_mode
		Tp "Режим престижа"
	else
		Tp "Обычный режим"
}

; ^d:: {
; 	global firestone_hwid
; 	firestone_hwid := WinExist("ahk_exe Firestone.exe")

; 	If WinExist(firestone_hwid){
; 		WinActivate
; 	}

; 	; Do Test Things
; }

^y:: {
	global saved_mouse_position_x, saved_mouse_position_y
    static toggled := false
	
    toggled := !toggled

	if !toggled {
		ToolTip "Скрипт приостановлен."
		SetTimer () => ToolTip(), -2000
		Sleep 2000
		Exit
	}
	
	if toggled
	{
		ToolTip "Запускаю."
		SetTimer () => ToolTip(), -2000
		MouseGetPos(&saved_mouse_position_x, &saved_mouse_position_y)
		DoWork
		SetTimer DoWork, 180000
	}
        
}

; Запускается по таймеру
DoWork() {
	global firestone_hwid, saved_mouse_position_x, saved_mouse_position_y

	MouseGetPos(&Mx, &My)
	; Если мышка двигалась пока спали, пропускаем задачу
	If((saved_mouse_position_x == Mx) && (saved_mouse_position_y == My)) {
		hwids := FindAllFirestones()
		Loop hwids.Length
		{
			firestone_hwid := hwids[A_Index]
			If WinExist(firestone_hwid){
				WinActivate
			}

			try
			{
				BackToMainScreen 
				SleepAndWait 1000
				DoUpgrades
				SleepAndWait 1000
				CollectMapLoot
				SleepAndWait 1000
				DoWMDailys
				SleepAndWait 1000
				DoAlchemy
				SleepAndWait 1000
				DoExpeditions
				SleepAndWait 2000
				CollectTools
				SleepAndWait 2000
				CollectXPGuard
			}
			catch Number
			{
				ToolTip "Прерываю работу."
				SetTimer () => ToolTip(), -2000
				break
			}
		}
    }
	

	MouseGetPos(&saved_mouse_position_x, &saved_mouse_position_y)
}

DoAlchemy() {
	ClickCityIcon
	FClick(480, 790)
	
	if CheckIfGreenAndClick(860, 764)
	{
		MouseMove(860, 200) ; Сдвигаем курсор, чтобы не загораживал
		CheckIfGreenAndClick(860, 764, 5000)
	}

	if CheckIfGreenAndClick(1210, 764)
	{
		MouseMove(860, 200) ; Сдвигаем курсор, чтобы не загораживал
		CheckIfGreenAndClick(1210, 764, 5000)
	}

	if CheckIfGreenAndClick(1560, 764)
	{
		MouseMove(860, 200) ; Сдвигаем курсор, чтобы не загораживал
		CheckIfGreenAndClick(1560, 764, 5000)
	}

	Press "{Esc}"
	Press "{Esc}"
}

DoWMDailys() {
	Press "{m}"
	FClick(1834, 583) ; Клик для перехода на карту военной кампании
	; Здесь можно проверить, светятся ли невыполненные дейлики
	if (WaitForPixel(1876, 942, "0xF30000 0xF40000 0xF70000", 2000))
	{
		FClick(1777, 977)
		FClick(720, 779) ; Кнопка выбора, освобождение
		SendEvent "{Click 265 575 Down}{click 1427 575 Up}"
		SleepAndWait 500
		; Первая миссия
		DoWMMission(221, 748) ; 1
		DoWMMission(626, 748) ; 2
		DoWMMission(1024, 748) ; 3
		DoWMMission(1425, 748) ; 4
		DoWMMission(1802, 748) ; 5
		; тут надо двигать мышь
		BackToMainScreen ; пока так для надёжности
		
	}
	else
		Press "{Esc}" ; Выходим с карты
}

DoUpgrades() {
	global prestige_mode

	Press "{u}", 500
	FClick(1771, 180, 200)
	FClick(1758, 875, 200)
	if prestige_mode
	{
		FClick(1758, 758, 200)
		FClick(1758, 644, 200)
		FClick(1758, 527, 200)
		FClick(1758, 424, 200)
	}
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
	FClick(1305, 296, 2000) ; Клик на кнопку принятия экспедиции
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

DoWMMission(x, y) {
	if WaitForPixel(x, y, "0x0AA008 0x0B9F05 0x0A9F05 0x0AA005", 2000)
	{
		FClick(x, y)
		MouseMove(1150, 212) ; Убираем мышь, чтобы не светила кнопку
		if WaitForPixel(926, 734, "0x0AA008 0x0B9F05 0x0A9F05", 120000) ; Ждём появление кнопки подтверждения
			FClick(926, 734)
		else
		{
			MsgBox "Не могу дождаться пикселя, выход"
			Exit
		}

	}
	else
		return 0
}

CheckIfGreenAndClick(x, y, timeout := 1000){
	if WaitForPixel(x, y, "0x0AA008 0x0B9F05 0x0A9F05 0x0AA005", timeout)
	{
		FClick(x, y)
		return 1
	}

	return 0
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

; Принудительный возврат на главный экран (Много раз жмёт Esc, потом кликает на закрытие диалога)
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
	SleepAndWait(wait)
}

Press(key, wait := 1000) {
	FindFirestoneWindowAndActivate

	Send key
	SleepAndWait(wait)
}

SleepAndWait(m := 1000) {
	MouseGetPos(&Mx1, &My1)
	Sleep m
	MouseGetPos(&Mx2, &My2)
	; Если мышка двигалась пока спали, пропускаем задачу
	If((Mx1 != Mx2) && (My1 != My2)) {
		throw 1
	}
}

WaitForPixel(x, y, colors, timeout := 300000) {
	t := 0
	while t <= timeout
	{
		if InStr(colors, String(PixelGetColor(x, y)))
		{
			return 1
		}
		SleepAndWait 500
		t += 500
	}

	return 0
}

Tp(text, timeout := -2000) {
	ToolTip text
	SetTimer () => ToolTip(), timeout
}

FindAllFirestones() {
	return WinGetList("ahk_exe Firestone.exe")
}
