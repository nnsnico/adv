module cmd

import android

pub fn leave_lock_task_mode(adb android.Adb) ! {
	selected_device := adb.select_active_device()!
	result := stop_lock_task_mode(adb, selected_device)!
	if result.exit_code != 0 {
		return error('Unexpected error')
	}
}
