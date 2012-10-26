#!/usr/bin/env perl

use strict;
use warnings;
use lib "../lib";
use Alleg::Squadroster;

my @squads=Squadroster::list_squads;

print "squads: @squads\n";

my $inactives = Squadroster::list_inactive("System X");
print "inactive pilots in System X:\n";
print "@$inactives\n";

my $actives = Squadroster::list_active("System X");
print "active pilots in System X:\n";
print "@$actives\n";

my $leadership = Squadroster::list_leadership("Allegiance Flight School");
print "leadership of Allegiance Flight School: \n";
print "@$leadership\n";
