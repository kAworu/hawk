[![Build Status](https://travis-ci.org/kAworu/hawk.svg?branch=master)](https://travis-ci.org/kAworu/hawk)

# hawk
A collection of rudimentary system logs parsing scripts

## Testing

You'll need a BSD make. If you're running a BSD then your `/usr/bin/make`
should be fine, otherwise install [the portable version of NetBSD make][bmake].

Each script has some comments at the end of the file. Theses comments are
pattern that the script should recognize and parse successfully, and so you can
just run a script on itself, for example:

```
./sudo.awk < sudo.awk
```

The output result should look like the `.expected` file from the test/
directory:

```
./sudo.awk < sudo.awk > sudo.report
diff test/sudo.expected sudo.report
```

The report file should match expected test file, and so `diff` should be
silent. This is exactly what the `Makefile` does, so in order to run the test
for each script just type:

```
make test
```

You may override the awk implementation and diff command used in this way:

```
AWKCMD="busybox awk" DIFFCMD=colordiff make clean test
```

Here we clean to force regeneration of the `.report` file since we want to
ensure having run the provided `AWKCMD`.

[bmake]: http://www.crufty.net/help/sjg/bmake.html
