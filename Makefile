AWKCMD?=	/usr/bin/env awk
DIFFCMD?=	/usr/bin/diff
CWD!=		pwd
SRCS!=		/usr/bin/find ${CWD} -name "*.awk"
REPORTS=	${SRCS:C/\.awk$/.report/}
TESTDIR=	${CWD}/test

.PHONY: test clean
.SUFFIXES: .awk .report

test: ${REPORTS}
.for REPORT in ${REPORTS}
	${DIFFCMD} -u ${REPORT:C/${CWD}\/(.*)\.report/${TESTDIR}\/\1.expected/} ${REPORT}
.endfor


clean:
	-/bin/rm -f ${REPORTS}

.awk.report:
	${AWKCMD} -f ${.IMPSRC} < ${.IMPSRC} > ${.TARGET}
