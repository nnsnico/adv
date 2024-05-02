module cmd

import os

@[noinit]
pub struct Adb {
pub:
	path string
}

pub fn create_adb() !Adb {
	adb_path := os.find_abs_path_of_executable('adb')!

	return Adb{
		path: adb_path
	}
}
