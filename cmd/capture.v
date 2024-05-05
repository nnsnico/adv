module cmd

import android
import os

const picture_path = '/sdcard/Pictures'
const movie_path = '/sdcard/Movies'

pub fn (a Adb) capture_screen(file_name string, is_exec_pull bool) ! {
	selected_device := a.select_active_device()!
	exec_screencap(a, selected_device, file_name)!

	if is_exec_pull {
		exec_pull(a, selected_device, '${cmd.picture_path}/${file_name}.png')!
		remove_file(a, selected_device, '${cmd.picture_path}/${file_name}.png')!
	}
}

pub fn (a Adb) record_screen(file_name string, is_exec_pull bool) ! {
	selected_device := a.select_active_device()!
	exec_screenrecord(a, selected_device, file_name)!

	if is_exec_pull {
		exec_pull(a, selected_device, '${cmd.movie_path}/${file_name}.mp4')!
		remove_file(a, selected_device, '${cmd.movie_path}/${file_name}.mp4')!
	}
}

pub fn (a Adb) pull_file(absolute_path string) ! {
	selected_device := a.select_active_device()!
	exec_pull(a, selected_device, absolute_path)!
}

fn exec_screencap(adb Adb, device android.Device, file_name string) ! {
	os.execute_opt('${adb.path} -s ${device.name} shell screencap ${cmd.picture_path}/${file_name}.png')!
}

fn exec_screenrecord(adb Adb, device android.Device, file_name string) ! {
	code := os.system('${adb.path} -s ${device.name} shell screenrecord ${cmd.movie_path}/${file_name}.mp4')
	if code != 130 {
		return error('Error occured while recording movie')
	}
}

fn exec_pull(adb Adb, device android.Device, absolute_path string) ! {
	os.execute_opt('${adb.path} -s ${device.name} pull ${absolute_path}')!
}
