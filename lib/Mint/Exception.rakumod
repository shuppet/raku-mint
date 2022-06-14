unit module Mint::Exception;

class X::Mint::Account::AlreadyExists is Exception {
    has $.account;
    has $.message = "✗ account '$!account' already exists";
}

class X::Mint::Account::IsFrozen is Exception {
    has $.account;
    has $.message = "✗ account '$!account' is frozen and thus immutable";
}
