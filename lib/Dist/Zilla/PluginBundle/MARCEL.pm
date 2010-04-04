use 5.008;
use strict;
use warnings;

package Dist::Zilla::PluginBundle::MARCEL;

# ABSTRACT: build and release a distribution like me
use Class::MOP;
use Moose;
use Moose::Autobox;

# plugins used
use Dist::Zilla::Plugin::AutoPrereq;
use Dist::Zilla::Plugin::AutoVersion;
use Dist::Zilla::Plugin::Bugtracker;
use Dist::Zilla::Plugin::CheckChangeLog;
use Dist::Zilla::Plugin::CheckChangesTests;
use Dist::Zilla::Plugin::CompileTests 1.100220;
use Dist::Zilla::Plugin::CriticTests;
use Dist::Zilla::Plugin::DistManifestTests;
use Dist::Zilla::Plugin::ExtraTests;
use Dist::Zilla::Plugin::GatherDir;
use Dist::Zilla::Plugin::HasVersionTests;
use Dist::Zilla::Plugin::Homepage;
use Dist::Zilla::Plugin::ExecDir;
use Dist::Zilla::Plugin::InstallGuide;
use Dist::Zilla::Plugin::InlineFilesMARCEL;
use Dist::Zilla::Plugin::KwaliteeTests;
use Dist::Zilla::Plugin::License;
use Dist::Zilla::Plugin::Manifest;
use Dist::Zilla::Plugin::ManifestSkip;
use Dist::Zilla::Plugin::MetaProvides::Package;
use Dist::Zilla::Plugin::MetaYAML;
use Dist::Zilla::Plugin::MetaJSON;
use Dist::Zilla::Plugin::MetaTests;
use Dist::Zilla::Plugin::MakeMaker;
use Dist::Zilla::Plugin::MinimumVersionTests;
use Dist::Zilla::Plugin::NextRelease;
use Dist::Zilla::Plugin::PkgVersion;
use Dist::Zilla::Plugin::PodCoverageTests;
use Dist::Zilla::Plugin::PodSyntaxTests;
use Dist::Zilla::Plugin::PodSpellingTests;
use Dist::Zilla::Plugin::PodWeaver;
use Dist::Zilla::Plugin::PortabilityTests;
use Dist::Zilla::Plugin::PruneCruft;
use Dist::Zilla::Plugin::ReadmeFromPod;
use Dist::Zilla::Plugin::ReportVersions;
use Dist::Zilla::Plugin::Repository;
use Dist::Zilla::Plugin::ShareDir;
use Dist::Zilla::Plugin::SynopsisTests;
use Dist::Zilla::Plugin::TaskWeaver;
use Dist::Zilla::Plugin::UnusedVarsTests;
use Dist::Zilla::Plugin::UploadToCPAN;
use Dist::Zilla::PluginBundle::Git;
with 'Dist::Zilla::Role::PluginBundle';

