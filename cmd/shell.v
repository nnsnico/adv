module cmd

import android

fn remove_file(adb android.Adb, selected_device android.Device, absolute_path string) ! {
	adb.run_waiting(selected_device, 'shell rm ${absolute_path}')!
}
