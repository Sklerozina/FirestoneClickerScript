Class Logs {
    enabled := false

    __New(dir) {
        if !DirExist(dir)
            DirCreate(dir)
        
        this.dir := dir
    }

    Log(text, before := "") {
        if this.enabled
            FileAppend(before . FormatTime(,"yyyy-MM-dd HH:mm:ss ") . text . "`n", this.dir FormatTime(, "yyyy-MM-dd") '.txt', "`n UTF-8")
    }

    Msg(text, timeout := 1000) {
        if this.enabled {
            MsgBox(text,,'T' timeout)
            Tools.Sleep(500)
        }
    }

    Enable() {
        this.enabled := 1
    }

    Disable() {
        this.enabled := 0
    }
}