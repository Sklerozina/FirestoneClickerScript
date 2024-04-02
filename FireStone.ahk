#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
#SingleInstance Force

Settings := {auto_research: ""}

; Считать настройки
Settings.auto_research := IniRead("settings.ini", "Settings", "auto_research", "None")
Settings.lvlup_priority := IniRead("settings.ini", "Settings", "lvlup_priority", "None")
Settings.open_boxes := IniRead("settings.ini", "Settings", "open_boxes", "None")

if (Settings.auto_research == "None") {
	IniWrite 0, "settings.ini", "Settings", "auto_research"
	Settings.auto_research := 0
}
	
if Settings.lvlup_priority == "None" {
	IniWrite "17", "settings.ini", "Settings", "lvlup_priority"
	Settings.lvlup_priority := "17"
}

if Settings.open_boxes == "None" {
	IniWrite 0, "settings.ini", "Settings", "open_boxes"
	Settings.open_boxes := 0
}

InstallKeybdHook

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
map_world_domination_missions := {954:503, 728:350}
; ~20 minutes
map_litle_missons := {866:207, 1390:320, 1333:409, 1216:435, 536:472, 682:493, 845:640, 1266:673, 1455:552, 907:335, 696:198, 499:158, 1338:619, 1291:159, 818:345, 1134:416, 630:330, 1087:860}
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
	if prestige_mode {
		Tp "Режим престижа"
		SetTimer DoPrestigeUpgrades, 60000
	}
	else
	{
		Tp "Обычный режим"
		SetTimer DoPrestigeUpgrades, 0
	}
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
	; }

^y:: {
	global saved_mouse_position_x, saved_mouse_position_y
    static toggled := false
	
    toggled := !toggled

	if !toggled {
		Tp "Скрипт приостановлен."
		Sleep 2000
		Exit
	}
	
	if toggled
	{
		Tp "Запускаю.", -1000
		MouseGetPos(&saved_mouse_position_x, &saved_mouse_position_y)
		try
		{
			Sleep 1100
			DoWork(true)
		}
		catch Number
		{
			; А хз, наверное будет пустым тут
		}
		SetTimer DoWork, 300000
	}
}

; Запускается по таймеру
DoWork(force := false) {
	global firestone_hwid, saved_mouse_position_x, saved_mouse_position_y
	static delay := 300000
	static daily_magazine_reward := true

	Thread "Priority", 1 ; На всякий случай, чтобы задача не прерывалась другими таймерами

	; Если мышка двигалась или нажималась клавиатура пока спали, пропускаем задачу
	MouseGetPos(&Mx, &My)

	; Если мышка двигалась или нажималась клавиатура пока спали, пропускаем задачу
	If((A_TimeIdlePhysical >= delay && saved_mouse_position_x == Mx && saved_mouse_position_y == My) || force == true) {
		hwids := FindAllFirestones()
		Loop hwids.Length
		{
			firestone_hwid := hwids[A_Index]
			If WinExist(firestone_hwid){
				WinActivate
			}

			try
			{
				Sleep 1000 ; Заглушка, чтобы пошёл таймер в A_TimeIdlePhysical
				BackToMainScreen 
				SleepAndWait 1000
				if CheckIfRed(1877, 517, 1912, 555)
					daily_magazine_reward := false
				DoUpgrades
				ClickCityIcon ; зайти в город
				if daily_magazine_reward == false
					DoDailyMagazineReward
					daily_magazine_reward := true
				DoAlchemy ; Алхимия
				CollectXPGuard ; Страж
				CollectTools ; Механик
				DoExpeditions ; Экспедиции
				if Settings.auto_research == 1
					DoResearch
				DoOracle
				Press "{Esc}" ; На главный экран
				if Settings.open_boxes == 1
					DoOpenBoxes
				BackToMainScreen ;; Страховка перед заходом на карту
				DoMap
			}
			catch Number
			{
				Tp "Прерываю работу."
				delay := 180000
				SetTimer DoWork, delay ; Если мышь двигалась, то следующий раз будет через 3 минуты
				break
			}
		}
		delay := 300000
		SetTimer DoWork, delay ; Если мышь не двигалась, то продолжаем через 5 минут
    }
	else
	{
		delay := 180000
		SetTimer DoWork, delay ; Если мышь двигалась, то следующий раз будет через 3 минуты
	}

	MouseGetPos(&saved_mouse_position_x, &saved_mouse_position_y)
}

