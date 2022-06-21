unit class Mint;

use Mint::Exception;

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

    method mint(UInt $value) {
        if !self.is-frozen {
            Transaction.^create(batch => UUID.new, :$value, from-account => 'mint', to-account => self.account, termination-point => 'system');
            say "✓ minted $value tokens for account: $!account";
        } else {
            X::Mint::Account::IsFrozen.new(:$!account).throw;
            CATCH { when X::Mint::Account::IsFrozen { say("✗ account '$!account' is frozen and thus immutable") } }
        }
    }

    method burn(UInt $value, Bool $bypass-overdraft = False) {
        if !self.is-frozen {
            my $anticipated-balance = self.available-balance - $value;
            if $anticipated-balance > self.available-balance and $bypass-overdraft == False {
                class X::Mint::Account::InsufficientBalance.new().throw;
            } else {
                Transaction.^create(batch => UUID.new, :$value, from-account => self.account, to-account => 'burn', termination-point => 'system');
                say "✓ burned $value tokens for account: $!account";
            }
        } else {
            X::Mint::Account::IsFrozen.new(:$!account).throw;
            CATCH { when X::Mint::Account::IsFrozen { say("✗ account '$!account' is frozen and thus immutable") } }
        }
    }

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

    method set-overdraft(UInt $value) {
        $!overdraft = $value; self.^save;
        say "✓ account '$!account' overdraft successfully set to $value";
    }

    method freeze {
        $!is-frozen = True; self.^save;
        say "✓ account '$!account' was successfully frozen";
    }

    method thaw {
        $!is-frozen = False; self.^save;
        say "✓ account '$!account' was successfully thawed";
    }
}

model Transaction is table<mint_transactions> is rw {
    has UUID $.batch is id;
    has UInt $.value is column;
    has Str $.from-account is referencing( *.account, :model(Account) ) is id;
    has Account $.sender is relationship(*.from-account);
    has Str $.to-account is referencing( *.account, :model(Account) ) is id;
    has Account $.recipient is relationship(*.to-account);
    has Str $.termination-point is column;
    has Bool $.is-void is column = False;
    has DateTime $.datetime is column{ :type<timestamptz> } = DateTime.now;
}

method create-account(Str $account) {
    if !Account.^load($account) {
        Account.^create(:$account);
        say "✓ new account created for $account";
     } else {
        X::Mint::Account::AlreadyExists.new(:$account).throw;
        CATCH { when X::Mint::Account::AlreadyExists { say("✗ account '$account' already exists") } }
    }
}

method new-transaction(UInt :$value, Str :$from-account, Str :$to-account) { ... }

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
