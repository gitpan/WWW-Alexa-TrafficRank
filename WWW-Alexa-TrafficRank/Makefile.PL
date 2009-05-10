use ExtUtils::MakeMaker;

WriteMakefile(
	      NAME => "WWW::Alexa::TrafficRank",
	      VERSION_FROM => "lib/WWW/Alexa/TrafficRank.pm",
	      'dist' => { COMPRESS=>"gzip", SUFFIX=>"gz" },
	      AUTHOR => 'Guruperl.net <root@guruperl.net>',
	      PREREQ_PM => { 'LWP::UserAgent' => 0 }
	     );