DoOpenBoxes() {
	box_coordinates := ["1808:776", "1659:776", "1501:776", "1808:639", "1659:639", "1501:639", "1808:478", "1659:478", "1501:478", "1808:318", "1659:318", "1501:318", "1808:172", "1659:172", " 1501:172"]
	i := 0
	For coords in box_coordinates
	{
		box_opened := false
		coords := StrSplit(coords, ":")
		x := coords[1]
		y := coords[2]

		i += 1
		if (PixelSearch(&outputX, &OutputY, x-10, y-10, x+10, y+10, 0x9E7F67, 1)) {
			; MsgBox "В " . i . " пусто!"
			continue
		}

		; MsgBox "Сундук обнаружен в слоте " . i . " по координатам " . x . ":" . y
		
		FClick x, y, 1000

		if PixelSearch(&OutpuxX, &OutpuxY, 1283, 696, 1301, 851, 0x0AA008, 1) { ; x50
			box_opened := true
			FClick OutpuxX, OutpuxY
		}

		if PixelSearch(&OutpuxX, &OutpuxY, 1153, 696, 1176, 851, 0x0AA008, 1) { ; x10
			box_opened := true
			FClick OutpuxX, OutpuxY
		}

		if PixelSearch(&OutpuxX, &OutpuxY, 863, 696, 1053, 851, 0x0AA008, 1) { ; x1
			box_opened := true
			FClick OutpuxX, OutpuxY
		}

		MouseMove 0, 0

		if PixelSearch(&OutpuxX, &OutpuxY, 631, 754, 1272, 825, 0x365E91, 1) {
			; MsgBox "Этот сундук нельзя открыть!"
			Press "{ESC}"
			continue
		}

		loop 30 ;; Ждём распаковку
		{
			;; Проверяем наличие зелёной кнопки
			if WaitForSearchPixel(835, 804, 1085, 869, 0x0AA008, 1, 250) {
				FClick 953, 833, 500
			}
			
			;; проверяем наличие крестика
			if WaitForSearchPixel(1817-15, 52-15, 1817+15, 52+15, 0xFF620A, 0, 250) {
				FClick 1817, 52, 500
				break
			}
				
			SleepAndWait 1000 ;; продолжаем ждать
		}
		
	}

	Press "{ESC}"
}

DoPrestigeUpgrades(force := false) {
	global firestone_hwid, saved_mouse_position_x, saved_mouse_position_y

	MouseGetPos(&Mx, &My)

	; Если мышка двигалась или нажималась клавиатура пока спали, пропускаем задачу
	If((A_TimeIdle >= 60000 && saved_mouse_position_x == Mx && saved_mouse_position_y == My) || force == true) {
		hwids := FindAllFirestones()
		Loop hwids.Length
		{
			firestone_hwid := hwids[A_Index]
			If WinExist(firestone_hwid){
				WinActivate
			}

			try
			{
				Sleep 1000 ; Заглушка, чтобы пошёл таймер в A_TimeIdlePhysical
				BackToMainScreen 
				SleepAndWait 1000
				DoUpgrades
			}
			catch Number
			{
				Tp "Прерываю работу."
				break
			}
		}
    }
	
	MouseGetPos(&saved_mouse_position_x, &saved_mouse_position_y)
}

