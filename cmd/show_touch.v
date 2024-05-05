module cmd

import os

pub enum TapStatus {
	off    = 0
	on     = 1
	toggle = 2
}

pub fn (a Adb) show_tap(sts TapStatus) ! {
	selected_device := a.select_active_device()!

	match sts {
		.on, .off {
			os.execute_opt('${a.path} -s ${selected_device.name} shell settings put system show_touches ${int(sts)}')!
		}
		.toggle {
			value := os.execute_opt('${a.path} -s ${selected_device.name} shell settings get system show_touches')!
			current_status := TapStatus.from(value.output.int())!
			next_status := match current_status {
				.on {
					TapStatus.off
				}
				.off {
					TapStatus.on
				}
				else {
					TapStatus.off
				}
			}
			os.execute_opt('${a.path} -s ${selected_device.name} shell settings put system show_touches ${int(next_status)}')!
		}
	}
}
