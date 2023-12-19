//
// C++ Unicode support
//
// Description: Includes the required headers and namespaces to support UTF-16
//
//
// Author: Andrew Shultzabarger <andrew@ardnew.com>, (C) 2023
//
// Copyright: See COPYING file that comes with this distribution
//
//
// This program is copyright (c) 2009 by Roderick W. Smith. It is distributed
// under the terms of the GNU GPL version 2, as detailed in the COPYING file.

#ifdef USE_UTF16

#  include <unicode/ustdio.h>
#  include <unicode/unistr.h>

using namespace icu;

#else

#  define UnicodeString string

#endif
