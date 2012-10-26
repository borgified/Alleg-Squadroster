#!/usr/bin/env perl

use strict;
use warnings;
use lib "../lib";
use Alleg::Squadroster 1.02;


print "module version: $Alleg::Squadroster::VERSION\n";

my @squads=Alleg::Squadroster::list_squads;

print "squads: @squads\n";

my $inactives = Alleg::Squadroster::list_inactive("System X");
print "inactive pilots in System X:\n";
print "@$inactives\n";

my $actives = Alleg::Squadroster::list_active("System X");
print "active pilots in System X:\n";
print "@$actives\n";

my $leadership = Alleg::Squadroster::list_leadership("Allegiance Flight School");
print "leadership of Allegiance Flight School: \n";
print "@$leadership\n";
