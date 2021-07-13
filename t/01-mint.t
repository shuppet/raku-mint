use Test;
use Mint;

my $m = Mint.new();

my $name = 'kawaii';
$m.create-account($name);

$m.new-transaction(:account($name), :value(35), :termination-point('system'));

done-testing;