DoResearch() {
	research_count := 0
	;; Проверяем, висит ли красный значёк у здания.
	if not CheckIfRed(384, 641, 424, 680)
		return

	FClick 313, 630
	FClick 1813, 930

	MouseMove 0, 0

	if PixelSearch(&OutputX, &OutputY, 445, 939, 461, 976, 0x285483, 1)
	{
		research_count += 1
	}

	if PixelSearch(&OutputX, &OutputY, 1090, 939, 1105, 976, 0x285483, 1)
	{
		research_count += 1
	}
	
	;; Проверка первого слота
	loop 2
	{
		; Проверка на оранжевую кнопку, досрочное завершение
		if CheckForImage(462, 899, 634, 948, "ResearchFree.png")
		{
			FClick 548, 925, 500
			research_count -= 1
		}

		; Проверить зелёную кнопку завершения
		if PixelSearch(&OutputX, &OutputY, 474, 895, 633, 950, 0x0AA008, 1)
		{
			FClick 548, 925, 500
			research_count -= 1
		}

		MouseMove 0, 0
		SleepAndWait 500
	}

	;; Проверка второго слота
	; Проверка на оранжевую кнопку, досрочное завершение
	if CheckForImage(1090, 879, 1301, 958, "ResearchFree.png")
	{
		FClick 1201, 916, 500
		research_count -= 1
	}

	; Проверить зелёную кнопку завершения
	if PixelSearch(&OutputX, &OutputY, 1122, 889, 1283, 951, 0x0AA008, 1)
	{
		FClick 1201, 916, 500
		research_count -= 1
	}

	MouseMove 0, 0
	SleepAndWait 500
	
	;; Добавить проверку на второе исследование
	if (research_count < 2)
	{
		loop 50
		{
			Press "{WheelUp}", 30
		}

		loop 2
		{
			x := 65
			while x < 1850
			{
				MouseMove x, 100
				if PixelSearch(&OutputX, &OutputY, x, 170, x, 824, 0x0D49DE, 1)
				{
					;; попробовать кликнуть
					FClick OutputX, OutputY
					;; Подождать окно принятия
					if WaitForSearchPixel(669, 707, 928, 775, 0x0AA007, 1, 1000)
					{
						FClick 795, 738, 500

						research_count += 1
					}
				}

				if (research_count == 2)
					break 2
		
				x += 50
		
				SleepAndWait 200
			}

			loop 35
			{
				Press "{WheelDown}", 30
			}
		}
	}
	

	Press "{ESC}"
}

DoDailyMagazineReward() {
	FClick 1300, 343
	
	if CheckForImage(390, 818, 785, 925, "magazine_free.png")
	{
		FClick 592, 743, 200
	}

	if CheckIfRed(1425, 25, 1474, 76)
	{
		FClick 1381, 91
		if PixelSearch(&OutputX, &OutputY, 1261, 796, 1404, 841, 0x4CA02E, 1)
		{
			FClick 1324, 811
		}
	}

	Press "{ESC}"

	return true
}

DoAlchemy() {
	;; Проверяем, висит ли красный значёк у здания.
	if not CheckIfRed(570, 808, 614, 851)
		return

	FClick(480, 790)

	alchemy_1 := false
	alchemy_2 := false
	alchemy_3 := false
	
	;; Сначала за пыль и монеты, потом за кровь
	; За пыль
	if CheckIfGreenAndClick(1210, 764, 250)
		alchemy_2 := true
	else
	{
		if CheckIfOrangeAndClick(1270, 740, 250)
			alchemy_2 := true
	}

	; За монеты
	if CheckIfGreenAndClick(1560, 764, 250)
		alchemy_3 := true
	else
	{
		if CheckIfOrangeAndClick(1620, 740, 250)
			alchemy_3 := true
	}

	; За кровь
	if CheckIfGreenAndClick(860, 764, 250)
		alchemy_1 := true
	else
	{
		if CheckIfOrangeAndClick(920, 740, 250)
			alchemy_1 := true
	}

	;; Сначала за пыль и монеты, потом за кровь
	; За пыль
	if alchemy_2 == true
		CheckIfGreenAndClick(1210, 764, 2500)

	; За монеты
	if alchemy_3 == true
		CheckIfGreenAndClick(1560, 764, 2500)

	; За кровь
	if alchemy_1 == true
		CheckIfGreenAndClick(860, 764, 2500)

	Press "{Esc}"
}

