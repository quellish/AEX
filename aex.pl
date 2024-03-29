#!/usr/bin/perl
#
# Heuristics to extract ABNF from an I-D or RFC.
# Bill Fenner <fenner@research.att.com> 26 September 2004
#
# $Fenner: abnf-parser/aex,v 1.4 2005/02/03 05:35:14 fenner Exp $
#
use strict;
my($inabnf, $indent, $curindent, $spaces, $newrule);
my($blanklines, $top);

# Strip spaces so that Bill's parser can handle the output
my($strip) = 1;

$indent = 0;
$inabnf = 0;
$blanklines = $top = 0;
while (<>) {
	chomp;
	# bewlow regex for rule name permits underscores;
	# rfc2234 doesn't but some grammars use it anyway
	($spaces, $newrule) = m,^(\s*)([A-Za-z][-0-9A-Za-z_]*\s*=/?)?,;
	if ($inabnf == 0 && $newrule) {
		$inabnf = 1;
	}
	next unless $inabnf;
	if (/^$/) {
		$blanklines++;
		next;
	} elsif (/\[[Pp]age [0-9ivx]+\]\s*$/ ||
		 /\014/ ||
		 /^\s*(Internet.Draft|RFC).*\d+\s*$/i) {
		$top = 1;
		next;
	}
	if ($blanklines && !$top) {
		print "\n" x $blanklines;
	}
	$blanklines = $top = 0;
	$curindent = length($spaces);
	if ($newrule) {
		# new rule - indentation can change
		if ($strip == 0 && $indent != 0 && $curindent != $indent) {
			print " " x $indent, "; XXX recommend keeping indentation consistent\n";
		}
		$indent = $curindent;
		s/^\s+// if ($strip);
	} elsif (/\S/ && $curindent <= $indent) {
		# all-whitespace lines stay
		#print "; terminating ABNF with $curindent $_\n";
		$inabnf = 0;
		next;
	}
	print $_, "\n";
}
