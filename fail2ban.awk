#!/usr/bin/awk -f

# Returns "foo" given "[foo]"
function unbracketize(s) {
	if (match(s, /\[[^]]+\]/)) {
		return substr(s, RSTART + 1, RLENGTH - 2);
	}
	return s;
}

$3 == "fail2ban.actions" && $5 == "NOTICE" && $7 == "Ban" {
	jail = unbracketize($6);
	ip   = $8;
	fail2ban[jail, ip] += 1;
}


function head() {
	return sprintf("%-16s %6s / %5s %4s", "fail2ban jail", "unique",
	       "total", "pct%");
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

function report(pipe, combined, jail_ip, jail, ip, total_per_jail, unique_per_jail,
	    unique, total, pct, output) {
	for (combined in fail2ban) {
		split(combined, jail_ip, SUBSEP);
		jail = jail_ip[1];
		ip   = jail_ip[2];
		unique += 1;
		total  += fail2ban[combined];
		unique_per_jail[jail] += 1;
		total_per_jail[jail]  += fail2ban[combined];
	}
	for (jail in total_per_jail) {
		pct = 100 * total_per_jail[jail] / total;
		output = output sprintf("%-16s %6d / %5d %3d%%\n", jail,
		       unique_per_jail[jail], total_per_jail[jail], pct);
	}
	print substr(output, 1, length(output) - 1) | pipe;
	close(pipe);
	line("-");
	pct = 100;
	printf "%-16s %6d / %5d %3d%%\n", "*", unique, total, pct;
}

END {
	header();
	report("/usr/bin/sort -s -k1,1 | /usr/bin/sort -snr -k4,4 -k2,2");
}

#1970-01-01 00:00:00,000 fail2ban.actions        [42]: NOTICE  [ssh] Ban 172.16.0.1
#1970-01-01 00:00:00,000 fail2ban.actions        [42]: NOTICE  [ssh] Ban 172.16.0.1
#1970-01-01 00:00:00,000 fail2ban.actions        [42]: NOTICE  [ssh] Ban 172.16.0.18
#1970-01-01 00:00:00,000 fail2ban.actions        [42]: NOTICE  [postfix] Ban 172.16.0.20
#1970-01-01 00:00:00,000 fail2ban.actions        [42]: NOTICE  [dovecot] Ban 172.16.0.3
#1970-01-01 00:00:00,000 fail2ban.actions        [42]: NOTICE  [postfix] Ban 172.16.0.4
#1970-01-01 00:00:00,000 fail2ban.actions        [42]: NOTICE  [nsd] Ban 172.16.0.1
#1970-01-01 00:00:00,000 fail2ban.actions        [42]: NOTICE  [nsd] Ban 172.16.0.1
#1970-01-01 00:00:00,000 fail2ban.actions        [42]: NOTICE  [nsd] Ban 172.16.0.1
