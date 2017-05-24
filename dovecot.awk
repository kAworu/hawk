#!/usr/bin/awk -f

# Returns "bar" given "FOO=bar"
function something_eq(s) {
	if (match(s, /=.*$/)) {
		return substr(s, RSTART + 1, RLENGTH - 1);
	}
	return s;
}

# Returns "foo" given "<foo>"
function uncrocodile(s) {
	if (match(s, /<[^>]+>/)) {
		return substr(s, RSTART + 1, RLENGTH - 2);
	}
	return s;
}

# Returns "foo" given "(foo)"
function unparen(s) {
	if (match(s, /\([^\)]+\)/)) {
		return substr(s, RSTART + 1, RLENGTH - 2);
	}
	return s;
}

$5 == "dovecot:" && $7 == "Login:" {
	user = uncrocodile(something_eq($8));
	dovecot_login[user] += 1;
}

$5 == "dovecot:" && $6 ~ /^lda(.*)$/ {
	user = unparen(substr($6, 4, length($6) - 4));
	dovecot_lda[user] += 1;
}


function head(type, n) {
	return sprintf("%-32s %8s (%4s)", type, n, "pct%");
}

function line(char, n, i) {
	n = length(head());
	for (i = 0; i < n; i++)
		printf "%c", char;
	printf "\n";
}

function header(type, n) {
	printf "%s\n", head(type, n);
	line("=");
}

function report(stats, pipe, total, email, pct, output) {
	for (email in stats)
		total += stats[email];
	for (email in stats) {
		pct = 100 * stats[email] / total;
		output = output sprintf("%-32s %8d (%3d%%)\n", email,
		       stats[email], pct);
	}
	print substr(output, 1, length(output) - 1) | pipe;
	close(pipe);
	line("-");
	printf "%-32s %8d (%3d%%)\n", "*", total, 100;
}

END {
	header("dovecot login", "times");
	report(dovecot_login, "/usr/bin/sort -nr -k2");
	print "";
	header("dovecot lda", "count");
	report(dovecot_lda, "/usr/bin/sort -nr -k2");
}


#Dec 19 15:08:44 hostname dovecot: imap-login: Login: user=<me@mydomain.tld>, method=PLAIN, rip=192.168.0.1, lip=10.0.0.1, mpid=42, TLS, session=<Ing8jUyj1rpNb0xJ>
#Dec 19 17:58:04 hostname dovecot: lda(me@mydomain.tld): sieve: msgid=<70.B1.4795X.0Foo8585@domain.tld>: stored mail into mailbox 'INBOX'
