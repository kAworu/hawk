#!/usr/bin/awk -f

# Returns "bar" given "FOO=bar"
function something_eq(s) {
	if (match(s, /=.*$/)) {
		return substr(s, RSTART + 1, RLENGTH - 1);
	}
	return s;
}

$5 == "sudo:" && $12 ~ /USER=/ {
	from   = $6;
	usereq = $12;
	sudo[from, something_eq(usereq)] += 1;
}


function head() {
	return sprintf("%-10s %10s %8s (%4s)", "sudo from", "to", "times", "pct%");
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
		output = output sprintf("%-10s %10s %8d (%3d%%)\n", from_to[1],
		       from_to[2], sudo[combined], pct);
	}
	print substr(output, 1, length(output) - 1) | pipe;
	close(pipe);
	line("-");
	printf "%-10s %10s %8d (%3d%%)\n", "*", "*", total, 100;
}

END {
	header();
	report("/usr/bin/sort -nr -k3");
}


#Jan 01 00:00:00 hostname sudo:     admin : TTY=pts/0 ; PWD=/usr/home/myuser ; USER=root ; COMMAND=/usr/local/bin/vim /etc/crontab
#Jan 01 00:00:00 hostname sudo:     admin : TTY=pts/0 ; PWD=/usr/home/myuser ; USER=root ; COMMAND=/usr/local/bin/vim /etc/crontab
#Jan 01 00:00:00 hostname sudo:     admin : TTY=pts/0 ; PWD=/usr/home/myuser ; USER=root ; COMMAND=/usr/local/bin/vim /etc/crontab
#Jan 01 00:00:00 hostname sudo:     alex : TTY=pts/0 ; PWD=/usr/home/myuser ; USER=root ; COMMAND=/usr/local/bin/vim /etc/crontab
