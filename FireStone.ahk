#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
#SingleInstance Force

AppVersion := "v0.0.20"
A_IconTip := "Firestone Clicker " AppVersion

#Include Settings.ahk
#Include Tools.ahk
#Include Logs.ahk
#Include Firestone\Firestone.ahk

#Include Firestone
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
#Include Mailbox.ahk
#Include WarCampaignMap.ahk
#Include MapMissions.ahk
#Include MapMission.ahk
#Include MapMissionDomination.ahk
#Include FirestoneMenu.ahk

InstallKeybdHook

SendMode "Input"
; Thread "Interrupt", 0  ; Make all threads always-interruptible.

; SetDefaultMouseSpeed 25

If !IsSet(Firestone_WorkingDir)
	Firestone_WorkingDir := A_WorkingDir

saved_mouse_position_x := 0
saved_mouse_position_y := 0
prestige_mode := false
Settings := Ini(Firestone_WorkingDir '\settings.ini')

if Settings.Section('GENERAL').Get('debug', 'none') == 'none'
	Settings.Section('GENERAL').Set('debug', 0)

if Settings.Section('GENERAL').Get('BOT_TOKEN', 'none') == 'none'
	Settings.Section('GENERAL').Set('BOT_TOKEN', '')

if Settings.Section('GENERAL').Get('TELEGRAM_CHAT_ID', 'none') == 'none'
	Settings.Section('GENERAL').Set('TELEGRAM_CHAT_ID', '')

DebugLog := Logs(Firestone_WorkingDir '\Logs\')
If Settings.Section('GENERAL').Get('debug', 0) {
	Firestone.Menu.Rename("Включить логи", 'Выключить логи')
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
	A_Clipboard := x ", " y ", " PixelGetColor(x, y)
	Tp(A_Clipboard)
}

; Сменить режим апгрейда героев
^NumpadEnd::PrestigeModeOnOff
^Numpad1::PrestigeModeOnOff

RButton::Firestone.Menu.Show()
#HotIf

^+e:: {
	MsgBox "Скрипт перезапущен."
	Reload
}

^y::RunOnOff

LogsOnOff() {
	if DebugLog.enabled	{
		Tp 'Логирование выключено'
		Firestone.Menu.Rename('Выключить логи', "Включить логи")
		DebugLog.Disable()
		Settings.Section('GENERAL').Set('debug', 0)
	} else {
		Tp 'Логирование включено'
		Firestone.Menu.Rename("Включить логи", 'Выключить логи')
		DebugLog.Enable()
		Settings.Section('GENERAL').Set('debug', 1)
	}
}

RunOnOff() {
	global saved_mouse_position_x, saved_mouse_position_y
    static toggled := false
	
    toggled := !toggled

	if !toggled {
		Tp "Скрипт приостановлен."
		Firestone.Menu.Rename('Выключить', 'Включить')
		Sleep 2000
		Exit
	}
	
	if toggled
	{
		Tp "Запускаю.", -1000
		Firestone.Menu.Rename('Включить', 'Выключить')
		MouseGetPos(&saved_mouse_position_x, &saved_mouse_position_y)
		Sleep 1100
		DoWork(true)

		SetTimer DoWork, 300000
	}
}

PrestigeModeOnOff() {
	global prestige_mode

	prestige_mode := !prestige_mode
	if prestige_mode {
		Tp "Режим престижа"
		Firestone.Menu.Rename('Режим престижа', 'Обычный режим')
		SetTimer DoPrestigeUpgrades, 60000
	}
	else
	{
		Tp "Обычный режим"
		Firestone.Menu.Rename('Обычный режим', 'Режим престижа')
		SetTimer DoPrestigeUpgrades, 0
	}
}

; Запускается по таймеру
DoWork(force := false) {
	global saved_mouse_position_x, saved_mouse_position_y
	static delay := 300000

	Thread "Priority", 1 ; На всякий случай, чтобы задача не прерывалась другими таймерами

	; Если мышка двигалась или нажималась клавиатура пока спали, пропускаем задачу
	MouseGetPos(&Mx, &My)

	; Если мышка двигалась или нажималась клавиатура пока спали, пропускаем задачу
	If((A_TimeIdlePhysical >= delay && saved_mouse_position_x == Mx && saved_mouse_position_y == My) || force == true) {
		DebugLog.Log('====`nНачинаю работу!', "`n`n")
		hwids := Firestone.FindAllWindows()
		for hwid in hwids
		{
			DebugLog.Log('Окно ' . WinGetProcessPath(hwid), "`n")
			Firestone.Set(hwid)

			try
			{
				Sleep 1000 ; Заглушка, чтобы пошёл таймер в A_TimeIdlePhysical
				Firestone.BackToMainScreen()
				Tools.Sleep 1000

				Mailbox.Do()
				HerosUpgrades.Do(Firestone.CurrentSettings.Get('lvlup_priority'), prestige_mode)
				Firestone.City() ; зайти в город
				Magazine.Do()
				Merchant.Do()
				Tavern.Do()
				Alchemy.Do(Firestone.CurrentSettings.Get('alchemy'))
				Guard.Do()
				Mechanic.Do() ; Механик
				Guild.Do() ; Экспедиции

				if Firestone.CurrentSettings.Get('auto_research') == 1
					Library.Do()
				
				Oracle.Do()
				Firestone.Esc()
				Firestone.BackToMainScreen() ;; Страховка перед заходом на карту

				WarCampaignMap.Do()

				if Firestone.CurrentSettings.Get('open_boxes') == 1
					Bags.Do()

				if Firestone.CurrentSettings.Get('auto_complete_quests') == 1
					Quests.Do()

				if Firestone.CurrentSettings.Get('auto_arena', 0) == 1 && Firestone.CurrentSettings.Get('daily_arena', false) == false {
					Arena.Do()
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
	global saved_mouse_position_x, saved_mouse_position_y

	MouseGetPos(&Mx, &My)

	; Если мышка двигалась или нажималась клавиатура пока спали, пропускаем задачу
	If((A_TimeIdle >= 60000 && saved_mouse_position_x == Mx && saved_mouse_position_y == My) || force == true) {
		DebugLog.Log('====`nНачинаю работу! Режим престижа!', "`n`n")
		hwids := Firestone.FindAllWindows()
		for hwid in hwids
		{
			DebugLog.Log('Окно ' . WinGetProcessPath(hwid), "`n")
			Firestone.Set(hwid)

			try
			{
				Sleep 1000 ; Заглушка, чтобы пошёл таймер в A_TimeIdlePhysical
				Firestone.BackToMainScreen()
				Tools.Sleep 1000
				HerosUpgrades.Do(Firestone.CurrentSettings.Get('lvlup_priority'), prestige_mode)
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
