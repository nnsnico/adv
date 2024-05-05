module cmd

import os
import android
import io.util { temp_file }

pub fn (a Adb) get_all_active_devices() ![]android.Device {
	devices := get_devices_str(a)!.map(fn (s string) android.Device {
		device_info := s.split('\t')
		return android.Device{
			name: device_info[0]
			device_type: android.check_device_type(device_info[0])
		}
	})
	return if devices.len != 0 {
		devices
	} else {
		error('No connected Device')
	}
}

pub fn (a Adb) select_active_device() !android.Device {
	fzf := os.find_abs_path_of_executable('fzf') or {
		return error('Not found FZF in your Environment PATH')
	}

	device_str := get_devices_str(a)!

	_, input_file := temp_file()!
	_, output_file := temp_file()!

	os.write_file(input_file, device_str.join('\n'))!

	code := os.system('${fzf} -0 -1 --preview= < "${input_file}" > "${output_file}"')

	if code != 0 {
		return error('Left from FZF')
	}

	selected_line := os.read_file(output_file)!.split('\t')
	device := android.Device{
		name: selected_line[0]
		device_type: android.check_device_type(selected_line[0])
	}

	os.rm(input_file)!
	os.rm(output_file)!

	return device
}

fn get_devices_str(a Adb) ![]string {
	devices_str := os.execute_opt('${a.path} devices')!.output.trim('\n')
	mut devices := devices_str.split('\n')
	devices.drop(1)

	if devices.len != 0 && devices[0].contains('* daemon started successfully') {
		devices.clear()
		return get_devices_str(a)!
	} else {
		return devices
	}
}