DoWMDailys() {
	; Здесь можно проверить, светятся ли невыполненные дейлики
	if (CheckIfRed(1850, 900, 1900, 950))
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

	if prestige_mode
	{
		FClick(1771, 180, 200)
		FClick(1758, 875, 200, 5)
		FClick(1758, 758, 200, 5)
		FClick(1758, 644, 200, 5)
		FClick(1758, 527, 200, 5)
		FClick(1758, 424, 200, 5)
		FClick(1764, 290, 200, 5)
	} else {
		loop parse Settings.lvlup_priority {
			switch A_LoopField {
				case "1":
					FClick(1771, 180, 200)
				case "2":
					FClick(1764, 290, 200, 5)
				case "3":
					FClick(1758, 424, 200, 5)
				case "4":
					FClick(1758, 527, 200, 5)
				case "5":
					FClick(1758, 644, 200, 5)
				case "6":
					FClick(1758, 758, 200, 5)
				case "7":
					FClick(1758, 875, 200, 5)
			}
		}
	}

	Press "{u}"
}

; Сбор инструментов
CollectTools() {
	;; Проверяем, висит ли красный значёк у здания.
	if not CheckIfRed(1325, 839, 1369, 882)
		return
	
	FClick 1230, 800 ; Клик на здание механика

	;; Проверяем, висит ли красный значёк у механика.
	if not CheckIfRed(724, 306, 759, 336)
	{
		Press "{ESC}"
		return
	}
		

	FClick 600, 460 ; Клик на выбор Механик
	FClick 1620, 680 ; Клик на кнопку получения инструментов
	Press "{Esc}"
}

; Прокачка стража
CollectXPGuard() {
	;; Проверяем, висит ли красный значёк у здания.
	if not CheckIfRed(738, 281, 783, 324)
		return

	FClick 625, 230 ; Здание стража
	FClick 1150, 765 ; Интерфейс стража
	Press "{Esc}"
}

DoOracle() {
	;; Проверяем, висит ли красный значёк у здания.
	if not CheckIfRed(1108, 931, 1152, 970)
		return

	FClick 1026, 911, 500

	;; Забрать ежедневный бесплатный подарок оракула
	if CheckIfRed(860, 660, 903, 695) {
		FClick 824, 738, 500

		if PixelGetColor(467, 815) == 0x5B5EAA
		{
			FClick 641, 739, 200
		}

		Press "{ESC}"
	}


	;; Проверяем, висит ли красный значёк у ритуалов.
	if not CheckIfRed(860, 317, 903, 356)
		return

	FClick 825, 393, 500

	;; Проверяем зелёные кнопки и кликаем
	CheckIfGreenAndClick(1092, 473, 250) ; Гармония
	CheckIfGreenAndClick(1504, 479, 250) ; Безмятежность
	CheckIfGreenAndClick(1502, 820, 250) ; Концентрация
	
	Press "{ESC}"
}

; Экспедиции
DoExpeditions() {
	FClick(1482, 127) ; Клик на здание гильдии

	;; Проверяем, висит ли красный значёк у здания.
	if not CheckIfRed(405, 443, 435, 475)
	{
		Press "{Esc}" ; Выйти в город
		return
	}

	FClick(296, 387) ; Клик на здание экспедиций
	CheckIfGreenAndClick 1184, 299
	MouseMove 0, 0
	CheckIfGreenAndClick 1184, 299, 3000
	Press "{Esc}" ; Закрыть окно экспедиций
	Press "{Esc}" ; Выйти в город
}

DoMap() {
	map_status := ''

	Press "{m}"
	FClick(1834, 583, 500) ; Клик для перехода на карту военной кампании
	CheckIfGreenAndClick(60, 953, 1000) ; Забрать лут
	FClick(1832, 438, 500) ; Вернуться обратно на карту миссий

	; Прокликать завершённые задания
	map_status := MapTryFinishMissions()
	if map_status == 'hangup'
		DoMapMissions(true)
	else
		DoMapMissions
	
	FClick(1834, 583, 500) ; Клик для перехода на карту военной кампании

	DoWMDailys

	Press "{Esc}"
}

CheckSquad() {
	; return CheckForImage(646, 946, 844, 1016, "*80 MapBezd.png")
	return PixelSearch(&FoundX, &FoundY, 646, 946, 816, 1016, 0xF9E7CE, 1)
}

