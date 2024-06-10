#!/usr/bin/env -S v

module main

import android
import cmd
import cli
import os
import utils
import v.vmod

const manifest = vmod.decode(@VMOD_FILE) or { panic(err) }

@[noreturn]
fn print_err(msg IError) {
	eprintln(utils.response_err(msg.str()))
	exit(1)
}

mut app := cli.Command{
	name: manifest.name
	description: manifest.description
	version: manifest.version
	posix_mode: true
	defaults: struct {
		man: false
	}
}

// ------------------------------ Command for App ------------------------------

app.add_command(cli.Command{
	name: 'devices'
	description: 'List connected devices.'
	execute: fn (_ cli.Command) ! {
		adb := android.Adb.create() or { print_err(err) }
		all_devices := adb.get_all_active_devices() or { print_err(err) }

		for d in all_devices {
			println(d.name)
		}
	}
})

app.add_command(cli.Command{
	name: 'device'
	description: 'Select a device from connected device list.'
	execute: fn (_ cli.Command) ! {
		adb := android.Adb.create() or { print_err(err) }
		selected_device := adb.select_active_device() or { print_err(err) }

		println(selected_device.name)
	}
})

mut android_app := cli.Command{
	name: 'app'
	description: 'Commands for App.'
	execute: fn (c cli.Command) ! {
		c.execute_help()
	}
}

android_app.add_command(cli.Command{
	name: 'list'
	description: 'List installed apps'
	execute: fn (_ cli.Command) ! {
		adb := android.Adb.create() or { print_err(err) }

		cmd.apps(adb) or { print_err(err) }
	}
})

android_app.add_command(cli.Command{
	name: 'start'
	description: 'launch selected apps'
	execute: fn (_ cli.Command) ! {
		adb := android.Adb.create() or { print_err(err) }

		cmd.start_app(adb) or { print_err(err) }
	}
})

app.add_command(android_app)

app.add_command(cli.Command{
	name: 'pull'
	description: 'Pull the specified file from a selected device.'
	execute: fn (c cli.Command) ! {
		adb := android.Adb.create() or { print_err(err) }

		filetype := c.flags.get_string('filetype') or { print_err(err) }
		match filetype {
			'm', 'Movie', 'movie' {
				cmd.pull_file(adb, '/sdcard/Movies') or { print_err(err) }
			}
			'p', 'Picture', 'picture' {
				cmd.pull_file(adb, '/sdcard/Pictures/') or { print_err(err) }
			}
			else {
				if c.args.len == 0 {
					print_err(error('Please specify the target path in absolute value.'))
				}

				cmd.pull_file(adb, c.args[0]) or { print_err(err) }
			}
		}
	}
	flags: [
		cli.Flag{
			flag: cli.FlagType.string
			name: 'filetype'
			abbrev: 'f'
			description: 'Specify file type Movie or Picture'
		},
	]
})

app.add_command(cli.Command{
	name: 'screencap'
	description: 'Capture a screenshot from a connected device with the given file name.'
	execute: fn (c cli.Command) ! {
		adb := android.Adb.create() or { print_err(err) }

		is_exec_pull := c.flags.get_bool('pull') or { print_err(err) }
		cmd.capture_screen(adb, c.args[0], is_exec_pull) or { print_err(err) }
	}
	required_args: 1
	flags: [
		cli.Flag{
			flag: cli.FlagType.bool
			name: 'pull'
			abbrev: 'p'
			description: 'Pull captured screen image at the same time.'
		},
	]
})

app.add_command(cli.Command{
	name: 'screenrecord'
	description: 'Record a screen from a connected device with the given file name.'
	execute: fn (c cli.Command) ! {
		adb := android.Adb.create() or { print_err(err) }

		is_exec_pull := c.flags.get_bool('pull') or { print_err(err) }
		cmd.record_screen(adb, c.args[0], is_exec_pull) or { print_err(err) }
	}
	required_args: 1
	flags: [
		cli.Flag{
			flag: cli.FlagType.bool
			name: 'pull'
			abbrev: 'p'
			description: 'Pull recorded screen video at the same time.'
		},
	]
})

mut developer := cli.Command{
	name: 'developer'
	description: 'Commands for Android developer.'
	execute: fn (c cli.Command) ! {
		c.execute_help()
	}
}
developer.add_command(cli.Command{
	name: 'showtap'
	usage: '[value 1|0|on|off]'
	description: 'Show tap position.'
	execute: fn (c cli.Command) ! {
		adb := android.Adb.create() or { print_err(err) }
		is_toggle := c.flags.get_bool('toggle') or { print_err(err) }
		is_show_status := c.flags.get_bool('status') or { print_err(err) }

		match true {
			is_toggle {
				next_status := cmd.toggle_tap(adb) or { print_err(err) }
				println(utils.response_success('Toggle showtap status to `${next_status}`'))
				exit(0)
			}
			is_show_status {
				current_status := cmd.get_showtap_status(adb) or { print_err(err) }
				println(utils.response_success('Current showtap status: ${current_status}'))
				exit(0)
			}
			else {
				if c.args.len == 0 {
					print_err(error('Please set value `1(on)` or `0(off)`'))
				}

				next_status := cmd.show_tap(adb, c.args[0]) or { print_err(err) }
				println(utils.response_success('Set showtap status to `${next_status}`'))
			}
		}
	}
	flags: [
		cli.Flag{
			flag: cli.FlagType.bool
			name: 'toggle'
			abbrev: 't'
			description: 'Toggle tap visibility.'
		},
		cli.Flag{
			flag: cli.FlagType.bool
			name: 'status'
			abbrev: 's'
			description: 'Show tap visibility status.'
		},
	]
})
developer.add_command(cli.Command{
	name: 'wifi'
	usage: '[value 1|0|on|off]'
	description: 'Toggle wifi'
	execute: fn (c cli.Command) ! {
		adb := android.Adb.create() or { print_err(err) }
		is_toggle := c.flags.get_bool('toggle') or { print_err(err) }
		is_show_status := c.flags.get_bool('status') or { print_err(err) }

		match true {
			is_toggle {
				next_status := cmd.toggle_wifi(adb) or { print_err(err) }
				println(utils.response_success('Toggle wifi status to `${next_status}`'))
				exit(0)
			}
			is_show_status {
				current_status := cmd.get_wifi_status(adb) or { print_err(err) }
				println(utils.response_success('Current wifi status: ${current_status}'))
				exit(0)
			}
			else {
				if c.args.len == 0 {
					print_err(error('Please set value `1(on)` or `0(off)`'))
				}

				next_status := cmd.activate_wifi(adb, c.args[0]) or { print_err(err) }
				println(utils.response_success('Set wifi status to `${next_status}`'))
			}
		}
	}
	flags: [
		cli.Flag{
			flag: cli.FlagType.bool
			name: 'toggle'
			abbrev: 't'
			description: 'Toggle wifi activation'
		},
		cli.Flag{
			flag: cli.FlagType.bool
			name: 'status'
			abbrev: 's'
			description: 'Show wifi activation status'
		},
	]
})

app.add_command(developer)

app.setup()
app.parse(os.args)
