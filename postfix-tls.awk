#!/usr/bin/awk -f

# NOTE: need smtpd_tls_loglevel /smtp_tls_loglevel set to (at least) 1 in the
# postfix config.
/(Anonymous|Untrusted) TLS connection established/ {
	type    = $6;
	version = $12;
	cipher  = $15;
	postfix_tls[type, version, cipher] += 1;
}


function head() {
	return sprintf("%-9s %-7s %-32s %5s %4s", "type", "version", "cipher",
	       "count", "pct%");
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

function report(pipe, combined, total, separated, type, version, cipher, pct,
		output) {
	for (combined in postfix_tls)
		total += postfix_tls[combined];
	for (combined in postfix_tls) {
		pct = 100 * postfix_tls[combined] / total;
		split(combined, separated, SUBSEP);
		type    = separated[1];
		version = separated[2];
		cipher  = separated[3];
		output  = output sprintf("%-9s %-7s %-32s %5d %3d%%\n", type,
                        version, cipher, postfix_tls[combined], pct);
	}
	print substr(output, 1, length(output) - 1) | pipe;
	close(pipe);
	line("-");
	pct = 100;
	printf "%-9s %-7s %-32s %5d %3d%%\n", "*", "*", "*", total, pct;
}

END {
	header();
	report("/usr/bin/sort -nr -k4");
}

#Jan 01 00:00:00 middle-earth postfix/tlsproxy[42]: Anonymous TLS connection established from [192.168.1.12]:1000: TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits)
#Jan 01 00:00:00 middle-earth postfix/smtp[42]: Untrusted TLS connection established to boromir.admin.gondor.gov[192.168.0.3]:25: TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits)
#Jan 01 00:00:00 middle-earth postfix/tlsproxy[42]: Anonymous TLS connection established from [192.168.1.18]:1000: TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits)
#Jan 01 00:00:00 middle-earth postfix/smtpd[42]: Anonymous TLS connection established from gandalf-laptop.isengard.edu[192.168.0.75]: TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits)
#Jan 01 00:00:00 middle-earth postfix/smtpd[42]: Anonymous TLS connection established from [192.168.49]: TLSv1 with cipher AES128-SHA (128/128 bits)
#Jan 01 00:00:00 middle-earth postfix/smtpd[42]: Anonymous TLS connection established from [2001::192:168:0:71]: TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits)
#Jan 01 00:00:00 middle-earth postfix/tlsproxy[42]: Anonymous TLS connection established from [192.168.1.38]:1000: TLSv1 with cipher DES-CBC3-SHA (112/168 bits)
