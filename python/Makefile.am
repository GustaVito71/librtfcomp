
if HAVE_PYTHON

AM_CPPFLAGS = -I$(top_srcdir)/include
CLEANFILES = pyrtfcomp.c

rtfcompbindingsdir = $(pyexecdir)
rtfcompbindings_LTLIBRARIES = pyrtfcomp.la

LDADD = ../src/librtfcomp.la
pyrtfcomp_la_CFLAGS = @PYTHON_INCLUDES@ -I../include -g -O0 -Wall -Werror -Wdeprecated-declarations
pyrtfcomp_la_LDFLAGS = -module -avoid-version -fPIC
pyrtfcomp_la_LIBADD = $(top_builddir)/src/librtfcomp.la
nodist_pyrtfcomp_la_SOURCES = pyrtfcomp.c

endif

EXTRA_DIST = pyrtfcomp.pyx

pyrtfcomp.c: $(srcdir)/pyrtfcomp.pyx
	cython3 -3 $(srcdir)/pyrtfcomp.pyx -o ./pyrtfcomp.c

