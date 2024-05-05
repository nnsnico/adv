#!/usr/bin/env -S v

module main

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

app.add_command(cli.Command{
	name: 'devices'
	description: 'List connected devices'
	execute: fn (_ cli.Command) ! {
		adb := cmd.Adb.create() or { print_err(err) }
		all_devices := adb.get_all_active_devices() or { print_err(err) }

		for d in all_devices {
			println(d.name)
		}
	}
})

app.add_command(cli.Command{
	name: 'device'
	description: 'Select a device from connected device list'
	execute: fn (_ cli.Command) ! {
		adb := cmd.Adb.create() or { print_err(err) }
		selected_device := adb.select_active_device() or { print_err(err) }

		println(selected_device.name)
	}
})

app.add_command(cli.Command{
	name: 'pull'
	description: 'Pull the specified file from a selected device'
	execute: fn (c cli.Command) ! {
		adb := cmd.Adb.create() or { print_err(err) }

		adb.pull_file(c.args[0]) or { print_err(err) }
	}
	required_args: 1
})

app.add_command(cli.Command{
	name: 'screencap'
	description: 'Capture a screenshot from a connected device with the given file name'
	execute: fn (c cli.Command) ! {
		adb := cmd.Adb.create() or { print_err(err) }

		is_exec_pull := c.flags.get_bool('pull') or { print_err(err) }
		adb.capture_screen(c.args[0], is_exec_pull) or { print_err(err) }
	}
	required_args: 1
	flags: [
		cli.Flag{
			flag: cli.FlagType.bool
			name: 'pull'
			abbrev: 'p'
			description: 'Pull captured screen image at the same time'
		},
	]
})

app.add_command(cli.Command{
	name: 'screenrecord'
	description: 'Record a screen from a connected device with the given file name'
	execute: fn (c cli.Command) ! {
		adb := cmd.Adb.create() or { print_err(err) }

		is_exec_pull := c.flags.get_bool('pull') or { print_err(err) }
		adb.record_screen(c.args[0], is_exec_pull) or { print_err(err) }
	}
	required_args: 1
	flags: [
		cli.Flag{
			flag: cli.FlagType.bool
			name: 'pull'
			abbrev: 'p'
			description: 'Pull recorded screen video at the same time'
		},
	]
})

mut developer := cli.Command{
	name: 'developer'
	description: 'Commands for Android develoepr'
  execute: fn (c cli.Command) ! {
    c.execute_help()
  }
}
developer.add_command(cli.Command{
	name: 'showtap'
	description: 'Show tap position'
	execute: fn (c cli.Command) ! {
		adb := cmd.Adb.create() or { print_err(err) }

    tap_status := if c.args.len == 0 {
      cmd.TapStatus.toggle
    } else {
      cmd.TapStatus.from(c.args[0].int()) or { print_err(err) }
    }
		adb.show_tap(tap_status) or { print_err(err) }
	}
})

app.add_command(developer)

app.setup()
app.parse(os.args)
