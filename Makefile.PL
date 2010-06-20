use inc::Module::Install;
name 'AnyEvent-Twitter-Stream-OAuth';
all_from 'lib/AnyEvent/Twitter/Stream/OAuth.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
