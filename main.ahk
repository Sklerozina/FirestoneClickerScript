Class Firestone {
	static Buttons := {
		Green: Button(0x0AA008),
		Red: Button(0xE7473F),
		Orange: Button(0xFBAC46)
	}

	static Click(x, y, wait := 1000, clickcount := 1) {
		FindFirestoneWindowAndActivate

		loop clickcount
		{
			Click x, y
			Tools.Sleep(wait)
		}
	}

	static Press(key, wait := 1000) {
		FindFirestoneWindowAndActivate
	
		Send key
		Tools.Sleep(wait)
	}
}
