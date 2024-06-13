module cmd

pub struct Movie {}

pub struct Picture {}

pub struct Others {
pub:
	raw_path string
}

type Path = Movie | Others | Picture

fn to_raw_path(p Path) string {
	return match p {
		Movie { '/sdcard/Movies' }
		Picture { '/sdcard/Pictures' }
		Others { p.raw_path }
	}
}
