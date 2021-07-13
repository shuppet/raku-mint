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

model Transaction is table<mint_transactions> is nullable is rw {
    has UUID $.batch is id;
    has Str $.account is id;
    has Int $.value is column;
    has Str $.from-account is referencing( *.account, :model(Account) );
    has Account $.sender is relationship(*.from-account);
    has Str $.to-account is referencing( *.account, :model(Account) );
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
    red-do { .execute: 'SELECT * FROM ...' }
}

multi method new-transaction(Str :$account, Int :$value, Str :$termination-point) {
    Transaction.^create(batch => ~UUID.new, :$account, :$value, to-account => $account, :$termination-point);
}

multi method new-transaction(Str :$account, Int :$value, Str :$from-account, Str :$to-account, Str :$termination-point) {
    Transaction.^create(batch => ~UUID.new, :$account, :$value, :$from-account, $to-account, :$termination-point);
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
