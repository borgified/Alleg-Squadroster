use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'			=> 'Alleg::Squadroster',
	'VERSION_FROM'	=> 'lib/Alleg/Squadroster.pm',
	'PREREQ_PM'		=> {
						LWP::Simple		=> 6.00,
						}
);
