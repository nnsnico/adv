module cmd

import android
import os

pub fn (a Adb) capture_screen(file_name string, is_exec_pull bool) ! {
	selected_device := a.select_active_device()!
	a.exec_screencap(selected_device, file_name)!

	if is_exec_pull {
		a.exec_pull(selected_device, file_name)!
	}
}

fn (a Adb) exec_screencap(device android.Device, file_name string) ! {
	os.execute_opt('${a.path} -s ${device.name} shell screencap /sdcard/Pictures/${file_name}.png')!
}

fn (a Adb) exec_pull(device android.Device, file_name string) ! {
	os.execute_opt('${a.path} -s ${device.name} pull /sdcard/Pictures/${file_name}.png')!
}
