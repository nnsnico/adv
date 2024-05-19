module android

import os
import io.util { temp_file }

@[noinit]
pub struct Adb {
	path string
}

pub fn Adb.create() !Adb {
	adb_path := os.find_abs_path_of_executable('adb')!

	return Adb{
		path: adb_path
	}
}

pub fn (a Adb) execute(device Device, cmd_str string) !os.Result {
	return os.execute_opt('${a.path} -s ${device.name} ${cmd_str}')!
}

pub fn (a Adb) run_waiting(device Device, cmd_str string) !int {
	code := os.system('${a.path} -s ${device.name} ${cmd_str}')
	return if code == 0 {
		code
	} else {
		error('adb command error: ${code}')
	}
}

pub fn (a Adb) get_all_active_devices() ![]Device {
	devices := a.get_devices_str()!.map(fn (s string) Device {
		device_info := s.split('\t')
		return Device{
			name: device_info[0]
			device_type: check_device_type(device_info[0])
		}
	})
	return if devices.len != 0 {
		devices
	} else {
		error('No connected Device')
	}
}

pub fn (a Adb) select_active_device() !Device {
	fzf := os.find_abs_path_of_executable('fzf') or {
		return error('Not found FZF in your Environment PATH')
	}

	device_str := a.get_devices_str()!

	if device_str.len == 0 {
		return error('No connected Device')
	}

	_, input_file := temp_file()!
	_, output_file := temp_file()!

	os.write_file(input_file, device_str.join('\n'))!

	code := os.system('${fzf} -0 -1 --preview= < "${input_file}" > "${output_file}"')

	if code != 0 {
		return error('Left from FZF')
	}

	selected_line := os.read_file(output_file)!.split('\t')
	device := Device{
		name: selected_line[0]
		device_type: check_device_type(selected_line[0])
	}

	os.rm(input_file)!
	os.rm(output_file)!

	return device
}

fn (a Adb) get_devices_str() ![]string {
	devices_str := os.execute_opt('${a.path} devices')!.output.trim('\n')
	mut devices := devices_str.split('\n')
	devices.drop(1)

	if devices.len != 0 && devices[0].contains('* daemon started successfully') {
		devices.clear()
		return a.get_devices_str()!
	} else {
		return devices
	}
}
