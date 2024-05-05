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
	description: 'list connected devices'
	execute: fn (_ cli.Command) ! {
		adb := cmd.create_adb() or { print_err(err) }
		all_devices := adb.get_all_active_devices() or { print_err(err) }

		for d in all_devices {
			println(d.name)
		}
	}
})

app.add_command(cli.Command{
	name: 'device'
	description: 'select a device from connected device list'
	execute: fn (_ cli.Command) ! {
		adb := cmd.create_adb() or { print_err(err) }
		selected_device := adb.select_active_device() or { print_err(err) }

		println(selected_device.name)
	}
})

app.add_command(cli.Command{
	name: 'screencap'
	description: 'Capture a screenshot from a connected device with the given file name'
	execute: fn (c cli.Command) ! {
		adb := cmd.create_adb() or { print_err(err) }

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

app.setup()
app.parse(os.args)
