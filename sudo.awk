#!/usr/bin/awk -f

# Returns "bar" given "FOO=bar"
function something_eq(s) {
	if (match(s, /=.*$/)) {
		return substr(s, RSTART + 1, RLENGTH - 1);
	}
	return s;
}

$5 == "sudo:" && $12 ~ /USER=/ {
	from = $6;
	to   = something_eq($12);
	sudo[from, to] += 1;
}


function head() {
	return sprintf("%-16s %-16s %8s %4s", "sudo from", "to", "times", "pct%");
}

function line(char, n, i) {
	n = length(head());
	for (i = 0; i < n; i++)
		printf "%c", char;
	printf "\n";
}

function header() {
	printf "%s\n", head();
	line("=");
}

function report(pipe, combined, total, pct, from_to, output) {
	for (combined in sudo)
		total += sudo[combined];
	for (combined in sudo) {
		pct = 100 * sudo[combined] / total;
		split(combined, from_to, SUBSEP);
		output = output sprintf("%-16s %-16s %8d %3d%%\n", from_to[1],
		       from_to[2], sudo[combined], pct);
	}
	print substr(output, 1, length(output) - 1) | pipe;
	close(pipe);
	line("-");
	pct = 100;
	printf "%-16s %-16s %8d %3d%%\n", "*", "*", total, pct;
}

END {
	header();
	# order by times desc, from, to
	report("/usr/bin/sort -s -k1,1 -k2,2 | /usr/bin/sort -snr -k3,3");
}


# FIXME: some dates could not be found on http://lotr.wikia.com/wiki/Quest_of_the_Ring

#Sep 22 00:00:00 middle-earth sudo:     frodo : TTY=pts/0 ; PWD=/shire/bag-end ; USER=root ; COMMAND=/bin/mv ~bilbo/the-One-Ring .
#Apr 12 00:00:00 middle-earth sudo:     gandalf : TTY=pts/0 ; PWD=/shire/bag-end ; USER=root ; COMMAND=/bin/mv ./the-One-Ring ./fire/
#Apr 12 00:01:00 middle-earth sudo:     frodo : TTY=pts/0 ; PWD=/shire/bag-end ; USER=root ; COMMAND=/bin/mv ./fire/the-One-Ring ~frodo/pocket
#??? ?? 00:00:00 middle-earth sudo:     frodo : TTY=pts/0 ; PWD=/bree/the-prancing-poney ; USER=root ; COMMAND=/usr/bin/touch ~frodo/pocket/the-One-Ring
#Oct 06 00:00:00 middle-earth sudo:     frodo : TTY=pts/0 ; PWD=/eriador/weathertop ; USER=root ; COMMAND=/usr/bin/touch ~frodo/pocket/the-One-Ring
#??? ?? 00:00:00 middle-earth sudo:     frodo : TTY=pts/0 ; PWD=/gondor/amon-hen ; USER=root ; COMMAND=/usr/bin/touch ~frodo/pocket/the-One-Ring
#??? ?? 00:00:00 middle-earth sudo:     sam : TTY=pts/0 ; PWD=/mordor/shelobs-lair ; USER=root ; COMMAND=/bin/mv ~frodo/pocket/the-One-Ring ~/pocket
#??? ?? 00:00:00 middle-earth sudo:     sam : TTY=pts/0 ; PWD=/mordor/cirith-ungol/tower ; USER=root ; COMMAND=/bin/mv ~/pocket/the-One-Ring ~frodo/pocket
#??? ?? 00:00:00 middle-earth sudo:     frodo : TTY=pts/0 ; PWD=/mordor/mount-doom ; USER=root ; COMMAND=/usr/bin/touch ~frodo/pocket/the-One-Ring
#??? ?? 00:00:00 middle-earth sudo:     smeagol : TTY=pts/0 ; PWD=/mordor/mount-doom ; USER=root ; COMMAND=/bin/mv ~frodo/pocket/the-One-Ring .
