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
#Include Library.ahk
#Include Quests.ahk
#Include Bags.ahk

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
					Library.Do()

				Oracle.Do()
				Firestone.Esc()
				Firestone.BackToMainScreen() ;; Страховка перед заходом на карту

				DoMap

				if CurrentSettings.Get('open_boxes') == 1
					Bags.Do()

				if CurrentSettings.Get('auto_complete_quests') == 1
					Quests.Do()

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
