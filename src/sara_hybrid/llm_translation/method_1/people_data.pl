% ----- people_data.pl -----
:- module(people_data,
          [ taxable_income/3               % Person × Year × Income
          ]).

taxable_income(alice, 2017,  42876).
taxable_income(alice, 2017, 615572).   % for case 2
taxable_income(alice, 2015, 260932).   % for case 3