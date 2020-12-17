#!/usr/bin/tclsh

set BUNDLE_FOLDER [lindex $argv 0]
set SEARCH_KEYS [lindex $argv 1]
foreach key $SEARCH_KEYS {
	set KEY_VALUE_MAP($key) [list]
}

file delete -force "$BUNDLE_FOLDER/bundle.mk"
set f [open "$BUNDLE_FOLDER/bundle.mk" "w"]

foreach arg [lrange $argv 2 end] {
	set fh [open $arg]
	set data [read $fh]
	close $fh

	set lines [split $data "\n"]
	foreach line $lines {
		foreach key $SEARCH_KEYS {
			if ([string match "$key = *" $line]) {
				set value [string range $line [string length "$key = "] end]
				set KEY_VALUE_MAP($key) [concat $KEY_VALUE_MAP($key) $value]
			}
		}
	}
}

foreach key $SEARCH_KEYS {
	set KEY_VALUE_MAP($key) [lsort -unique $KEY_VALUE_MAP($key)]
	puts $f "$key = $KEY_VALUE_MAP($key)"
}

close $f
