module cmd

import android

fn remove_file(adb android.Adb, selected_device android.Device, absolute_path string) ! {
	adb.run_waiting(selected_device, 'shell rm ${absolute_path}')!
}

fn list_files(adb android.Adb, target_path string) ![]string {
	selected_device := adb.select_active_device()!
	files := adb.execute(selected_device, 'shell ls -a ${target_path}')!

	return files.output.trim_space().split('\n')
}
