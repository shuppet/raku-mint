use Test;
use Mint;

my $m = Mint.new();

my $name = 'kawaii';
$m.create-account($name);

$m.mint(:account($name), :value(35));
$m.burn(:account($name), :value(100));

say $m.balance(:account($name));

done-testing;
