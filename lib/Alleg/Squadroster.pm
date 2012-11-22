package Alleg::Squadroster;

require Exporter;
use warnings;
use strict;

use LWP::Simple;

use Net::Google::Spreadsheets;

our $VERSION = '1.04';

my @ISA = qw(Exporter);
my @EXPORT = qw(list_squads list_inactive list_leadership list_active list_unlisted);

my $DEBUG=0;

my %config = do '/secret/google.config';

my $roster_content = get 'http://acss.alleg.net/Stats/SquadRoster.aspx';
if(!defined($roster_content)){
	die "couldnt fetch squad roster: $!";
}

my %data;

sub list_squads {
#returns all squads in a list in order of appearance (left->right)
	my $token='<thead>';
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
	my $once=1;

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
				
				if($once && defined($config{$squads[$count]})){
				    $data{"$squads[$count]"}{'unlisted'}=&get_unlisted("$squads[$count]");
				}elsif(!$once && defined($config{$squads[$count]})){
						#do nothing, we already did it once
				}else{
				    $data{"$squads[$count]"}{'unlisted'}=[];
				}
				$once=0;
				$helper=0;
		}
	}

	$once=1;
	$count++;
}

#for debugging

#foreach my $squads (keys %data){
#	print "roster: @{$data{$squads}{'roster'}}\n";
#	print "leadership: @{$data{$squads}{'leadership'}}\n";
#	print "inactive: @{$data{$squads}{'inactive'}}\n";
#}

#unlisted pilots come from another source: google docs, they may or may not
#have a callsign, all we know about them is that they have a forum name

sub get_unlisted{
	my $squad = shift @_;

	my $key = $config{$squad};

	my $service = Net::Google::Spreadsheets->new(
			username => $config{'username'},
			password => $config{'password'},
			);

# find a spreadsheet by key
	my $spreadsheet = $service->spreadsheet(
			{
			key => $key,
			}
			);

# find a worksheet by title
	my $worksheet = $spreadsheet->worksheet(
			{
			title => 'Sheet1'
			}
			);

	my @rows = $worksheet->rows;

	my @unlisted;

	foreach my $row (@rows){
		push(@unlisted,${$row->content}{'forumname'});
	}
	return \@unlisted;
}


sub get_exsquadded{

	my $key = $config{'exsquadded'};

	my $service = Net::Google::Spreadsheets->new(
			username => $config{'username'},
			password => $config{'password'},
			);

# find a spreadsheet by key
	my $spreadsheet = $service->spreadsheet(
			{
			key => $key,
			}
			);

# find a worksheet by title
	my $worksheet = $spreadsheet->worksheet(
			{
			title => 'Sheet1'
			}
			);

	my @rows = $worksheet->rows;

	my @exsquadded;

	foreach my $row (@rows){
		push(@exsquadded,${$row->content}{'forumname'});
	}
	return \@exsquadded;
}

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

sub list_unlisted{
	my $squad_tag=shift @_;
	return ($data{$squad_tag}{'unlisted'});
}

sub list_exsquadded{
	my $a=&get_exsquadded;
	return $a;
}

1;
