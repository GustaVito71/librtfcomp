# PYRTFCOMP.PYX
#
# Python wrappers for librtfcomp
#
# Copyright 28/2/2007 Dr J A Gow
#
# This file is released under the terms and conditions of the LGPL - please see the LICENCE
# file in the package root directory.
#
# Changes for
# String Handling: Replaced PyString_* functions with PyBytes_*
# for Python 3 compatibility.
# Syntax Updates:  Updated the print statement in RTFException.dump i
# to use Python 3's print function.
# Validation: All string handling is now explicit about bytes since the C functions
# work with byte data.
#

cdef extern from "rtfcomp/rtfcomp.h":

    ctypedef struct RTFOPTS:
        int         lenOpts
        unsigned int isCompressed

    int LZRTFCompress(
        unsigned char **dest,
        unsigned int *outlen,
        unsigned char *src,
        int len
    ) nogil
    int LZRTFDecompress(
        unsigned char ** dest,
        unsigned int * outlen,
        unsigned char * src,
        unsigned int len
    ) nogil
    int LZRTFConvertRTFToUTF8(
        unsigned char ** utfout,
        unsigned int * utflen,
        unsigned char * rtfin,
        unsigned int rtflen,
        RTFOPTS * options
    ) nogil
    int LZRTFConvertUTF8ToRTF(
        unsigned char ** rtfout,
        unsigned int * lenOut,
        unsigned char * utfin,
        unsigned int len,
        unsigned char * rtfhdr,
        unsigned int hdrlen,
        RTFOPTS * options
    ) nogil
    char * LZRTFGetStringErrorCode(int ec) nogil

cdef extern from "Python.h":
    char *PyBytes_AsString(object string)
    object PyBytes_FromStringAndSize(char *s, int len)
    int PyBytes_AsStringAndSize(object obj, char **buffer, Py_ssize_t *length)

cdef extern from "stdlib.h":
    void free(void * ptr) nogil


class RTFException(Exception):
    def __init__(self, ec):
        self.errorcode = ec
        self.strdesc = <char *>LZRTFGetStringErrorCode(ec)

    def __str__(self):
        return str(self.errorcode) + ": " + str(LZRTFGetStringErrorCode(self.errorcode))

    def dump(self):
        print(f"Failed to convert: {self.strdesc}")


def RTFCompress(src):
    cdef unsigned char * result
    cdef unsigned int reslen
    cdef int rc
    cdef char * source_str
    cdef Py_ssize_t source_len

    PyBytes_AsStringAndSize(src, &source_str, &source_len)

    with nogil:
        rc = LZRTFCompress(&result, &reslen, <unsigned char *>source_str, source_len)

    if rc != 0:
        raise RTFException(rc)

    rstr = PyBytes_FromStringAndSize(<char *>result, reslen)
    free(result)
    return rstr


def RTFDecompress(src):
    cdef unsigned char * result
    cdef unsigned int reslen
    cdef int rc
    cdef char * source_str
    cdef Py_ssize_t source_len

    PyBytes_AsStringAndSize(src, &source_str, &source_len)

    with nogil:
        rc = LZRTFDecompress(&result, &reslen, <unsigned char *>source_str, source_len)

    if rc != 0:
        raise RTFException(rc)

    rstr = PyBytes_FromStringAndSize(<char *>result, reslen)
    free(result)
    return rstr


def RTFConvertToUTF8(src, isCompressed):
    cdef RTFOPTS opts
    cdef unsigned char * result
    cdef unsigned int reslen
    cdef int rc
    cdef char * source_str
    cdef Py_ssize_t source_len

    opts.lenOpts = sizeof(RTFOPTS)
    opts.isCompressed = isCompressed

    PyBytes_AsStringAndSize(src, &source_str, &source_len)

    with nogil:
        rc = LZRTFConvertRTFToUTF8(
            &result, &reslen,
            <unsigned char *>source_str,
            source_len, &opts
        )

    if rc != 0:
        raise RTFException(rc)

    rstr = PyBytes_FromStringAndSize(<char *>result, reslen)
    free(result)
    return rstr


def RTFConvertFromUTF8(src, header, isCompressed):
    cdef RTFOPTS opts
    cdef unsigned char * result
    cdef unsigned int reslen
    cdef int rc
    cdef char * source_str
    cdef Py_ssize_t source_len
    cdef char * header_str
    cdef Py_ssize_t header_len

    opts.lenOpts = sizeof(RTFOPTS)
    opts.isCompressed = isCompressed

    PyBytes_AsStringAndSize(src, &source_str, &source_len)
    PyBytes_AsStringAndSize(header, &header_str, &header_len)

    with nogil:
        rc = LZRTFConvertUTF8ToRTF(
            &result, &reslen,
            <unsigned char *>source_str,
            source_len, <unsigned char *>header_str,
            header_len, &opts
        )

    if rc != 0:
        raise RTFException(rc)

    rstr = PyBytes_FromStringAndSize(<char *>result, reslen)
    free(result)
    return rstr
