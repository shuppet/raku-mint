unit class Mint;

use LibUUID;
use Red:api<2>;

has $.RED-DB = database "Pg", :host<localhost>, :database<mint>, :user<mint>, :password<password>;
has $.termination-points = set 'system', 'transfer', 'reward', 'penalty';

model Accounts is table<mint_accounts> is rw {
    has Str $.account is unique;
    has Int $.balance is column;
    has Int $.overdraft is column = 0;
    has DateTime $.last-updated is column{ :type<timestamptz> } = DateTime.now;
}

model Transactions is table<mint_transactions> is rw {
    has UUID $.batch is column;
    has Str $.account is column;
    has Int $.value is column;
    has Str $.from-account is referencing( *.account, :model(Accounts) );
    has Accounts $.sender is relationship( *.from-account );
    has Str $.to-account is referencing( *.account, :model(Accounts) );
    has Accounts $.recipient is relationship( *.to-account );
    has Str $.termination-point is column;
    has Bool $.is-void is column = False;
    has DateTime $.datetime is column{ :type<timestamptz> } = DateTime.now;
}

submethod TWEAK() {
    Accounts.^create-table: :if-not-exists;
    Transactions.^create-table: :if-not-exists;
}

method register-termination-points(Set $new-termination-points) {
    $.termination-points = $.termination-points (|) $new-termination-points;
    return $.termination-points;
}
