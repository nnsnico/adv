module cmd

import android
import utils

const picture_path = '/sdcard/Pictures'
const movie_path = '/sdcard/Movies'

pub fn capture_screen(a android.Adb, file_name string, is_exec_pull bool) ! {
	selected_device := a.select_active_device()!
	exec_screencap(a, selected_device, file_name)!

	if is_exec_pull {
		exec_pull(a, selected_device, '${cmd.picture_path}/${file_name}.png')!
		remove_file(a, selected_device, '${cmd.picture_path}/${file_name}.png')!
	}
}

pub fn record_screen(a android.Adb, file_name string, is_exec_pull bool) ! {
	selected_device := a.select_active_device()!
	exec_screenrecord(a, selected_device, file_name)!

	if is_exec_pull {
		exec_pull(a, selected_device, '${cmd.movie_path}/${file_name}.mp4')!
		remove_file(a, selected_device, '${cmd.movie_path}/${file_name}.mp4')!
	}
}

pub fn pull_file(a android.Adb, target_dir_path string) ! {
	selected_device := a.select_active_device()!
	list := list_files(a, target_dir_path)!
	download_target := utils.exec_fzf(list)!

	exec_pull(a, selected_device, '${target_dir_path.trim_right('/')}/${download_target}')!
}

fn exec_screencap(adb android.Adb, device android.Device, file_name string) ! {
	adb.execute(device, 'shell screencap ${cmd.picture_path}/${file_name}.png')!
}

fn exec_screenrecord(adb android.Adb, device android.Device, file_name string) ! {
	result := adb.execute(device, 'shell screenrecord ${cmd.movie_path}/${file_name}.mp4')!
	if result.exit_code != 130 {
		return error('Error occured while recording movie')
	}
}

fn exec_pull(adb android.Adb, device android.Device, absolute_path string) ! {
	adb.execute(device, 'pull ${absolute_path}')!
}
