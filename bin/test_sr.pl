#!/usr/bin/env perl

use strict;
use warnings;
use lib "../lib";
use Alleg::Squadroster 1.03;


print "module version: $Alleg::Squadroster::VERSION\n";

my @squads=Alleg::Squadroster::list_squads;

print "squads: @squads\n";

my $inactives = Alleg::Squadroster::list_inactive("SystemX");
print "inactive pilots in System X:\n";
print "@$inactives\n";

my $actives = Alleg::Squadroster::list_active("SystemX");
print "active pilots in System X:\n";
print "@$actives\n";

my $leadership = Alleg::Squadroster::list_leadership("AllegianceFlightSchool");
print "leadership of Allegiance Flight School: \n";
print "@$leadership\n";

print "---------------------------------\n";
print "list unlisted in System X:\n";
my $unlisted = Alleg::Squadroster::list_unlisted("SystemX");
print "@$unlisted\n";


print "---------------------------------\n";

print "list exsquadded:\n";
my $exsquadded = Alleg::Squadroster::list_exsquadded;
print "@$exsquadded\n";
