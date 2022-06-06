use Test;
use Mint;

my $m = Mint.new();

my $name = 'kawaii';
$m.create-account($name);

#$m.mint(:account($name), :value(400));
#$m.burn(:account($name), :value(20));

my $account = Account.^load(:account($name));

say $account.balance;
say $account.available-balance;

done-testing;
