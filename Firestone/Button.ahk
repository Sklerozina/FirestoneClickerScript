Class Button {
	__New(color) {
		this.color := color
	}

	Check(x1, y1, x2, y2) {
		return Tools.PixelSearch(x1, y1, x2, y2, this.color, 1)
	}

	Wait(x1, y1, x2, y2, timeout := 30000) {
		return Tools.WaitForSearchPixel(x1, y1, x2, y2, this.color, 1, timeout)
	}

	CheckAndClick(x1, y1, x2, y2, click_x?, click_y?, wait?, clickcount?) {
		if this.Check(x1, y1, x2, y2)
		{
			if !IsSet(click_x) || !IsSet(click_y)
			{
				click_x := x1 + ((x2 - x1) / 2)
				click_y := y1 + ((y2 - y1) / 2)
			}
			
			Firestone.Click(click_x, click_y, wait?, clickcount?)
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
			
			Firestone.Click(click_x, click_y, wait?, clickcount?)
			return true
		}
		
		return false
	}
}
