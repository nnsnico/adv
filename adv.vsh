#!/usr/bin/env -S v

module main

import android
import cmd
import cli
import os
import utils
import v.vmod

const manifest = vmod.decode(@VMOD_FILE) or { panic(err) }

fn run(callback fn () !) {
	callback() or {
		eprintln(utils.response_err(err.str()))
		exit(1)
	}
}

mut app := cli.Command{
	name:        manifest.name
	description: manifest.description
	version:     manifest.version
	posix_mode:  true
	defaults:    struct {
		man: false
	}
}

// ------------------------------ Command for App ------------------------------

app.add_command(cli.Command{
	name:        'devices'
	description: 'List connected devices.'
	execute:     fn (_ cli.Command) ! {
		run(fn () ! {
			adb := android.Adb.create()!
			all_devices := adb.get_all_active_devices()!

			for d in all_devices {
				println(d.name)
			}
		})
	}
})

app.add_command(cli.Command{
	name:        'device'
	description: 'Select a device from connected device list.'
	execute:     fn (_ cli.Command) ! {
		run(fn () ! {
			adb := android.Adb.create()!
			selected_device := adb.select_active_device()!

			println(selected_device.name)
		})
	}
})

mut android_app := cli.Command{
	name:        'app'
	description: 'Commands for App.'
	execute:     fn (c cli.Command) ! {
		c.execute_help()
	}
}

android_app.add_command(cli.Command{
	name:        'list'
	description: 'List installed apps'
	execute:     fn (_ cli.Command) ! {
		run(fn () ! {
			adb := android.Adb.create()!

			cmd.apps(adb)!
		})
	}
})

android_app.add_command(cli.Command{
	name:        'start'
	description: 'launch selected apps'
	execute:     fn (_ cli.Command) ! {
		run(fn () ! {
			adb := android.Adb.create()!

			cmd.start_app(adb)!
		})
	}
})

app.add_command(android_app)

app.add_command(cli.Command{
	name:        'pull'
	description: 'Pull the specified file from a selected device.'
	execute:     fn (c cli.Command) ! {
		run(fn [c] () ! {
			adb := android.Adb.create()!

			filetype := c.flags.get_string('filetype')!
			match filetype {
				'm', 'Movie', 'movie' {
					if c.args.len == 0 {
						cmd.pull_file(adb, cmd.Movie{})!
					} else {
						cmd.pull_all_files(adb, cmd.Movie{}, ...c.args)!
					}
				}
				'p', 'Picture', 'picture' {
					if c.args.len == 0 {
						cmd.pull_file(adb, cmd.Picture{})!
					} else {
						cmd.pull_all_files(adb, cmd.Picture{}, ...c.args)!
					}
				}
				else {
					if c.args.len == 0 {
						return error('Please specify the target path in absolute value.')
					}

					cmd.pull_file(adb, cmd.Others{
						raw_path: c.args[0]
					})!
				}
			}
		})
	}
	flags: [
		cli.Flag{
			flag:        cli.FlagType.string
			name:        'filetype'
			abbrev:      'f'
			description: 'Specify file type Movie or Picture'
		},
	]
})

app.add_command(cli.Command{
	name:        'cap'
	description: 'Capture a screenshot from a connected device with the given file name.'
	execute:     fn (c cli.Command) ! {
		run(fn [c] () ! {
			adb := android.Adb.create()!

			is_exec_pull := c.flags.get_bool('pull')!
			cmd.capture_screen(adb, c.args[0], is_exec_pull)!
		})
	}
	required_args: 1
	flags:         [
		cli.Flag{
			flag:        cli.FlagType.bool
			name:        'pull'
			abbrev:      'p'
			description: 'Pull captured screen image at the same time.'
		},
	]
})

app.add_command(cli.Command{
	name:        'rec'
	description: 'Record a screen from a connected device with the given file name.'
	execute:     fn (c cli.Command) ! {
		run(fn [c] () ! {
			adb := android.Adb.create()!

			is_exec_pull := c.flags.get_bool('pull')!
			cmd.record_screen(adb, c.args[0], is_exec_pull)!
		})
	}
	required_args: 1
	flags:         [
		cli.Flag{
			flag:        cli.FlagType.bool
			name:        'pull'
			abbrev:      'p'
			description: 'Pull recorded screen video at the same time.'
		},
	]
})

mut developer := cli.Command{
	name:        'dev'
	description: 'Commands for Android developer.'
	execute:     fn (c cli.Command) ! {
		c.execute_help()
	}
}
developer.add_command(cli.Command{
	name:        'showtap'
	usage:       '[value 1|0|on|off]'
	description: 'Show tap position.'
	execute:     fn (c cli.Command) ! {
		run(fn [c] () ! {
			adb := android.Adb.create()!
			is_toggle := c.flags.get_bool('toggle')!
			is_show_status := c.flags.get_bool('status')!

			match true {
				is_toggle {
					next_status := cmd.toggle_tap(adb)!
					println(utils.response_success('Toggle showtap status to `${next_status}`'))
					exit(0)
				}
				is_show_status {
					current_status := cmd.get_showtap_status(adb)!
					println(utils.response_success('Current showtap status: ${current_status}'))
					exit(0)
				}
				else {
					if c.args.len == 0 {
						return error('Please set value `1(on)` or `0(off)`')
					}

					next_status := cmd.show_tap(adb, c.args[0])!
					println(utils.response_success('Set showtap status to `${next_status}`'))
				}
			}
		})
	}
	flags: [
		cli.Flag{
			flag:        cli.FlagType.bool
			name:        'toggle'
			abbrev:      't'
			description: 'Toggle tap visibility.'
		},
		cli.Flag{
			flag:        cli.FlagType.bool
			name:        'status'
			abbrev:      's'
			description: 'Show tap visibility status.'
		},
	]
})
developer.add_command(cli.Command{
	name:        'wifi'
	usage:       '[value 1|0|on|off]'
	description: 'Toggle wifi'
	execute:     fn (c cli.Command) ! {
		run(fn [c] () ! {
			adb := android.Adb.create()!
			is_toggle := c.flags.get_bool('toggle')!
			is_show_status := c.flags.get_bool('status')!

			match true {
				is_toggle {
					next_status := cmd.toggle_wifi(adb)!
					println(utils.response_success('Toggle wifi status to `${next_status}`'))
					exit(0)
				}
				is_show_status {
					current_status := cmd.get_wifi_status(adb)!
					println(utils.response_success('Current wifi status: ${current_status}'))
					exit(0)
				}
				else {
					if c.args.len == 0 {
						return error('Please set value `1(on)` or `0(off)`')
					}

					next_status := cmd.activate_wifi(adb, c.args[0])!
					println(utils.response_success('Set wifi status to `${next_status}`'))
				}
			}
		})
	}
	flags: [
		cli.Flag{
			flag:        cli.FlagType.bool
			name:        'toggle'
			abbrev:      't'
			description: 'Toggle wifi activation'
		},
		cli.Flag{
			flag:        cli.FlagType.bool
			name:        'status'
			abbrev:      's'
			description: 'Show wifi activation status'
		},
	]
})
developer.add_command(cli.Command{
	name:        'stoptask'
	description: 'Stop lock task mode'
	execute:     fn (c cli.Command) ! {
		run(fn () ! {
			adb := android.Adb.create()!
			cmd.leave_lock_task_mode(adb)!
		})
	}
})

app.add_command(developer)

app.setup()
app.parse(os.args)
