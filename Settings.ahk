Class Ini {
    ini_name := ""

    __New(file_name) {
        this.ini_name := file_name
        this.data := Map()

        if !FileExist(this.ini_name)
            FileAppend("", this.ini_name)

        ini_sections := IniRead(this.ini_name)

        Loop parse, ini_sections, "`n", "`r" {
            this.data.Set(A_LoopField, IniSection(A_LoopField, this.ini_name))
        }

        for k in this.data {
            pairs := IniRead(this.ini_name, k)
            
            Loop parse, pairs, "`n", "`r"
            {
                Result := StrSplit(A_LoopField, "=")
                this.data[k][Result[1]] := Result[2]
            }
        }

        return this
    }

    Reload() {
        ini_sections := IniRead(this.ini_name)

        Loop parse, ini_sections, "`n", "`r" {
            if !this.data.Has(A_LoopField)
                this.data.Set(A_LoopField, IniSection(A_LoopField, this.ini_name))
        }

        for k in this.data {
            try
            {
                pairs := IniRead(this.ini_name, k)
            }
            catch
            {
                continue
            }
            Loop parse, pairs, "`n", "`r"
            {
                Result := StrSplit(A_LoopField, "=")
                this.data[k][Result[1]] := Result[2]
            }
            
        }

        return this
    }

    Section(key) {
        if !this.data.Has(key)
            this.data.Set(key, IniSection(key, this.ini_name))

        return this.data.Get(key)
    }
}

Class IniSection extends Map {
    __New(name, ini_name) {
        this.name := name
        this.ini_name := ini_name
    }

    Set(Key1, Val1) {
        if !super.Has(Key1) || Val1 != super.Get(Key1)
        {
            IniWrite(Val1, this.ini_name, this.name, Key1)
        }

        super.Set(Key1, Val1)
        return this
    }
}
