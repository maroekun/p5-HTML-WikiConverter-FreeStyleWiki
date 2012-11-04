use inc::Module::Install;
name 'HTML-WikiConverter-FreeStyleWiki';
all_from 'lib/HTML/WikiConverter/FreeStyleWiki.pm';
readme_from 'lib/HTML/WikiConverter/FreeStyleWiki.pm';
readme_markdown_from 'lib/HTML/WikiConverter/FreeStyleWiki.pm';
readme_pod_from 'lib/HTML/WikiConverter/FreeStyleWiki.pm';
githubmeta;

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
