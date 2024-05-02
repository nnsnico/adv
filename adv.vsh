#!/usr/bin/env -S v

module main

import cmd

adb := cmd.create_adb() or {
	eprintln(err)
	exit(1)
}

devices := adb.select_active_device() or {
	eprintln(err)
	exit(1)
}

println(devices)
