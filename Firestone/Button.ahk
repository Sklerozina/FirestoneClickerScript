Class Button {
	__New(Firestone, color, variation := 1) {
		this.color := color
		this.variation := variation
		this.Firestone := Firestone
	}

	CheckPixels(coords*) {
		if Mod(coords.Length, 2) != 0
			Throw ValueError("Неверное количество параметров, должно быть кратно двум!", -1, coords.Length)

		xy := []
		i := 0
		
		loop coords.Length / 2
		{
			xy.Push([coords[i+1], coords[i+2]])
			i += 2
		}

		for coords in xy
		{
			if PixelGetColor(coords[1], coords[2]) != this.color
				return false
		}

		return true
	}

	Check(x1, y1, x2, y2) {
		return Tools.PixelSearch(x1, y1, x2, y2, this.color, this.variation)
	}

	Find(x1, y1, x2, y2, &FoundX, &FoundY) {
		return Tools.PixelSearch(x1, y1, x2, y2, this.color, this.variation, &FoundX, &FoundY)
	}

	Wait(x1, y1, x2, y2, timeout := 30000) {
		return Tools.WaitForSearchPixel(x1, y1, x2, y2, this.color, this.variation, timeout)
	}

	CheckAndClick(x1, y1, x2, y2, click_x?, click_y?, wait?, clickcount?) {
		if this.Check(x1, y1, x2, y2)
		{
			if !IsSet(click_x) || !IsSet(click_y)
			{
				click_x := x1 + ((x2 - x1) / 2)
				click_y := y1 + ((y2 - y1) / 2)
			}
			
			this.Firestone.Click(click_x, click_y, wait?, clickcount?)
			return true
		}

		return false
	}

	FindAndClick(x1, y1, x2, y2, wait?, clickcount?) {
		if this.Find(x1, y1, x2, y2, &click_x, &click_y)
		{
			this.Firestone.Click(click_x, click_y, wait?, clickcount?)
			return true
		}

		return false
	}

	WaitAndClick(x1, y1, x2, y2, timeout := 30000, click_x?, click_y?, wait?, clickcount?) {
		if this.Wait(x1, y1, x2, y2, timeout) {
			if !IsSet(click_x) || !IsSet(click_y)
			{
				click_x := x1 + ((x2 - x1) / 2)
				click_y := y1 + ((y2 - y1) / 2)
			}
			
			this.Firestone.Click(click_x, click_y, wait?, clickcount?)
			return true
		}
		
		return false
	}
}
