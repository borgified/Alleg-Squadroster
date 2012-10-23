package Squadroster;

require Exporter;
use warnings;
use strict;

use LWP::Simple;

use vars qw($VERSION);

$VERSION = '0.01';

my @ISA = qw(Exporter);
my @EXPORT = qw(list_squads list_red list_grey list_leadership);

my $DEBUG=0;

my $roster_content = get 'https://acss.alleg.net/Stats/SquadRoster.aspx';
if(!defined($roster_content)){
	die "couldnt fetch squad roster: $!";
}

my $token='<TD valign=\'top\' nowrap><B><U>';

my %data;

my @squads= split(/$token/,$roster_content);

shift(@squads);

foreach my $squad (@squads){

#gotta remove all <b> </b> because when it shows up, it doesnt leave a space behind the
#callsign which i use for pattern matching
	$squad =~ s/<b>//gi;
	$squad =~ s/<\/b>//gi;

	$squad=~/^(.*?)&nbsp;.*\(\@(.*?)\)/;

	my $squad_name=$1;
	my $squad_tag=$2;
	$DEBUG && print "--------------------------\n";
	$DEBUG && print $squad_name," ",$squad_tag,"\n";


#identify squad leadership
	my @squad_leadership;
	my @pilots=split(/<br>/i,$squad);
	foreach my $pilot (@pilots){
		if($pilot =~ /[\*\+\^](.*?) /){
			push(@squad_leadership,$1);
		}
	}
	$DEBUG && print "squad leadership: @squad_leadership\n";

#inactives (>30 days)
	my @inactives = split(/<strike>/,$squad);
	my @grey;

	foreach my $inactive (@inactives){
		if($inactive =~/[\*\+\^]?(.*)\s<\/strike> /){
			#print "grey: $1\n";
			push(@grey,$1);
		}
	}
	$DEBUG && print "grey: @grey\n";
#reds (>21 days)
	my @red; #sorry for the confusing naming convention...
	my @reds = split(/<font color="red">/,$squad);
	shift(@reds);
	foreach my $red (@reds){
		if($red =~/[\*\+\^]?(.*?)\s<\/strike><\/font>/){
			#print "red: $1\n";
			push(@red,$1);
		}
	}
	$DEBUG && print "red: @red\n";


	$data{$squad_tag}{'leadership'}=\@squad_leadership;
	$data{$squad_tag}{'red'}=\@red;
	$data{$squad_tag}{'grey'}=\@grey;

}

sub list_squads{
	return keys(%data);
}

sub list_red{
	my $squad_tag=shift @_;
	return ($data{$squad_tag}{'red'});
}
sub list_grey{
	my $squad_tag=shift @_;
	return ($data{$squad_tag}{'grey'});
}
sub list_leadership{
	my $squad_tag=shift @_;
	return ($data{$squad_tag}{'leadership'});
}


1;
