module android

pub enum DeviceType {
	device
	emulator
}

pub struct Device {
pub:
	name        string
	device_type DeviceType
}

pub fn check_device_type(s string) DeviceType {
	return match true {
		s.contains('emulator-') { .emulator }
		else { .device }
	}
}
