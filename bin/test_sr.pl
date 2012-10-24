#!/usr/bin/env perl

use strict;
use warnings;
use lib "../lib";
use Alleg::Squadroster;

my @squads=Squadroster::list_squads;

print "squads: @squads\n";

my $inactives = Squadroster::list_inactive("System X");
print "@$inactives";
