use Test;
use LWP::Simple;

BEGIN { plan tests => 1}

ok(get 'https://acss.alleg.net/Stats/SquadRoster.aspx');
