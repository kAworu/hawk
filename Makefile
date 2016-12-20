AWK?=			/usr/bin/env awk
HAWKDIR?=		${:!pwd!}
HAWKTESTDIR=	${HAWKDIR}/test
HAWKSRCS=		${:!/usr/bin/find ${HAWKDIR} -name "*.awk"!}
HAWKREPORTS=	${HAWKSRCS:C/\.awk$/.report/}

.PHONY: test clean
.SUFFIXES: .awk .report

test: ${HAWKREPORTS}
.for REPORT in ${HAWKREPORTS}
	/usr/bin/diff -u ${REPORT:C/${HAWKDIR}\/(.*)\.report/${HAWKTESTDIR}\/\1.expected/} ${REPORT}
.endfor


clean:
	-/bin/rm -f ${HAWKREPORTS}

.awk.report:
	${AWK} -f ${.IMPSRC} ${.IMPSRC} > ${.TARGET}
