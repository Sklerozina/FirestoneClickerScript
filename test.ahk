#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
SetControlDelay -1  ; May improve reliability and reduce side effects.

hid := WinExist("ahk_exe Firestone.exe")
SendMode "InputThenPlay"

^a:: {
    hwids := WinGetList("ahk_exe Firestone.exe")
    Loop hwids.Length
        firestone_hwid := hwids[A_Index]
        If WinExist(firestone_hwid)
            WinActivate
}

^y:: {
    MouseGetPos(&MouseX, &MouseY)
    Sleep 5000
    MouseGetPos(&MouseXa, &MouseYa)
    If((MouseX != MouseXa) && (MouseY != MouseYa)) {
        MsgBox 'Двигалась!'
    }
    else
    {
        MsgBox 'Не двигалась!'
    }
    
}

FClick(x) {
	Click hid,,,,,x
	Sleep 1000
}

Press(key) {
	ControlSend key,, hid
	Sleep 1000
    MsgBox("!!!")
}