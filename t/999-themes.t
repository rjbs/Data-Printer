use strict;
use warnings;
use Test::More tests => 31;
use Data::Printer::Theme;

test_basic_load();
test_color_override();
test_invalid_colors();
exit;

sub test_invalid_colors {
    my @invalids = (
        {},
        'rgb(256,255,255)',
        'rgb(255,256,255)',
        'rgb(255,255,256)',
        'rgb(-1,0,0)',
        'rgb(0,-1,0)',
        'rgb(0,0,-1)',
        '#AABBCCDD',
        '#eeffgg',
        'green on_some_bizarre_color',
        'another_weird_color',
    );
    my $i = 0;
    require Data::Printer::Common;
    no warnings 'redefine';
    *Data::Printer::Common::_warn = sub {
        my $message = shift;
        like $message, qr/invalid color/, "invalid color '$invalids[$i]'";
    };

    while ($i < @invalids) {
        my $theme = Data::Printer::Theme->new('Material', { string => $invalids[$i] });
        $i++;
    }
}

sub test_color_override {
    ok my $theme = Data::Printer::Theme->new('Material', {
        array  => 'rgb(55,100,80)',
        hash   => '#B2CCD6',
        string => "\e[0;38;2m",
        number => 'bright_green on_yellow',
    }), 'able to load theme with customization';
    is $theme->name, 'Material', 'customized theme keeps its name';
    is $theme->customized, 1, 'customized flag is set';
    is $theme->color_for('array'), 'rgb(55,100,80)', 'custom color for array';
    is $theme->color_for('hash'), '#B2CCD6', 'custom color for hash';
    is $theme->color_for('string'), "\e[0;38;2m", 'custom color for string';
    is $theme->color_for('number'), 'bright_green on_yellow', 'custom color for number';

    my $sgr = $theme->sgr_color_for('array');
    $sgr =~ s{\e}{\\e};
    is $sgr, '\e[0;38;2;55;100;80m', 'custom SGR for array';

    $sgr = $theme->sgr_color_for('hash');
    $sgr =~ s{\e}{\\e};
    is $sgr, '\e[0;38;2;178;204;214m', 'custom SGR for hash';

    $sgr = $theme->sgr_color_for('string');
    $sgr =~ s{\e}{\\e};
    is $sgr, '\e[0;38;2m', 'custom SGR for string';

    $sgr = $theme->sgr_color_for('number');
    $sgr =~ s{\e}{\\e};
    is $sgr, '\e[92;43m', 'custom SGR for number';

    $sgr = $theme->sgr_color_for('class');
    $sgr =~ s{\e}{\\e};
    is $sgr, '\e[0;38;2;199;146;234m', 'original SGR for class color unchanged';
}

sub test_basic_load {
    ok my $theme = Data::Printer::Theme->new('Material'), 'able to load default theme';
    isa_ok $theme, 'Data::Printer::Theme';
    can_ok $theme, qw(new name customized color_reset color_for sgr_color_for);
    is $theme->name, 'Material', 'got the right theme';
    is $theme->customized, 0, 'customized flag not set';
    is $theme->color_for('array'), '#B2CCD6', 'fetched original color';
    my $sgr = $theme->sgr_color_for('array');
    $sgr =~ s{\e}{\\e};
    is $sgr, '\e[0;38;2;178;204;214m', 'fetched SGR variant for array color';

    $sgr = $theme->sgr_color_for('class');
    $sgr =~ s{\e}{\\e};
    is $sgr, '\e[0;38;2;199;146;234m', 'fetched SGR variant for class color';
}
