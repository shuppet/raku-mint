unit module Mint::Exception;

class X::Mint::Account::AlreadyExists is Exception {
    has $.account;
    has $.message = "Account '$!account' already exists.";
}

class X::Mint::Account::InsufficientBalance is Exception {
    has $.account;
    has $.message = "Account '$!account' has insufficient Tokens to fund the transaction.";
}

class X::Mint::Account::IsFrozen is Exception {
    has $.account;
    has $.message = "Account '$!account' is frozen and thus immutable.";
}
