#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
#SingleInstance Force

#Include Settings.ahk
#Include Tools.ahk
#Include Firestone\main.ahk

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
Settings('settings.ini')
CurrentSettings := ""
colors := Map(
	'green_button', 0x0AA008
)

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
		Sleep 1100
		DoWork(true)

		SetTimer DoWork, 300000
	}
}

; Запускается по таймеру
DoWork(force := false) {
	global firestone_hwid, saved_mouse_position_x, saved_mouse_position_y
	static delay := 300000

	Thread "Priority", 1 ; На всякий случай, чтобы задача не прерывалась другими таймерами

	; Если мышка двигалась или нажималась клавиатура пока спали, пропускаем задачу
	MouseGetPos(&Mx, &My)

	; Если мышка двигалась или нажималась клавиатура пока спали, пропускаем задачу
	If((A_TimeIdlePhysical >= delay && saved_mouse_position_x == Mx && saved_mouse_position_y == My) || force == true) {
		hwids := FindAllFirestones()
		Loop hwids.Length
		{
			daily_magazine_rewards := false
			firestone_hwid := hwids[A_Index]
			SetCurrentSettings()

			If WinExist(firestone_hwid){
				WinActivate
			}

			try
			{
				Sleep 1000 ; Заглушка, чтобы пошёл таймер в A_TimeIdlePhysical
				Firestone.BackToMainScreen()
				Tools.Sleep 1000
				if CheckIfRed(1877, 517, 1912, 555)
					daily_magazine_rewards := true
				DoUpgrades
				ClickCityIcon ; зайти в город
				
				if daily_magazine_rewards == true {
					if CurrentSettings.Get('auto_arena', 0) == 1 {
						CurrentSettings.Set('arena_today', false)
						Settings.Save()
					}
					DoDailyMagazineReward
				}
				
				if CheckIfRed(814, 910, 848, 949)
					DoTavern

				DoAlchemy ; Алхимия
				CollectXPGuard ; Страж
				CollectTools ; Механик
				DoExpeditions ; Экспедиции

				if CurrentSettings.Get('auto_research') == 1
					DoResearch

				DoOracle
				Press "{Esc}" ; На главный экран
				Firestone.BackToMainScreen() ;; Страховка перед заходом на карту

				DoMap

				if CurrentSettings.Get('open_boxes') == 1
					DoOpenBoxes

				if CurrentSettings.Get('auto_complete_quests') == 1
					DoQuests

				if CurrentSettings.Get('auto_arena', 0) == 1 && CurrentSettings.Get('arena_today', false) == false {
					Arena.Do()
				}
			}
			catch String as err
			{
				Tp "Прерываю работу. " . err, -2000
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
		delay := 120000
		SetTimer DoWork, delay ; Если мышь двигалась, то следующий раз будет через 2 минуты
	}

	MouseGetPos(&saved_mouse_position_x, &saved_mouse_position_y)
}

DoTavern() {
	Firestone.Click 717, 911
	Firestone.Click 1731, 42

	while WaitForSearchPixel(344-5, 437-5, 344+5, 437+5, 0x3CA8E1, 1, 1000) {
		Firestone.Click 521, 509
	}

	Press "{ESC}"
	Press "{ESC}"
}

DoQuests() {
	Press "{Q}"

	; Дейлики
	if CheckIfRed(929, 82, 969, 115) {
		Firestone.Click 773, 130

		loop 8
		{
			MouseMove 0, 0
			Tools.Sleep 2000
			If CheckIfGreen(1572, 256, 1621, 318) {
				Firestone.Click 1486, 283
				if CheckIfGreen(1035, 635, 1099, 727) {
					Firestone.Click 1169, 672, 250
				}
			} else {
				break
			}
			
		}
	}

	; Виклики
	if CheckIfRed(1322, 79, 1364, 113) {
		Firestone.Click 1167, 132

		loop 8
		{
			MouseMove 0, 0
			Tools.Sleep 2000
			If CheckIfGreen(1572, 256, 1621, 318) {
				Firestone.Click 1486, 283
				if CheckIfGreen(1035, 635, 1099, 727) {
					Firestone.Click 1169, 672, 250
				}
			} else {
				break
			}
			
		}
	}

	Press "{ESC}"
}

DoOpenBoxes() {
	Press "{B}"
	Firestone.Click 1373, 548, 500
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
		
		Firestone.Click x, y, 1000

		;; Проверяем, что сундук и правда открылся, а не ложное срабатывание
		if not PixelSearch(&OutpuxX, &OutpuxY, 590-10, 86-10, 1301+10, 851+10, 0x9CC4E3, 1) {
			Tools.Sleep 1000
			continue
		}

		if PixelSearch(&OutpuxX, &OutpuxY, 1283, 696, 1301, 851, colors['green_button'], 1) { ; x50
			box_opened := true
			Firestone.Click OutpuxX, OutpuxY
		}

		if PixelSearch(&OutpuxX, &OutpuxY, 1153, 696, 1176, 851, colors['green_button'], 1) { ; x10
			box_opened := true
			Firestone.Click OutpuxX, OutpuxY
		}

		if PixelSearch(&OutpuxX, &OutpuxY, 863, 696, 1053, 851, colors['green_button'], 1) { ; x1
			box_opened := true
			Firestone.Click OutpuxX, OutpuxY
		}

		MouseMove 0, 0

		if PixelSearch(&OutpuxX, &OutpuxY, 631, 754, 1272, 825, 0x365E91, 1) {
			; MsgBox "Этот сундук нельзя открыть!"
			Press "{ESC}"
			continue
		}

		loop 20 ;; Ждём распаковку
		{
			;; Проверяем наличие зелёной кнопки
			if WaitForSearchPixel(835, 804, 1085, 869, colors['green_button'], 1, 250) {
				Firestone.Click 953, 833, 500
			}
			
			;; проверяем наличие крестика
			if WaitForSearchPixel(1817-15, 52-15, 1817+15, 52+15, 0xFF620A, 0, 250) {
				Firestone.Click 1817, 52, 500
				break
			}
				
			Tools.Sleep 1000 ;; продолжаем ждать
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
			SetCurrentSettings()
			If WinExist(firestone_hwid){
				WinActivate
			}

			try
			{
				Sleep 1000 ; Заглушка, чтобы пошёл таймер в A_TimeIdlePhysical
				Firestone.BackToMainScreen()
				Tools.Sleep 1000
				DoUpgrades
			}
			catch String as err
			{
				Tp "Прерываю работу. " . err
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

	Firestone.Click 313, 630
	Firestone.Click 1813, 930

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
		if CheckForImage(462, 899, 634, 948, "*120 images/ResearchFree.png")
		{
			Firestone.Click 548, 925, 500
			research_count -= 1
		}

		; Проверить зелёную кнопку завершения
		if PixelSearch(&OutputX, &OutputY, 474, 895, 633, 950, colors['green_button'], 1)
		{
			Firestone.Click 548, 925, 500
			research_count -= 1
		}

		MouseMove 0, 0
		Tools.Sleep 500
	}

	;; Проверка второго слота
	; Проверка на оранжевую кнопку, досрочное завершение
	if CheckForImage(1090, 879, 1301, 958, "*120 images/ResearchFree.png")
	{
		Firestone.Click 1201, 916, 500
		research_count -= 1
	}

	; Проверить зелёную кнопку завершения
	if PixelSearch(&OutputX, &OutputY, 1122, 889, 1283, 951, colors['green_button'], 1)
	{
		Firestone.Click 1201, 916, 500
		research_count -= 1
	}

	MouseMove 0, 0
	Tools.Sleep 500
	
	;; Добавить проверку на второе исследование
	if (research_count < 2)
	{
		loop 50
		{
			Press "{WheelUp}", 30
		}

		loop 2
		{
			;; Scan line 1
			for y in [226, 718, 348, 596, 472] {
				if FindResearch(y) {
						research_count += 1
					}

				if (research_count == 2)
					break 2
			}
		
			Tools.Sleep 200

			loop 35
			{
				Press "{WheelDown}", 30
			}
		}
	}
	

	Press "{ESC}"
}

DoDailyMagazineReward() {
	Firestone.Click 1300, 343

	if PixelSearch(&OutputX, &OutputY, 432, 869, 442, 879, 0x5B5EAA, 1)
	{
		Firestone.Click 592, 743, 200
	}

	if CheckIfRed(1425, 25, 1474, 76)
	{
		Firestone.Click 1381, 91
		if PixelSearch(&OutputX, &OutputY, 1261, 796, 1404, 841, 0x4CA02E, 1)
		{
			Firestone.Click 1324, 811
		}
	}

	Press "{ESC}"

	return true
}

DoAlchemy() {
	;; Проверяем, висит ли красный значёк у здания.
	if not CheckIfRed(570, 808, 614, 851)
		return

	Firestone.Click(480, 790)

	alchemy_1 := false
	alchemy_2 := false
	alchemy_3 := false

	alchemy := [
		SubStr(CurrentSettings.Get('alchemy'), 1, 1),
		SubStr(CurrentSettings.Get('alchemy'), 2, 1),
		SubStr(CurrentSettings.Get('alchemy'), 3, 1)
	]
	
	;; Сначала за пыль и монеты, потом за кровь
	; За пыль
	if (alchemy[2] == "1") {
		if CheckIfGreenAndClick(1210, 764, 250)
			alchemy_2 := true
		else
		{
			if CheckIfOrangeAndClick(1270, 740, 250)
				alchemy_2 := true
		}
	}

	; За монеты
	if (alchemy[3] == "1") {
		if CheckIfGreenAndClick(1560, 764, 250)
			alchemy_3 := true
		else
		{
			if CheckIfOrangeAndClick(1620, 740, 250)
				alchemy_3 := true
		}
	}

	; За кровь
	if (alchemy[1] == "1") {
		if CheckIfGreenAndClick(860, 764, 250)
			alchemy_1 := true
		else
		{
			if CheckIfOrangeAndClick(920, 740, 250)
				alchemy_1 := true
		}
	}

	;; Сначала за пыль и монеты, потом за кровь
	; За пыль
	if (alchemy[2] == "1") {
		if alchemy_2 == true
			CheckIfGreenAndClick(1210, 764, 2500)
	}

	; За монеты
	if (alchemy[3] == "1") {
		if alchemy_3 == true
			CheckIfGreenAndClick(1560, 764, 2500)
	}

	; За кровь
	if (alchemy[1] == "1") {
		if alchemy_1 == true
			CheckIfGreenAndClick(860, 764, 2500)
	}

	Press "{Esc}"
}

DoWMDailys() {
	; Здесь можно проверить, светятся ли невыполненные дейлики
	if (CheckIfRed(1850, 900, 1900, 950))
	{
		Firestone.Click(1777, 977) ; Ежедневные миссии
		Firestone.Click(720, 779) ; Кнопка выбора, освобождение
		SendEvent "{Click 265 575 Down}{click 1427 575 Up}" ; Скролл дейликов в самое начало
		SendEvent "{Click 265 575 Down}{click 1427 575 Up}" ; Скролл дейликов в самое начало

		Tools.Sleep 500
		; Первая миссия
		DoWMMission(190, 700, 450, 770, 312, 740) ; 1
		DoWMMission(580, 700, 850, 770, 720, 740) ; 2
		DoWMMission(985, 700, 1240, 770, 1110, 740) ; 3
		DoWMMission(1380, 700, 1640, 770, 1500, 740) ; 4
		DoWMMission(1777, 700, 1800, 770, 1790, 740) ; 5

		SendEvent "{click 1427 575 Down}{Click 265 575 Up}" ; Скролл дейликов в конец
		SendEvent "{click 1427 575 Down}{Click 265 575 Up}" ; Скролл дейликов в конец

		DoWMMission(280, 700, 540, 770, 405, 740) ; 6
		DoWMMission(680, 710, 929, 768, 804, 740) ; 7

		Press "{Esc}" ; Вышли на карту

		; Зайти ещё раз и проверить вторую стопку дейликов
		Firestone.Click(1777, 977, 500) ; Ежедневные миссии
		if PixelSearch(&Found_X, &Found_Y, 1100, 740, 1340, 810, colors['green_button'], 1) ; 
		{
			Firestone.Click 1235, 770, 500 ; Жмём кнопку для захода в задания подземелий

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
		UpgradeHero(1652, 134, 1776, 219, 1771, 180) ; 1
		UpgradeHero(1652, 817, 1776, 889, 1758, 875, 5) ; 7
		UpgradeHero(1652, 704, 1776, 776, 1758, 758, 5) ; 6
		UpgradeHero(1652, 593, 1776, 665, 1758, 644, 5) ; 5
		UpgradeHero(1652, 479, 1776, 551, 1758, 527, 5) ; 4
		UpgradeHero(1652, 366, 1776, 438, 1758, 424, 5) ; 3
		UpgradeHero(1652, 251, 1776, 323, 1764, 290, 5) ; 2
	} else {
		loop parse CurrentSettings.Get('lvlup_priority') {
			switch A_LoopField {
				case "1":
					UpgradeHero(1652, 134, 1776, 219, 1771, 180) ; 1
				case "2":
					UpgradeHero(1652, 251, 1776, 323, 1764, 290, 5) ; 2
				case "3":
					UpgradeHero(1652, 366, 1776, 438, 1758, 424, 5) ; 3
				case "4":
					UpgradeHero(1652, 479, 1776, 551, 1758, 527, 5) ; 4
				case "5":
					UpgradeHero(1652, 593, 1776, 665, 1758, 644, 5) ; 5
				case "6":
					UpgradeHero(1652, 704, 1776, 776, 1758, 758, 5) ; 6
				case "7":
					UpgradeHero(1652, 817, 1776, 889, 1758, 875, 5) ; 7
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
	
	Firestone.Click 1230, 800 ; Клик на здание механика

	;; Проверяем, висит ли красный значёк у механика.
	if not CheckIfRed(724, 306, 759, 336)
	{
		Press "{ESC}"
		return
	}
		

	Firestone.Click 600, 460 ; Клик на выбор Механик
	Firestone.Click 1620, 680 ; Клик на кнопку получения инструментов
	Press "{Esc}"
}

; Прокачка стража
CollectXPGuard() {
	;; Проверяем, висит ли красный значёк у здания.
	if not CheckIfRed(738, 281, 783, 324)
		return

	Firestone.Click 625, 230 ; Здание стража
	Firestone.Click 1150, 765 ; Интерфейс стража
	Press "{Esc}"
}

DoOracle() {
	;; Проверяем, висит ли красный значёк у здания.
	if not CheckIfRed(1108, 931, 1152, 970)
		return

	Firestone.Click 1026, 911, 500

	;; Забрать ежедневный бесплатный подарок оракула
	if CheckIfRed(860, 660, 903, 695) {
		Firestone.Click 824, 738, 500

		if PixelGetColor(467, 815) == 0x5B5EAA
		{
			Firestone.Click 641, 739, 200
		}

		Press "{ESC}"
	}


	;; Проверяем, висит ли красный значёк у ритуалов.
	if not CheckIfRed(860, 317, 903, 356) {
		Press "{ESC}"
		return
	}

	Firestone.Click 825, 393, 500

	;; Проверяем зелёные кнопки и кликаем
	CheckIfGreenAndClick(1092, 473, 250) ; Гармония
	CheckIfGreenAndClick(1504, 479, 250) ; Безмятежность
	CheckIfGreenAndClick(1502, 820, 250) ; Концентрация
	CheckIfGreenAndClick(1092, 820, 250) ; Послушание
	
	Press "{ESC}"
}

; Экспедиции
DoExpeditions() {
	Firestone.Click(1482, 127) ; Клик на здание гильдии

	;; Забрать заодно кирки
	if CheckIfRed(739, 284, 780, 324)
	{
		Firestone.Click 660, 211, 500 ;; Здание магазина

		if CheckIfRed(161, 668, 196, 709){
			Firestone.Click 211, 721, 500
			Firestone.Click 712, 410, 500
		}

		Press "{ESC}"
	}

	;; Проверяем, висит ли красный значёк у здания.
	if not CheckIfRed(405, 443, 435, 475)
	{
		Press "{Esc}" ; Выйти в город
		return
	}

	Firestone.Click(296, 387) ; Клик на здание экспедиций
	CheckIfGreenAndClick 1184, 299
	MouseMove 0, 0
	CheckIfGreenAndClick 1184, 299, 3000
	Press "{Esc}" ; Закрыть окно экспедиций
	Press "{Esc}" ; Выйти в город
}

DoMap() {
	map_status := ''

	Press "{m}"
	Firestone.Click(1834, 583, 500) ; Клик для перехода на карту военной кампании
	Firestone.Buttons.Green.CheckAndClick(36, 912, 67, 965)  ; Забрать лут
	Firestone.Click(1832, 438, 500) ; Вернуться обратно на карту миссий

	; Прокликать завершённые задания
	map_status := MapTryFinishMissions()
	if map_status == 'hangup'
		DoMapMissions(true)
	else
		DoMapMissions
	
	Firestone.Click(1834, 583, 500) ; Клик для перехода на карту военной кампании

	DoWMDailys

	Press "{Esc}"
}

CheckSquad() {
	return PixelSearch(&FoundX, &FoundY, 646, 946, 816, 1016, 0xF9E7CE, 1)
}

ClickOnMapMission(x, y) {
	Firestone.Click x, y, 100
	; Зелёная кнопка принятия
	MouseMove 0, 0

	; Смотрим, появилось окно или нет, если не появилось, значит можно не проверять кнопки.
	; Должно ускорить поиск миссий
	if !Tools.WaitForSearchPixel(414, 206, 424, 216, 0xE1CDAC, 1, 250) {
		return
	}

	; Проверяем наличие кнопки принятия миссии и кликаем её
	if !Firestone.Buttons.Green.WaitAndClick(955, 802, 990, 886, 500) ; Ищем кнопку и кликаем, если нет, проверяем другие варианты
	{
		
		if(Firestone.Buttons.Orange.CheckAndClick(1251, 720, 1491, 790))
		{
			Firestone.Buttons.Green.WaitAndClick(802, 572, 828, 637, 5000)
			return
		}

		; Проверяем наличие кнопки отмены
		if(Firestone.Buttons.Red.Check(967, 713, 1009, 783)){
			Firestone.Press("{Esc}")
			return
		}

		if(CheckForImage(1024, 803, 1164, 874, "*80 images/NotEnoughSquads.png")){
			Firestone.Press "{Esc}"
			return
		}

		; окно подтверждения принятия награды "награды миссии"
		Firestone.Buttons.Green.CheckAndClick(802, 572, 828, 637)
	}
}

DoWMMission(zone_x1, zone_y1, zone_x2, zone_y2, click_x, click_y) {
	Tools.Sleep 500
	if PixelSearch(&Found_X, &Found_Y, zone_x1, zone_y1, zone_x2, zone_y2, colors['green_button'], 1)
	{
		Firestone.Click click_x, click_y
		MouseMove(0, 0) ; Убираем мышь, чтобы не светила кнопку
		if !CheckIfGreenAndClick(926, 734, 120000) ; Ждём появление кнопки подтверждения
		{
			throw 1
		}
	}
	else
		return 0
}

EachMapMissions(missions, force := false, finish := false) {
	try_finish := false
	For x, y in missions.OwnProps()
	{
		If !CheckSquad() && force == false
			break

		ClickOnMapMission(x, y)
		try_finish := true
	}

	if try_finish == true || finish == true
		MapTryFinishMissions
}

DoMapMissions(force := false){
	; Проверить, есть ли не задания на карте и попытаться их начать.
	if (CheckSquad() || force == true)
	{
		; Мисси при событии "Мировое господство"
		EachMapMissions(map_world_domination_missions, force, true)
		EachMapMissions(map_litle_missons, force, true)
		EachMapMissions(map_big_missons, force, true)
		EachMapMissions(map_small_missons, force, true)
		EachMapMissions(map_medium_missons, force)
	}
}

MapTryFinishMissions() {
	; Попробовать завершить задания, которым осталось меньше 3-х минут
	loop 20 ; Ограничим цикл, если вдруг что-то пошло не так.
	{
		if not Tools.PixelSearch(14, 208, 263, 341, 0xF7E5CB, 1)
			break
		else
		{
			Firestone.Click 138, 239, 500
			; окно подтверждения принятия награды "награды миссии"
			if Firestone.Buttons.Green.CheckAndClick(802, 572, 828, 637) {
				continue
			}

			if(CheckForImage(1251, 720, 1491, 790, "*120 images/FreeOrange.png"))
			{
				Firestone.Click 1367, 747, 500
				Firestone.Buttons.Green.WaitAndClick(802, 572, 828, 637, 5000)
				continue
			}
	
			; Проверяем наличие кнопки отмены
			if(Firestone.Buttons.Red.Check(967, 713, 1009, 783)){
				Firestone.Press("{Esc}")
				break
			}

			if (Tools.PixelSearch(85, 274, 138, 332, 0xADABAD, 1)) {
				return 'hangup'
			}
		}
	}
}

CheckIfOrangeAndClick(x, y, timeout := 1000){
	if WaitForPixel(x, y, "0xFCAF47 0xFCAC47 0xFBAC46 0xFAAB45 0xF9AB44 0xFBAB47 0xFAAB46 0xF9AB45 0xF8AA44 0xF8A945 0xF9AA45 0xF9A946 0xF9A847", timeout)
	{
		Firestone.Click(x, y)
		return 1
	}

	return 0
}

CheckIfGreenAndClick(x, y, timeout := 1000){
	if WaitForPixel(x, y, "0x0AA008 0x0B9F05 0x0A9F05 0x0AA005 0x0AA006", timeout)
	{
		Firestone.Click(x, y)
		return 1
	}

	return 0
}

CheckIfRed(x1, y1, x2, y2) {
	return PixelSearch(&FoundX, &FoundY, x1, y1, x2, y2, 0xF30000, 1)
}

CheckIfGreen(x1, y1, x2, y2) {
	return PixelSearch(&FoundX, &FoundY, x1, y1, x2, y2, colors['green_button'], 1)
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



; Клик на иконку города на главном экране
ClickCityIcon() {
	; Firestone.Click 1850, 185 ; Клик на иконку города
	Press "{t}"
}

UpgradeHero(x1, y1, x2, y2, clickx, clicky, clicks := 1) {
	Firestone.Buttons.Green.CheckAndClick(x1, y1, x2, y2, clickx, clicky, 200, clicks)
}

FindResearch(y) {
	MouseMove 20, y
	if PixelSearch(&OutputX, &OutputY, 20, y, 1900, y, 0x0D49DE, 1)
	{
		;; попробовать кликнуть
		Firestone.Click OutputX, OutputY
		MouseMove 0, 0
		Tools.Sleep 250
		;; Подождать окно принятия
		if Tools.WaitForSearchPixel(669, 707, 928, 775, colors['green_button'], 1, 1000)
		{
			Firestone.Click 795, 738, 500
			
			return true
		}
	}


}

Press(key, wait := 1000) {
	FindFirestoneWindowAndActivate

	Send key
	Tools.Sleep(wait)
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
		Tools.Sleep 500
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
		Tools.Sleep 500
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

SetCurrentSettings() {
	global firestone_hwid, CurrentSettings

	ProcessPath := WinGetProcessPath(firestone_hwid)

	CurrentSettings := Settings.Section(ProcessPath)

	defaults := Map(
		'auto_research', 0,
		'lvlup_priority', '17',
		'open_boxes', 0,
		'auto_complete_quests', 0,
		'auto_arena', 0,
		'arena_today', false,
		'alchemy', '111'
	)

	for key, value in defaults {
		if !CurrentSettings.Has(key)
			CurrentSettings.Set(key, value)
	}
}

OnExit ExitFunc

ExitFunc(ExitReason, ExitCode) {
	Settings.Save()
}
