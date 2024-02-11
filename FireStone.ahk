#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
#SingleInstance Force

SendMode "InputThenPlay"
; Thread "Interrupt", 0  ; Make all threads always-interruptible.

SetDefaultMouseSpeed 25

^+e:: {
	MsgBox "Скрипт перезапущен."
	Reload
}

; Игра должна быть в разрешении 1920x1018,
; без рамок, например с помощью Borderless Gaming приложения

hwids := 0
firestone_hwid := 0
saved_mouse_position_x := 0
saved_mouse_position_y := 0
prestige_mode := false

;; Координаты заданий для карты
; ~20 minutes
map_litle_missons := {866:207, 1390:320, 1333:409, 1216:435, 536:472, 682:493, 845:640, 1266:673, 1455:552, 907:335, 696:198, 499:158, 1338:619, 1291:159, 818:345, 1134:416, 617:325, 1087:860}
; ~40 minutes
map_small_missons := {564:262, 1289:280, 1480:227, 789:476, 672:569, 1433:663, 668:728, 854:515, 1034:648, 466:306, 478:387, 445:644, 1012:500, 1418:394, 1318:517, 1411:845}
; ~1-2 hours
map_medium_missons := {1214:285, 1008:401, 773:621, 1140:600, 1450:469, 840:767, 1047:769, 1325:774, 1147:948, 1202:521, 760:822, 702:656, 951:198, 896:732, 1400:753, 1245:360, 646:392, 921:578}
; Seas, Monsters, Dragons
map_big_missons := {1097:522, 459:899, 596:540, 1485:749, 374:972, 836:944, 957:787, 542:947, 609:169, 1245:819, 1137:310, 873:422} ; Если не будет работать 836:944 то можно попробовать 836:1013

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

; ^m:: {
; 	global firestone_hwid
; 	hwids := FindAllFirestones()
; 	Loop hwids.Length
; 	{
; 		firestone_hwid := hwids[A_Index]
; 		If WinExist(firestone_hwid){
; 			WinActivate
; 		}

; 		try
; 		{
; 			BackToMainScreen
; 			Press "{m}"
; 			; Прокликать завершённые задания
; 			MapFinishMissions
; 			DoMapMissions
; 			Press "{Esc}" ; На главный экран
; 		}
; 		catch Number
; 		{
; 			ToolTip "Прерываю работу."
; 			SetTimer () => ToolTip(), -2000
; 		}
; 	}
; }

; ^d:: {
; 	global firestone_hwid
; 	firestone_hwid := WinExist("ahk_exe Firestone.exe")

; 	If WinExist(firestone_hwid){
; 		WinActivate
; 	}

; 	; Do Test Things
; 	MapFinishMissions
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
				ClickCityIcon ; зайти в город
				DoAlchemy ; Алхимия
				CollectXPGuard ; Страж
				CollectTools ; Механик
				DoExpeditions ; Экспедиции
				Press "{Esc}" ; На главный экран
				DoMap
			}
			catch Number
			{
				ToolTip "Прерываю работу."
				SetTimer () => ToolTip(), -2000
				SetTimer DoWork, 180000 ; Если мышь двигалась, то следующий раз будет через 3 минуты
				break
			}
		}

		SetTimer DoWork, 300000 ; Если мышь не двигалась, то продолжаем через 5 минут
    }
	else
	{
		SetTimer DoWork, 180000 ; Если мышь двигалась, то следующий раз будет через 3 минуты
	}
	
	MouseGetPos(&saved_mouse_position_x, &saved_mouse_position_y)
}

DoAlchemy() {
	FClick(480, 790)
	
	if CheckIfGreenAndClick(860, 764, 250) || CheckIfOrangeAndClick(920, 740, 250)
	{
		MouseMove(860, 200) ; Сдвигаем курсор, чтобы не загораживал
		CheckIfGreenAndClick(860, 764, 5000)
	}

	if CheckIfGreenAndClick(1210, 764, 250) || CheckIfOrangeAndClick(1270, 740, 250)
	{
		MouseMove(860, 200) ; Сдвигаем курсор, чтобы не загораживал
		CheckIfGreenAndClick(1210, 764, 5000)
	}

	if CheckIfGreenAndClick(1560, 764, 250) || CheckIfOrangeAndClick(1620, 740, 250)
	{
		MouseMove(860, 200) ; Сдвигаем курсор, чтобы не загораживал
		CheckIfGreenAndClick(1560, 764, 5000)
	}

	Press "{Esc}"
}

