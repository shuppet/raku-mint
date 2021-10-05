unit class Mint;

use UUID;
use Red:api<2>;

has $.termination-points = set 'system', 'transfer', 'reward', 'penalty';

model Account { ... }
model Transaction { ... }

model Account is table<mint_accounts> is rw is export {
    has Str $.account is id;
    has @.transactions is relationship( *.account, :model(Transaction) );
    has Int $.overdraft is column = 0;
    has Bool $.is-frozen is column = False;
    has DateTime $.registration-date is column{ :type<timestamptz> } = DateTime.now;
}

model Transaction is table<mint_transactions> is rw {
    has UUID $.batch is id;
    has Int $.value is column;
    has Str $.from-account is referencing( *.account, :model(Account) ) is id;
    has Account $.sender is relationship(*.from-account);
    has Str $.to-account is referencing( *.account, :model(Account) ) is id;
    has Account $.recipient is relationship(*.to-account);
    has Str $.termination-point is column;
    has Bool $.is-void is column = False;
    has DateTime $.datetime is column{ :type<timestamptz> } = DateTime.now;
}

method create-account(Str $account-name) {
    if !Account.^load($account-name) {
        Account.^create(:account($account-name));
        say "✓ new account created for $account-name";
     } else {
        say "✗ account '$account-name' already exists";
    }
}

method balance(:$account) {
    my %balance = red-do { .execute("select coalesce(sum(tin.value),0) - coalesce(sum(tout.value),0) as balance from mint_accounts a left join mint_transactions tin on tin.to_account = a.account and not tin.is_void left join mint_transactions tout on tout.from_account = a.account and not tout.is_void where a.account = '$account';").row }
    return %balance<balance>:v;
}

method mint(Str :$account, Int :$value) {
    Transaction.^create(batch => ~UUID.new, :$value, from-account => 'mint', to-account => $account, termination-point => 'system');
}

method new-transaction(Int :$value, Str :$from-account, Str :$to-account) {
    Transaction.^create(batch => ~UUID.new, :$value, :$from-account, :$to-account, termination-point => 'transfer');
}

submethod TWEAK() {
    red-defaults "Pg",
            host => "localhost",
            database => "mint",
            user => "mint",
            password => "password",
            :default;

    #schema(Account, Transaction).create;
}

method register-termination-points(Set $new-termination-points) {
    $.termination-points = $.termination-points (|) $new-termination-points;
    return $.termination-points;
}
