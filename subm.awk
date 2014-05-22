/\[submodule/ {
	line = $0
} 

/^.*path.=/ {
    if (!index(line,$4)) {
        print line
        print $0
    }
}