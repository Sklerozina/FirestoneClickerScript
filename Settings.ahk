Class Settings {
    static ini_name := ""
    static settings := Map()

    static Call(file_name) {
        this.ini_name := file_name

        if !FileExist(this.ini_name)
            FileAppend("", this.ini_name)

        ini_sections := IniRead(this.ini_name)

        Loop parse, ini_sections, "`n", "`r" {
            this.settings.Set(A_LoopField, Map())
        }

        for k in this.settings {
            pairs := IniRead(this.ini_name, k)
            
            Loop parse, pairs, "`n", "`r"
            {
                Result := StrSplit(A_LoopField, "=")
                this.settings[k].Set(Result[1], Result[2])
            }
        }

        return this
    }

    static Section(key) {
        if !this.settings.Has(key)
            this.settings.Set(key, Map())

        return this.settings.Get(key)
    }

    static Save() {
        for section in this.settings {
            pairs := ""

            for key, value in this.settings.Get(section) {
                pairs .= key . "=" . value . "`n"
            }

            IniWrite(pairs, this.ini_name, section)
        }
    }
}