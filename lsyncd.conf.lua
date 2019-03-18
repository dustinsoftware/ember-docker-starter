sync {
	default.rsync,
	source = "/host-app",
	target = "/app",
	init = false,
	delay = 1,
	delete = "running",
	exclude = { "/node_modules", "/dist" }
}
