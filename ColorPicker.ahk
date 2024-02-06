#Requires AutoHotkey v2.0

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