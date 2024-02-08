#Requires AutoHotkey v2.0

A_Clipboard := ""
; Сменить режим апгрейда героев
Numpad0::
{
	MouseGetPos(&x, &y)
    if (A_Clipboard != "")
        A_Clipboard .= ", "
    
    A_Clipboard .= x . ":" . y

}

; Собрать все цвета +-10 вверх и вниз от цвентра
^p::
{
    MouseGetPos(&x, &y)
    Sleep 5000
    y_p := y-10
    colors := ""
    loop 20
    {
        color := String(PixelGetColor(x, y_p))
        if not InStr(colors, color)
            colors .= color . " "
        y_p += 1
    }

    A_Clipboard := SubStr(colors, 1, StrLen(colors)-1)
    Tp "Цвет скопирован в буфер"
    
}

Tp(text, timeout := -2000) {
    ToolTip text
    SetTimer () => ToolTip(), timeout
}