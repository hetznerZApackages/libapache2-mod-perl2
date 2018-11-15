#!/usr/bin/perl
use strict;

package ChangesPodFormatter;
use base qw(Pod::Simple::Methody);

sub start_Document {
    my $self = shift;
    $self->{state} = 'Doc';
    $self->{year} = '';
    if (not exists $self->{contributers}) {
        $self->{contributers} = {};
    }
}

sub start_item_text {
    my $self = shift;
    $self->{state} = 'Item';
    return;
}

sub end_item_text {
    my $self = shift;
    $self->{state} = 'Doc';
    return;
}

sub handle_text {
    my ($self, $text) = @_;
    if ($self->{state} eq 'Item') {
        if ($text =~ /\w+\s+\d{1,2},\s+(\d{4})$/) {
            my $year = $1;
            $self->{year} = $year;
        }
        else {
            print "$text\n";
        }
    }
    else {
        foreach my $c ($text =~ /\[([\w\s\<\>\@\.\-]+)\]/g) {
            $self->{contributers}->{$c}->{$self->{year}} = 1;
        }
    }
    return;
}

1;
package main;
my $parser = ChangesPodFormatter->new;
$parser->parse_file('Apache-Test/Changes');
$parser->parse_file('Changes');
foreach my $c (keys %{$parser->{contributers}}) {
    my %years = %{$parser->{contributers}->{$c}};
    print join ", ", sort keys %years;
    print ", $c\n";
}
exit 0;
