DIFF?=		/usr/bin/diff
AWK?=			/usr/bin/env awk

CWD?=		${:!pwd!}
TESTDIR=	${CWD}/test
SRCS=		${:!/usr/bin/find ${CWD} -name "*.awk"!}
REPORTS=	${SRCS:C/\.awk$/.report/}

.PHONY: test clean
.SUFFIXES: .awk .report

test: ${REPORTS}
.for REPORT in ${REPORTS}
	${DIFF} -u ${REPORT:C/${CWD}\/(.*)\.report/${TESTDIR}\/\1.expected/} ${REPORT}
.endfor


clean:
	-/bin/rm -f ${REPORTS}

.awk.report:
	${AWK} -f ${.IMPSRC} < ${.IMPSRC} > ${.TARGET}
