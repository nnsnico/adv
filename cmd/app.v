module cmd

import android
import utils

pub fn apps(a android.Adb) ! {
	selected_device := a.select_active_device()!

	result := a.execute(selected_device, 'shell pm list packages')!.output.trim_space()
	raw_apps := result.split('\n')
	mut trimed_prefix := raw_apps.map(fn (l string) string {
		return l.split(':')[1]
	})
	trimed_prefix.sort()

	for v in trimed_prefix {
		println(utils.response_success(v))
	}
}
