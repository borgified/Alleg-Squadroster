use Test;
use LWP::Simple;

BEGIN { plan tests => 1}

ok(get 'http://asgs.alleg.net/asgsweb/squads.aspx');
