Class Settings {
    ini_name := ""
    settings := Map()

    static Call(file_name, defaults := Map()) {
        this.ini_name := file_name
        sections := IniRead(file_name)
    }

    Set(key, value) {
        super.Set(key, value)
    }

    Get(key, default?) {
        super.Settings.Get(key, default?)
    }
}