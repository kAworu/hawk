#!/usr/bin/awk -f

# Returns "foo" given "[foo]"
function unbracketize(s) {
	if (match(s, /\[[^\]]+\]/)) {
		return substr(s, RSTART + 1, RLENGTH - 2);
	}
}

/postfix\/postscreen\[[0-9]+\]: CONNECT from/ {
	ip = unbracketize($8);
	connect[ip] += 1;
}

/postfix\/postscreen\[[0-9]+\]: DNSBL/ {
	rank = $8; # XXX: unused at the moment
	ip   = unbracketize($10);
	dnsbl[ip] += 1;
}

/postfix\/postscreen\[[0-9]+\]: NOQUEUE/ {
	ip = unbracketize($10);
	noqueue[ip] += 1;
}

/postfix\/postscreen\[[0-9]+\]: HANGUP/ {
	ip = unbracketize($10);
	hangup[ip] += 1;
}

/postfix\/postscreen\[[0-9]+\]: PREGREET/ {
	ip = unbracketize($11);
	pregreet[ip] += 1;
}

/postfix\/postscreen\[[0-9]+\]: DISCONNECT/ {
	ip = unbracketize($7);
	disconnect[ip] += 1;
}

/postfix\/postscreen\[[0-9]+\]: PASS NEW/ {
	ip = unbracketize($8);
	pass_new[ip] += 1;
}

/postfix\/postscreen\[[0-9]+\]: PASS OLD/ {
	ip = unbracketize($8);
	pass_old[ip] += 1;
}

/postfix\/postscreen\[[0-9]+\]: WHITELISTED/ {
	ip = unbracketize($7);
	whitelisted[ip] += 1;
}


function head() {
	return sprintf("%-11s %6s / %5s", "postscreen", "unique", "total");
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

function report(name, stats, ip, count, total) {
	for (ip in stats) {
		count += 1;
		total += stats[ip];
	}
	printf "%-11s %6d / %5d\n", name, count, total;
}

END {
	header();
	report("CONNECT",     connect);
	report("NOQUEUE",     noqueue);
	report("HANGUP",      hangup);
	report("PREGREET",    pregreet);
	report("DISCONNECT",  disconnect);
	report("DNSBL",       dnsbl);
	report("PASS NEW",    pass_new);
	report("PASS OLD",    pass_old);
	report("WHITELISTED", whitelisted);
}

# FIXME: we could do more here, theses tests are too simple.

#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: CONNECT from [172.16.0.1]:666 to [10.0.0.1]:25
#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: DNSBL rank 6 for [172.16.0.1]:666
#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: NOQUEUE: reject: RCPT from [172.16.87.1]:666: 550 5.7.1 Service unavailable; client [172.16.0.1] blocked using coat.thorin.oakenshield.lonely-mountain.realm; from=<thranduil@woodland.realm>, to=<bombur@lonely-mountain.realm>, proto=ESMTP, helo=<elvenking.woodland.realm>
#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: HANGUP after 1.9 from [172.16.0.1]:666 in tests after SMTP handshake
#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: HANGUP after 1.7 from [172.16.0.8]:666 in tests after SMTP handshake
#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: PREGREET 14 after 0.26 from [172.16.0.1]:666: EHLO Noro lim\r\n
#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: PREGREET 9 after 0.26 from [172.16.9.2]:666: EHLO Noro lim\r\n
#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: PREGREET 21 after 0.26 from [172.16.21.9]:666: EHLO Noro lim\r\n
#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: PREGREET 16 after 0.26 from [172.16.9.2]:666: EHLO Noro lim\r\n
#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: PREGREET 17 after 0.26 from [172.16.9.2]:666: EHLO Noro lim\r\n
#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: DISCONNECT [172.16.0.1]:666
#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: PASS NEW [192.168.0.1]:1000
#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: PASS OLD [192.168.0.1]:1000
#Jan 01 00:00:00 middle-earth postfix/postscreen[42]: WHITELISTED [192.168.0.1]:1000
