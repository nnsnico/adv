module cmd

import android

pub enum TapStatus {
	off       = 0
	on        = 1
	otherwise = 2
}

pub fn show_tap(a android.Adb, raw_arg string) !TapStatus {
	selected_device := a.select_active_device()!
	status := if raw_arg.is_int() {
		TapStatus.from(raw_arg.int())!
	} else {
		TapStatus.from(raw_arg)!
	}

	match status {
		.on, .off {
			a.execute(selected_device, 'shell settings put system show_touches ${int(status)}')!
			return status
		}
		else {
			return error('Please set value `1(on)` or `0(off)`')
		}
	}
}

pub fn toggle_tap(a android.Adb) !TapStatus {
	selected_device := a.select_active_device()!

	value := a.execute(selected_device, 'shell settings get system show_touches')!
	current_status := TapStatus.from(value.output.int())!
	next_status := match current_status {
		.on {
			TapStatus.off
		}
		.off {
			TapStatus.on
		}
		else {
			TapStatus.off
		}
	}
	a.execute(selected_device, 'shell settings put system show_touches ${int(next_status)}')!

	return next_status
}

pub fn get_showtap_status(a android.Adb) !TapStatus {
	selected_device := a.select_active_device()!
	value := a.execute(selected_device, 'shell settings get system show_touches')!
	current_status := TapStatus.from(value.output.int())!

	return current_status
}
