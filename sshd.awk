#!/usr/bin/awk -f

/sshd\[[0-9]+\]: Invalid user/ {
	username = $8;
	invalid_user[username] += 1;
}

/sshd\[[0-9]+\]: input_userauth_request: invalid user/ {
	username = $9;
	invalid_user[username] += 1;
}

/sshd\[[0-9]+\]: Accepted publickey for/ {
	username = $9;
	accepted_publickey[username] += 1;
}

function head(type) {
	return sprintf("%-17s %8s %4s", type, "times", "pct%");
}

function line(char, n, i) {
	n = length(head());
	for (i = 0; i < n; i++)
		printf "%c", char;
	printf "\n";
}

function header(type) {
	printf "%s\n", head(type);
	line("=");
}

function report(stats, pipe, username, total, pct, output) {
	for (username in stats)
		total += stats[username];
	for (username in stats) {
		pct = 100 * stats[username] / total;
		output = output sprintf("%-17s %8d %3d%%\n", username,
		       stats[username], pct);
	}
	print substr(output, 1, length(output) - 1) | pipe;
	close(pipe);
	line("-");
	pct = 100;
	printf "%-17s %8d %3d%%\n", "*", total, pct;
}

END {
	header("sshd accepted key");
	report(accepted_publickey, "/usr/bin/sort -snr -k2");
	print "";
	header("sshd invalid user");
	report(invalid_user, "/usr/bin/sort -snr -k2");
}


#Jan 01 00:00:00 middle-earth sshd[42]: Invalid user saruman from 172.16.0.2
#Jan 01 00:00:00 middle-earth sshd[42]: Invalid user sauron from 666:666:666:666:666:666:666:666
#Jan 01 00:00:00 middle-earth sshd[42]: input_userauth_request: invalid user smaug [preauth]
#Jan 01 00:00:00 middle-earth sshd[42]: Invalid user saruman from 172.16.0.1
#Jan 01 00:00:00 middle-earth sshd[42]: Invalid user saruman from 172.16.0.2
#Jan 01 00:00:00 middle-earth sshd[42]: Invalid user saruman from 172.16.0.2
#Jan 01 00:00:00 middle-earth sshd[42]: Accepted publickey for bbaggins from 192.168.0.1 port 1000 ssh2: RSA SHA256:IWONTGIVEMYPRECIOUSAWAYITELLYOU
#Jan 01 00:00:00 middle-earth sshd[42]: Accepted publickey for tbombadil from 192.168.0.2 port 1000 ssh2: RSA SHA256:ELDESTTHATSWHATIAM
