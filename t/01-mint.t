use Test;
use Mint;

my $m = Mint.new();

my $name = 'kawaii';
$m.create-account($name);

my $account = Account.^load(:account($name));

$account.mint(500);

say $account.balance;
say $account.available-balance;

done-testing;
