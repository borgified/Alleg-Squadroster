package Squadroster;

require Exporter;
use warnings;
use strict;

use LWP::Simple;

use vars qw($VERSION);

$VERSION = '1.01';

my @ISA = qw(Exporter);
my @EXPORT = qw(list_squads list_red list_grey list_leadership);

my $DEBUG=0;

my $roster_content = get 'http://acss.alleg.net/Stats/SquadRoster.aspx';
if(!defined($roster_content)){
	die "couldnt fetch squad roster: $!";
}

my $token='<thead>';

my %data;

sub list_squads {
#returns all squads in a list in order of appearance (left->right)
	my @squads = split(/$token/,$roster_content);
	my @results;

	shift(@squads);

	@squads = split (/\n/,"@squads");

	foreach my $squad (@squads){
		if($squad =~ /<th class="centerHeaders">(.*)<\/th>/){
			push(@results,$1);
		}
	}

	return @results;
}

my @squads = &list_squads;

my @aspnet = split(/<div class="AspNet-GridView">/,$roster_content);
shift @aspnet;
my @valign = split(/<table>/,"@aspnet");
shift @valign;

my $count=0;
foreach my $item (@valign){
	#print "$item\n";
	my @list=split(/\n/,$item);
	my($token,$callsign,$status);

	my $helper=0;

	foreach my $item (@list){
#		print "-------------------------\n";
#		print "$item\n";
#		print "-------------------------\n";

		if($item=~/<td style="width: 10px; text-align: right;">(.*)<\/td>/){
			$token=$1;
			$helper++;
		}
		if($item=~/<td>(.*)<\/td>/){
			$callsign=$1;
			$helper++;
		}
		if($item=~/<tr class="(.*)">/){
			$status=$1;
		}
		if($helper==2){
				if($token eq '&nbsp;'){
					$token = 'p';
				}
				print "$squads[$count] $token $callsign $status\n";

				if(!exists($data{"$squads[$count]"}{'roster'}){
					my @roster;
					push(@roster,$callsign);
					$data{"$squads[$count]"}{'roster'}=\@roster;
				}else{
					
					




				$helper=0;
		}
	}
	$count++;
}



__END__

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
