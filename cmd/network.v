module cmd

import android

pub enum WifiStatus {
	off       = 0
	on        = 1
	otherwise = 2
}

pub fn activate_wifi(a android.Adb, raw_arg string) !WifiStatus {
	selected_device := a.select_active_device()!
	status := if raw_arg.is_int() {
		WifiStatus.from(raw_arg.int())!
	} else {
		WifiStatus.from(raw_arg)!
	}

	return execute_toggle_wifi(a, selected_device, status)!
}

pub fn toggle_wifi(a android.Adb) !WifiStatus {
	selected_device := a.select_active_device()!

	value := a.execute(selected_device, 'shell settings get global wifi_on')!
	current_status := WifiStatus.from(value.output.int())!
	next_status := match current_status {
		.on {
			WifiStatus.off
		}
		.off {
			WifiStatus.on
		}
		else {
			WifiStatus.off
		}
	}
	return execute_toggle_wifi(a, selected_device, next_status)!
}

pub fn get_wifi_status(a android.Adb) !WifiStatus {
	selected_device := a.select_active_device()!
	value := a.execute(selected_device, 'shell settings get global wifi_on')!
	current_status := WifiStatus.from(value.output.int())!

	return current_status
}

fn execute_toggle_wifi(a android.Adb, device android.Device, status WifiStatus) !WifiStatus {
	return match status {
		.on {
			a.execute(device, 'shell svc wifi enable')!
			status
		}
		.off {
			a.execute(device, 'shell svc wifi disable')!
			status
		}
		else {
			error('Please set value `1(on)` or `0(off)`')
		}
	}
}