ClickOnMapMission(x, y) {
	FClick x, y, 100
	; Зелёная кнопка принятия
	MouseMove 0, 0
	if !CheckIfGreenAndClick(966, 855, 250)
	{
		if(CheckForImage(1251, 720, 1491, 790, "*80 FreeOrange.png"))
		{
			FClick 1367, 747, 500
			CheckIfGreenAndClick(815, 613, 5000)
			return
		}

		if(CheckForImage(948, 706, 1219, 807, "*80 Otmena.png")){
			Press "{Esc}"
			return
		}
			

		if(CheckForImage(1024, 803, 1164, 874, "*80 NotEnoughSquads.png")){
			Press "{Esc}"
			return
		}

		CheckIfGreenAndClick(814, 603, 500)
			
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
			throw 1
		}
	}
	else
		return 0
}

DoMapMissions(force := false){
	; Проверить, есть ли не задания на карте и попытаться их начать.
	if (CheckSquad() || force == true)
	{
		; Мисси при событии "Мировое господство"
		try_finish := false
		For x, y in map_world_domination_missions.OwnProps()
		{
			If !CheckSquad() && force == false
				break
	
			ClickOnMapMission(x, y)
			try_finish := true
		}

		if try_finish == true
			MapTryFinishMissions

		; Tp "У нас есть задания, которые нужно сделать!"
		try_finish := false
		For x, y in map_litle_missons.OwnProps()
		{
			If !CheckSquad() && force == false
				break
	
			ClickOnMapMission(x, y)
			try_finish := true
		}

		if try_finish == true
			MapTryFinishMissions
		
		try_finish := false
		For x, y in map_small_missons.OwnProps()
		{
			If !CheckSquad() && force == false
				break
	
			ClickOnMapMission(x, y)
			try_finish := true
		}

		if try_finish == true
			MapTryFinishMissions
	
		try_finish := false
		For x, y in map_big_missons.OwnProps()
		{
			If !CheckSquad() && force == false
				break
	
			ClickOnMapMission(x, y)
			try_finish := true
		}

		if try_finish == true
			MapTryFinishMissions

		For x, y in map_medium_missons.OwnProps()
		{
			If !CheckSquad() && force == false
				break
	
			ClickOnMapMission(x, y)
		}
	}
}

MapTryFinishMissions() {
	; Попробовать завершить задания, которым осталось меньше 3-х минут
	loop 20 ; Ограничим цикл, если вдруг что-то пошло не так.
	{
		if not PixelSearch(&FoundX, &FoundY, 14, 208, 263, 341, 0xF7E5CB, 1)
			break
		else
		{
			FClick 138, 239, 500
			if (CheckIfGreenAndClick(815, 605, 500)){
				continue
			}

			if(CheckForImage(1251, 720, 1491, 790, "*120 FreeOrange.png"))
			{
				FClick 1367, 747, 500
				CheckIfGreenAndClick(815, 605, 5000)
				continue
			}
	
			if(CheckForImage(948, 706, 1219, 807, "*120 Otmena.png")){
				Press "{Esc}"
				break
			}

			if (PixelSearch(&FoundX, &FoundY, 85, 274, 138, 332, 0xADABAD, 1)) {
				return 'hangup'
			}
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

CheckIfRed(x1, y1, x2, y2) {
	return PixelSearch(&FoundX, &FoundY, x1, y1, x2, y2, 0xF30000, 1)
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
	Press "{Esc}", 250
	Press "{Esc}", 250
	Press "{Esc}", 250
	FClick 1398, 279, 250 ;; Клик по окошку "Нравится игра?"
	Press "{Esc}", 250
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
	loop clickcount
	{
		Click x, y
		SleepAndWait(wait)
	}
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
	If((Mx1 != Mx2) && (My1 != My2) || A_TimeIdlePhysical <= m) {
		throw 1
	}
}

CheckForImage(X1, Y1, X2, Y2, image) {
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

WaitForSearchPixel(x1, y1, x2, y2, color, variation := 0, timeout := 300000) {
	t := 0
	while t <= timeout
	{
		if PixelSearch(&OutputX, &OutputY, x1, y1, x2, y2, color, variation)
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
