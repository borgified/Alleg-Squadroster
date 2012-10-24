use Test;
use LWP::Simple;

BEGIN { plan tests => 1}

ok(get 'http://acss.alleg.net/Stats/SquadRoster.aspx');