sub bundle_config {
    my ($self, $section) = @_;
    # my $class = ref($self) || $self;
    my $arg = $section->{payload};

    # params for AutoVersion
    my $major_version =
      defined $arg->{major_version} ? $arg->{major_version} : 1;
    my $version_format =
        q<{{ $major }}.{{ cldr('yyDDD') }}>
      . sprintf('%01u', ($ENV{N} || 0))
      . ($ENV{DEV} ? (sprintf '_%03u', $ENV{DEV}) : '');

    # params for autoprereq
    my $prereq_params =
      defined $arg->{skip_prereq}
      ? { skip => $arg->{skip_prereq} }
      : {};

    # params for compiletests
    my $compile_params =
      defined $arg->{fake_home}
      ? { fake_home => $arg->{fake_home} }
      : {};

    # params for pod weaver
    $arg->{weaver} ||= 'pod';

    # long list of plugins
    my @wanted = (

        # -- static meta-information
        [   AutoVersion => {
                major     => $major_version,
                format    => $version_format,
                time_zone => 'Europe/Vienna',
            }
        ],

        # -- fetch & generate files
        [ GatherDir           => {} ],
        [ CompileTests        => $compile_params ],
        [ CriticTests         => {} ],
        [ MetaTests           => {} ],
        [ PodCoverageTests    => {} ],
        [ PodSyntaxTests      => {} ],
        [ PodSpellingTests    => {} ],
        [ KwaliteeTests       => {} ],
        [ PortabilityTests    => {} ],
        [ SynopsisTests       => {} ],
        [ MinimumVersionTests => {} ],
        [ HasVersionTests     => {} ],
        [ CheckChangesTests   => {} ],
        [ DistManifestTests   => {} ],
        [ UnusedVarsTests     => {} ],
        [ InlineFilesMARCEL   => {} ],
        [ ReportVersions      => {} ],

        # -- remove some files
        [ PruneCruft   => {} ],
        [ ManifestSkip => {} ],

        # -- get prereqs
        [ AutoPrereq => $prereq_params ],

        # -- gather metadata
        [ Repository => {} ],
        [ Bugtracker => {} ],
        [ Homepage   => {} ],

        # -- munge files
        [ ExtraTests  => {} ],
        [ NextRelease => {} ],
        [ PkgVersion  => {} ],

        (   $arg->{weaver} eq 'task'
            ? [ 'TaskWeaver' => {} ]
            : [ 'PodWeaver' => { config_plugin => '@MARCEL' } ]
        ),

        # -- dynamic meta-information
        [ ExecDir                 => {} ],
        [ ShareDir                => {} ],
        [ 'MetaProvides::Package' => {} ],

        # -- generate meta files
        [ License       => {} ],
        [ MakeMaker     => {} ],
        [ MetaYAML      => {} ],
        [ MetaJSON      => {} ],
        [ ReadmeFromPod => {} ],
        [ InstallGuide  => {} ],
        [ Manifest      => {} ],    # should come last

        # -- release
        [ CheckChangeLog => {} ],

        #[ @Git],
        [ UploadToCPAN => {} ],
    );

    # create list of plugins
    my @plugins;
    for my $wanted (@wanted) {
        my ($name, $arg) = @$wanted;
        my $class = "Dist::Zilla::Plugin::$name";
        Class::MOP::load_class($class);    # make sure plugin exists
        push @plugins, [ "$section->{name}/$name" => $class => $arg ];
    }

    # add git plugins
    my @gitplugins = Dist::Zilla::PluginBundle::Git->bundle_config(
        {   name    => "$section->{name}/Git",
            payload => {},
        }
    );
    push @plugins, @gitplugins;
    return @plugins;
}
__PACKAGE__->meta->make_immutable;
no Moose;
1;

=pod

=begin :prelude

=for test_synopsis
1;
__END__

=for stopwords AutoPrereq AutoVersion CompileTests PodWeaver TaskWeaver

=end :prelude

=head1 SYNOPSIS

In your F<dist.ini>:

    [@MARCEL]
    major_version = 1          ; this is the default
    weaver        = pod        ; default, can also be 'task'
    skip_prereq   = ::Test$    ; no default

=head1 DESCRIPTION

This is a plugin bundle to load all plugins that I am using. It is
equivalent to:

    [AutoVersion]

    ; -- fetch & generate files
    [GatherDir]
    [CompileTests]
    [CriticTests]
    [MetaTests]
    [PodCoverageTests]
    [PodSyntaxTests]
    [PodSpellingTests]
    [KwaliteeTests]
    [PortabilityTests]
    [SynopsisTests]
    [MinimumVersionTests]
    [HasVersionTests]
    [CheckChangesTests]
    [DistManifestTests]
    [UnusedVarsTests]
    [InlineFilesMARCEL]
    [ReportVersions]

    ; -- remove some files
    [PruneCruft]
    [ManifestSkip]

    ; -- get prereqs
    [AutoPrereq]

    ; -- gather metadata
    [Repository]
    [Bugtracker]
    [Homepage]

    ; -- munge files
    [ExtraTests]
    [NextRelease]
    [PkgVersion]
    [PodWeaver]

    ; -- dynamic meta-information
    [ExecDir]
    [ShareDir]
    [MetaProvides::Package]

    ; -- generate meta files
    [License]
    [MakeMaker]
    [MetaYAML]
    [MetaJSON]
    [ReadmeFromPod]
    [InstallGuide]
    [Manifest] ; should come last

    ; -- release
    [CheckChangeLog]
    [@Git]
    [UploadToCPAN]

The following options are accepted:

=over 4

=item * C<major_version> - passed as C<major> option to the
L<AutoVersion|Dist::Zilla::Plugin::AutoVersion> plugin. Default to 1.

=item * C<weaver> - can be either C<pod> (default) or C<task>, to load
respectively either L<PodWeaver|Dist::Zilla::Plugin::PodWeaver> or
L<TaskWeaver|Dist::Zilla::Plugin::TaskWeaver>.

=item * C<skip_prereq> - passed as C<skip> option to the
L<AutoPrereq|Dist::Zilla::Plugin::AutoPrereq> plugin if set. No default.

=item * C<fake_home> - passed to
L<CompileTests|Dist::Zilla::Plugin::CompileTests> to control whether
to fake home.

=back

=function bundle_config

Defines the bundle's contents and passes on this bundle's configuration to the
individual plugins as described above.

