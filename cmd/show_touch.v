module cmd

import os

pub enum TapStatus {
	off       = 0
	on        = 1
	otherwise = 2
}

pub fn (a Adb) show_tap(raw_arg string) !TapStatus {
	selected_device := a.select_active_device()!
	status := if raw_arg.is_int() {
		TapStatus.from(raw_arg.int())!
	} else {
		TapStatus.from(raw_arg)!
	}

	match status {
		.on, .off {
			os.execute_opt('${a.path} -s ${selected_device.name} shell settings put system show_touches ${int(status)}')!
			return status
		}
		else {
			return error('Please set value `1(on)` or `0(off)`')
		}
	}
}

pub fn (a Adb) toggle_tap() !TapStatus {
	selected_device := a.select_active_device()!

	value := os.execute_opt('${a.path} -s ${selected_device.name} shell settings get system show_touches')!
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
	os.execute_opt('${a.path} -s ${selected_device.name} shell settings put system show_touches ${int(next_status)}')!

	return next_status
}

pub fn (a Adb) get_showtap_status() !TapStatus {
	selected_device := a.select_active_device()!
	value := os.execute_opt('${a.path} -s ${selected_device.name} shell settings get system show_touches')!
	current_status := TapStatus.from(value.output.int())!

	return current_status
}
