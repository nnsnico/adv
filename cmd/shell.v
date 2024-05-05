module cmd

import os
import android

fn (a Adb) remove_file(selected_device android.Device, absolute_path string) ! {
	os.execute_opt('${a.path} -s ${selected_device.name} shell rm ${absolute_path}')!
}
