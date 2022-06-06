unit class Mint;

use LibUUID;
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

    method balance() {
        my %balance = red-do { .execute(
            qq:to/SQL/
              select i.value - o.value as balance from mint_accounts a
                left join ( select to_account, sum(value) as value from mint_transactions where not is_void group by to_account )
                  i on i.to_account = a.account
                left join ( select from_account, sum(value) as value from mint_transactions where not is_void group by from_account )
                  o on o.from_account = a.account
              where a.account = '$!account';
            SQL
        ).row }
        return %balance<balance>:v;
    }

    method available-balance() {
        return self.balance + self.overdraft;
    }
}

model Transaction is table<mint_transactions> is rw {
    has UUID $.batch is column;
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

method available-balance(:$account) {
    my $overdraft = Account.^load(:account-name($account)).overdraft;
    my $available-balance = Account.^load(:account-name($account)).balance + $overdraft;
    return $available-balance;
}

method mint(Str :$account, Int :$value) {
    Transaction.^create(batch => UUID.new, :$value, from-account => 'mint', to-account => $account, termination-point => 'system');
    say "✓ minted $value tokens for account: $account";
}

method burn(Str :$account, Int :$value) {
    Transaction.^create(batch => UUID.new, :$value, from-account => $account, to-account => 'burn', termination-point => 'system');
    say "✓ burned $value tokens for account: $account";
}

method new-transaction(Int :$value, Str :$from-account, Str :$to-account) { ... }

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
