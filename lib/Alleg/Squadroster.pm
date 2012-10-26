package Squadroster;

require Exporter;
use warnings;
use strict;

use LWP::Simple;

use vars qw($VERSION);

$VERSION = '1.02';

my @ISA = qw(Exporter);
my @EXPORT = qw(list_squads list_inactive list_leadership list_active);

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
				#print "$squads[$count] $token $callsign $status\n";

				if(!exists($data{"$squads[$count]"}{'roster'})){
					my @roster;
					push(@roster,$callsign);
					$data{"$squads[$count]"}{'roster'}=\@roster;
				}else{
					push($data{"$squads[$count]"}{'roster'}, $callsign);
				}

				if($token ne 'p'){
					if(!exists($data{"$squads[$count]"}{'leadership'})){
						my @leadership;
						push(@leadership,$callsign);
						$data{"$squads[$count]"}{'leadership'}=\@leadership;
					}else{
						push($data{"$squads[$count]"}{'leadership'}, $callsign);
					}   
				}
				
				if($status eq 'inactive'){
					if(!exists($data{"$squads[$count]"}{'inactive'})){
						my @inactive;
						push(@inactive,$callsign);
						$data{"$squads[$count]"}{'inactive'}=\@inactive;
					}else{                                                      
						push($data{"$squads[$count]"}{'inactive'}, $callsign);
					}                                                                   
				}else{
					if(!exists($data{"$squads[$count]"}{'active'})){
						my @active;
						push(@active,$callsign);
						$data{"$squads[$count]"}{'active'}=\@active;
					}else{    
						push($data{"$squads[$count]"}{'active'}, $callsign);
					}    
				}

				$helper=0;
		}
	}
	$count++;
}

#for debugging

#foreach my $squads (keys %data){
#	print "roster: @{$data{$squads}{'roster'}}\n";
#	print "leadership: @{$data{$squads}{'leadership'}}\n";
#	print "inactive: @{$data{$squads}{'inactive'}}\n";
#}


sub list_inactive{
	my $squad_tag=shift @_;
	return ($data{$squad_tag}{'inactive'});
}

sub list_active{
	my $squad_tag=shift @_;
	return ($data{$squad_tag}{'active'});
}

sub list_leadership{
	my $squad_tag=shift @_;
	return ($data{$squad_tag}{'leadership'});
}

1;
