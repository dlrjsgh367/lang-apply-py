set url=https://script.google.com/macros/s/AKfycby1MXACd4iSGRNLATIC6lcOTSi8EH9-qFh-7oqVyWXaIUZfSofgGdrF1cBHYsevXsPj/exec
CALL curl -L -o lib/l10n/app_en.arb %url%?locale=en
CALL curl -L -o lib/l10n/app_ko.arb %url%?locale=ko
CALL flutter gen-l10n