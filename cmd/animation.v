module cmd

import android

pub fn set_window_animation(a android.Adb, value f32) ! {
	selected_device := a.select_active_device()!
	a.run_waiting(selected_device, 'shell settings put global window_animation_scale ${value}')!
}

pub fn set_transition_animation(a android.Adb, value f32) ! {
	selected_device := a.select_active_device()!
	a.run_waiting(selected_device, 'shell settings put global transition_animation_scale ${value}')!
}

pub fn set_animator_duration(a android.Adb, value f32) ! {
	selected_device := a.select_active_device()!
	a.run_waiting(selected_device, 'shell settings put global animator_duration_scale ${value}')!
}
