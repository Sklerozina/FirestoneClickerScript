#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
#SingleInstance Force

AppVersion := "v0.1.19"
A_IconTip := "Firestone Clicker " AppVersion

If !IsSet(Firestone_WorkingDir)
	Firestone_WorkingDir := A_WorkingDir

#Include Settings.ahk
#Include Tools.ahk
#Include Logs.ahk

Settings := Ini(Firestone_WorkingDir '\settings.ini')

#Include Firestone
#Include Firestone.ahk
#Include FirestoneController.ahk
#Include FirestoneWindow.ahk
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
#Include Merchant.ahk
#Include Quests.ahk
#Include Bags.ahk
#Include Chests.ahk
#Include Mailbox.ahk
#Include WarCampaignMap.ahk
#Include MapMissions.ahk
#Include MapMission.ahk
#Include MapMissionDomination.ahk
#Include FirestoneMenu.ahk
#Include Events.ahk

InstallKeybdHook
InstallMouseHook

SendMode "Input"
; Thread "Interrupt", 0  ; Make all threads always-interruptible.

; SetDefaultMouseSpeed 25

saved_mouse_position_x := 0
saved_mouse_position_y := 0
last_run := 0

if Settings.Section('GENERAL').Get('debug', 'none') == 'none'
	Settings.Section('GENERAL').Set('debug', 0)

if Settings.Section('GENERAL').Get('BOT_TOKEN', 'none') == 'none'
	Settings.Section('GENERAL').Set('BOT_TOKEN', '')

if Settings.Section('GENERAL').Get('TELEGRAM_CHAT_ID', 'none') == 'none'
	Settings.Section('GENERAL').Set('TELEGRAM_CHAT_ID', '')

