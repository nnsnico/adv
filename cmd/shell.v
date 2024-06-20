module cmd

import android
import os

fn remove_file(adb android.Adb, selected_device android.Device, absolute_path string) ! {
	adb.run_waiting(selected_device, 'shell rm ${absolute_path}')!
}

fn list_files(adb android.Adb, selected_device android.Device, target_path string) ![]string {
	files := adb.execute(selected_device, 'shell ls -a ${target_path}')!

	return files.output.split('\n').filter(!it.is_blank())
}

fn stop_lock_task_mode(adb android.Adb, device android.Device) !os.Result {
	return adb.execute(device, 'shell am task lock stop')!
}

fn check_file_exists(adb android.Adb, device android.Device, path string) !bool {
 	result := adb.execute(device, "shell '[ -e ${path} ] && echo -n 'ok' || echo -n 'ng''")!

	return if result.output == 'ok' {
		true
	} else {
		false
	}
}

