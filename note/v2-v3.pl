use strict;
use YAML::XS;
use IO::All;
use XXX;

my $ccng_data = Load io('data/ccng.yaml')->all;
my (@v2, @v3);
for my $elem (@$ccng_data) {
    my ($type, $api, $verb, $path) = @$elem;
    next unless $type eq 'route';
    $path =~ s/:(\w+)/{$1}/g;
    if ($api eq 'v2') {
        next unless $path =~ s!^/v2/!/!;
        push @v2, "$path - $verb\n";
    }
    elsif ($api eq 'v3') {
        push @v3, "$path - $verb\n";
    }
    else {
        XXX $elem;
    }
}
io("v2-ccng.paths")->print(join '', sort @v2);
io("v3-ccng.paths")->print(join '', sort @v3);

my $v2_data = Load io('src/openapi-v2.yaml')->all;
my @v2 = ();
for my $path (sort keys %$v2_data) {
    next unless $path =~ m!^/!;
    for my $verb (sort keys $v2_data->{$path}) {
        push @v2, "$path - $verb\n";
    }
}
io("v2-src.paths")->print(join '', sort @v2);

my $v3_data = Load io('src/openapi-v3.yaml')->all;
my @v3 = ();
for my $path (sort keys %$v3_data) {
    next unless $path =~ m!^/!;
    for my $verb (sort keys $v3_data->{$path}) {
        push @v3, "$path - $verb\n";
    }
}
io("v3-src.paths")->print(join '', sort @v3);

system ("uniq v2-ccng.paths > /tmp/v2-ccng.paths && mv /tmp/v2-ccng.paths v2-ccng.paths") == 0 or die;
system ("diff -u v2-ccng.paths v2-src.paths > v2.diff") == 0 or die;