DebugLog := Logs(Firestone_WorkingDir '\Logs\')
If Settings.Section('GENERAL').Get('debug', 0) {
	FirestoneController.Menu.Rename("Включить логи", 'Выключить логи')
	DebugLog.Enable()
}

#HotIf WinActive("ahk_exe Firestone.exe")
^+C::{
	MouseGetPos(&x, &y)
	A_Clipboard := x ", " y
	Tp("Координаты курсора скопированы в буфер обмена")
}

^+x::{
	MouseGetPos(&x, &y)
	MouseMove 0, 0
	Sleep 300
	A_Clipboard := x ", " y ", " PixelGetColor(x, y)
	MouseMove x, y
	Tp(A_Clipboard)
}

^+Space::{
	static toggle := false

	if !toggle
		toggle := true
	else
		toggle := false

	if toggle {
		Tp("Кликер в фоне активирован.")
		SetTimer(DoBackgroundClicker, 50, -100)
	} else {
		Tp("Кликер в фоне выключен.")
		SetTimer(DoBackgroundClicker, 0)
	}
}

; Сменить режим апгрейда героев
^NumpadEnd::PrestigeModeOnOff
^Numpad1::PrestigeModeOnOff
#HotIf

#HotIf MouseOverWindow()
RButton::FirestoneController.Menu.Show()
#HotIf

MouseOverWindow() {
	MouseGetPos(&x, &y, &WinId)

	if WinGetTitle(WinId) == 'Firestone'
		return true
	else
		return false
}

^+e:: {
	MsgBox "Скрипт перезапущен."
	Reload
}

^y::RunOnOff

LogsOnOff() {
	if DebugLog.enabled	{
		Tp 'Логирование выключено'
		FirestoneController.Menu.Rename('Выключить логи', "Включить логи")
		DebugLog.Disable()
		Settings.Section('GENERAL').Set('debug', 0)
	} else {
		Tp 'Логирование включено'
		FirestoneController.Menu.Rename("Включить логи", 'Выключить логи')
		DebugLog.Enable()
		Settings.Section('GENERAL').Set('debug', 1)
	}
}

DoBackgroundClicker() {
	MouseGetPos(&x, &y)
	for Path, Firestone in FirestoneController.Firestones {
		if x > 230 && x < 1512 && y > 268 && y < 779
			ControlClick('X0 Y0',Firestone.Window.hwid)
	}
}

RunOnOff() {
	global saved_mouse_position_x, saved_mouse_position_y
    static toggled := false
	
    toggled := !toggled

	if !toggled {
		Tp "Скрипт приостановлен."
		FirestoneController.Menu.Rename('Выключить', 'Включить')
		SetTimer DoWork, 0
	}
	
	if toggled
	{
		Tp "Запускаю.", -1000
		FirestoneController.Menu.Rename('Включить', 'Выключить')
		MouseGetPos(&saved_mouse_position_x, &saved_mouse_position_y)

		SetTimer(DoWork, 300000)
		SetTimer((*) => (DoWork(true)), -1000)
	}
}

PrestigeModeOnOff() {
	FirestoneController.prestige_mode := !FirestoneController.prestige_mode

	for Path, Firestone in FirestoneController.Firestones
	{
		Firestone.prestige_mode := FirestoneController.prestige_mode
	}

	if FirestoneController.prestige_mode {
		Tp "Режим престижа"
		FirestoneController.Menu.Rename('Режим престижа', 'Обычный режим')
		SetTimer DoPrestigeUpgrades, 60000
	}
	else
	{
		Tp "Обычный режим"
		FirestoneController.Menu.Rename('Обычный режим', 'Режим престижа')
		SetTimer DoPrestigeUpgrades, 0
	}
}

SetAllDailyComplete(){
	date := FormatTime(, 'yyyyMMdd')

	for key, value in Settings.data {
		if InStr(key, 'Firestone.exe')
		{

			Settings.Section(key).Set('daily_merchant', 1)
			Settings.Section(key).Set('daily_arena', 1)
			Settings.Section(key).Set('daily_tavern', 1)
			Settings.Section(key).Set('daily_crystal', 1)
			Settings.Section(key).Set('daily_magazine', 1)
			Settings.Section(key).Set('daily_date', date)
		}
	}
}

SetAllDailyUncomplete() {
	if MsgBox("Вы уверены?", "Сбросить счётчик дейликов", 0x4) == "No"
		return

	if MsgBox("Вы ТОЧНО уверены? Это заставит скрипт попытаться сделать все дейлики ещё раз!", "Сбросить счётчик дейликов", 0x4) == "No"
		return


	for key, value in Settings.data {
		if InStr(key, 'Firestone.exe')
		{

			Settings.Section(key).Set('daily_merchant', 0)
			Settings.Section(key).Set('daily_arena', 0)
			Settings.Section(key).Set('daily_tavern', 0)
			Settings.Section(key).Set('daily_crystal', 0)
			Settings.Section(key).Set('daily_magazine', 0)
		}
	}
}

FirestoneController.FindAllWindows()

; Запускается по таймеру
DoWork(force := false) {
	global saved_mouse_position_x, saved_mouse_position_y, last_run
	static delay := 300000

	Thread("NoTimers") ; Чтобы задача не прерывалась другими таймерами
	FirestoneController.FindAllWindows()

	; Если мышка двигалась или нажималась клавиатура пока спали, пропускаем задачу
	MouseGetPos(&Mx, &My)

	; Если мышка двигалась или нажималась клавиатура пока спали, пропускаем задачу
	If((A_TimeIdlePhysical >= delay && saved_mouse_position_x == Mx && saved_mouse_position_y == My) || force == true) {
		Settings.Reload()
		DebugLog.Log('====`nНачинаю работу!', "`n`n")
		
		for Path, Firestone in FirestoneController.Firestones
		{
			DebugLog.Log('Окно ' . Path ' [' Firestone.Window.hwid ']', "`n")
			DebugLog.Log('Перезапуск был ' FormatTime(Firestone.Window.last_start, "dd.MM.yy HH:mm") ' ' DateDiff(A_Now, Firestone.Window.last_start, 'Hours') ' ч. назад.')

			try
			{
				if Firestone.Settings.Get('auto_restart_every_hours', 0) > 0 &&
					Firestone.Settings.Get('run_string', '') != '' &&
					DateDiff(A_Now, Firestone.Window.last_start, 'Hours') >= Firestone.Settings.Get('auto_restart_every_hours', 0) && Firestone.Window.Exist()
				{
					DebugLog.Log('Пришло время автоматического перезапуска игры')
					Firestone.Restart()
				}

				if !Firestone.Window.Exist() && Firestone.Settings.Get('autorun_if_notfound', 0) {
					DebugLog.Log('Окно с игрой не найдено, запуск.')
					result_yn := MsgBox("Запуск игры через 30 секунд...",, "Y/N/C T30")
					if (result_yn = "Timeout" || result_yn = "Yes") {
						Firestone.Restart()
					} else if result_yn = "Cancel" {
						RunOnOff()
					}
				} else if !Firestone.Window.Exist() {
					continue
				}

				if Firestone.force_restart == true && Firestone.Settings.Get('run_string', '') != '' {
					DebugLog.Log('Принудительный перезапуск игры.')
					Firestone.Restart()
					Firestone.force_restart := false
				}
			
				; Sleep 1000 ; Заглушка, чтобы пошёл таймер в A_TimeIdlePhysical
				Firestone.BackToMainScreen()
				Tools.Sleep 1000

				; Сбрасываем дейлики
				if Firestone.Icons.Red.Check(1883, 508, 1911, 541)
					Firestone.ResetDailys()

				Firestone.Mailbox.Do()
				Firestone.HerosUpgrades.Do()
				Firestone.City() ; зайти в город
				Firestone.Magazine.Do()
				Firestone.Merchant.Do()
				Firestone.Tavern.Do()
				Firestone.Alchemy.Do()
				Firestone.Guard.Do()
				Firestone.Mechanic.Do() ; Механик
				Firestone.Guild.Do() ; Экспедиции

				if Firestone.Settings.Get('auto_research') == 1
					Firestone.Library.Do()
				
				Firestone.Oracle.Do()
				Firestone.Esc()
				Firestone.BackToMainScreen() ;; Страховка перед заходом на карту

				Firestone.WarCampaignMap.Do()

				if Firestone.Settings.Get('open_boxes') == 1
					Firestone.Bags.Do()

				if Firestone.Settings.Get('auto_complete_quests') == 1
					Firestone.Quests.Do()

				if Firestone.Settings.Get('auto_arena', 0) == 1 && Firestone.Settings.Get('daily_arena', false) == false {
					Firestone.Arena.Do()
				}

				if Firestone.Settings.Get('auto_events', 0) == 1 {
					Firestone.Events.Do()
				}

				DebugLog.Log('==== Закончил работу!', "`n")
			}
			catch String as err
			{
				DebugLog.Log("Прерываю работу. " . err . " (From Catch)")
				Tp "Прерываю работу. " . err, -2000
				delay := 180000
				SetTimer DoWork, delay ; Если мышь двигалась, то следующий раз будет через 3 минуты
				break
			}
		}

		last_run := A_Now
		delay := 300000
		SetTimer DoWork, delay ; Если мышь не двигалась, то продолжаем через 5 минут
    }
	else
	{
		DebugLog.Log('Мышь двигалась или были нажатия клавиатуры. Работа отложена.', "`n")
		delay := 120000
		SetTimer DoWork, delay ; Если мышь двигалась, то следующий раз будет через 2 минуты
	}

	MouseGetPos(&saved_mouse_position_x, &saved_mouse_position_y)
}

DoPrestigeUpgrades(force := false) {
	global saved_mouse_position_x, saved_mouse_position_y, last_run

	; Проверяем, когда последний раз запускалась основная работа и откладываем запуск, если уже пора
	if last_run != 0 && DateDiff(A_Now, last_run, 'Seconds') > 300
		return

	MouseGetPos(&Mx, &My)
	FirestoneController.FindAllWindows()

	; Если мышка двигалась или нажималась клавиатура пока спали, пропускаем задачу
	If((A_TimeIdle >= 60000 && saved_mouse_position_x == Mx && saved_mouse_position_y == My) || force == true) {
		DebugLog.Log('====`nНачинаю работу! Режим престижа!', "`n`n")

		for Path, Firestone in FirestoneController.Firestones
		{
			if !Firestone.Window.Exist()
				continue

			DebugLog.Log('Окно ' . WinGetProcessPath(Firestone.Window.hwid), "`n")

			try
			{
				Sleep 1000 ; Заглушка, чтобы пошёл таймер в A_TimeIdlePhysical
				Firestone.BackToMainScreen()
				Tools.Sleep 1000
				Firestone.HerosUpgrades.Do()
			}
			catch String as err
			{
				DebugLog.Log("Прерываю работу. " . err . " (From Catch)")
				Tp "Прерываю работу. " . err, -2000
				break
			}
		}
    }
	else {
		DebugLog.Log('Режим престижа. Мышь двигалась или были нажатия клавиатуры. Работа отложена.', "`n")
	}
	
	MouseGetPos(&saved_mouse_position_x, &saved_mouse_position_y)
}

Tp(text, timeout := -2000) {
	ToolTip text
	SetTimer () => ToolTip(), timeout
}
