use Test;
use Mint;

my $m = Mint.new();

my $name = 'kawaii';
$m.create-account($name);

my $account = Account.^load(:account($name));

# mint some new Tokens to the loaded account
$account.mint(500);

# burn (remove) Tokens from the account
$account.burn(100);

# freeze an account, and attempt to burn some Tokens from a frozen account
$account.freeze;
$account.burn(100);

# unfreeze (thaw) the account
$account.thaw;

# check the literal balance of an account
say "{$account.account} has a balance of {$account.balance} Tokens available.";

# check the theoretical balance of an account including any overdraft
say "{$account.account} has a balance of {$account.available-balance} Tokens available, accounting for an overdraft of {$account.overdraft}.";

# set the overdraft of the account to 200, and check the available balance again, it should be .balance + 200
$account.set-overdraft(200);
say "{$account.account} has a balance of {$account.available-balance} Tokens available, accounting for an overdraft of {$account.overdraft}.";

done-testing;
