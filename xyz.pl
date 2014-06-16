#!/usr/bin/env perl6
use JSON::Tiny;

multi MAIN(Str :$file = 'META.info', Bool :$major, Bool :$minor, Bool :$patch) {
  my %json = from-json slurp $file;
  fail "No version / invalid version specified" unless %json<version> ~~ / \d ** 3 % '.' /;
  say "Current version : %json<version>";
  my $next-version = increment(%json<version>, ($major, $minor, $patch));
  return if $next-version eq %json<version>;
  say "Press <enter> to bump to $next-version.";

  if $*IN.get eq "" {
    %json<version> = $next-version;
    spurt $file, to-json %json;
    say "Updated $file to $next-version.";
    git-update($file, $next-version);
  }
}

sub git-update(Str $file, Str $version) {
  qqx/git add '$file'/;
  qqx/git commit -m "Version $version"/;
  qqx/git tag --annotate '$version' --message "Version $version"/;
  qqx[git push origin 'refs/heads/master' 'refs/tags/$version'];
  say "Tagged and pushed new version";
  # TODO something with cpan ?
}

sub increment($version, @els) {
  $version.split('.').map(* + @els[(state $a)++].Int).join('.');
}
