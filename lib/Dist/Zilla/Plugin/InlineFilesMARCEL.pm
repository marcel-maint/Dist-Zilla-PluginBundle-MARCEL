use 5.008;
use strict;
use warnings;

package Dist::Zilla::Plugin::InlineFilesMARCEL;
# ABSTRACT: Write static files that I always use
use Moose;
use Test::Synopsis;
extends 'Dist::Zilla::Plugin::InlineFiles';

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=begin :prelude

=for test_synopsis
1;
__END__

=for stopwords Quelin

=end :prelude

=head1 SYNOPSIS

In C<dist.ini>:

    [InlineFilesMARCEL]

=head1 DESCRIPTION

This is an extension of L<Dist::Zilla::Plugin::InlineFiles>, providing the
following files:

  t/perlcriticrc
  MANIFEST.SKIP

They contain the settings which I always use in my distributions. This plugin
is automatically included in the C<@MARCEL> plugin bundle.

=cut

__DATA__
___[ t/perlcriticrc ]___
# no strict 'refs'
[TestingAndDebugging::ProhibitNoStrict]
allow = refs

[-BuiltinFunctions::ProhibitStringyEval]
[-ControlStructures::ProhibitMutatingListFunctions]
[-Subroutines::ProhibitExplicitReturnUndef]
[-Subroutines::ProhibitSubroutinePrototypes]
[-Variables::ProhibitConditionalDeclarations]

# for mkdir $dir, 0777
[-ValuesAndExpressions::ProhibitLeadingZeros]

___[ MANIFEST.SKIP ]___
# Version control files and dirs.
\\bRCS\b
\\bCVS\b
\\.svn
\\.git
,v$

# Makemaker/Build.PL generated files and dirs.
MANIFEST.old
^Makefile$
^Build$
^blib
^pm_to_blib$
^_build
^MakeMaker-\d
embedded
cover_db
smoke.html
smoke.yaml
smoketee.txt
sqlnet.log
BUILD.SKIP
COVER.SKIP
CPAN.SKIP
t/000_standard__*
Debian_CPANTS.txt
nytprof.out

# Temp, old, emacs, vim, backup files.
~$
\\.old$
\\.swp$
\\.tar$
\\.tar\.gz$
^#.*#$
^\.#
.shipit

# Local files, not to be included
^scratch$
^core$
^var$