DoWMDailys() {
	; Здесь можно проверить, светятся ли невыполненные дейлики
	if (PixelSearch(&FoundX, &FoundY,1850, 900, 1900, 950, 0xF30000, 1))
	{
		FClick(1777, 977) ; Ежедневные миссии
		FClick(720, 779) ; Кнопка выбора, освобождение
		SendEvent "{Click 265 575 Down}{click 1427 575 Up}" ; Скролл дейликов в самое начало
		SendEvent "{Click 265 575 Down}{click 1427 575 Up}" ; Скролл дейликов в самое начало

		SleepAndWait 500
		; Первая миссия
		DoWMMission(190, 700, 450, 770, 312, 740) ; 1
		DoWMMission(580, 700, 850, 770, 720, 740) ; 2
		DoWMMission(985, 700, 1240, 770, 1110, 740) ; 3
		DoWMMission(1380, 700, 1640, 770, 1500, 740) ; 4
		DoWMMission(1777, 700, 1800, 770, 1790, 740) ; 5

		SendEvent "{click 1427 575 Down}{Click 265 575 Up}" ; Скролл дейликов в конец
		SendEvent "{click 1427 575 Down}{Click 265 575 Up}" ; Скролл дейликов в конец

		DoWMMission(280, 700, 540, 770, 405, 740) ; 6

		Press "{Esc}" ; Вышли на карту

		; Зайти ещё раз и проверить вторую стопку дейликов
		FClick(1777, 977, 500) ; Ежедневные миссии
		if PixelSearch(&Found_X, &Found_Y, 1100, 740, 1340, 810, 0x0AA008, 1) ; 
		{
			FClick 1235, 770, 500 ; Жмём кнопку для захода в задания подземелий

			DoWMMission(630, 700, 890, 770, 755, 740) ; 1 подземелье
			
			Press "{Esc}" ; Вышли на карту
		}
		else
		{
			Press "{Esc}"
		}
	}
}

DoUpgrades() {
	global prestige_mode

	Press "{u}", 500
	FClick(1771, 180, 200)
	FClick(1758, 875, 200, 5)
	if prestige_mode
	{
		FClick(1758, 758, 200, 5)
		FClick(1758, 644, 200, 5)
		FClick(1758, 527, 200, 5)
		FClick(1758, 424, 200, 5)
	}
	Press "{u}"
}

; Сбор инструментов
CollectTools() {
	FClick 1230, 800 ; Клик на здание механика
	FClick 600, 460 ; Клик на выбор Механик
	FClick 1620, 680 ; Клик на кнопку получения инструментов
	Press "{Esc}"
}

; Прокачка стража
CollectXPGuard() {
	FClick 625, 230 ; Здание стража
	FClick 1150, 765 ; Интерфейс стража
	Press "{Esc}"
}

; Экспедиции
DoExpeditions() {
	FClick(1482, 127) ; Клик на здание гильдии
	FClick(296, 387) ; Клик на здание экспедиций
	FClick(1305, 296, 2000) ; Клик на кнопку принятия экспедиции
	FClick(1305, 296) ; Клик на кнопку принятия экспедиции
	Press "{Esc}" ; Закрыть окно экспедиций
	Press "{Esc}" ; Выйти в город
}

DoMap() {
	Press "{m}"
	FClick(1834, 583, 500) ; Клик для перехода на карту военной кампании
	CheckIfGreenAndClick(60, 953, 1000) ; Забрать лут
	FClick(1832, 438, 500) ; Вернуться обратно на карту миссий

	; Прокликать завершённые задания
	MapFinishMissions
	DoMapMissions
	
	FClick(1834, 583, 500) ; Клик для перехода на карту военной кампании

	DoWMDailys

	Press "{Esc}"
}

CheckSquad() {
	; return CheckForImage(&FoundX, &FoundY, 646, 946, 844, 1016, "*80 MapBezd.png")
	return PixelSearch(&FoundX, &FoundY, 646, 946, 816, 1016, 0xF9E7CE, 1)
}

ClickOnMapMission(x, y) {
	FClick x, y, 100
	; Зелёная кнопка принятия
	MouseMove 0, 0
	if !CheckIfGreenAndClick(966, 855, 500)
	{
		if(CheckForImage(&FoundX, &FoundY, 1251, 720, 1491, 790, "*80 FreeOrange.png"))
		{
			FClick 1367, 747, 500
			CheckIfGreenAndClick(815, 613, 5000)
		}

		if(CheckForImage(&FoundX, &FoundY, 948, 706, 1219, 807, "*80 Otmena.png"))
			Press "{Esc}"

		if(CheckForImage(&FoundX, &FoundY, 780, 835, 836, 873, "*80 x2.png"))
			Press "{Esc}"

		
	}
}

