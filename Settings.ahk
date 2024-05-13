Class Settings {
    static ini_name := ""
    static data := Map()

    static Call(file_name) {
        this.ini_name := file_name

        if !FileExist(this.ini_name)
            FileAppend("", this.ini_name)

        ini_sections := IniRead(this.ini_name)

        Loop parse, ini_sections, "`n", "`r" {
            this.data.Set(A_LoopField, Map())
        }

        for k in this.data {
            pairs := IniRead(this.ini_name, k)
            
            Loop parse, pairs, "`n", "`r"
            {
                Result := StrSplit(A_LoopField, "=")
                this.data[k].Set(Result[1], Result[2])
            }
        }

        return this
    }

    static Reload() {
        ini_sections := IniRead(this.ini_name)

        Loop parse, ini_sections, "`n", "`r" {
            if !this.data.Has(A_LoopField)
                this.data.Set(A_LoopField, Map())
        }

        for k in this.data {
            pairs := IniRead(this.ini_name, k)
            
            Loop parse, pairs, "`n", "`r"
            {
                Result := StrSplit(A_LoopField, "=")
                this.data[k].Set(Result[1], Result[2])
            }
        }

        return this
    }

    static Section(key) {
        if !this.data.Has(key)
            this.data.Set(key, Map())

        return this.data.Get(key)
    }

    static Save() {
        for section in this.data {
            pairs := ""

            for key, value in this.data.Get(section) {
                pairs .= key . "=" . value . "`n"
            }

            IniWrite(pairs, this.ini_name, section)
        }
    }
}