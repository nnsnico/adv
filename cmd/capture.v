module cmd

import android
import utils

pub fn capture_screen(a android.Adb, file_name string, is_exec_pull bool) ! {
	selected_device := a.select_active_device()!
	exec_screencap(a, selected_device, file_name)!

	if is_exec_pull {
		exec_pull(a, selected_device, '${to_raw_path(Picture{})}/${file_name}.png')!
		remove_file(a, selected_device, '${to_raw_path(Picture{})}/${file_name}.png')!
	}
}

pub fn record_screen(a android.Adb, file_name string, is_exec_pull bool) ! {
	selected_device := a.select_active_device()!
	exec_screenrecord(a, selected_device, file_name)!

	if is_exec_pull {
		exec_pull(a, selected_device, '${to_raw_path(Movie{})}/${file_name}.mp4')!
		remove_file(a, selected_device, '${to_raw_path(Movie{})}/${file_name}.mp4')!
	}
}

pub fn pull_file(a android.Adb, target_dir_path Path) ! {
	selected_device := a.select_active_device()!
	raw_path := to_raw_path(target_dir_path)
	list := list_files(a, selected_device, raw_path)!

	if list.len == 0 {
		return error('No files in ${raw_path}')
	}

	download_target := utils.exec_fzf(list)!
	exec_pull(a, selected_device, '${raw_path}/${download_target}')!
}

pub fn pull_all_files(a android.Adb, target_dir_path Path, target_path ...string) ! {
	selected_device := a.select_active_device()!
	raw_paths := target_path.map('${to_raw_path(target_dir_path)}/${it}')

	validated_paths := check_all_file_exists(a, selected_device, raw_paths)!

	match validated_paths {
		ValidatePath {
			for path in validated_paths.paths {
				exec_pull(a, selected_device, path)!
			}
		}
		InvalidatePath {
			return error('Not found file: ${validated_paths.paths.join(", ")}')
		}
	}
}

fn exec_screencap(adb android.Adb, device android.Device, file_name string) ! {
	adb.execute(device, 'shell screencap ${to_raw_path(Picture{})}/${file_name}.png')!
}

fn exec_screenrecord(adb android.Adb, device android.Device, file_name string) ! {
	result := adb.execute(device, 'shell screenrecord ${to_raw_path(Movie{})}/${file_name}.mp4')!
	if result.exit_code != 130 {
		return error('Error occured while recording movie')
	}
}

fn exec_pull(adb android.Adb, device android.Device, absolute_path string) ! {
	adb.execute(device, 'pull ${absolute_path}')!
}
