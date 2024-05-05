module cmd

import android
import os

const picture_path = '/sdcard/Pictures'
const movie_path = '/sdcard/Movies'

pub fn (a Adb) capture_screen(file_name string, is_exec_pull bool) ! {
	selected_device := a.select_active_device()!
	a.exec_screencap(selected_device, file_name)!

	if is_exec_pull {
		a.exec_pull(selected_device, '${cmd.picture_path}/${file_name}.png')!
		a.remove_file(selected_device, '${cmd.picture_path}/${file_name}.png')!
	}
}

pub fn (a Adb) record_screen(file_name string, is_exec_pull bool) ! {
	selected_device := a.select_active_device()!
	a.exec_screenrecord(selected_device, file_name)!

	if is_exec_pull {
		a.exec_pull(selected_device, '${cmd.movie_path}/${file_name}.mp4')!
		a.remove_file(selected_device, '${cmd.movie_path}/${file_name}.mp4')!
	}
}

pub fn (a Adb) pull_file(absolute_path string) ! {
	selected_device := a.select_active_device()!
	a.exec_pull(selected_device, absolute_path)!
}

fn (a Adb) exec_screencap(device android.Device, file_name string) ! {
	os.execute_opt('${a.path} -s ${device.name} shell screencap ${cmd.picture_path}/${file_name}.png')!
}

fn (a Adb) exec_screenrecord(device android.Device, file_name string) ! {
	code := os.system('${a.path} -s ${device.name} shell screenrecord ${cmd.movie_path}/${file_name}.mp4')
	if code != 130 {
		return error('Error occured while recording movie')
	}
}

fn (a Adb) exec_pull(device android.Device, absolute_path string) ! {
	os.execute_opt('${a.path} -s ${device.name} pull ${absolute_path}')!
}
