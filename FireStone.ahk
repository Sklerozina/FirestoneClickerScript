#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
#SingleInstance Force

#Include Settings.ahk
#Include Tools.ahk
#Include Firestone\Firestone.ahk

#Include Firestone
#Include Button.ahk
#Include Arena.ahk
#Include Guild.ahk
#Include Oracle.ahk
#Include HeroesUpgrades.ahk
#Include Magazine.ahk
#Include Tavern.ahk
#Include Alchemy.ahk
#Include Guard.ahk
#Include Mechanic.ahk

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
				if Firestone.Icons.Red.Check(1877, 517, 1912, 555)
					daily_magazine_rewards := true

				HerosUpgrades.Do(CurrentSettings.Get('lvlup_priority'), prestige_mode)
				Firestone.City() ; зайти в город
				
				if daily_magazine_rewards == true {
					if CurrentSettings.Get('auto_arena', 0) == 1 {
						CurrentSettings.Set('arena_today', false)
						Settings.Save()
					}

					Magazine.Do()
				}
				
				Tavern.Do()
				Alchemy.Do(CurrentSettings.Get('alchemy'))
				Guard.Do()
				Mechanic.Do() ; Механик
				Guild.Do() ; Экспедиции

				if CurrentSettings.Get('auto_research') == 1
					DoResearch

				Oracle.Do()
				Firestone.Esc()
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
				HerosUpgrades.Do(CurrentSettings.Get('lvlup_priority'), prestige_mode)
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
