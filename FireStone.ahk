#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
#SingleInstance Force

#Include Settings.ahk
#Include Tools.ahk
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
#Include Quests.ahk
#Include Bags.ahk
#Include WarCampaignMap.ahk
#Include FirestoneMenu.ahk

InstallKeybdHook

SendMode "InputThenPlay"
; Thread "Interrupt", 0  ; Make all threads always-interruptible.

SetDefaultMouseSpeed 25

AppVersion := "v0.0.1-alpha"

saved_mouse_position_x := 0
saved_mouse_position_y := 0
prestige_mode := false
Settings('settings.ini')
FirestoneMenu.Create()

^+e:: {
	MsgBox "Скрипт перезапущен."
	Reload
}

~RButton::{
    if WinActive("ahk_exe Firestone.exe")
        FirestoneMenu.Menu.Show()
}

; Сменить режим апгрейда героев
^NumpadEnd::
^Numpad1:: {
	PrestigeModeOnOff
}

^y:: {
	RunOnOff
}

RunOnOff() {
	global saved_mouse_position_x, saved_mouse_position_y
    static toggled := false
	
    toggled := !toggled

	if !toggled {
		Tp "Скрипт приостановлен."
		FirestoneMenu.Menu.Rename('1&', 'Включить')
		Sleep 2000
		Exit
	}
	
	if toggled
	{
		Tp "Запускаю.", -1000
		FirestoneMenu.Menu.Rename('1&', 'Выключить')
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
		FirestoneMenu.Menu.Rename('2&', 'Обычный режим')
		SetTimer DoPrestigeUpgrades, 60000
	}
	else
	{
		Tp "Обычный режим"
		FirestoneMenu.Menu.Rename('2&', 'Режим престижа')
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
		hwids := Firestone.FindAllWindows()
		for hwid in hwids
		{
			daily_magazine_rewards := false
			Firestone.Set(hwid)

			try
			{
				Sleep 1000 ; Заглушка, чтобы пошёл таймер в A_TimeIdlePhysical
				Firestone.BackToMainScreen()
				Tools.Sleep 1000
				if Firestone.Icons.Red.Check(1877, 517, 1912, 555)
					daily_magazine_rewards := true

				HerosUpgrades.Do(Firestone.CurrentSettings.Get('lvlup_priority'), prestige_mode)
				Firestone.City() ; зайти в город
				
				if daily_magazine_rewards == true {
					if Firestone.CurrentSettings.Get('auto_arena', 0) == 1 {
						Firestone.CurrentSettings.Set('arena_today', false)
						Settings.Save()
					}

					Magazine.Do()
				}
				
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

				if Firestone.CurrentSettings.Get('auto_arena', 0) == 1 && Firestone.CurrentSettings.Get('arena_today', false) == false {
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
	global saved_mouse_position_x, saved_mouse_position_y

	MouseGetPos(&Mx, &My)

	; Если мышка двигалась или нажималась клавиатура пока спали, пропускаем задачу
	If((A_TimeIdle >= 60000 && saved_mouse_position_x == Mx && saved_mouse_position_y == My) || force == true) {
		hwids := Firestone.FindAllWindows()
		for hwid in hwids
		{
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
				Tp "Прерываю работу. " . err
				break
			}
		}
    }
	
	MouseGetPos(&saved_mouse_position_x, &saved_mouse_position_y)
}

Tp(text, timeout := -2000) {
	ToolTip text
	SetTimer () => ToolTip(), timeout
}

OnExit ExitFunc

ExitFunc(ExitReason, ExitCode) {
	Settings.Save()
}
