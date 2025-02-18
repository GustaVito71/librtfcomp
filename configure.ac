AC_PREREQ([2.71])
AC_INIT([librtfcomp],[1.4])
AC_CONFIG_SRCDIR(src/rtfcomp.c)
AM_INIT_AUTOMAKE([1.9 foreign])
AC_CONFIG_MACRO_DIRS([m4])

AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_MAKE_SET
LT_INIT

dnl # test for visibility flag - compile with all symbols visible
dnl # if we do not have it

dnl save_CFLAGS="$CFLAGS"
dnl CFLAGS="$CFLAGS -Wall -Werror"
AC_MSG_CHECKING([whether $CC supports the GNUC visibility attribute])
AC_COMPILE_IFELSE(
[AC_LANG_SOURCE(
[
  void __attribute__ ((visibility("default"))) test_default (void) {}
  void __attribute__ ((visibility("hidden"))) test_hidden (void) {}
  int main (int argc, char **argv) { test_default (); test_hidden (); return 0; }
])],
[
  have_gccvisibility=yes
  AC_MSG_RESULT([yes])
],
[
  AC_MSG_RESULT([no])
])

if test x"$have_gccvisibility" = x"yes"; then
	VISIBILITY="-DHAVE_GCCVISIBILITY -fvisibility=hidden"
fi
AC_SUBST(VISIBILITY)

dnl # Now we must check for Python/Cython

dnl (need python3, python headers, and cython3)

AC_ARG_ENABLE(python-bindings, AS_HELP_STRING([--disable-python-bindings], [do not build python bindings]),[enable_python=$enableval], [enable_python=auto])
 
if test x$enable_python = xno; then
    have_python=no
else
    AC_MSG_NOTICE([Checking to see if we can build Python bindings])
    have_python=no
    if test x$enable_python != xyes -a x$enable_python != xauto; then
        minimum_version=$enable_python
	enable_python=yes
    else
        minimum_version=3.11
    fi
	AM_PATH_PYTHON_LOCAL($minimum_version, [have_python_path=yes], [have_python_path=no] )
	AC_CHECK_PROGS(CYTHON, cython3, cython3)
	AM_CHECK_PYTHON_HEADERS([have_python_header=yes], [have_python_header=no])
	
	if test x$have_python_path = xno -o x$have_python_header = xno -o x$CYTHON != xcython3 ; then
            if test x$enable_python = xyes ; then
                AC_MSG_ERROR([Building python explicitly requested, but can't build python bindings])
            else
                AC_MSG_NOTICE([Not building Python bindings])
            fi
	else
	    if test -z "$PYTHON" ; then
	        AC_MSG_WARN([Python not found])
	    else
		have_python=yes
	    fi
	
	    if test x$have_python = xno ; then
	        if test x$enable_python = xyes ; then
	            AC_MSG_ERROR([Building python explicitly requested, but can't build python bindings])
	        else
	            AC_MSG_NOTICE([Not building Python bindings])
	        fi
	    else

dnl # require at least cython3 0.29

		AC_MSG_CHECKING([cython version])

		cython_ver=`$CYTHON --version 2>&1 | sed -e 's/Cython version //'`
	 	`echo "$cython_ver" | awk 'BEGIN { FS = "."; } { printf "export cython_maj_ver=%s export cython_min_ver=%s export cython_sub_ver=%s", $1, $2, $3;}'`

		if test "$cython_min_ver" -lt 29 ; then
		    AC_MSG_RESULT([$cython_ver])
		    if test x$enable_python = xyes ; then
			AC_MSG_ERROR([Building python explicitly requested, but can't build python bindings, need at least cython 0.29])
		    else
			AC_MSG_NOTICE([Not building Python bindings, need at least cython 0.29])
			have_python=no
	            fi
    		else
		    AC_MSG_RESULT([ok])
    		fi

	    fi
	fi
fi
AM_CONDITIONAL(HAVE_PYTHON, test x$have_python = xyes)

# build files

AC_CONFIG_FILES([Makefile src/Makefile tests/Makefile python/Makefile])
AC_OUTPUT

