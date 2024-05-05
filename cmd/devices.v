module cmd

import os
import android
import io.util { temp_file }

pub fn (a Adb) get_all_active_devices() ![]android.Device {
	devices := a.get_devices_str()!.map(fn (s string) []string {
		return s.split('\t')
	})
	return devices.map(fn (s []string) android.Device {
		return android.Device{
			name: s[0]
			device_type: android.check_device_type(s[0])
		}
	})
}

pub fn (a Adb) select_active_device() !android.Device {
	fzf := os.find_abs_path_of_executable('fzf') or {
		return error('Not found FZF in your Environment PATH')
	}

	device_str := a.get_devices_str()!

	_, input_file := temp_file()!
	_, output_file := temp_file()!

	os.write_file(input_file, device_str.join('\n'))!

	os.system('${fzf} -0 < "${input_file}" > "${output_file}"')

	selected_line := os.read_lines(output_file)!.map(fn (s string) []string {
		return s.split('\t')
	})
	devices := selected_line.map(fn (s []string) android.Device {
		return android.Device{
			name: s[0]
			device_type: android.check_device_type(s[0])
		}
	})

	os.rm(input_file)!
	os.rm(output_file)!

	return if devices.len != 0 {
		devices[0]
	} else {
		error('No connected Device')
	}
}

fn (a Adb) get_devices_str() ![]string {
	devices_str := os.execute_opt('${a.path} devices')!.output.trim('\n')
	mut devices := devices_str.split('\n')
	devices.drop(1)

	if devices.len != 0 && devices[0].contains("* daemon started successfully") {
		devices.clear()
		return a.get_devices_str()!
	} else {
		return devices
	}
}
