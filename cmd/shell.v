module cmd

import android

fn remove_file(adb android.Adb, selected_device android.Device, absolute_path string) ! {
	adb.run_waiting(selected_device, 'shell rm ${absolute_path}')!
}

fn list_files(adb android.Adb, target_path string) ![]string {
	selected_device := adb.select_active_device()!
	files := adb.execute(selected_device, 'shell ls -a ${target_path}')!

	return files.output.split('\n').filter(!it.is_blank())
}

fn check_file_exists(adb android.Adb, device android.Device, path string) !bool {
 	result := adb.execute(device, "shell '[ -e ${path} ] && echo -n 'ok' || echo -n 'ng''")!

	return if result.output == 'ok' {
		true
	} else {
		false
	}
}

