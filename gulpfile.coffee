externals = [
	
]

(require "coffee-project")
	documentation: enabled: false
	forever:       enabled: false
	livereload:    enabled: true
	bundle:        enabled: true, externals: externals
	copy:          enabled: true
	less:          enabled: true
	tests:         enabled: true
	coffee:        enabled: true
	watch:         enabled: true
	nodemon:       enabled: true
	clean:         enabled: true
