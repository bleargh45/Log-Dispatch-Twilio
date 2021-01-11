# NAME

Log::Dispatch::Twilio - Log output via Twilio SMS Message

# SYNOPSIS

```perl
use Log::Dispatch;

my $logger = Log::Dispatch->new(
    outputs => [
        [ 'Twilio',
          min_level   => 'emergency',
          account_sid => '<your-twilio-account-sid>',
          auth_token  => '<your-twilio-auth-token>',
          from        => '<number-to-send-msg-from>',
          to          => '<number-to-send-msg-to>',
        ],
    ],
);
```

# DESCRIPTION

This module provides a `Log::Dispatch` output that sends log messages via
Twilio.

While you probably don't want _every_ logged message from your application to
go out via Twilio, I find it particularly useful to set it up as part of my
`Log::Dispatch` configuration for critical/emergency errors.  In the event
that something dire happens, I'll receive an SMS message through Twilio right
away.

## Required Options

When adding Twilio output to your [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch) configuration, the following
options are required:

- account\_sid

    Your Twilio "Account Sid".

- auth\_token

    Your Twilio "Auth Token".

- from

    The telephone number from which the SMS messages will appear to be sent from.

    This number must be a number attached to your Twilio account.

- to

    The telephone number to which the SMS messages will be sent to.

## Additional Options

- max\_messages (default 1)

    Maximum number of SMS messages that can be generated from a single logged
    item.  Defaults to 1.

# METHODS

- new

    Constructor.

    Implemented as per the [Log::Dispatch::Output](https://metacpan.org/pod/Log%3A%3ADispatch%3A%3AOutput) interface.

- log\_message

    Logs message, by sending it as an SMS message to the configured number via the
    Twilio API.

    Implemented as per the [Log::Dispatch::Output](https://metacpan.org/pod/Log%3A%3ADispatch%3A%3AOutput) interface.

# AUTHOR

Graham TerMarsch (cpan@howlingfrog.com)

# COPYRIGHT

Copyright (C) 2012, Graham TerMarsch.  All Rights Reserved.

This is free software, you can redistribute it and/or modify it under the
Artistic-2.0 license.

# SEE ALSO

[Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch),
[http://www.twilio.com/](http://www.twilio.com/).
