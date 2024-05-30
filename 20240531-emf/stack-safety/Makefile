# Before running the binary, enable c18n, if needed:
# $ elfctl -e +cheric18n stack-safety
# This can be later reverted with:
# $ elfctl -e -cheric18n stack-safety

PROG=	stack-safety

MAN=

LDFLAGS+=	-L./libmalicious/ -lmalicious

.include <bsd.prog.mk>
