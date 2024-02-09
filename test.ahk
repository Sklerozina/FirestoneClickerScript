#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
; SetControlDelay -1  ; May improve reliability and reduce side effects.

hid := WinExist("ahk_exe Firestone.exe")
SendMode "InputThenPlay"

^+e:: {
	MsgBox "Скрипт перезапущен."
	Reload
}

^a:: {
    try
        {
            if ImageSearch(&FoundX, &FoundY, 0, 0, 1920, 1040, "*150 M1.jpg")
			{
				MsgBox "The icon was found at " FoundX "x" FoundY
				Click FoundX, FoundY
			}
            else
                MsgBox "Icon could not be found on the screen."
        }
        catch as exc
            MsgBox "Could not conduct the search due to the following error:`n" exc.Message
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

ImageSearchAll(imageFile, x1 := 0, y1 := 0, x2 := "Screen", y2 := "Screen", var := 0)
{
	; found coordinates are returned as a simple array of coordinate pairs
	; each coordinate pair is an associative array with keys "x" and "y"

	x2 := x2 = "Screen" ? A_ScreenWidth : x2
	y2 := y2 = "Screen" ? A_ScreenHeight : y2
	found := []
	y := y1
	loop {
		x := x1
		loop {
			ImageSearch, foundX, foundY, x, y, x2, y2, % "*" var " " imageFile
			if (ErrorLevel = 2)
				return -1
			if !ErrorLevel {
				found.Push({x: foundX, y: foundY})
				x := foundX + 1
				lastFoundY := foundY
			}
		} until ErrorLevel
		Y := lastFoundY + 1
	} until (x = x1) && ErrorLevel
	return found
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