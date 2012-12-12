#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Log::Dispatch;
use Log::Dispatch::Twilio;

###############################################################################
### Ensure that we have all of the ENV vars we need for testing.
unless ($ENV{TWILIO_ACCOUNT_SID}) {
    plan skip_all => "TWILIO_ACCOUNT_SID must be set in your environment for testing.";
}
unless ($ENV{TWILIO_ACCOUNT_TOKEN}) {
    plan skip_all => "TWILIO_ACCOUNT_TOKEN must be set in your environment for testing.";
}
unless ($ENV{TWILIO_FROM}) {
    plan skip_all => "TWILIO_FROM must be set in your environment for testing.";
}
unless ($ENV{TWILIO_TO}) {
    plan skip_all => "TWILIO_TO must be set in your environment for testing.";
}
plan tests => 18;

###############################################################################
### TEST PARAMETERS
my %params = (
    account_sid => $ENV{TWILIO_ACCOUNT_SID},
    auth_token  => $ENV{TWILIO_ACCOUNT_TOKEN},
    from        => $ENV{TWILIO_FROM},
    to          => $ENV{TWILIO_TO},
);

###############################################################################
# Required parameters for instantiation.
required_parameters: {
    foreach my $p (sort keys %params) {
        my %data = %params;
        delete $data{$p};

        my $output = eval {
            Log::Dispatch::Twilio->new(
                name      => 'twilio',
                min_level => 'debug',
                %data,
            );
        };
        like $@, qr/requires '$p' parameter/, "$p is required parameter";
    }
}

###############################################################################
# Instantiation.
instantiation: {
    my $output = Log::Dispatch::Twilio->new(
        name      => 'twilio',
        min_level => 'debug',
        %params,
    );
    isa_ok $output, 'Log::Dispatch::Twilio';
}

###############################################################################
# Instantiation via Log::Dispatch;
instantiation_via_log_dispatch: {
    my $logger = Log::Dispatch->new(
        outputs => [
            ['Twilio',
                name      => 'twilio',
                min_level => 'debug',
                %params,
            ],
        ],
    );
    isa_ok $logger, 'Log::Dispatch';

    my $output = $logger->output('twilio');
    isa_ok $output, 'Log::Dispatch::Twilio';
}

###############################################################################
# Logging test
logging_test: {
    my $logger = Log::Dispatch->new(
        outputs => [
            ['Twilio',
                name      => 'twilio',
                min_level => 'debug',
                %params,
            ],
        ],
    );

    my @messages;
    local $SIG{__WARN__} = sub { push @messages, @_ };
    $logger->info("test message, logged via Twilio");

    ok !@messages, 'Message logged via Twilio';
}

###############################################################################
# Long messages are truncated by default (and at the correct point).
truncate_by_default: {
    my $logger = Log::Dispatch::Twilio->new(
        name      => 'twilio',
        min_level => 'debug',
        %params,
    );

    local $Log::Dispatch::Twilio::MAX_TWILIO_LENGTH = 10;
    my $message  = '1234567890abcdefghijklmnop';
    my @expanded = $logger->_expand_message($message);
    is @expanded, 1, 'Long message auto-truncated by default';
    is $expanded[0], '1234567890', '... and truncated at correct point';
}

###############################################################################
# Long messages can be exploded out to multiple messages, each being truncated
# at the correct point.
multiple_messages: {
    my $logger = Log::Dispatch::Twilio->new(
        name         => 'twilio',
        min_level    => 'debug',
        max_messages => 2,
        %params,
    );

    local $Log::Dispatch::Twilio::MAX_TWILIO_LENGTH = 10;
    my $message  = '1234567890abcdefghijklmnop';
    my @expanded = $logger->_expand_message($message);
    is @expanded, 2, 'Long message truncated to max number of messages';
    is $expanded[0], '1/2: 12345', '... first message truncated to length';
    is $expanded[1], '2/2: 67890', '... second message truncated to length';
}

###############################################################################
# Long messages can be exploded and truncated, if it generates less than max
# messages.
truncate_subsequent_message: {
    my $logger = Log::Dispatch::Twilio->new(
        name         => 'twilio',
        min_level    => 'debug',
        max_messages => 2,
        %params,
    );

    local $Log::Dispatch::Twilio::MAX_TWILIO_LENGTH = 15;
    my $message  = '1234567890abcdefg';
    my @expanded = $logger->_expand_message($message);
    is @expanded, 2, 'Long message truncated to max number of messages';
    is $expanded[0], '1/2: 1234567890', '... first message truncated to length';
    is $expanded[1], '2/2: abcdefg', '... second message complete';
}

###############################################################################
# Short messages don't generate multiples, even when configured
short_messages_stay_short: {
    my $logger = Log::Dispatch::Twilio->new(
        name         => 'twilio',
        min_level    => 'debug',
        max_messages => 9,
        %params,
    );

    my $message  = "w00t!";
    my @expanded = $logger->_expand_message($message);
    is @expanded, 1, 'Short message expanded to one message';
}

###############################################################################
# Messages have leading/trailing whitespace trimmed from them automatically.
whitespace_trimmed: {
    my $logger = Log::Dispatch::Twilio->new(
        name         => 'twilio',
        min_level    => 'debug',
        max_messages => 9,
        %params,
    );

    my $message  = "   no whitespace here    ";
    my @expanded = $logger->_expand_message($message);
    is $expanded[0], 'no whitespace here',
        'Leading/trailing whitespace stripped';
}