DoWMMission(zone_x1, zone_y1, zone_x2, zone_y2, click_x, click_y) {
	SleepAndWait 500
	if PixelSearch(&Found_X, &Found_Y, zone_x1, zone_y1, zone_x2, zone_y2, 0x0AA008, 1)
	{
		FClick click_x, click_y
		MouseMove(0, 0) ; Убираем мышь, чтобы не светила кнопку
		if !CheckIfGreenAndClick(926, 734, 120000) ; Ждём появление кнопки подтверждения
		{
			MsgBox "Не могу дождаться пикселя, выход"
			Exit
		}
	}
	else
		return 0
}

MapFinishMissions(){
	loop
	{
		if not CheckIfGreenAndClick(95, 310, 1500)
			break
		else
			CheckIfGreenAndClick(814, 614, 1500)
	}

	; Попробовать завершить задания, которым осталось меньше 3-х минут
	loop
	{
		if not PixelSearch(&FoundX, &FoundY, 14, 208, 263, 341, 0xF7E5CB, 1)
			break
		else
		{
			FClick 138, 239, 500
			if !CheckIfGreenAndClick(966, 855, 500)
			{
				if(CheckForImage(&FoundX, &FoundY, 1251, 720, 1491, 790, "*120 FreeOrange.png"))
				{
					FClick 1367, 747, 500
					CheckIfGreenAndClick(815, 613, 5000)
					continue
				}
		
				if(CheckForImage(&FoundX, &FoundY, 948, 706, 1219, 807, "*120 Otmena.png"))
					Press "{Esc}"
					break
			}
			else
			{
				CheckIfGreenAndClick(815, 613, 5000)
			}
		}
	}
}

DoMapMissions(){
	; Проверить, есть ли не задания на карте и попытаться их начать.
	if (CheckSquad())
	{
		; Tp "У нас есть задания, которые нужно сделать!"
		For x, y in map_litle_missons.OwnProps()
		{
			If !CheckSquad()
				break
	
			ClickOnMapMission(x, y)
		}
	
		For x, y in map_small_missons.OwnProps()
		{
			If !CheckSquad()
				break
	
			ClickOnMapMission(x, y)
		}
	
		For x, y in map_big_missons.OwnProps()
		{
			If !CheckSquad()
				break
	
			ClickOnMapMission(x, y)
		}

		For x, y in map_medium_missons.OwnProps()
		{
			If !CheckSquad()
				break
	
			ClickOnMapMission(x, y)
		}
	}
}

CheckIfOrangeAndClick(x, y, timeout := 1000){
	if WaitForPixel(x, y, "0xFCAF47 0xFCAC47 0xFBAC46 0xFAAB45 0xF9AB44 0xFBAB47 0xFAAB46 0xF9AB45 0xF8AA44 0xF8A945 0xF9AA45 0xF9A946 0xF9A847", timeout)
	{
		FClick(x, y)
		return 1
	}

	return 0
}

CheckIfGreenAndClick(x, y, timeout := 1000){
	if WaitForPixel(x, y, "0x0AA008 0x0B9F05 0x0A9F05 0x0AA005 0x0AA006", timeout)
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
		; "Окно с игрой не найдено! Перываю работу."
		throw 1
	}

	if !WinActive(firestone_hwid)
	{
		; "Окно перестало быть активным! Перываю работу."
		throw 1
	}
}

; Принудительный возврат на главный экран (Много раз жмёт Esc, потом кликает на закрытие диалога)
BackToMainScreen(){
	Press "{Esc}", 500
	Press "{Esc}", 500
	Press "{Esc}", 500
	Press "{Esc}", 500
	FClick(1537, 275, 250)
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

FClick(x, y, wait := 1000, clickcount := 1) {
	FindFirestoneWindowAndActivate

	Click x, y, clickcount
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

CheckForImage(&OutputX, &OutputY, X1, Y1, X2, Y2, image) {
	try
	{
		return ImageSearch(&OutputX, &OutputY, X1, Y1, X2, Y2, image)
	}
	catch as exc
		MsgBox "Возникла неожиданная ошибка с поиском изображения:`n" exc.Message
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
