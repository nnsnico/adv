module cmd

import os
import android

fn remove_file(adb Adb, selected_device android.Device, absolute_path string) ! {
	os.execute_opt('${adb.path} -s ${selected_device.name} shell rm ${absolute_path}')!
}
