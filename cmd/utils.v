module cmd

import android

struct ValidatePath {
	paths []string
}

struct InvalidatePath {
	paths []string
}

type FileExistsResult = ValidatePath | InvalidatePath

pub fn check_all_file_exists(a android.Adb, device android.Device, paths []string) !FileExistsResult {
	mut invalid_paths := []string{}
	for path in paths {
		is_valid := check_file_exists(a, device, path)!
		if !is_valid {
			invalid_paths << path
		}
	}

	return if invalid_paths.len > 0 {
		InvalidatePath{
			paths: invalid_paths
		}
	} else {
		ValidatePath{
			paths: paths
		}
	}
}
