module cmd

import android
import utils

pub fn apps(a android.Adb) ! {
	selected_device := a.select_active_device()!
	raw_apps := exec_list_packages(a, selected_device)!

	mut trimed_prefix := raw_apps.map(fn (l string) string {
		return l.split(':')[1]
	})
	trimed_prefix.sort()

	for v in trimed_prefix {
		println(utils.response_success(v))
	}
}

fn exec_list_packages(a android.Adb, selected_device android.Device) ![]string {
	result := a.execute(selected_device, 'shell pm list packages')!.output.trim_space()
	return result.split('\n')
}
