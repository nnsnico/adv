module utils

import os
import io.util { temp_file }

pub fn exec_fzf(lines []string) !string {
	fzf := os.find_abs_path_of_executable('fzf') or {
		return error('Not found FZF in your Environment PATH')
	}

	_, input_file := temp_file()!
	_, output_file := temp_file()!

	os.write_file(input_file, lines.join('\n'))!

	code := os.system('${fzf} -0 -1 --preview= < "${input_file}" > "${output_file}"')

	if code != 0 {
		return error('Left from FZF')
	}

	selected_line := os.read_file(output_file)!.split('\t')[0]

	os.rm(input_file)!
	os.rm(output_file)!

	if selected_line.len == 0 {
		return error('No target selected')
	}

	return selected_line.trim_space()
}
